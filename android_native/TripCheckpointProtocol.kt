package vn.navitaximeter

/**
 * DESIGN-ONLY, JVM-testable contract for a future single-owner trip service.
 *
 * This class has no Android GPS access, no SQLite implementation, no fare
 * engine, and is NOT used by MainActivity/LocationSafetyService or Flutter.
 * A returned receipt can only prove durability if the eventual writer
 * implements the documented transaction contract. Unit tests use a fake.
 */
enum class TripProtocolPhase {
    IDLE, START_REQUESTED, SERVICE_ACKED, GPS_ACQUIRING, ACTIVE, SUSPENDED
}

data class TripSessionFence(val sessionId: String, val generation: Long) {
    init {
        require(sessionId.isNotBlank() && sessionId.length <= 128) {
            "A nonblank bounded trip identity is required"
        }
        require(generation > 0L) { "Session generation must be positive" }
    }
}

/**
 * GPS metadata only, deliberately without coordinates, prices or fare.
 * This alone is NOT proof that the fix came from physical GNSS.
 */
data class GpsCheckpointCandidate(
    val fence: TripSessionFence,
    val sequence: Long, // Same zero-based indexing as active_trip_route.
    val gnssElapsedRealtimeNanos: Long,
    val accuracyMeters: Double,
    val speedKmh: Double,
    val isMocked: Boolean
)

data class CheckpointCommitReceipt(
    val fence: TripSessionFence,
    val sequence: Long,
    val databaseCheckpointId: String
)

/**
 * A production implementation MUST atomically write active_trip and
 * active_trip_route and return only AFTER the SQLite transaction commits.
 * A fake test writer cannot establish actual durability.
 */
fun interface AtomicTripCheckpointWriter {
    fun commit(candidate: GpsCheckpointCandidate): CheckpointCommitReceipt
}

/**
 * Single-session protocol draft, isolated from real device and fare code.
 * All entry points are serialized to prevent concurrent writes/replay races.
 * Any uncertain write or GNSS gap suspends the protocol with no auto-resume.
 */
class TripCheckpointProtocol(private val writer: AtomicTripCheckpointWriter) {
    companion object {
        private const val MAX_HEARTBEAT_AGE_MS = 7000L
        private const val MAX_GNSS_GAP_NS = 12_000_000_000L

        /**
         * The caller must first have READ and VERIFIED the durable SQLite
         * checkpoint. Recovery is ALWAYS suspended, never ACTIVE.
         * No resume API exists until actual service + DB integration exists.
         */
        fun recoveredPaused(
            writer: AtomicTripCheckpointWriter,
            fence: TripSessionFence,
            lastCommittedSequence: Long
        ): TripCheckpointProtocol {
            require(lastCommittedSequence >= -1L)
            return TripCheckpointProtocol(writer).apply {
                activeFence = fence
                lastSequence = lastCommittedSequence
                phase = TripProtocolPhase.SUSPENDED
                suspensionReason = "recovered_paused"
            }
        }
    }

    var phase: TripProtocolPhase = TripProtocolPhase.IDLE
        private set
    var suspensionReason: String? = null
        private set
    var lastSequence: Long = -1L
        private set

    private var activeFence: TripSessionFence? = null
    private var lastGnssNanos = -1L
    private var lastReceipt: CheckpointCommitReceipt? = null
    private var lastCandidate: GpsCheckpointCandidate? = null

    @Synchronized
    fun requestStart(fence: TripSessionFence): Boolean {
        if (phase != TripProtocolPhase.IDLE) return false
        activeFence = fence
        phase = TripProtocolPhase.START_REQUESTED
        return true
    }

    /**
     * Requires caller-supplied live native service ACK with matching lease.
     * Callers must independently check OS service state and heartbeat source.
     */
    @Synchronized
    fun serviceAcknowledged(fence: TripSessionFence, heartbeatAgeMs: Long): Boolean {
        if (!matches(fence) || phase != TripProtocolPhase.START_REQUESTED ||
            heartbeatAgeMs !in 0L..MAX_HEARTBEAT_AGE_MS
        ) return false
        phase = TripProtocolPhase.SERVICE_ACKED
        return true
    }

    @Synchronized
    fun beginGpsAcquisition(fence: TripSessionFence): Boolean {
        if (!matches(fence) || phase != TripProtocolPhase.SERVICE_ACKED) return false
        phase = TripProtocolPhase.GPS_ACQUIRING
        return true
    }

    /**
     * Only the future GNSS verifier may call this after a trusted real fix.
     * This protocol draft provides no location verifier itself.
     */
    @Synchronized
    fun trustedGnssAvailable(fence: TripSessionFence): Boolean {
        if (!matches(fence) || phase != TripProtocolPhase.GPS_ACQUIRING) return false
        phase = TripProtocolPhase.ACTIVE
        return true
    }

    @Synchronized
    fun suspend(fence: TripSessionFence, reason: String): Boolean {
        if (!matches(fence) || phase == TripProtocolPhase.IDLE) return false
        failClosed(reason)
        return true
    }

    /**
     * A checkpoint is ACKed only after writer.commit returns a matching
     * nonempty receipt. Real SQLite atomicity remains an external obligation.
     * Duplicate last-sequence requests return the prior ACK only when the
     * in-process candidate is identical. Older replay/gaps fail closed.
     */
    @Synchronized
    fun checkpoint(candidate: GpsCheckpointCandidate): CheckpointCommitReceipt {
        if (!matches(candidate.fence)) {
            throw SecurityException("Stale or foreign GPS session generation")
        }
        check(phase == TripProtocolPhase.ACTIVE) {
            "GPS processing is not ACTIVE; manual recovery is required"
        }
        if (candidate.sequence == lastSequence && lastReceipt != null) {
            if (candidate == lastCandidate) return lastReceipt!!
            failClosed("conflicting_replay")
            throw IllegalStateException("Duplicate sequence has changed GPS data")
        }
        if (candidate.sequence != lastSequence + 1L) {
            failClosed("sequence_gap_or_replay")
            throw IllegalStateException("GPS sequence is not contiguous")
        }
        val nanos = candidate.gnssElapsedRealtimeNanos
        if (nanos <= 0L || (lastGnssNanos >= 0L &&
            (nanos <= lastGnssNanos || nanos - lastGnssNanos > MAX_GNSS_GAP_NS))
        ) {
            failClosed("stale_or_gapped_gnss")
            throw IllegalStateException("GNSS elapsed time is unsafe")
        }
        if (candidate.isMocked ||
            !candidate.accuracyMeters.isFinite() ||
            candidate.accuracyMeters !in 0.0..30.0 ||
            !candidate.speedKmh.isFinite() ||
            candidate.speedKmh !in 0.0..220.0
        ) {
            failClosed("untrusted_gnss")
            throw IllegalStateException("Untrusted GPS metadata")
        }

        val receipt = try {
            writer.commit(candidate)
        } catch (error: Exception) {
            // Even if SQLite committed but transport failed, NEVER ACK.
            failClosed("checkpoint_unconfirmed")
            throw IllegalStateException("Durable checkpoint not confirmed", error)
        }
        if (receipt.fence != candidate.fence ||
            receipt.sequence != candidate.sequence ||
            receipt.databaseCheckpointId.isBlank()
        ) {
            failClosed("checkpoint_mismatch")
            throw IllegalStateException("Writer returned mismatched checkpoint")
        }

        // This is assigned only AFTER the writer reports a committed result.
        lastSequence = candidate.sequence
        lastGnssNanos = nanos
        lastReceipt = receipt
        lastCandidate = candidate
        return receipt
    }

    private fun matches(fence: TripSessionFence): Boolean =
        activeFence == fence

    private fun failClosed(reason: String) {
        phase = TripProtocolPhase.SUSPENDED
        suspensionReason = reason
    }
}
