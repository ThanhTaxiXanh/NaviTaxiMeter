#!/usr/bin/env python3
"""Preliminary fail-closed API billing scanner; not a live invoice audit."""
import json
import re
import sys
from pathlib import Path
ROOT = Path(__file__).resolve().parents[1]
SUFFIXES = {'.dart', '.yaml', '.yml', '.gradle', '.kts', '.kt', '.java', '.xml', '.properties'}
SKIP = {'test', 'tool', 'docs', '.git', 'build', '.dart_tool', '.gradle', 'assets'}
RULES = {
    'METERED_MAP_PROVIDER': r'(?i)(maps[_-]?3d[_-]?sdk|immersive[_ -]?maps|navigation[_-]?sdk|places\.googleapis\.com|routes\.googleapis\.com|roads\.googleapis\.com|geocoding\.googleapis\.com|api\.mapbox\.com|api\.maptiler\.com|api\.here\.com|api\.tomtom\.com)',
    'GOOGLE_MAPS_BILLING_UNAPPROVED': r'(?i)(google_maps_flutter|com\.google\.android\.gms:play-services-maps|com\.google\.android\.libraries\.maps)',
    'MAP_ID': r'(?i)(\bmapId\s*:|\bmap_id\s*[:=]|com\.google\.android\.geo\.MAP_ID)',
    'EMBEDDED_API_KEY': r'AIza[0-9A-Za-z_-]{30,}',
    'OSM_PUBLIC_BULK_DOWNLOAD': r'(?i)(tile\.openstreetmap\.org.*(?:prefetch|download)|(?:prefetch|bulk_download).*tile\.openstreetmap\.org)',
}
def audit(root=ROOT):
    found=[]
    for p in sorted(root.rglob('*')):
        if not p.is_file() or p.suffix.lower() not in SUFFIXES:
            continue
        rel=p.relative_to(root)
        if any(part in SKIP for part in rel.parts[:-1]):
            continue
        for i,line in enumerate(p.read_text(encoding='utf-8',errors='replace').splitlines(),1):
            if line.lstrip().startswith(('#','//','*','<!--')):
                continue
            for code,pat in RULES.items():
                if re.search(pat,line):
                    found.append({'path':str(rel),'line':i,'code':code})
    return found
if __name__=='__main__':
    found=audit()
    print(json.dumps({'status':'FAIL' if found else 'STATIC_SCAN_PASS_ONLY',
                      'findings':found,'unverified':['Cloud Billing SKUs',
                      'runtime network dependencies','device GPS','map license']},
                     ensure_ascii=False,indent=2))
    sys.exit(bool(found))
