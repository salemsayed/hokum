from pathlib import Path
from PIL import Image, ImageDraw

root = Path('/evidence/review-evidence/fedora-renamed')
composite = Image.new('RGB', (920, 370), '#eeeeee')
for i, (variant, title) in enumerate([
    ('pre-review', 'Renamed COLRv1 font: earlier branch'),
    ('branch', 'Renamed COLRv1 font: guarded branch'),
]):
    crop = Image.open(root / variant / 'card.png').convert('RGB').crop((1040, 0, 1500, 340))
    crop.save(root / variant / 'crop.png')
    composite.paste(crop, (i * 460, 30))
    ImageDraw.Draw(composite).text((i * 460 + 12, 8), title, fill='black')
composite.save(root / 'comparison.png')
