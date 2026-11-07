# Servitecnicos

Tienda web de Servitécnicos SYM: tóners, tintas y suministros para impresoras, con envíos en Bogotá.

- `index.html`: la página completa (intro con el logo, categorías en video, catálogo, Nosotros, Contáctanos, carrito y checkout).
- `media/`: videos, fondos, fotos de productos y logos de marcas. `media/fotos/min/` tiene las fotos livianas (480 px) que usan las tarjetas del catálogo; se crean con `python3 herramientas/miniaturas.py` cada vez que se agrega una foto.
- `_headers`: le dice al navegador que guarde fotos y videos para que la tienda abra más rápido en la segunda visita.
- `supabase/`: estructura y datos de la base de datos (no se publica).

## Publicación

Se publica en **Cloudflare Workers** (plan gratis). Cloudflare está conectado a este repositorio desde el 6 de noviembre de 2026: cada cambio en la rama `main` se publica solo en el Worker `floral-mouse-ac26`.

- `wrangler.jsonc` le dice a Cloudflare que publique esta carpeta como sitio estático.
- `.assetsignore` deja por fuera lo que no es de la tienda (README, supabase, configuración).

Los precios, el inventario y los productos visibles se leen en vivo desde Supabase, así que cambiarlos no requiere volver a publicar.
