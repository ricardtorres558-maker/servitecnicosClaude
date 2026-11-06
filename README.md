# Servitecnicos

Tienda web de Servitécnicos SYM: tóners, tintas y suministros para impresoras, con envíos en Bogotá.

- `public/index.html`: la página completa (intro con el logo, categorías en video, catálogo, Nosotros, Contáctanos, carrito y checkout).
- `public/media/`: videos, fondos, fotos de productos y logos de marcas.
- `supabase/`: estructura y datos de la base de datos (no se publica).

## Publicación

Se publica en **Cloudflare Workers** (plan gratis). Cloudflare está conectado a este repositorio desde el 6 de noviembre de 2026: cada cambio en la rama `main` se publica solo en el Worker `floral-mouse-ac26`.

- `wrangler.jsonc` le dice a Cloudflare que publique solo la carpeta `public/` como sitio estático.

Los precios, el inventario y los productos visibles se leen en vivo desde Supabase, así que cambiarlos no requiere volver a publicar.
