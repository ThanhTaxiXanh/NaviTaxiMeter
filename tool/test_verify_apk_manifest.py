import unittest

from verify_apk_manifest import verify_texts, SERVICE, REQUIRED

class CompiledManifestTests(unittest.TestCase):
    def fake(self):
        service = (
            'E: service (line=120)\n'
            '  A: android:name(0x01010003)="' + SERVICE + '"\n'
            '  A: android:foregroundServiceType(0x01010599)=(type 0x11)0x00000008\n'
        )
        permissions = '\n'.join(
            "uses-permission: name='" + name + "'" for name in REQUIRED)
        badging = "package: name='vn.navitaximeter' versionCode='4'"
        return service, permissions, badging

    def test_correct_compiled_manifest(self):
        verify_texts(*self.fake())

    def test_missing_location_service_type_is_denied(self):
        a, b, c = self.fake()
        with self.assertRaises(ValueError):
            verify_texts(a.replace("0x00000008", "0x00000004"), b, c)

    def test_missing_location_permission_is_denied(self):
        a, b, c = self.fake()
        with self.assertRaises(ValueError):
            verify_texts(a, b.replace("android.permission.FOREGROUND_SERVICE_LOCATION", ""),
                         c)

    def test_background_permission_is_denied(self):
        a, b, c = self.fake()
        with self.assertRaises(ValueError):
            verify_texts(a, b + "\nandroid.permission.ACCESS_BACKGROUND_LOCATION", c)

    def test_wrong_app_id_is_denied(self):
        a, b, c = self.fake()
        with self.assertRaises(ValueError):
            verify_texts(a, b, c.replace("vn.navitaximeter", "vn.dummy"))
