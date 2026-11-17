#!/usr/bin/env python3
"""Require executed (not just compiled) Android DEBUG instrumentation evidence.

Four headless SQLite probes and two real-service token lifecycle regressions
must each appear once as passing JUnit XML testcases. Emulator evidence is NOT
physical GNSS, production SQLite, or passenger-fare certification.
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
EXPECTED_TOKEN_CLASS = "vn.navitaximeter.LocationSafetyTokenInstrumentedTest"
EXPECTED_STALE_TOKEN_METHOD = "savedRealNotificationStopFromOldLeaseCannotStopNewFgService"
EXPECTED_PRE_ACK_METHOD = "preAckStopKeepsLeaseUntilTeardownAndRejectsStaleStart"
EXPECTED_CASES = tuple((EXPECTED_CLASS, method) for method in EXPECTED_METHODS) + (
    (EXPECTED_TOKEN_CLASS, EXPECTED_STALE_TOKEN_METHOD),
    (EXPECTED_TOKEN_CLASS, EXPECTED_PRE_ACK_METHOD),
)


def verify(results_dir: Path) -> int:
    root = Path(results_dir)
    if not root.is_dir():
        raise ValueError("Android instrumented XML directory missing")
    executed = {key: 0 for key in EXPECTED_CASES}
    for report in root.rglob("*.xml"):
        try:
            tree = ET.parse(report)
        except ET.ParseError:
            continue
        for case in tree.iter("testcase"):
            cls = case.attrib.get("classname", "")
            method = case.attrib.get("name", "")
            match = next(
                (key for key in EXPECTED_CASES
                 if cls.endswith(key[0]) and method == key[1]), None
            )
            if match is None:
                continue
            executed[match] += 1
            if any(child.tag in ("failure", "error", "skipped") for child in case):
                raise ValueError("Android test failed/skipped: " + str(report))
    if any(count != 1 for count in executed.values()):
        raise ValueError(
            "Require exactly one PASS for all SIX Android DEBUG methods, found "
            + str(executed)
        )
    print("PASS: SIX Android emulator instrumented methods executed: "
          "four headless SQLite probes and two native safety-service token races")
    print("WARNING: no physical GNSS, production trip writer or passenger-fare proof")
    return sum(executed.values())


if __name__ == "__main__":
    if len(sys.argv) != 2:
        sys.exit("Usage: verify_android_probe_results.py <connected-test-results-dir>")
    try:
        verify(Path(sys.argv[1]))
    except ValueError as exc:
        sys.exit("FAIL: " + str(exc))
