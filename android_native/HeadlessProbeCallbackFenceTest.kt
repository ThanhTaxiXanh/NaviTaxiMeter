package vn.navitaximeter

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test

/** Unit JVM tests only: debug callback lifetime, not Android/SQLite. */
class HeadlessProbeCallbackFenceTest {
    @Test fun responseArrivesExactlyOnce() {
        val fence = HeadlessProbeCallbackFence()
        fence.open()
        var responses = 0
        var value: Any? = null
        val id = fence.register { result, error ->
            responses++
            value = result
            assertNull(error)
        }!!
        assertTrue(fence.resolve(id, "probe-only", null))
        assertFalse(fence.resolve(id, "stale", null))
        fence.close()
        assertEquals(1, responses)
        assertEquals("probe-only", value)
    }

    @Test fun destroyFailsPendingRequestAndRejectsLateSuccess() {
        val fence = HeadlessProbeCallbackFence()
        fence.open()
        val replies = mutableListOf<Pair<Any?, String?>>()
        val id = fence.register { value, error -> replies.add(value to error) }!!
        fence.close()
        assertEquals(listOf(null to "SERVICE_DESTROYED"), replies)
        assertFalse(fence.resolve(id, "post-destroy-success", null))
        assertNull(fence.register { _, _ -> })
        assertEquals(1, replies.size)
    }

    @Test fun stopFailsAllPendingWithoutDoubleCompleting() {
        val fence = HeadlessProbeCallbackFence()
        fence.open()
        val results = mutableListOf<String?>()
        repeat(8) { fence.register { _, error -> results.add(error) } }
        fence.close()
        fence.close()
        assertEquals(8, results.size)
        assertTrue(results.all { it == "SERVICE_DESTROYED" })
    }

    @Test fun reopenCannotAcceptOldRequestId() {
        val fence = HeadlessProbeCallbackFence()
        fence.open()
        val reports = mutableListOf<String?>()
        val oldId = fence.register { _, error -> reports.add(error) }!!
        fence.close()
        fence.open()
        val newId = fence.register { _, error -> reports.add(error) }!!
        assertTrue(newId > oldId)
        assertFalse(fence.resolve(oldId, null, null))
        assertTrue(fence.resolve(newId, "new", null))
        fence.close()
        assertEquals(listOf("SERVICE_DESTROYED", null), reports)
    }
}
