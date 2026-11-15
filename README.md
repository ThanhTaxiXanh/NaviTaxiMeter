# NaviTaxiMeter

Flutter Android fare, SQLite and GPS-gate foundation. A domain session coordinator now checkpoints trusted GPS with fare state transactionally and suspends on gaps. It is not yet wired to the Android GPS preview. Package/app ID: `vn.navitaximeter`.

**Not ready for real passenger fare collection:** GPS FGS, configured tariff UI, and checkpointed operating UI remain incomplete. No fictional fare, route or location is displayed. No paid API or Google Billing is enabled. Read [foundation status](docs/FOUNDATION_STATUS.md).

Preserves independence from TTX-AATaximeter. CI builds a test-only APK and tests domain models. Draft PR only, no main merge.
