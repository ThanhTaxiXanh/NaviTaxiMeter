package vn.navitaximeter

/**
 * Pure Kotlin precondition for a potential future single native GNSS owner.
 *
 * Current Android caller is ONLY the safety/health monitor; this does NOT
 * attest physical antenna origin or authorize fares, routes, or SQLite ACKs.
 * Rejects coarse/network, mock, stale/out-of-order and gapped samples.
 * A failed gate cannot re-arm itself: create a new gate on explicit Service
 * restart. Never fill missing GNSS time by interpolation.
 */
internal data class GnssFixEvidence(
    val provider: String?,
    val hasFineLocationPermission: Boolean,
    val mocked: Boolean,
    val fixElapsedRealtimeNanos: Long,
    val observedElapsedRealtimeNanos: Long,
    val accuracyMeters: Float?,
    val latitude: Double,
    val longitude: Double
)

internal class GnssFixTrustGate {
    private var lastAcceptedFixNanos = -1L
    private var suspended = false

    fun accepts(evidence: GnssFixEvidence): Boolean {
        if (suspended) return false
        val fixNanos = evidence.fixElapsedRealtimeNanos
        val nowNanos = evidence.observedElapsedRealtimeNanos
        val ageNanos = if (fixNanos > 0L && nowNanos >= fixNanos) {
            nowNanos - fixNanos
        } else Long.MAX_VALUE
        val accuracy = evidence.accuracyMeters
        val gapNanos = if (lastAcceptedFixNanos > 0L &&
            fixNanos > lastAcceptedFixNanos
        ) fixNanos - lastAcceptedFixNanos else Long.MAX_VALUE

        val credible = evidence.provider == "gps" &&
            evidence.hasFineLocationPermission && !evidence.mocked &&
            ageNanos in 0L..MAX_AGE_NANOS &&
            accuracy != null && accuracy.isFinite() && accuracy in 0f..30f &&
            evidence.latitude.isFinite() && evidence.latitude in -90.0..90.0 &&
            evidence.longitude.isFinite() && evidence.longitude in -180.0..180.0 &&
            (lastAcceptedFixNanos < 0L ||
                (fixNanos > lastAcceptedFixNanos && gapNanos <= MAX_GAP_NANOS))
        if (!credible) {
            suspended = true
            return false
        }
        lastAcceptedFixNanos = fixNanos
        return true
    }

    companion object {
        private const val MAX_AGE_NANOS = 12_000_000_000L
        private const val MAX_GAP_NANOS = 12_000_000_000L
    }
}
