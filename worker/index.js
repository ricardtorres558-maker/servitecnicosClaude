// Worker de Servitecnicos en Cloudflare.
// La tienda (index.html, pedidos.html, fotos, videos) la sirve Cloudflare como archivos estáticos;
// este código solo atiende dos direcciones de pagos con Wompi:
//
//   POST /api/pago          -> recibe {numero} de un pedido creado con crear_pedido() y devuelve el
//                              enlace al Web Checkout de Wompi con la firma de integridad.
//   POST /api/wompi/evento  -> Wompi avisa aquí cuando un pago cambia de estado. Se verifica la firma
//                              y el pedido pasa a "pagado" (o "rechazado") en Supabase.
//
// Mientras no estén las llaves (Cloudflare > Worker > Settings > Variables and Secrets) ambas
// direcciones responden "pagos no activos" y la tienda sigue igual que hoy.
//   WOMPI_PUBLIC_KEY      pub_test_... / pub_prod_...   (Wompi > Desarrolladores)
//   WOMPI_INTEGRITY       secreto de integridad
//   WOMPI_EVENTS          secreto de eventos
//   SUPABASE_SERVICE_KEY  llave secreta de Supabase (Settings > API keys > secret)
//   SITIO_URL             opcional, ej. https://servitecnicos.com.co (a donde vuelve el cliente al pagar)

const SUPA_URL = 'https://uuajuepfysbfcwyafglb.supabase.co';

export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    try {
      if (url.pathname === '/api/pago' && request.method === 'POST') return await pago(request, env, url);
      if (url.pathname === '/api/wompi/evento' && request.method === 'POST') return await evento(request, env);
      if (url.pathname.startsWith('/api/')) return json({ error: 'no_encontrado' }, 404);
    } catch (e) {
      console.error('Error en', url.pathname, e && e.stack || e);
      return json({ error: 'error_interno' }, 500);
    }
    return env.ASSETS.fetch(request);
  },
};

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'no-store' },
  });
}

async function sha256(texto) {
  const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(texto));
  return [...new Uint8Array(buf)].map((b) => b.toString(16).padStart(2, '0')).join('');
}

function supa(env, path, init = {}) {
  return fetch(SUPA_URL + path, {
    ...init,
    headers: {
      apikey: env.SUPABASE_SERVICE_KEY,
      Authorization: 'Bearer ' + env.SUPABASE_SERVICE_KEY,
      'Content-Type': 'application/json',
      ...(init.headers || {}),
    },
  });
}

async function buscarPedido(env, numero) {
  const r = await supa(env, '/rest/v1/pedidos?select=id,numero,total,estado,estado_pago,cliente_email,notas_internas&numero=eq.' + encodeURIComponent(numero));
  if (!r.ok) throw new Error('Supabase ' + r.status + ' ' + (await r.text()));
  const rows = await r.json();
  return rows[0] || null;
}

// ---------- 1. Enlace de pago ----------
async function pago(request, env, url) {
  if (!env.WOMPI_PUBLIC_KEY || !env.WOMPI_INTEGRITY || !env.SUPABASE_SERVICE_KEY) {
    return json({ error: 'pagos_no_activos' }, 503);
  }
  const body = await request.json().catch(() => ({}));
  const numero = String(body.numero || '');
  if (!/^SV-\d+$/.test(numero)) return json({ error: 'pedido_invalido' }, 400);

  const ped = await buscarPedido(env, numero);
  if (!ped) return json({ error: 'pedido_no_existe' }, 404);
  if (ped.estado_pago !== 'pendiente' && ped.estado_pago !== 'rechazado') return json({ error: 'pedido_ya_pagado' }, 409);

  // Cada intento de pago lleva una referencia distinta (Wompi no deja repetirlas): SV-1001-LX3K9
  const referencia = numero + '-' + Date.now().toString(36).toUpperCase();
  const centavos = ped.total * 100;
  const firma = await sha256(referencia + centavos + 'COP' + env.WOMPI_INTEGRITY);
  const sitio = env.SITIO_URL || url.origin;

  const q = new URLSearchParams({
    'public-key': env.WOMPI_PUBLIC_KEY,
    currency: 'COP',
    'amount-in-cents': String(centavos),
    reference: referencia,
    'signature:integrity': firma,
    'redirect-url': sitio + '/?pedido=' + encodeURIComponent(numero),
  });
  if (ped.cliente_email) q.set('customer-data:email', ped.cliente_email);
  return json({ url: 'https://checkout.wompi.co/p/?' + q.toString(), referencia });
}

// ---------- 2. Aviso de Wompi ----------
function valorEn(obj, ruta) {
  return ruta.split('.').reduce((o, k) => (o == null ? undefined : o[k]), obj);
}

async function evento(request, env) {
  if (!env.WOMPI_EVENTS || !env.SUPABASE_SERVICE_KEY) return json({ error: 'pagos_no_activos' }, 503);
  const ev = await request.json().catch(() => null);
  if (!ev || !ev.signature || !Array.isArray(ev.signature.properties)) return json({ error: 'evento_invalido' }, 400);

  // Firma de Wompi: SHA256(valores de "properties" en orden + timestamp + secreto de eventos)
  const cadena = ev.signature.properties.map((p) => String(valorEn(ev.data, p) ?? '')).join('') + ev.timestamp + env.WOMPI_EVENTS;
  const esperado = await sha256(cadena);
  if (esperado !== String(ev.signature.checksum || '').toLowerCase()) {
    console.warn('Evento de Wompi con firma inválida');
    return json({ error: 'firma_invalida' }, 401);
  }
  if (ev.event !== 'transaction.updated' || !ev.data || !ev.data.transaction) return json({ ok: true, ignorado: true });

  const tx = ev.data.transaction;
  const m = /^(SV-\d+)/.exec(String(tx.reference || ''));
  if (!m) return json({ ok: true, ignorado: 'referencia ajena' });
  const ped = await buscarPedido(env, m[1]);
  if (!ped) return json({ ok: true, ignorado: 'pedido no existe' });

  const metodo = { CARD: 'tarjeta', PSE: 'pse', NEQUI: 'nequi', BANCOLOMBIA_TRANSFER: 'bancolombia', BANCOLOMBIA_QR: 'bancolombia' }[tx.payment_method_type] || 'wompi';
  const cambios = { wompi_transaccion: tx.id, wompi_estado: tx.status };

  if (tx.status === 'APPROVED') {
    if (ped.estado_pago === 'pagado') return json({ ok: true, repetido: true });
    if (tx.currency === 'COP' && Number(tx.amount_in_cents) === ped.total * 100) {
      cambios.estado_pago = 'pagado';
      cambios.metodo_pago = metodo;
    } else {
      // Pago aprobado por otro valor: no se marca pagado, el panel muestra una alerta.
      cambios.wompi_estado = 'APPROVED_MONTO_DIFERENTE';
      cambios.notas_internas = [ped.notas_internas, 'Wompi aprobó ' + (Number(tx.amount_in_cents) / 100) + ' ' + tx.currency + ' (transacción ' + tx.id + ') pero el pedido es por ' + ped.total + '.'].filter(Boolean).join('\n');
    }
  } else if (['DECLINED', 'VOIDED', 'ERROR'].includes(tx.status)) {
    if (ped.estado_pago === 'pagado') return json({ ok: true, ignorado: 'ya estaba pagado' });
    cambios.estado_pago = 'rechazado';
  }

  const r = await supa(env, '/rest/v1/pedidos?id=eq.' + ped.id, { method: 'PATCH', body: JSON.stringify(cambios) });
  if (!r.ok) throw new Error('No se pudo actualizar el pedido: ' + r.status + ' ' + (await r.text()));
  return json({ ok: true });
}
