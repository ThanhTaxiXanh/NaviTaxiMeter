import unittest
from pathlib import Path
from bootstrap_android import (
    patch_manifest, patch_debug_manifest, patch_gradle, PERMISSIONS, UNIT_TEST_DEP,
    NATIVE_SOURCES, JVM_TEST_SOURCES, RUNNER_LINE, ANDROID_TEST_DEPS,
    DEBUG_SOURCES, ANDROID_TEST_SOURCES,
)

SAMPLE = """<manifest xmlns:android="http://schemas.android.com/apk/res/android">
<application android:label="navitaximeter" android:name="generated">
    <activity android:name=".MainActivity" android:exported="true" />
</application>
</manifest>
"""

class AndroidBootstrapTests(unittest.TestCase):
    def test_native_service_installed_and_non_exported(self):
        manifest = patch_manifest(SAMPLE)
        self.assertIn('android:name=".LocationSafetyService"', manifest)
        self.assertIn('android:foregroundServiceType="location"', manifest)
        self.assertIn('android:exported="false"', manifest)
        for permission in PERMISSIONS:
            self.assertIn(permission, manifest)
        self.assertNotIn("android.permission.ACCESS_BACKGROUND_LOCATION", manifest)

    def test_debug_headless_probe_is_not_main_or_location_fgs(self):
        debug = '<manifest xmlns:android="http://schemas.android.com/apk/res/android">\\n</manifest>'
        rendered = patch_debug_manifest(debug)
        self.assertEqual(rendered, patch_debug_manifest(rendered))
        self.assertIn('android:name=".HeadlessSqliteProbeService"', rendered)
        self.assertIn('android:exported="false"', rendered)
        self.assertNotIn('android:foregroundServiceType=', rendered)
        self.assertNotIn('HeadlessSqliteProbeService', patch_manifest(SAMPLE))
        self.assertIn('HeadlessSqliteProbeService.kt', DEBUG_SOURCES)
        self.assertIn('HeadlessProbeCallbackFence.kt', DEBUG_SOURCES)
        self.assertIn('HeadlessProbeCallbackFenceTest.kt', JVM_TEST_SOURCES)
        self.assertIn('HeadlessSqliteProbeInstrumentedTest.kt', ANDROID_TEST_SOURCES)

    def test_headless_probe_never_targets_app_database(self):
        root = Path(__file__).resolve().parents[1]
        dart = (root / 'lib/src/lab/headless_sqlite_probe.dart').read_text()
        service = (root / 'android_native/HeadlessSqliteProbeService.kt').read_text()
        device_test = (root / 'android_native/HeadlessSqliteProbeInstrumentedTest.kt').read_text()
        self.assertIn('navitaximeter_HEADLESS_PROBE_ONLY.db', dart)
        self.assertIn('isDedicatedHeadlessProbePath(dbPath)', dart)
        self.assertNotIn('navitaximeter_v1.db', dart)
        self.assertNotIn('LocationManager', service)
        self.assertNotIn('startForeground', service)
        self.assertIn('FlutterEngine(applicationContext)', service)
        self.assertIn('writeAndRead', device_test)
        self.assertIn('callbackFence.close()', service)
        # Both MethodChannel success paths must verify the live DEBUG writer
        # lease when the callback arrives, not merely before dispatch.
        # Two live MethodChannel ACK paths plus one TEST-ONLY late-callback hook.
        self.assertEqual(service.count('callbackFence.resolveIfWriterOwned('), 3)
        self.assertEqual(service.count('val ownsAtDelivery = ownsDebugWriter()'), 2)
        self.assertIn('DEBUG_LATE_REPLY_TEST_ONLY', service)
        self.assertIn('debugHoldPendingCallbackForTest', service)
        self.assertIn('val ownsAtDelivery = ownsDebugWriter()', service)
        self.assertIn('if (checkpointFaulted || !ownsDebugWriter())', service)
        self.assertNotIn('callbackFence.resolve(requestId, result, null)', service)
        fence_test = (root / 'android_native/HeadlessProbeCallbackFenceTest.kt').read_text()
        self.assertIn('destroyFailsPendingRequestAndRejectsLateSuccess', fence_test)
        self.assertIn('stopFailsAllPendingWithoutDoubleCompleting', fence_test)
        self.assertIn('delayedValidAckCannotEscapeAfterWriterLeaseIsLost', fence_test)
        self.assertIn('stillOwnedAckCanCompleteOnlyItsOwnPendingRequest', fence_test)

    def test_location_owner_contract_sources(self):
        root = Path(__file__).resolve().parents[1] / "android_native"
        registry = (root / "LocationOwnerRegistry.kt").read_text()
        activity = (root / "MainActivity.kt").read_text()
        service = (root / "LocationSafetyService.kt").read_text()
        self.assertIn('fun claim(requestedOwner: String)', registry)
        self.assertIn('fun matches(requestedOwner: String, leaseId: Long)', registry)
        self.assertIn('fun release(requestedOwner: String, leaseId: Long)', registry)
        self.assertIn('LocationOwnerRegistry.claim(owner)', activity)
        self.assertIn('LocationOwnerRegistry.claim("native_safety")', activity)
        self.assertIn('LocationOwnerRegistry.matches("native_safety"', service)
        self.assertIn('"acknowledged" to acknowledged', service)
        self.assertIn('LocationOwnerRegistry.release("native_safety"', service)
        self.assertIn('data = Uri.parse("navitaximeter://gps-safety/stop/', service)
        self.assertIn('serviceLeaseId == requestedLease', service)
        self.assertIn('!hasLocationPermission()', service)
        self.assertIn('!providerStillEnabled()', service)
        self.assertIn('LocationOwnerRegistry.safetyStopRequested(requestedLease)', service)
        self.assertIn('LocationOwnerRegistry.requestSafetyStop(requestedLease)', service)
        self.assertIn('!LocationOwnerRegistry.safetyStopRequested(serviceLeaseId)', service)
        self.assertIn('LocationOwnerRegistry.requestSafetyStop(expected)', activity)
        # Safety health never labels coarse/network fixes as trusted GNSS.
        self.assertIn('GnssFixTrustGate.kt', NATIVE_SOURCES)
        self.assertIn('GnssFixTrustGateTest.kt', JVM_TEST_SOURCES)
        self.assertIn('fixTrustGate.accepts(GnssFixEvidence(', service)
        self.assertIn('registeredProvider == LocationManager.GPS_PROVIDER', service)
        self.assertIn('latestAcceptedElapsedMs = 0L', service)
        gate = (root / "GnssFixTrustGate.kt").read_text()
        self.assertIn('evidence.provider == "gps"', gate)
        self.assertIn('evidence.hasFineLocationPermission', gate)
        self.assertIn('fixNanos > lastAcceptedFixNanos', gate)
        self.assertNotIn('LocationOwnerRegistry.cancelPendingSafety', activity)
        self.assertIn('owner != "preview" && owner != "lab"', activity)

    def test_protocol_contract_is_unwired_and_has_runtime_tests(self):
        root = Path(__file__).resolve().parents[1] / "android_native"
        source = (root / "TripCheckpointProtocol.kt").read_text()
        tests = (root / "TripCheckpointProtocolTest.kt").read_text()
        self.assertIn("TripCheckpointProtocol.kt", NATIVE_SOURCES)
        self.assertIn("TripCheckpointProtocolTest.kt", JVM_TEST_SOURCES)
        self.assertIn("class TripCheckpointProtocol", source)
        self.assertIn("fun interface AtomicTripCheckpointWriter", source)
        self.assertIn("class TripCheckpointProtocolTest", tests)
        self.assertIn("fun sqliteFailureEvenAfterPossibleCommitDoesNotAck", tests)
        activity = (root / "MainActivity.kt").read_text()
        native = (root / "LocationSafetyService.kt").read_text()
        self.assertNotIn("TripCheckpointProtocol", activity)
        self.assertNotIn("TripCheckpointProtocol", native)
        self.assertNotIn("TaxiFare", source)

    def test_gradle_unit_test_patch_idempotent(self):
        source = 'plugins { id("com.android.application") }\nandroid { defaultConfig { } }\n'
        first = patch_gradle(source)
        self.assertIn(UNIT_TEST_DEP, first)
        self.assertIn(RUNNER_LINE, first)
        for dep in ANDROID_TEST_DEPS:
            self.assertIn(dep, first)
        self.assertEqual(first, patch_gradle(first))
        with self.assertRaises(ValueError):
            patch_gradle("android { }")

    def test_native_jvm_tests_in_source(self):
        root = Path(__file__).resolve().parents[1] / "android_native"
        test_source = (root / "LocationOwnerRegistryTest.kt").read_text()
        self.assertIn("class LocationOwnerRegistryTest", test_source)
        self.assertIn("fun concurrentClaimAllowsExactlyOneOwner", test_source)
        self.assertIn("fun staleReleaseNeverClearsNewOwner", test_source)

    def test_idempotent(self):
        first = patch_manifest(SAMPLE)
        self.assertEqual(patch_manifest(first), first)

    def test_reject_background_location(self):
        with self.assertRaises(ValueError):
            patch_manifest(SAMPLE.replace("<application",
                '<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION"/>'
                "<application"))

    def test_no_synthetic_application(self):
        with self.assertRaises(ValueError):
            patch_manifest("<manifest />")

if __name__ == "__main__":
    unittest.main()
