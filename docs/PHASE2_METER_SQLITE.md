# Phase 2.2 · GPS → Meter → SQLite coordinator

Version `0.1.2+3`, source branch `feature/navitaximeter-foundation`.

## Implemented in the domain/data layer
- `MeteredTripCoordinator` requires a driver-confirmed tariff and a fresh, non-mocked GPS observation from an active subscribed foreground location stream before a session can start. The boolean from the caller is **not** OS-level proof of a running service.
- Every trusted GPS fix goes through the original fare engine and into the **same SQLite transaction** as the metering checkpoint (incremental `active_trip_route`). The smoothed map camera is never an input.
- No periodic timer can increase fare. A GPS gap over 12 seconds, mocked fix, or missing location stream suspends the trip at the last trusted time, without inventing distance or waiting fee.
- The driver must explicitly resume with a newly trusted GPS fix. Polyline segment indexes separate disconnected GPS periods.
- On app restart, load the original frozen tariff and persisted GPS route, but remain `paused/interrupted`. Do not retroactively bill time when app was absent.
- Finishing requires explicit driver confirmation. SQLite inserts the final receipt and deletes the checkpoint atomically. Only identical retrying of a previously committed receipt ID is allowed. Conflicting IDs or mismatched session starts / persisted route counts fail closed.
- On checkpoint persistence errors, further operations are blocked pending explicit restart/recovery. Partial in-memory fare changes are NOT proof of committed mileage.

## Important limitations
- **NOT YET connected to the visible GPS preview or a production Android service.** The controller is a tested domain integration seam, not a complete metering mode. Passenger fare buttons remain disabled.
- Geolocator plugin preview is still only a development GPS display; true foreground lifecycle survival, callback delivery and service permissions/manifest on real Android devices require testing. A service-associated session owner and UI connection are next.
- The 12-second threshold is an initial policy parameter, not legally certified fare-meter accuracy.
- Development tests use synthetic GPS/time under `test/` only. Real usage must use physical position callbacks with explicit mock flag checks.
- SQLite `completeActive` now validates the identity of the saved active checkpoint and the exact route count, forbids `ConflictAlgorithm.replace` for receipts.
- This is not an operational taxi meter, nor a statement of API monthly billing amount. Google Maps Billing remains unconfigured. Real-device 30-day and 1/50/100-user stress tests remain outstanding.

## Next exact step
Wire the physical Android location stream from the active test screen to the coordinator **with a foreground service owner that survives screen changes**, permission/notification gates and observed GPS health. Introduce safe lab-only controls and validate persistence across Activity recreation, service loss, offline use, and subsequent reinstallation/update scenarios. Only then consider unlocking passenger-facing metered journeys.
