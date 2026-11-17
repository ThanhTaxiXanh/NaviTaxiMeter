# NaviTaxiMeter | Vietnam Map Integrity

**Owner's cartographic presentation requirement:** label `Biển Đông`; depict Hoàng Sa and Trường Sa in a way consistent with the owner's Vietnam sovereignty requirement. Treat this as a product requirement and map-data QA task, not as proof of an existing renderer. The region has contested international claims; identify actual map provider/data and rendering constraints rather than inventing a global legal ruling.

## Validation
1. Record map provider, exact dataset/style/version/licence, language and zoom profiles.
2. Inspect mainland and islands, labels for Biển Đông/Hoàng Sa/Trường Sa and unsupported overlays.
3. Compare provider baseline with required application presentation. If labels/boundaries are controlled by Google or third-party tiles and cannot be lawfully altered, mark BLOCKED or find a lawful independent rendering/data source.
4. Preserve attribution and map licence; no screenshot tile repainting, bulk scraping or fabricated geography.
5. Collect on-device screenshots only when a renderer exists and compare against a documented geographic checklist.

**Current status:** no production map renderer or verified sovereignty screenshot on branch; NOT TESTED.
