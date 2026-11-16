#!/usr/bin/env python3
"""Install checked-in, non-billing native GPS service into generated Flutter Android."""

from pathlib import Path
import shutil
import sys

ROOT = Path(__file__).resolve().parents[1]
ANDROID = ROOT / "android"
MANIFEST = ANDROID / "app/src/main/AndroidManifest.xml"
DEBUG_MANIFEST = ANDROID / "app/src/debug/AndroidManifest.xml"
SOURCE = ROOT / "android_native"
TARGET = ANDROID / "app/src/main/kotlin/vn/navitaximeter"
UNIT_TEST_TARGET = ANDROID / "app/src/test/kotlin/vn/navitaximeter"
DEBUG_TARGET = ANDROID / "app/src/debug/kotlin/vn/navitaximeter"
ANDROID_TEST_TARGET = ANDROID / "app/src/androidTest/kotlin/vn/navitaximeter"
GRADLE = ANDROID / "app/build.gradle.kts"
UNIT_TEST_DEP = 'testImplementation("junit:junit:4.13.2")'
RUNNER_LINE = 'testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"'
ANDROID_TEST_DEPS = (
    'androidTestImplementation("androidx.test:runner:1.6.2")',
    'androidTestImplementation("androidx.test.ext:junit:1.2.1")',
    'androidTestImplementation("androidx.test:core:1.6.1")',
)
NATIVE_SOURCES = (
    "MainActivity.kt", "LocationSafetyService.kt",
    "LocationOwnerRegistry.kt", "TripCheckpointProtocol.kt",
    "GnssFixTrustGate.kt", "DebugWriterOwnershipRegistry.kt",
)
JVM_TEST_SOURCES = (
    "LocationOwnerRegistryTest.kt", "TripCheckpointProtocolTest.kt",
    "GnssFixTrustGateTest.kt", "HeadlessProbeCallbackFenceTest.kt",
    "DebugWriterOwnershipRegistryTest.kt",
)
DEBUG_SOURCES = ("HeadlessSqliteProbeService.kt", "HeadlessProbeCallbackFence.kt")
ANDROID_TEST_SOURCES = ("HeadlessSqliteProbeInstrumentedTest.kt",)
DEBUG_SERVICE_TAG = (
    '        <service android:name=".HeadlessSqliteProbeService"\n'
    '            android:exported="false" />\n'
)
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

def patch_debug_manifest(text: str) -> str:
    """Install a non-exported, non-FGS probe in DEBUG manifest only."""
    if "</manifest>" not in text:
        raise ValueError("Generated debug manifest is invalid")
    if "HeadlessSqliteProbeService" in text:
        if text.count("HeadlessSqliteProbeService") != 1:
            raise ValueError("Duplicate debug headless service")
        return text
    if "</application>" in text:
        text = text.replace("</application>", DEBUG_SERVICE_TAG + "    </application>", 1)
    else:
        text = text.replace("</manifest>",
            "    <application>\n" + DEBUG_SERVICE_TAG +
            "    </application>\n</manifest>", 1)
    return text


def patch_gradle(text: str) -> str:
    """Compile JVM tests and Android device-only debug instrumentation tests."""
    if "plugins {" not in text or "defaultConfig {" not in text:
        raise ValueError("Unexpected Android Kotlin DSL build file")
    if RUNNER_LINE not in text:
        text = text.replace("defaultConfig {",
            "defaultConfig {\n        " + RUNNER_LINE, 1)
    deps = tuple(dep for dep in (UNIT_TEST_DEP,) + ANDROID_TEST_DEPS
                 if dep not in text)
    if deps:
        text = text.rstrip() + (
            "\n\n// Test dependencies: no billing, map APIs or runtime network.\n"
            "dependencies {\n" +
            "".join("    " + dep + "\n" for dep in deps) + "}\n"
        )
    return text


def check():
    if not MANIFEST.is_file():
        raise ValueError("Generate Flutter Android project before checking manifest")
    content = MANIFEST.read_text(encoding="utf-8")
    if not DEBUG_MANIFEST.is_file():
        raise ValueError("Generated Android debug manifest missing")
    debug = DEBUG_MANIFEST.read_text(encoding="utf-8")
    if (debug.count("HeadlessSqliteProbeService") != 1 or
        'android:exported="false"' not in debug):
        raise ValueError("Debug-only bound headless service is missing/unsafe")
    if "HeadlessSqliteProbeService" in content:
        raise ValueError("Headless probe must not be in the main manifest")
    if any(p not in content for p in PERMISSIONS):
        raise ValueError("Missing foreground GPS permissions")
    if (".LocationSafetyService" not in content or
        'android:exported="false"' not in content or
        'android:foregroundServiceType="location"' not in content):
        raise ValueError("Native service declaration is missing/unsafe")
    if "android.permission.ACCESS_BACKGROUND_LOCATION" in content:
        raise ValueError("Unexpected background location permission")
    for name in NATIVE_SOURCES:
        dst = TARGET / name
        if not dst.is_file() or dst.read_bytes() != (SOURCE / name).read_bytes():
            raise ValueError("Native Kotlin source not installed exactly: " + name)
    for name in JVM_TEST_SOURCES:
        installed = UNIT_TEST_TARGET / name
        if not installed.is_file() or installed.read_bytes() != (SOURCE / name).read_bytes():
            raise ValueError("Native JVM safety test not installed exactly: " + name)
    for name in DEBUG_SOURCES:
        installed = DEBUG_TARGET / name
        if not installed.is_file() or installed.read_bytes() != (SOURCE / name).read_bytes():
            raise ValueError("Debug-only headless probe not installed exactly: " + name)
    for name in ANDROID_TEST_SOURCES:
        installed = ANDROID_TEST_TARGET / name
        if not installed.is_file() or installed.read_bytes() != (SOURCE / name).read_bytes():
            raise ValueError("Android device test not installed exactly: " + name)
    gradle = GRADLE.read_text(encoding="utf-8") if GRADLE.is_file() else ""
    if (UNIT_TEST_DEP not in gradle or RUNNER_LINE not in gradle or
        any(dep not in gradle for dep in ANDROID_TEST_DEPS)):
        raise ValueError("Native test Gradle wiring missing")
    print("PASS: native GPS safety, debug headless probe and test wiring installed")

def install():
    if not MANIFEST.is_file():
        raise ValueError("Run flutter create before Android bootstrap")
    MANIFEST.write_text(
        patch_manifest(MANIFEST.read_text(encoding="utf-8")),
        encoding="utf-8",
    )
    if not DEBUG_MANIFEST.is_file():
        raise ValueError("Generate Flutter debug manifest before bootstrap")
    DEBUG_MANIFEST.write_text(
        patch_debug_manifest(DEBUG_MANIFEST.read_text(encoding="utf-8")),
        encoding="utf-8",
    )
    TARGET.mkdir(parents=True, exist_ok=True)
    for name in NATIVE_SOURCES:
        shutil.copyfile(SOURCE / name, TARGET / name)
    UNIT_TEST_TARGET.mkdir(parents=True, exist_ok=True)
    for name in JVM_TEST_SOURCES:
        shutil.copyfile(SOURCE / name, UNIT_TEST_TARGET / name)
    DEBUG_TARGET.mkdir(parents=True, exist_ok=True)
    for name in DEBUG_SOURCES:
        shutil.copyfile(SOURCE / name, DEBUG_TARGET / name)
    ANDROID_TEST_TARGET.mkdir(parents=True, exist_ok=True)
    for name in ANDROID_TEST_SOURCES:
        shutil.copyfile(SOURCE / name, ANDROID_TEST_TARGET / name)
    if not GRADLE.is_file():
        raise ValueError("Generated Android Kotlin DSL Gradle file missing")
    GRADLE.write_text(patch_gradle(GRADLE.read_text(encoding="utf-8")),
                      encoding="utf-8")
    check()

if __name__ == "__main__":
    try:
        check() if "--check" in sys.argv else install()
    except (OSError, ValueError) as error:
        sys.exit("FAIL: " + str(error))
