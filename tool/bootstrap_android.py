#!/usr/bin/env python3
"""Install checked-in, non-billing native GPS service into generated Flutter Android."""

from pathlib import Path
import shutil
import sys

ROOT = Path(__file__).resolve().parents[1]
ANDROID = ROOT / "android"
MANIFEST = ANDROID / "app/src/main/AndroidManifest.xml"
SOURCE = ROOT / "android_native"
TARGET = ANDROID / "app/src/main/kotlin/vn/navitaximeter"
PERMISSIONS = (
    "android.permission.ACCESS_COARSE_LOCATION",
    "android.permission.ACCESS_FINE_LOCATION",
    "android.permission.FOREGROUND_SERVICE",
    "android.permission.FOREGROUND_SERVICE_LOCATION",
    "android.permission.POST_NOTIFICATIONS",
)
SERVICE_TAG = (
    '        <service android:name=".LocationSafetyService"\n'
    '            android:exported="false"\n'
    '            android:foregroundServiceType="location" />\n'
)

def patch_manifest(text: str) -> str:
    if "<application" not in text or "</application>" not in text:
        raise ValueError("Android manifest application tag missing")
    if "android.permission.ACCESS_BACKGROUND_LOCATION" in text:
        raise ValueError("This laboratory build must not request background permission")
    missing = "".join(
        f'    <uses-permission android:name="{name}" />\n'
        for name in PERMISSIONS if name not in text
    )
    if missing:
        text = text.replace("<application", missing + "<application", 1)
    if "LocationSafetyService" not in text:
        text = text.replace("</application>", SERVICE_TAG + "    </application>", 1)
    if text.count("LocationSafetyService") != 1:
        raise ValueError("Duplicate LocationSafetyService declaration")
    return text

def check():
    if not MANIFEST.is_file():
        raise ValueError("Generate Flutter Android project before checking manifest")
    content = MANIFEST.read_text(encoding="utf-8")
    if any(p not in content for p in PERMISSIONS):
        raise ValueError("Missing foreground GPS permissions")
    if (".LocationSafetyService" not in content or
        'android:exported="false"' not in content or
        'android:foregroundServiceType="location"' not in content):
        raise ValueError("Native service declaration is missing/unsafe")
    if "android.permission.ACCESS_BACKGROUND_LOCATION" in content:
        raise ValueError("Unexpected background location permission")
    for name in ("MainActivity.kt", "LocationSafetyService.kt", "LocationOwnerRegistry.kt"):
        dst = TARGET / name
        if not dst.is_file() or dst.read_bytes() != (SOURCE / name).read_bytes():
            raise ValueError("Native Kotlin source not installed exactly: " + name)
    print("PASS: native service and source Android permissions present")

def install():
    if not MANIFEST.is_file():
        raise ValueError("Run flutter create before Android bootstrap")
    MANIFEST.write_text(
        patch_manifest(MANIFEST.read_text(encoding="utf-8")),
        encoding="utf-8",
    )
    TARGET.mkdir(parents=True, exist_ok=True)
    for name in ("MainActivity.kt", "LocationSafetyService.kt", "LocationOwnerRegistry.kt"):
        shutil.copyfile(SOURCE / name, TARGET / name)
    check()

if __name__ == "__main__":
    try:
        check() if "--check" in sys.argv else install()
    except (OSError, ValueError) as error:
        sys.exit("FAIL: " + str(error))
