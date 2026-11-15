#!/usr/bin/env python3
"""Add Android GPS foreground permissions after flutter create."""
from pathlib import Path
import sys

manifest = Path('android/app/src/main/AndroidManifest.xml')
if not manifest.is_file():
    sys.exit('FAIL: Run flutter create before injecting Android permissions')
source = manifest.read_text(encoding='utf-8')
permissions = (
    'android.permission.ACCESS_COARSE_LOCATION',
    'android.permission.ACCESS_FINE_LOCATION',
    'android.permission.FOREGROUND_SERVICE',
    'android.permission.FOREGROUND_SERVICE_LOCATION',
    'android.permission.POST_NOTIFICATIONS',
)
if '--check' in sys.argv:
    missing = [name for name in permissions if name not in source]
    if missing:
        sys.exit(f'FAIL: Missing Android permissions: {missing}')
    print('PASS: location permission declarations present in source manifest')
else:
    if '<application' not in source:
        sys.exit('FAIL: no <application> in AndroidManifest.xml')
    additions = ''.join(
        f'    <uses-permission android:name="{name}" />\n'
        for name in permissions if name not in source
    )
    if additions:
        source = source.replace('<application', additions + '    <application', 1)
        manifest.write_text(source, encoding='utf-8')
    print('Added Android location declarations, without billing services or keys')
