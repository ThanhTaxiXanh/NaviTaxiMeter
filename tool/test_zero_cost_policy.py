import tempfile
import unittest
from pathlib import Path
from check_zero_cost_policy import audit

class ZeroCostGateTests(unittest.TestCase):
    def scan(self,text):
        with tempfile.TemporaryDirectory() as d:
            root=Path(d)
            (root/'pubspec.yaml').write_text(text,encoding='utf-8')
            return audit(root)
    def test_offline_is_allowed(self):
        self.assertFalse(self.scan('sqflite: ^2.4.2+1'))
    def test_google_maps_requires_separate_owner_approval(self):
        self.assertEqual(self.scan('google_maps_flutter: ^2.14.0')[0]['code'],
                         'GOOGLE_MAPS_BILLING_UNAPPROVED')
    def test_paid_provider_rejected(self):
        self.assertEqual(self.scan('url: https://api.mapbox.com')[0]['code'],
                         'METERED_MAP_PROVIDER')
    def test_map_id_rejected(self):
        self.assertEqual(self.scan('mapId: example')[0]['code'],'MAP_ID')
