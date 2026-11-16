package vn.navitaximeter

/**
 * DEBUG-only main-thread callback gate for the headless SQLite probe.
 * No GPS, money, trip database, or production checkpoint ACK.
 * Each request receives at most one callback. Stopping a bound service fails
 * all unresolved requests; late Dart responses cannot appear as successful.
 */
internal class HeadlessProbeCallbackFence {
    private var accepting = false
    private var nextId = 0L
    private val pending = LinkedHashMap<Long, (Any?, String?) -> Unit>()

    fun open() {
        check(!accepting && pending.isEmpty())
        accepting = true
    }

    fun register(callback: (Any?, String?) -> Unit): Long? {
        if (!accepting) return null
        val id = ++nextId
        pending[id] = callback
        return id
    }

    fun resolve(id: Long, result: Any?, error: String?): Boolean {
        val callback = pending.remove(id) ?: return false
        callback(result, error)
        return true
    }

    fun close() {
        accepting = false
        val unresolved = pending.values.toList()
        pending.clear()
        unresolved.forEach { callback ->
            try {
                callback(null, "SERVICE_DESTROYED")
            } catch (_: RuntimeException) {
                // A broken observer must not abort service teardown or keep
                // another pending caller from receiving its terminal failure.
                // All request IDs were already invalidated above.
            }
        }
    }
}
