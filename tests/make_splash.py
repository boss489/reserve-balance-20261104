"""Original 800x600 boot illustration; Pillow only needed to regenerate this asset."""
from pathlib import Path
from PIL import Image, ImageDraw, ImageFont

root = Path(__file__).resolve().parent.parent
im = Image.new('RGB', (800, 600), '#243644')
d = ImageDraw.Draw(im)
ink = '#f3ead8'
gold = '#c18c55'
for x in range(24, 800, 28):
    d.line((x, 0, x, 600), fill='#293d4a', width=1)
for y in range(24, 600, 28):
    d.line((0, y, 800, y), fill='#293d4a', width=1)
d.rectangle((18, 18, 782, 582), outline=gold, width=2)
d.line((400, 149, 400, 398), fill=ink, width=12)
d.line((346, 400, 454, 400), fill=gold, width=12)
d.line((225, 222, 400, 191, 575, 222), fill=ink, width=9, joint='curve')
d.ellipse((384, 176, 416, 208), fill=gold)
for x, y, radius, color in [(248, 291, 34, '#92b1aa'), (532, 295, 29, '#d5aa6c'), (572, 299, 20, '#bd826b')]:
    d.line((x, 216, x, 325), fill=gold, width=3)
    d.line((x-61, 338, x+61, 338), fill=ink, width=6)
    d.ellipse((x-radius, y-radius, x+radius, y+radius), fill=color)
font = root / 'assets' / 'GowunDodum-Regular.ttf'
for value, size, y, color in [('양팔 저울', 56, 445, ink), ('R E S E R V E   B A L A N C E', 19, 520, gold)]:
    f = ImageFont.truetype(font, size)
    box = d.textbbox((0, 0), value, font=f)
    d.text(((800 - (box[2]-box[0]))/2, y), value, font=f, fill=color)
im.save(root / 'assets' / 'splash.png', optimize=True)
print('wrote', root / 'assets' / 'splash.png')
