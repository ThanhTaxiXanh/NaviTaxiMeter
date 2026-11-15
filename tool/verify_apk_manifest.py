#!/usr/bin/env python3
"""Check the COMPILED APK, not merely source AndroidManifest.xml.

This verifies permission and plugin service declarations. It is NOT a device
GPS/foreground-lifecycle or production billing certification.
"""
import os
import re
import subprocess
from pathlib import Path

APK = Path("build/app/outputs/flutter-apk/app-debug.apk")
REQUIRED = (
    "android.permission.ACCESS_COARSE_LOCATION",
    "android.permission.ACCESS_FINE_LOCATION",
    "android.permission.FOREGROUND_SERVICE",
    "android.permission.FOREGROUND_SERVICE_LOCATION",
)
SERVICE = "com.baseflow.geolocator.GeolocatorLocationService"
PACKAGE = "vn.navitaximeter"

def verify_texts(manifest, permissions, badging):
    if not re.search(r"package:\s+name=['\"]vn\.navitaximeter['\"]", badging):
        raise ValueError("Unexpected Android application package")
    missing = [p for p in REQUIRED if p not in permissions]
    if missing:
        raise ValueError("Missing compiled Android permissions: " + ", ".join(missing))
    if "android.permission.ACCESS_BACKGROUND_LOCATION" in permissions:
        raise ValueError("Preview build must not request background location")
    index = manifest.find(SERVICE)
    if index < 0:
        raise ValueError("Geolocator location service not in merged APK manifest")
    scope = manifest[index:index + 1600]
    if not re.search(
        r"foregroundServiceType[^\n]*(?:0x0*8\b|location)",
        scope,
        re.IGNORECASE,
    ):
        raise ValueError("Geolocator foregroundServiceType=location missing")
    if "com.google.android.geo.API_KEY" in manifest or (
        "com.google.android.maps.v2.API_KEY" in manifest
    ):
        raise ValueError("Unexpected Google Maps API key in compiled manifest")

def aapt_tool():
    sdk = Path(os.environ.get("ANDROID_HOME") or
               os.environ.get("ANDROID_SDK_ROOT") or
               "/usr/local/lib/android/sdk")
    paths = list((sdk / "build-tools").glob("*/aapt"))
    if not paths:
        raise ValueError("Android aapt tool missing from " + str(sdk))
    def version(p):
        return tuple(int(x) for x in re.findall(r"\d+", p.parent.name))
    return sorted(paths, key=version)[-1]

def verify_apk():
    if not APK.is_file():
        raise ValueError("APK missing: " + str(APK))
    aapt = str(aapt_tool())
    def dump(*args):
        return subprocess.check_output([aapt, "dump", *args, str(APK)],
             text=True, stderr=subprocess.STDOUT)
    verify_texts(
        dump("xmltree", "AndroidManifest.xml"),
        dump("permissions"),
        dump("badging"),
    )
    print("PASS: APK contains mandatory GPS foreground type and permissions")
    print("PASS: no background location permission, no Maps API key")
    print("WARNING: physical-device, OEM lifecycle and billing not certified")

if __name__ == "__main__":
    verify_apk()
