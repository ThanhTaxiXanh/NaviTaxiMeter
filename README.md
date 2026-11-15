# NaviTaxiMeter

Flutter Android fare, SQLite and GPS-gate foundation. A domain session coordinator now checkpoints trusted GPS with fare state transactionally and suspends on gaps. It is not yet wired to the Android GPS preview. Package/app ID: `vn.navitaximeter`.

**Not ready for real passenger fare collection:** GPS FGS, configured tariff UI, and checkpointed operating UI remain incomplete. No fictional fare, route or location is displayed. No paid API or Google Billing is enabled. Read [foundation status](docs/FOUNDATION_STATUS.md).

Preserves independence from TTX-AATaximeter. CI builds a test-only APK and tests domain models. Draft PR only, no main merge.

## GPS laboratory (v0.1.3+4)

The new **Phòng thử** tab receives physical Geolocator GPS while visible, can open an explicitly labeled lab-only checkpoint, checkpoint accepted GPS into SQLite and recover only as paused. It does not show fare, issue a receipt or record business revenue. A completed business trip flow is not exposed. Android manifest in the APK is checked by tool/verify_apk_manifest.py. For scope and limits, see docs/PHASE2_LAB_ANDROID_GPS.md.
