from pathlib import Path
import json
from PIL import Image, ImageChops, ImageDraw

root = Path('/evidence/outline-evidence/matrix')
rows = []
results = {}
for distro in ['arch', 'ubuntu', 'opensuse', 'fedora', 'debian']:
    panels = []
    for variant in ['dev', 'branch']:
        im = Image.open(root / distro / variant / 'emoji/card.png').convert('RGB')
        crop = im.crop((1040, 0, 1500, 340))
        panel = Image.new('RGB', (460, 370), '#eeeeee')
        panel.paste(crop, (0, 30))
        ImageDraw.Draw(panel).text((12, 8), f'{distro}: {variant}', fill='black')
        panels.append(panel)
    row = Image.new('RGB', (920, 370))
    row.paste(panels[0], (0, 0))
    row.paste(panels[1], (460, 0))
    rows.append(row)
    stock = [Image.open(root / distro / variant / 'stock/card.png').convert('RGB') for variant in ['dev', 'branch']]
    raw = sum(px != (0, 0, 0) for px in ImageChops.difference(*stock).getdata())
    for im in stock:
        ImageDraw.Draw(im).rectangle((1400, 0, 1440, 600), fill='black')
    changed = sum(px != (0, 0, 0) for px in ImageChops.difference(*stock).getdata())
    results[distro] = {'stock_changed_pixels': changed, 'stock_unmasked_changed_pixels': raw}
    ImageChops.difference(*stock).save(root / distro / 'stock-diff.png')
    stock[0].crop((1040, 0, 1500, 600)).save(root / distro / 'stock-crop.png')
composite = Image.new('RGB', (920, 370 * len(rows)))
for i, row in enumerate(rows):
    composite.paste(row, (0, i * 370))
composite.save('/evidence/outline-evidence/desktops.png')
Path('/evidence/outline-evidence/matrix-results.json').write_text(json.dumps(results, indent=2) + '\n')
print(json.dumps(results, indent=2))
assert all(r['stock_changed_pixels'] == 0 for r in results.values())
