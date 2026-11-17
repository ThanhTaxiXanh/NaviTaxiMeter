# NaviTaxiMeter | Data, Security and Privacy Policy

- Protect private user location, route history, customer data, accounts, bank BIN/account/name, API keys, signing and service credentials.
- Only collect GNSS with user-authorized location permissions and compliant visible foreground service; avoid hidden monitoring or OS restriction bypass.
- Do not print raw journey coordinates, account numbers, keystore data or tokens in public CI/logs; redact diagnostic samples.
- Confirm SQLite schema v3 and SharedPreferences keys before changes. Never reset a database or use replace-style receipt writes to hide inconsistency.
- For backup, export atomic versioned archive, verify hashes, stage/preview restore, handle duplicates and rollback. Never include signing secrets or unencrypted sensitive fields by default.
- For VietQR, verify actual payload with official/bank-compatible test vectors and physical bank-app scan; never share real accounts in tests.
- Secure Android exported components and IPC scope; diagnostic services must not be treated as production route tracking.
- Before third-party map/POI/traffic API use, complete licence, privacy, pricing and explicit zero-cost gate.
