import subprocess, sys, os
from fontTools.ttLib import TTFont
from PIL import Image, ImageDraw
font, dump, out, size = sys.argv[1], sys.argv[2], sys.argv[3], int(sys.argv[4])
ids = sys.argv[5].split(',') if len(sys.argv) > 5 else None
f = TTFont(font)
order = f.getGlyphOrder()
rev = {}
for cp, name in f.getBestCmap().items():
    rev.setdefault(order.index(name), cp)
meta = {int(l.split()[0]): l.split()[1:] for l in open(f'{dump}/meta.txt')}
gids = [int(i) for i in ids] if ids else sorted(meta)
cell = size * 2 + 24
cols = 8
rows = (len(gids) + cols - 1) // cols
sheet = Image.new('RGB', (cols * cell * 2, rows * (cell + 14)), 'white')
d = ImageDraw.Draw(sheet)
for n, g in enumerate(gids):
    x0, y0 = (n % cols) * cell * 2, (n // cols) * (cell + 14)
    d.text((x0 + 4, y0), f'{g} rune | hb-view', fill='black')
    if g in meta:
        left, top, w, h, fg = meta[g]
        im = Image.open(f'{dump}/{g}.png').convert('RGBA')
        bg = Image.new('RGBA', im.size, 'white'); bg.alpha_composite(im)
        sheet.paste(bg.convert('RGB'), (x0 + 8 + int(left), y0 + 14 + size + 8 - int(top)))
    if g in rev:
        p = f'/tmp/hb{g}.png'
        subprocess.run(['hb-view', f'--font-size={size}', '--margin=0', '--foreground=2060C0FF', '--background=FFFFFFFF', '-O', 'png', '-o', p, f'--unicodes=U+{rev[g]:04X}', font], check=True, capture_output=True)
        hb = Image.open(p).convert('RGB')
        asc = f['hhea'].ascent * size / f['head'].unitsPerEm
        sheet.paste(hb, (x0 + cell + 8, y0 + 14 + size + 8 - round(asc)))
    d.line([(x0 + cell, y0), (x0 + cell, y0 + cell + 14)], fill=(200, 200, 200))
sheet.save(out)
