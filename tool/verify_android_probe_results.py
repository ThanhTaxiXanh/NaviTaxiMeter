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
EXPECTED_DEBUG_METHOD = "realKotlinToHeadlessDartDebugIpcAcksOnlyAfterSqliteReadback"
EXPECTED_LEASE_METHOD = "competingWriterLeaseDeniesEngineUntilTeardownAndExplicitRebind"
EXPECTED_LATE_METHOD = "pendingNativeCallbackFailsOnServiceDestroyAndCannotReachReboundEngine"
EXPECTED_METHODS = (
    EXPECTED_METHOD, EXPECTED_DEBUG_METHOD, EXPECTED_LEASE_METHOD,
    EXPECTED_LATE_METHOD,
)


def verify(results_dir: Path) -> int:
    root = Path(results_dir)
    if not root.is_dir():
        raise ValueError("Android instrumented XML directory missing")
    executed = {name: 0 for name in EXPECTED_METHODS}
    for report in root.rglob("*.xml"):
        try:
            tree = ET.parse(report)
        except ET.ParseError:
            continue
        for case in tree.iter("testcase"):
            cls = case.attrib.get("classname", "")
            method = case.attrib.get("name", "")
            if not cls.endswith(EXPECTED_CLASS) or method not in EXPECTED_METHODS:
                continue
            executed[method] += 1
            if any(child.tag in ("failure", "error", "skipped") for child in case):
                raise ValueError("Headless Android test failed/skipped: " + str(report))
    if any(count != 1 for count in executed.values()):
        raise ValueError(
            "Require exactly one executed result for ALL FOUR Android debug "
            + "probe methods, found " + str(executed)
        )
    print("PASS: FOUR Android emulator instrumented methods executed: "
          "headless SQLite counter, Kotlin-Dart DEBUG checkpoint ACK, "
          "contended writer Service lifecycle, and stale ACK after teardown/rebind")
    print("WARNING: NO production SQLite writer, GNSS or passenger-fare proof")
    return sum(executed.values())


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("Usage: verify_android_probe_results.py <connected-test-results-dir>")
    try:
        verify(Path(sys.argv[1]))
    except ValueError as exc:
        sys.exit("FAIL: " + str(exc))
