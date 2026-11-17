package vn.navitaximeter

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import java.util.concurrent.Callable
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

/**
 * Executes the real Android process-local location registry on the JVM.
 * Does not replace physical Android foreground-service lifecycle tests.
 */
class LocationOwnerRegistryTest {
    @Test
    fun nativeSafetyBlocksBothGeolocatorClients() {
        val lease = requireNotNull(LocationOwnerRegistry.claim("native_safety"))
        try {
            assertTrue(LocationOwnerRegistry.matches("native_safety", lease))
            assertNull(LocationOwnerRegistry.claim("preview"))
            assertNull(LocationOwnerRegistry.claim("lab"))
            assertEquals("native_safety", LocationOwnerRegistry.currentOwner())
        } finally {
            assertTrue(LocationOwnerRegistry.release("native_safety", lease))
        }
    }

    @Test
    fun labAndPreviewCannotOverlap() {
        val lease = requireNotNull(LocationOwnerRegistry.claim("lab"))
        try {
            assertNull(LocationOwnerRegistry.claim("preview"))
            assertNull(LocationOwnerRegistry.claim("native_safety"))
            assertFalse(LocationOwnerRegistry.release("preview", lease))
        } finally {
            assertTrue(LocationOwnerRegistry.release("lab", lease))
        }
    }

    @Test
    fun staleReleaseNeverClearsNewOwner() {
        val first = requireNotNull(LocationOwnerRegistry.claim("preview"))
        assertTrue(LocationOwnerRegistry.release("preview", first))
        val second = requireNotNull(LocationOwnerRegistry.claim("native_safety"))
        try {
            assertTrue(second > first)
            assertFalse(LocationOwnerRegistry.release("preview", first))
            assertFalse(LocationOwnerRegistry.release("native_safety", first))
            assertTrue(LocationOwnerRegistry.matches("native_safety", second))
            assertNull(LocationOwnerRegistry.claim("lab"))
        } finally {
            assertTrue(LocationOwnerRegistry.release("native_safety", second))
        }
    }

    @Test
    fun pendingStopNeverReleasesGpsBeforeOnDestroy() {
        val old = requireNotNull(LocationOwnerRegistry.claim("native_safety"))
        assertTrue(old > 0L)
        assertFalse(LocationOwnerRegistry.requestSafetyStop(old + 1))
        assertFalse(LocationOwnerRegistry.safetyStopRequested(old))
        assertTrue(LocationOwnerRegistry.requestSafetyStop(old))
        assertTrue(LocationOwnerRegistry.safetyStopRequested(old))
        assertEquals(true, LocationOwnerRegistry.snapshot()["stopRequested"])
        // Start is still pending: a competing GPS client MUST be refused.
        assertNull(LocationOwnerRegistry.claim("lab"))
        assertNull(LocationOwnerRegistry.claim("preview"))
        assertNull(LocationOwnerRegistry.claim("native_safety"))
        // Service onDestroy is the only operation releasing this generation.
        assertTrue(LocationOwnerRegistry.release("native_safety", old))
        assertEquals(false, LocationOwnerRegistry.snapshot()["stopRequested"])
        val next = requireNotNull(LocationOwnerRegistry.claim("native_safety"))
        try {
            assertTrue(next > old)
            assertFalse(LocationOwnerRegistry.requestSafetyStop(old))
            assertFalse(LocationOwnerRegistry.safetyStopRequested(next))
            assertTrue(LocationOwnerRegistry.matches("native_safety", next))
        } finally {
            assertTrue(LocationOwnerRegistry.release("native_safety", next))
        }
        assertEquals(-1L, LocationOwnerRegistry.snapshot()["leaseId"])
    }

    @Test
    fun repeatedPendingStopIsIdempotentWithoutReleasingLease() {
        val lease = requireNotNull(LocationOwnerRegistry.claim("native_safety"))
        try {
            assertTrue(LocationOwnerRegistry.requestSafetyStop(lease))
            assertTrue(LocationOwnerRegistry.requestSafetyStop(lease))
            assertTrue(LocationOwnerRegistry.safetyStopRequested(lease))
            assertNull(LocationOwnerRegistry.claim("preview"))
        } finally {
            assertTrue(LocationOwnerRegistry.release("native_safety", lease))
        }
    }

    @Test
    fun rejectInvalidOwnerOrInvalidToken() {
        assertNull(LocationOwnerRegistry.claim("passenger_fare"))
        assertNull(LocationOwnerRegistry.claim(""))
        assertFalse(LocationOwnerRegistry.matches("native_safety", 0))
        assertFalse(LocationOwnerRegistry.release("lab", 0))
    }

    @Test
    fun concurrentClaimAllowsExactlyOneOwner() {
        val count = 16
        val pool = Executors.newFixedThreadPool(count)
        val ready = CountDownLatch(count)
        val start = CountDownLatch(1)
        try {
            val attempts = (0 until count).map { index ->
                pool.submit(Callable {
                    ready.countDown()
                    check(start.await(10, TimeUnit.SECONDS))
                    LocationOwnerRegistry.claim(
                        if (index % 2 == 0) "preview" else "native_safety"
                    )?.let { Pair(index, it) }
                })
            }
            assertTrue("Threads did not start", ready.await(10, TimeUnit.SECONDS))
            start.countDown()
            val winners = attempts.mapNotNull { it.get(10, TimeUnit.SECONDS) }
            assertEquals("Exactly one lease", 1, winners.size)
            val (index, lease) = winners.single()
            val owner = if (index % 2 == 0) "preview" else "native_safety"
            assertTrue(LocationOwnerRegistry.matches(owner, lease))
            assertTrue(LocationOwnerRegistry.release(owner, lease))
        } finally {
            start.countDown()
            pool.shutdownNow()
        }
    }
}
