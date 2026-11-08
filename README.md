# Servitecnicos

Tienda web de Servitécnicos SYM: tóners, tintas y suministros para impresoras, con envíos en Bogotá.

- `index.html`: la página completa (intro con el logo, categorías en video, catálogo, Nosotros, Contáctanos, carrito y checkout).
- `media/`: videos, fondos, fotos de productos y logos de marcas.
- `supabase/`: estructura y datos de la base de datos (no se publica).

## Publicación

Se publica en **Cloudflare Workers** (plan gratis). Cloudflare está conectado a este repositorio desde el 6 de noviembre de 2026: cada cambio en la rama `main` se publica solo en el Worker `floral-mouse-ac26`.

- `wrangler.jsonc` le dice a Cloudflare que publique esta carpeta como sitio estático.
- `.assetsignore` deja por fuera lo que no es de la tienda (README, supabase, configuración).

Los precios, el inventario y los productos visibles se leen en vivo desde Supabase, así que cambiarlos no requiere volver a publicar.

## Pedidos (panel del dueño)

- `pedidos.html` (se abre en `/pedidos`): panel privado para despachar. Muestra los pedidos por despachar, en camino, entregados, esperando pago y cancelados, con los datos de envío, los productos para alistar, botones para escribirle al cliente por WhatsApp, copiar los datos para Mipaquete o Picap e imprimir el rótulo del paquete.
- Solo entran los correos de la tabla `administradores` de Supabase, con su contraseña de Supabase (Authentication > Users > Add user).
- `supabase/pedidos.sql`: tabla `pedidos` y la función `crear_pedido()` que usa la tienda (los precios se toman de Supabase, no del navegador).
- `worker/index.js`: pagos con Wompi. `/api/pago` arma el enlace al Web Checkout con la firma, y `/api/wompi/evento` recibe el aviso de Wompi, verifica la firma y marca el pedido como pagado. Se activa al poner las llaves en Cloudflare (ver el comentario al inicio del archivo). URL de eventos para Wompi: `https://<dominio>/api/wompi/evento`.
