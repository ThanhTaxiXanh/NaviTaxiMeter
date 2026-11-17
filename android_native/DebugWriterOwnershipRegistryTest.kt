package vn.navitaximeter

import org.junit.Assert.*
import org.junit.Test
import java.util.concurrent.Callable
import java.util.concurrent.CountDownLatch
import java.util.concurrent.Executors
import java.util.concurrent.TimeUnit

class DebugWriterOwnershipRegistryTest {
    @Test fun competingWorkersHaveExactlyOneLease() {
        val n = 12
        val pool = Executors.newFixedThreadPool(n)
        val ready = CountDownLatch(n)
        val start = CountDownLatch(1)
        try {
            val futures = (0 until n).map {
                pool.submit(Callable {
                    ready.countDown()
                    check(start.await(10, TimeUnit.SECONDS))
                    DebugWriterOwnershipRegistry.claim()
                })
            }
            assertTrue(ready.await(10, TimeUnit.SECONDS))
            start.countDown()
            val winners = futures.mapNotNull { it.get(10, TimeUnit.SECONDS) }
            assertEquals(1, winners.size)
            val first = winners.single()
            assertTrue(DebugWriterOwnershipRegistry.matches(first))
            assertNull(DebugWriterOwnershipRegistry.claim())
            assertFalse(DebugWriterOwnershipRegistry.release(first + 1))
            assertTrue(DebugWriterOwnershipRegistry.matches(first))
            assertTrue(DebugWriterOwnershipRegistry.release(first))
            val next = requireNotNull(DebugWriterOwnershipRegistry.claim())
            assertTrue(next > first)
            assertFalse(DebugWriterOwnershipRegistry.release(first))
            assertTrue(DebugWriterOwnershipRegistry.matches(next))
            assertTrue(DebugWriterOwnershipRegistry.release(next))
        } finally {
            start.countDown()
            pool.shutdownNow()
        }
    }
}
