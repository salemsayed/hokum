import sys
from PIL import Image
import numpy as np
root, size = sys.argv[1], sys.argv[2]
def load(d):
    meta = [l.split() for l in open(f'{root}/{d}{size}/meta.txt')]
    return [(int(m[0]), int(m[1]), int(m[2]), Image.open(f'{root}/{d}{size}/{m[0]}.png').convert('RGBA')) for m in meta]
def canvas(left, top, im, W=400, ox=100, oy=300):
    c = Image.new('RGBA', (W, W), (255, 255, 255, 255))
    c.alpha_composite(im, (ox + left, oy - top))
    return np.asarray(c.convert('RGB')).astype(float)
def ink(im, left, top, ox=100, oy=300):
    a = np.asarray(im)[:, :, 3]
    ys, xs = np.nonzero(a > 127)
    return (ox + left + xs.min(), oy - top + ys.min(), ox + left + xs.max() + 1, oy - top + ys.max() + 1)
cb = load('cbdt')
res = {}
for mode in ['lin', 'srgb']:
    v1 = load(mode)
    diffs, shifts = [], []
    for (g1, l1, t1, i1), (g2, l2, t2, i2) in zip(v1, cb):
        a, b = canvas(l1, t1, i1), canvas(l2, t2, i2)
        k1, k2 = ink(i1, l1, t1), ink(i2, l2, t2)
        x0, y0, x1, y1 = min(k1[0], k2[0]), min(k1[1], k2[1]), max(k1[2], k2[2]), max(k1[3], k2[3])
        diffs.append(np.abs(a - b)[y0:y1, x0:x1].mean())
        shifts.append(tuple(x - y for x, y in zip(k1, k2)))
    res[mode] = diffs
    print(mode, 'ink-box mean abs diff (0-255):', ' '.join(f'{d:.2f}' for d in diffs), '| mean', f'{np.mean(diffs):.3f}')
    print(mode, 'ink box delta (l,t,r,b) colrv1 - cbdt:', shifts)
