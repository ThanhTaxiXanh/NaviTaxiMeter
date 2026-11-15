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
        "owner" to owner, "occupied" to (owner != "none")
    )

    @Synchronized
    fun cancelPendingSafety(): Boolean {
        if (owner != "native_safety") return false
        owner = "none"
        return true
    }
}
