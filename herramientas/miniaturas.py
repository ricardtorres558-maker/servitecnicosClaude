# Crea las fotos livianas del catálogo (media/fotos/min, 480 px).
# Uso: python3 herramientas/miniaturas.py   (necesita Pillow: pip install pillow)
# Córrelo cada vez que agregues o cambies una foto en media/fotos.
# Si una miniatura falta, la tienda usa la foto grande, así que nada se rompe.
from PIL import Image
import glob, os
os.makedirs('media/fotos/min', exist_ok=True)
for f in sorted(glob.glob('media/fotos/*.jpg')):
    o = 'media/fotos/min/' + os.path.basename(f)
    if os.path.exists(o) and os.path.getmtime(o) >= os.path.getmtime(f):
        continue
    im = Image.open(f).convert('RGB')
    im.thumbnail((480, 480), Image.LANCZOS)
    im.save(o, 'JPEG', quality=82, optimize=True, progressive=True)
    print('lista', o)
