package vn.navitaximeter

/**
 * A process-local safety interlock for the three GPS experiments.
 * This is NOT a persistent/billable trip-service owner.
 */
object LocationOwnerRegistry {
    private var owner = "none"
    private var generation = 0L
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
        return true
    }

    @Synchronized
    fun currentOwner(): String = owner

    @Synchronized
    fun snapshot(): Map<String, Any> = mapOf(
        "owner" to owner,
        "occupied" to (owner != "none"),
        "leaseId" to (if (owner == "none") -1L else generation)
    )

    /**
     * Cancel only the safety start with the token that was dispatched.
     * A delayed stop from an older session must never clear a newer owner.
     * Caller must independently verify no live native service is running.
     */
    @Synchronized
    fun cancelPendingSafety(expectedLeaseId: Long): Boolean {
        return release("native_safety", expectedLeaseId)
    }
}
