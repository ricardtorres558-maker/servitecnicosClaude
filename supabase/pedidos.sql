-- Servitecnicos: pedidos de la tienda (panel "Pedidos" del dueño + pagos con Wompi)
-- Pegar en Supabase > SQL Editor > New query > Run (ya se aplicó el 8 nov 2026).
--
-- Cómo fluye un pedido:
--   1. El cliente llena el checkout -> la tienda llama crear_pedido() -> queda "Esperando pago"
--      (o "Contra entrega", que ya se puede despachar).
--   2. Wompi avisa al Worker de Cloudflare (worker/index.js) -> pago "pagado".
--   3. El dueño lo ve en /pedidos, lo prepara, pone transportadora y guía y lo marca "Enviado".
--   4. Cuando llega, lo marca "Entregado".

create sequence if not exists pedidos_numero_seq start 1001;

create table if not exists pedidos (
  id              bigint generated always as identity primary key,
  numero          text not null unique default ('SV-' || nextval('pedidos_numero_seq')),
  creado          timestamptz not null default now(),
  actualizado     timestamptz not null default now(),

  -- Estado del despacho: nuevo -> preparando -> enviado -> entregado (o cancelado)
  estado          text not null default 'nuevo'
                  check (estado in ('nuevo','preparando','enviado','entregado','cancelado')),
  -- Estado del pago: pendiente (esperando Wompi), pagado, rechazado o contraentrega
  estado_pago     text not null default 'pendiente'
                  check (estado_pago in ('pendiente','pagado','rechazado','contraentrega')),
  metodo_pago     text,                      -- tarjeta, pse, nequi, contraentrega...

  -- Cliente
  cliente_nombre  text not null,
  cliente_doc     text,
  cliente_tel     text not null,
  cliente_email   text,

  -- Entrega
  entrega         text not null default 'domicilio' check (entrega in ('domicilio','recoger')),
  direccion       text,
  barrio          text,
  localidad       text,
  ciudad          text not null default 'Bogotá',
  notas_cliente   text,

  -- Productos: [{codigo, nombre, cantidad, precio}] con el precio del momento de la compra
  items           jsonb not null default '[]'::jsonb,
  subtotal        int  not null default 0 check (subtotal >= 0),
  envio           int  not null default 0 check (envio >= 0),
  total           int  not null default 0 check (total >= 0),

  -- Wompi
  wompi_transaccion text,
  wompi_estado      text,
  pagado_en         timestamptz,

  -- Despacho
  transportadora  text,                      -- Mipaquete, Picap, mensajero propio...
  guia            text,                      -- número de guía o enlace de seguimiento
  costo_envio_real int check (costo_envio_real >= 0),  -- lo que le costó el envío a la tienda
  enviado_en      timestamptz,
  entregado_en    timestamptz,
  notas_internas  text,                      -- solo las ve el dueño

  prueba          boolean not null default false  -- pedidos de ejemplo para probar el panel
);

create index if not exists pedidos_estado_idx on pedidos(estado, estado_pago);
create index if not exists pedidos_creado_idx on pedidos(creado desc);

-- Fechas automáticas al cambiar de estado
create or replace function pedidos_tocar() returns trigger language plpgsql set search_path = '' as $$
begin
  new.actualizado = now();
  if new.estado = 'enviado' and new.enviado_en is null then new.enviado_en = now(); end if;
  if new.estado = 'entregado' and new.entregado_en is null then new.entregado_en = now(); end if;
  if new.estado = 'entregado' and new.enviado_en is null then new.enviado_en = now(); end if;
  if new.estado_pago = 'pagado' and new.pagado_en is null then new.pagado_en = now(); end if;
  return new;
end $$;
drop trigger if exists pedidos_tocar on pedidos;
create trigger pedidos_tocar before insert or update on pedidos
  for each row execute function pedidos_tocar();

-- Seguridad: los pedidos tienen datos personales. Solo los administradores los ven y editan.
-- Los clientes NO leen la tabla: crean su pedido solo con crear_pedido().
alter table pedidos enable row level security;
drop policy if exists "admin ve pedidos" on pedidos;
create policy "admin ve pedidos" on pedidos for select to authenticated using ((select es_admin()));
drop policy if exists "admin edita pedidos" on pedidos;
create policy "admin edita pedidos" on pedidos for update to authenticated
  using ((select es_admin())) with check ((select es_admin()));
drop policy if exists "admin borra pedidos" on pedidos;
create policy "admin borra pedidos" on pedidos for delete to authenticated using ((select es_admin()));
revoke all on pedidos from anon;

-- Crear pedido desde la tienda. Los precios se toman de la tabla productos (no del navegador),
-- así nadie puede cambiar el valor a pagar. Devuelve el número y el total.
-- items: [{"codigo":"TN-HP-CF248A","cantidad":2}, ...]
create or replace function crear_pedido(cliente jsonb, items jsonb, metodo text default 'contraentrega')
returns jsonb language plpgsql security definer set search_path = '' as $$
declare
  it jsonb; p record; n int; lineas jsonb := '[]'::jsonb; sub int := 0; ped public.pedidos;
  ent text := coalesce(nullif(cliente->>'entrega',''),'domicilio');
begin
  if jsonb_typeof(items) <> 'array' or jsonb_array_length(items) = 0 or jsonb_array_length(items) > 50 then
    raise exception 'El pedido no tiene productos';
  end if;
  if coalesce(trim(cliente->>'nombre'),'') = '' or length(regexp_replace(coalesce(cliente->>'tel',''),'\D','','g')) < 10 then
    raise exception 'Faltan el nombre o el celular';
  end if;
  if ent = 'domicilio' and coalesce(trim(cliente->>'direccion'),'') = '' then
    raise exception 'Falta la dirección de envío';
  end if;
  if metodo not in ('tarjeta','pse','nequi','wompi','contraentrega') then metodo := 'wompi'; end if;

  for it in select * from jsonb_array_elements(items) loop
    n := greatest(1, least(99, coalesce((it->>'cantidad')::int, 1)));
    select codigo, nombre, case when precio_oferta is not null and precio_oferta < precio then precio_oferta else precio end as valor
      into p from public.productos where codigo = it->>'codigo' and visible;
    if not found or p.valor is null or p.valor <= 0 then
      raise exception 'Producto no disponible: %', it->>'codigo';
    end if;
    lineas := lineas || jsonb_build_object('codigo', p.codigo, 'nombre', p.nombre, 'cantidad', n, 'precio', p.valor);
    sub := sub + p.valor * n;
  end loop;

  insert into public.pedidos (estado_pago, metodo_pago, cliente_nombre, cliente_doc, cliente_tel, cliente_email,
      entrega, direccion, barrio, localidad, notas_cliente, items, subtotal, envio, total)
  values (case when metodo = 'contraentrega' then 'contraentrega' else 'pendiente' end, metodo,
      left(trim(cliente->>'nombre'),120), left(cliente->>'doc',30), left(cliente->>'tel',30), left(cliente->>'email',120),
      ent, left(cliente->>'direccion',200), left(cliente->>'barrio',80), left(cliente->>'localidad',60), left(cliente->>'notas',500),
      lineas, sub, 0, sub)
  returning * into ped;

  return jsonb_build_object('numero', ped.numero, 'total', ped.total, 'estado_pago', ped.estado_pago);
end $$;
revoke all on function crear_pedido(jsonb, jsonb, text) from public;
grant execute on function crear_pedido(jsonb, jsonb, text) to anon, authenticated;

-- Para borrar los pedidos de ejemplo cuando empiecen las ventas reales:
--   delete from pedidos where prueba;
