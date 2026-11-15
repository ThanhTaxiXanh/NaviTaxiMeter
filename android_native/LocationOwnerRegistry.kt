package vn.navitaximeter

import java.security.SecureRandom

/**
 * A process-local safety interlock for the three GPS experiments.
 * This is NOT a persistent/billable trip-service owner.
 */
object LocationOwnerRegistry {
    private var owner = "none"
    // Do not reuse a small lease token after Android process death:
    // stale notification PendingIntents can outlive an earlier process.
    private var generation = SecureRandom().nextLong().ushr(2)
    private var stopRequestedLeaseId = -1L
    private val allowed = setOf("preview", "lab", "native_safety")

    @Synchronized
    fun claim(requestedOwner: String): Long? {
        if (requestedOwner !in allowed || owner != "none") return null
        generation += 1L
        owner = requestedOwner
        return generation
    }

    @Synchronized
    fun matches(requestedOwner: String, leaseId: Long): Boolean =
        requestedOwner in allowed && owner == requestedOwner &&
            leaseId > 0L && generation == leaseId

    @Synchronized
    fun release(requestedOwner: String, leaseId: Long): Boolean {
        if (!matches(requestedOwner, leaseId)) return false
        owner = "none"
        stopRequestedLeaseId = -1L
        return true
    }

    @Synchronized
    fun currentOwner(): String = owner

    @Synchronized
    fun snapshot(): Map<String, Any> = mapOf(
        "owner" to owner,
        "occupied" to (owner != "none"),
        "leaseId" to (if (owner == "none") -1L else generation),
        "stopRequested" to (owner == "native_safety" &&
            stopRequestedLeaseId == generation)
    )

    /**
     * A stop during the asynchronous START reservation is a request, NOT
     * permission to release GPS. Only service onDestroy confirms teardown.
     * If Android never dispatches onStartCommand, retain the lease fail-closed
     * until the process is restarted, rather than allowing overlapping FGS.
     */
    @Synchronized
    fun requestSafetyStop(expectedLeaseId: Long): Boolean {
        if (!matches("native_safety", expectedLeaseId)) return false
        stopRequestedLeaseId = expectedLeaseId
        return true
    }

    @Synchronized
    fun safetyStopRequested(expectedLeaseId: Long): Boolean =
        matches("native_safety", expectedLeaseId) &&
            stopRequestedLeaseId == expectedLeaseId
}
