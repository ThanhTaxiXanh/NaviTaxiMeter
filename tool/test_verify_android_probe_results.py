import tempfile
import unittest
from pathlib import Path
from verify_android_probe_results import (verify, EXPECTED_CLASS,
                                          EXPECTED_METHOD, EXPECTED_DEBUG_METHOD, EXPECTED_LEASE_METHOD,
                                          EXPECTED_LATE_METHOD,
                                          EXPECTED_TOKEN_CLASS,
                                          EXPECTED_STALE_TOKEN_METHOD,
                                          EXPECTED_PRE_ACK_METHOD)


class AndroidProbeEvidenceTests(unittest.TestCase):
    def setUp(self):
        self.sandbox = tempfile.TemporaryDirectory(prefix="navi-android-probe-test-")
        self.addCleanup(self.sandbox.cleanup)
        self.dir = Path(self.sandbox.name) / "connected" / "debug"
        self.dir.mkdir(parents=True)

    def report(self, body="", cls=EXPECTED_CLASS, name=EXPECTED_METHOD,
               include_lease=True, lease_body="",
               include_late=True, late_body="",
               include_token=True, stale_body="",
               include_pre_ack=True, pre_ack_body=""):
        debug_case = (f'<testcase classname="{cls}" name="{EXPECTED_DEBUG_METHOD}" />'
                      if name == EXPECTED_METHOD and cls == EXPECTED_CLASS else "")
        lease_case = (
            f'<testcase classname="{cls}" name="{EXPECTED_LEASE_METHOD}">'
            f'{lease_body}</testcase>'
            if include_lease and name == EXPECTED_METHOD and cls == EXPECTED_CLASS
            else ""
        )
        late_case = (
            f'<testcase classname="{cls}" name="{EXPECTED_LATE_METHOD}">'
            f'{late_body}</testcase>'
            if include_late and name == EXPECTED_METHOD and cls == EXPECTED_CLASS
            else ""
        )
        (self.dir / "TEST-probe.xml").write_text(
            f'<testsuite name="probe" tests="4">'
            f'<testcase classname="{cls}" name="{name}">{body}</testcase>'
             + debug_case + lease_case + late_case + '</testsuite>', encoding="utf-8",
        )
        token_cases = ""
        if include_token:
            token_cases += (
                f'<testcase classname="{EXPECTED_TOKEN_CLASS}" '
                f'name="{EXPECTED_STALE_TOKEN_METHOD}">{stale_body}</testcase>'
            )
        if include_pre_ack:
            token_cases += (
                f'<testcase classname="{EXPECTED_TOKEN_CLASS}" '
                f'name="{EXPECTED_PRE_ACK_METHOD}">{pre_ack_body}</testcase>'
            )
        (self.dir / "TEST-token.xml").write_text(
            f'<testsuite name="safety" tests="2">{token_cases}</testsuite>',
            encoding="utf-8",
        )

    def test_accepts_all_six_executed_passes(self):
        self.report()
        self.assertEqual(verify(self.dir.parent), 6)

    def test_rejects_missing_stale_notification_result(self):
        self.report(include_token=False)
        with self.assertRaises(ValueError):
            verify(self.dir.parent)

    def test_rejects_failed_or_skipped_stale_notification(self):
        for failure in ('<failure message="old stop wrong" />', '<skipped />'):
            self.report(stale_body=failure)
            with self.assertRaises(ValueError):
                verify(self.dir.parent)

    def test_rejects_missing_pre_ack_result(self):
        self.report(include_pre_ack=False)
        with self.assertRaises(ValueError):
            verify(self.dir.parent)

    def test_rejects_failed_or_skipped_pre_ack(self):
        for failure in ('<failure message="owner overlap" />', '<skipped />'):
            self.report(pre_ack_body=failure)
            with self.assertRaises(ValueError):
                verify(self.dir.parent)

    def test_rejects_missing_writer_service_lifecycle_result(self):
        self.report(include_lease=False)
        with self.assertRaises(ValueError):
            verify(self.dir.parent)

    def test_rejects_failed_or_skipped_writer_service_lifecycle(self):
        for failure in ('<failure message="writer-lease failed" />', '<skipped />'):
            self.report(lease_body=failure)
            with self.assertRaises(ValueError):
                verify(self.dir.parent)

    def test_rejects_missing_late_callback_lifecycle_result(self):
        self.report(include_late=False)
        with self.assertRaises(ValueError):
            verify(self.dir.parent)

    def test_rejects_failed_or_skipped_late_callback_lifecycle(self):
        for failure in ('<failure message="late-callback failed" />', '<skipped />'):
            self.report(late_body=failure)
            with self.assertRaises(ValueError):
                verify(self.dir.parent)

    def test_rejects_missing_results(self):
        with self.assertRaises(ValueError):
            verify(self.dir.parent / "unknown")

    def test_rejects_compile_only_empty_folder(self):
        with self.assertRaises(ValueError):
            verify(self.dir.parent)

    def test_rejects_wrong_test_name(self):
        self.report(name="someOtherTest")
        with self.assertRaises(ValueError):
            verify(self.dir.parent)

    def test_rejects_failure(self):
        self.report('<failure message="test failed" />')
        with self.assertRaises(ValueError):
            verify(self.dir.parent)

    def test_rejects_skipped(self):
        self.report("<skipped />")
        with self.assertRaises(ValueError):
            verify(self.dir.parent)

    def test_rejects_duplicate_report(self):
        self.report()
        (self.dir / "TEST-second.xml").write_text(
            f'<testsuite><testcase classname="{EXPECTED_CLASS}" '
            f'name="{EXPECTED_METHOD}" /></testsuite>', encoding="utf-8",
        )
        with self.assertRaises(ValueError):
            verify(self.dir.parent)


if __name__ == "__main__":
    unittest.main()
