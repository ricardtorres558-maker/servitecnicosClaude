# Servitecnicos

Tienda web de Servitécnicos SYM: tóners, tintas y suministros para impresoras, con envíos en Bogotá.

- `index.html`: la página completa (intro con el logo, categorías en video, catálogo, Nosotros, Contáctanos, carrito y checkout).
- `media/`: videos, fondos, fotos de productos y logos de marcas.
- `supabase/`: estructura y datos de la base de datos (no se publica).

## Publicación

Se publica en **Cloudflare Workers** (plan gratis). Cloudflare está conectado a este repositorio: cada cambio en la rama `main` se publica solo.

- `wrangler.jsonc` le dice a Cloudflare que publique esta carpeta como sitio estático.
- `.assetsignore` deja por fuera lo que no es de la tienda (README, supabase, configuración).

Los precios, el inventario y los productos visibles se leen en vivo desde Supabase, así que cambiarlos no requiere volver a publicar.
