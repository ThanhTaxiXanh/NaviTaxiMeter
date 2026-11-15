#!/usr/bin/env python3
"""Require executed Android instrumentation results for DEBUG-only SQLite probe.

A successful :app:assembleDebugAndroidTest proves COMPILATION only; this
parser accepts only a real connectedDebugAndroidTest JUnit XML testcase.
It does not certify physical device GNSS/FGS or production trip durability.
"""
import sys
from pathlib import Path
import xml.etree.ElementTree as ET

EXPECTED_CLASS = "vn.navitaximeter.HeadlessSqliteProbeInstrumentedTest"
EXPECTED_METHOD = "boundHeadlessEngineCanOpenSqfliteAndReadCommittedProbe"


def verify(results_dir: Path) -> int:
    root = Path(results_dir)
    if not root.is_dir():
        raise ValueError("Android instrumented XML directory missing")
    executed = 0
    for report in root.rglob("*.xml"):
        try:
            tree = ET.parse(report)
        except ET.ParseError:
            continue
        for case in tree.iter("testcase"):
            cls = case.attrib.get("classname", "")
            method = case.attrib.get("name", "")
            if not cls.endswith(EXPECTED_CLASS) or method != EXPECTED_METHOD:
                continue
            executed += 1
            if any(child.tag in ("failure", "error", "skipped") for child in case):
                raise ValueError("Headless Android test failed/skipped: " + str(report))
    if executed != 1:
        raise ValueError(
            "Expected exactly ONE executed headless Android test; found "
            + str(executed) + ". Compile-only/empty result is NOT PASS."
        )
    print("PASS: headless FlutterEngine/sqflite instrumentation actually "
          "executed once on an Android emulator (NOT a physical device)")
    print("WARNING: NO production SQLite writer, GNSS or passenger-fare proof")
    return executed


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("Usage: verify_android_probe_results.py <connected-test-results-dir>")
    try:
        verify(Path(sys.argv[1]))
    except ValueError as exc:
        sys.exit("FAIL: " + str(exc))
