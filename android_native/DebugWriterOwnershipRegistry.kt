package vn.navitaximeter

import java.security.SecureRandom

/**
 * DEBUG ONLY: process-local ownership of the isolated headless SQLite writer.
 * No durable cross-process lock, no production database, no GNSS or fare.
 * An owner may release its token only after the engine is torn down.
 */
internal object DebugWriterOwnershipRegistry {
    private var token = SecureRandom().nextLong().ushr(2)
    private var held: Long? = null

    @Synchronized
    fun claim(): Long? {
        if (held != null) return null
        token += 1
        held = token
        return token
    }

    @Synchronized
    fun matches(candidate: Long): Boolean = candidate > 0 && held == candidate

    @Synchronized
    fun release(candidate: Long): Boolean {
        if (!matches(candidate)) return false
        held = null
        return true
    }
}
