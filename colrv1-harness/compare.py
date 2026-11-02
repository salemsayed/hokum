from pathlib import Path
import json
from PIL import Image, ImageChops, ImageDraw

root = Path('/evidence/evidence')
matrix = root / 'matrix'
distros = ['arch', 'ubuntu', 'opensuse', 'fedora', 'debian']
CLOCK = (1400, 0, 1440, 600)
CARD = (1040, 0, 1500, 340)


def load(distro, variant, case):
    return Image.open(matrix / distro / variant / case / 'card.png').convert('RGB')


def changed(a, b, mask):
    a, b = a.copy(), b.copy()
    if mask:
        for im in (a, b):
            ImageDraw.Draw(im).rectangle(CLOCK, fill='black')
    return sum(px != (0, 0, 0) for px in ImageChops.difference(a, b).getdata())


def panel(im, label, box=CARD, scale=1):
    crop = im.crop(box)
    if scale != 1:
        crop = crop.resize((crop.width * scale, crop.height * scale), Image.NEAREST)
    p = Image.new('RGB', (crop.width, crop.height + 30), '#eeeeee')
    p.paste(crop, (0, 30))
    ImageDraw.Draw(p).text((12, 8), label, fill='black')
    return p


def row(panels):
    w = sum(p.width for p in panels)
    h = max(p.height for p in panels)
    out = Image.new('RGB', (w, h), 'white')
    x = 0
    for p in panels:
        out.paste(p, (x, 0))
        x += p.width
    return out


def column(rows):
    out = Image.new('RGB', (max(r.width for r in rows), sum(r.height for r in rows)), 'white')
    y = 0
    for r in rows:
        out.paste(r, (0, y))
        y += r.height
    return out


results = {}
rows = []
for distro in distros:
    emoji = {v: load(distro, v, 'emoji') for v in ['dev', 'branch', 'colrv1']}
    stock = {v: load(distro, v, 'stock') for v in ['dev', 'branch', 'colrv1']}
    results[distro] = {
        'emoji_colrv1_vs_branch_changed_pixels': changed(emoji['branch'], emoji['colrv1'], True),
        'emoji_colrv1_vs_branch_unmasked_changed_pixels': changed(emoji['branch'], emoji['colrv1'], False),
        'stock_colrv1_vs_dev_changed_pixels': changed(stock['dev'], stock['colrv1'], True),
        'stock_colrv1_vs_dev_unmasked_changed_pixels': changed(stock['dev'], stock['colrv1'], False),
        'stock_colrv1_vs_branch_changed_pixels': changed(stock['branch'], stock['colrv1'], True),
    }
    rows.append(row([panel(emoji[v], f'{distro}: {name}') for v, name in
                     [('dev', 'dev'), ('branch', 'emoji-presentation'), ('colrv1', 'colrv1')]]))
column(rows).save(root / 'desktops.png')

fedora = load('fedora', 'colrv1', 'emoji')
arch = load('arch', 'branch', 'emoji')
column([
    row([panel(load('fedora', 'branch', 'emoji'), 'Fedora 44, emoji-presentation: COLRv1 font ineligible, outlines'),
         panel(fedora, 'Fedora 44, colrv1: Noto COLRv1 painted')]),
    row([panel(arch, 'Arch, emoji-presentation: Noto CBDT bitmaps'),
         panel(fedora, 'Fedora 44, colrv1: Noto COLRv1 painted')]),
]).save(root / 'fedora-vs-arch.png')
zoom = (1060, 40, 1490, 260)
row([panel(arch, 'Arch CBDT, 2x', zoom, 2), panel(fedora, 'Fedora COLRv1, 2x', zoom, 2)]).save(root / 'fedora-vs-arch-zoom.png')

(root / 'matrix-results.json').write_text(json.dumps(results, indent=2) + '\n')
print(json.dumps(results, indent=2))
