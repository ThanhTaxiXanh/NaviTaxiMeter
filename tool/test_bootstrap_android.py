import unittest
from bootstrap_android import patch_manifest, PERMISSIONS

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
