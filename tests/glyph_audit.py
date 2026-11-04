"""Audit every literal Hangul, numeral, Latin and UI symbol against bundled font cmap."""
import json
import re
from pathlib import Path
from fontTools.ttLib import TTFont

root = Path(__file__).resolve().parent.parent
source = (root / 'main.gd').read_text(encoding='utf-8')
levels = (root / 'levels.json').read_text(encoding='utf-8')
# Include source text, not just visible strings: a superset cannot conceal missing UI glyphs.
required = {c for c in source + levels if c.isprintable() and (c.isalnum() or c in '·↵▴–+−/%:←→—')}
font = TTFont(root / 'assets/GowunDodum-Regular.ttf')
available = set().union(*(set(table.cmap) for table in font['cmap'].tables))
missing = sorted(required - {chr(x) for x in available})
print(f'font glyph audit: {len(required)} required, {len(missing)} missing', ''.join(missing))
if missing:
    raise SystemExit(1)
