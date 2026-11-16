package vn.navitaximeter

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.ServiceConnection
import android.os.IBinder
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import java.util.Collections
import java.util.concurrent.CountDownLatch
import java.util.concurrent.TimeUnit

/**
 * Must RUN on Android instrumentation/device: CI compiles but does not run it.
 * No Activity/FGS/GNSS/fare or production DB is used by this debug-only test.
 */
@RunWith(AndroidJUnit4::class)
class HeadlessSqliteProbeInstrumentedTest {
    @Test
    fun boundHeadlessEngineCanOpenSqfliteAndReadCommittedProbe() {
        val context = InstrumentationRegistry.getInstrumentation().targetContext
        val destroyedBefore = HeadlessSqliteProbeService.destructionCount()
        var lastCommittedProbeCount = -1
        var firstWriterLease = -1L
        val serviceReady = CountDownLatch(1)
        var binder: HeadlessSqliteProbeService.ProbeBinder? = null
        val connection = object : ServiceConnection {
            override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
                binder = service as? HeadlessSqliteProbeService.ProbeBinder
                serviceReady.countDown()
            }
            override fun onServiceDisconnected(name: ComponentName?) {
                binder = null
            }
        }
        val attached = context.bindService(
            Intent(context, HeadlessSqliteProbeService::class.java),
            connection,
            Context.BIND_AUTO_CREATE
        )
        assertTrue("Test-only bound service was rejected", attached)
        try {
            assertTrue("Service never bound", serviceReady.await(20, TimeUnit.SECONDS))
            val worker = binder
            assertNotNull(worker)
            var attempts = 0
            while (worker?.isReady() != true && attempts++ < 150) {
                Thread.sleep(100)
            }
            assertTrue("Headless Dart entrypoint never ACKed ready", worker?.isReady() == true)
            firstWriterLease = worker?.debugWriterLeaseForTest() ?: -1L
            assertTrue("First service has no positive writer lease", firstWriterLease > 0L)
            val finished = CountDownLatch(1)
            var result: Any? = null
            var error: String? = null
            worker!!.writeAndRead { value, failure ->
                result = value
                error = failure
                finished.countDown()
            }
            assertTrue("Dart/sqflite probe timed out", finished.await(30, TimeUnit.SECONDS))
            assertEquals("Unexpected platform/sqflite error", null, error)
            @Suppress("UNCHECKED_CAST")
            val response = result as? Map<String, Any?>
            assertNotNull("No committed SQLite readback", response)
            assertEquals(true, response!!["probeOnly"])
            assertEquals(true, response["reopened"])
            assertEquals(false, response["passengerFareEnabled"])
            assertEquals("navitaximeter_HEADLESS_PROBE_ONLY.db", response["databaseName"])

            // Eight requests are sent before waiting for callbacks. Only the
            // Dart service-owned probe writer may mutate this isolated DB.
            // Verify unique consecutive persisted counters, not passenger ACKs.
            val initial = (response["rowCount"] as? Number)?.toInt()
                ?: throw AssertionError("Probe did not expose a row count")
            val parallelDone = CountDownLatch(8)
            val parallelCounts = Collections.synchronizedList(mutableListOf<Int>())
            val parallelErrors = Collections.synchronizedList(mutableListOf<String>())
            repeat(8) {
                worker.writeAndRead { value, failure ->
                    if (failure != null) {
                        parallelErrors.add(failure)
                    } else {
                        val count = ((value as? Map<*, *>)?.get("rowCount")
                            as? Number)?.toInt()
                        if (count == null) {
                            parallelErrors.add("Missing SQLite readback count")
                        } else {
                            parallelCounts.add(count)
                        }
                    }
                    parallelDone.countDown()
                }
            }
            assertTrue("Parallel SQLite probes timed out",
                parallelDone.await(40, TimeUnit.SECONDS))
            assertTrue("Probe requests failed: $parallelErrors",
                parallelErrors.isEmpty())
            assertEquals((initial + 1..initial + 8).toList(),
                parallelCounts.sorted())
            lastCommittedProbeCount = initial + 8
        } finally {
            context.unbindService(connection)
        }

        // A bound service with no remaining clients must be destroyed.
        // The next bind must construct a fresh headless FlutterEngine, while
        // a separate test-only SQLite database retains its committed count.
        var destroyAttempts = 0
        while (HeadlessSqliteProbeService.destructionCount() <= destroyedBefore &&
               destroyAttempts++ < 150) {
            Thread.sleep(100)
        }
        assertTrue("First debug headless service was not destroyed",
            HeadlessSqliteProbeService.destructionCount() > destroyedBefore)
        assertTrue("No committed count from first service", lastCommittedProbeCount >= 0)

        val rebound = CountDownLatch(1)
        var nextBinder: HeadlessSqliteProbeService.ProbeBinder? = null
        val nextConnection = object : ServiceConnection {
            override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
                nextBinder = service as? HeadlessSqliteProbeService.ProbeBinder
                rebound.countDown()
            }
            override fun onServiceDisconnected(name: ComponentName?) {
                nextBinder = null
            }
        }
        val reboundAccepted = context.bindService(
            Intent(context, HeadlessSqliteProbeService::class.java),
            nextConnection, Context.BIND_AUTO_CREATE
        )
        assertTrue("Rebind to new debug headless engine failed", reboundAccepted)
        try {
            assertTrue("Second debug headless service did not connect",
                rebound.await(20, TimeUnit.SECONDS))
            val next = nextBinder
            assertNotNull(next)
            var readyAttempts = 0
            while (next?.isReady() != true && readyAttempts++ < 150) {
                Thread.sleep(100)
            }
            assertTrue("Second Dart engine never reported ready", next?.isReady() == true)
            val secondWriterLease = next?.debugWriterLeaseForTest()
            assertNotNull("Rebound service has no writer lease", secondWriterLease)
            assertTrue("New service reused a stale writer lease",
                secondWriterLease!! > firstWriterLease)
            val completed = CountDownLatch(1)
            var reboundValue: Any? = null
            var reboundError: String? = null
            next!!.writeAndRead { value, error ->
                reboundValue = value
                reboundError = error
                completed.countDown()
            }
            assertTrue("Rebound Dart/sqflite call timed out",
                completed.await(30, TimeUnit.SECONDS))
            assertEquals("Rebound Dart/sqflite call failed", null, reboundError)
            val counter = ((reboundValue as? Map<*, *>)?.get("rowCount")
                as? Number)?.toInt()
            assertEquals("SQLite readback lost state after engine teardown",
                lastCommittedProbeCount + 1, counter)
        } finally {
            context.unbindService(nextConnection)
        }
    }

    @Test
    fun realKotlinToHeadlessDartDebugIpcAcksOnlyAfterSqliteReadback() {
        // No GPS, tariff, route, money or production SQLite in this test.
        val context = InstrumentationRegistry.getInstrumentation().targetContext
        val destroyedBefore = HeadlessSqliteProbeService.destructionCount()
        var originalLease: Long? = null
        val serviceReady = CountDownLatch(1)
        var binder: HeadlessSqliteProbeService.ProbeBinder? = null
        val connection = object : ServiceConnection {
            override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
                binder = service as? HeadlessSqliteProbeService.ProbeBinder
                serviceReady.countDown()
            }
            override fun onServiceDisconnected(name: ComponentName?) {
                binder = null
            }
        }
        assertTrue(context.bindService(
            Intent(context, HeadlessSqliteProbeService::class.java),
            connection, Context.BIND_AUTO_CREATE
        ))
        val session = "DBG_${android.os.SystemClock.elapsedRealtimeNanos()}"
        val payload = "a".repeat(64)
        try {
            assertTrue("Debug service did not bind", serviceReady.await(20, TimeUnit.SECONDS))
            val worker = binder ?: throw AssertionError("Debug binder is missing")
            var attempts = 0
            while (!worker.isReady() && attempts++ < 150) Thread.sleep(100)
            assertTrue("Dart debug checkpoint worker not ready", worker.isReady())
            originalLease = worker.debugWriterLeaseForTest()
            assertNotNull("DEBUG writer lease absent during IPC", originalLease)

            // Reject malformed wire identities at the native boundary without
            // touching Dart or poisoning a valid, not-yet-started session.
            val invalidDone = CountDownLatch(2)
            val invalidErrors = Collections.synchronizedList(mutableListOf<String>())
            worker.debugCheckpoint("NOT_A_DEBUG_SESSION", 71L, 0L, payload) { _, error ->
                invalidErrors.add(error ?: "UNEXPECTED_INVALID_SESSION_ACK")
                invalidDone.countDown()
            }
            worker.debugCheckpoint(session, 71L, 0L, "bad-hash") { _, error ->
                invalidErrors.add(error ?: "UNEXPECTED_INVALID_HASH_ACK")
                invalidDone.countDown()
            }
            assertTrue("Malformed native proposals timed out",
                invalidDone.await(30, TimeUnit.SECONDS))
            assertEquals(listOf("INVALID_DEBUG_PROPOSAL", "INVALID_DEBUG_PROPOSAL"),
                invalidErrors.sorted())

            // Eight actual Kotlin MethodChannel requests contend for the one
            // serialized Dart sqflite writer. ACK requires COMMIT + reopen.
            val done = CountDownLatch(8)
            val acked = Collections.synchronizedList(mutableListOf<Long>())
            val ids = Collections.synchronizedSet(mutableSetOf<String>())
            val failures = Collections.synchronizedList(mutableListOf<String>())
            repeat(8) { index ->
                worker.debugCheckpoint(session, 71L, index.toLong(), payload) {
                    response, error ->
                    if (error != null) failures.add(error)
                    val ack = response as? Map<*, *>
                    if (ack == null) {
                        failures.add("No post-COMMIT ACK at sequence $index")
                    } else {
                        if (ack["type"] != "debug.checkpoint.ack.v1" ||
                            ack["sessionId"] != session ||
                            (ack["generation"] as? Number)?.toLong() != 71L ||
                            (ack["sequence"] as? Number)?.toLong() != index.toLong() ||
                            ack["payloadHash"] != payload ||
                            ack["probeOnly"] != true ||
                            ack["passengerFareEnabled"] != false
                        ) {
                            failures.add("Unverified DEBUG ACK at $index")
                        }
                        acked.add(index.toLong())
                        ids.add(ack["checkpointId"].toString())
                    }
                    done.countDown()
                }
            }
            assertTrue("Native->Dart callback timeout",
                done.await(90, TimeUnit.SECONDS))
            assertTrue("Native IPC error: $failures", failures.isEmpty())
            assertEquals((0L..7L).toList(), acked.sorted())
            assertEquals(8, ids.size)

            // Byte-identical replay must return the same committed identity.
            val replayDone = CountDownLatch(1)
            var replayId: String? = null
            var replayError: String? = null
            worker.debugCheckpoint(session, 71L, 7L, payload) { response, error ->
                replayId = (response as? Map<*, *>)?.get("checkpointId") as? String
                replayError = error
                replayDone.countDown()
            }
            assertTrue(replayDone.await(30, TimeUnit.SECONDS))
            assertEquals(null, replayError)
            assertTrue(ids.contains(replayId))

            // Foreign generation is rejected natively before Dart sees it.
            val staleDone = CountDownLatch(1)
            var staleError: String? = null
            worker.debugCheckpoint(session, 72L, 8L, payload) { _, error ->
                staleError = error
                staleDone.countDown()
            }
            assertTrue(staleDone.await(30, TimeUnit.SECONDS))
            assertEquals("STALE_DEBUG_FENCE", staleError)

            val nextDone = CountDownLatch(1)
            var nextError: String? = null
            worker.debugCheckpoint(session, 71L, 8L, payload) { _, error ->
                nextError = error
                nextDone.countDown()
            }
            assertTrue(nextDone.await(30, TimeUnit.SECONDS))
            assertEquals(null, nextError)

            // Conflicting same-sequence payload fails closed. The service
            // rejects any subsequent request, even when the data is valid.
            val conflictDone = CountDownLatch(1)
            var conflictError: String? = null
            worker.debugCheckpoint(session, 71L, 8L, "b".repeat(64)) { _, error ->
                conflictError = error
                conflictDone.countDown()
            }
            assertTrue(conflictDone.await(30, TimeUnit.SECONDS))
            assertNotNull("Conflicting replay must be rejected", conflictError)
            val pausedDone = CountDownLatch(1)
            var pausedError: String? = null
            worker.debugCheckpoint(session, 71L, 9L, payload) { _, error ->
                pausedError = error
                pausedDone.countDown()
            }
            assertTrue(pausedDone.await(30, TimeUnit.SECONDS))
            assertEquals("DEBUG_SESSION_PAUSED", pausedError)
        } finally {
            context.unbindService(connection)
        }

        var waits = 0
        while (HeadlessSqliteProbeService.destructionCount() <= destroyedBefore &&
            waits++ < 150) Thread.sleep(100)
        assertTrue("Old engine was not torn down",
            HeadlessSqliteProbeService.destructionCount() > destroyedBefore)

        // Recreating the engine must not silently revive a persisted session.
        val rebindDone = CountDownLatch(1)
        var rebound: HeadlessSqliteProbeService.ProbeBinder? = null
        val secondConnection = object : ServiceConnection {
            override fun onServiceConnected(name: ComponentName?, service: IBinder?) {
                rebound = service as? HeadlessSqliteProbeService.ProbeBinder
                rebindDone.countDown()
            }
            override fun onServiceDisconnected(name: ComponentName?) {
                rebound = null
            }
        }
        assertTrue(context.bindService(
            Intent(context, HeadlessSqliteProbeService::class.java),
            secondConnection, Context.BIND_AUTO_CREATE
        ))
        try {
            assertTrue(rebindDone.await(20, TimeUnit.SECONDS))
            val worker = rebound ?: throw AssertionError("Rebound worker missing")
            var attempts = 0
            while (!worker.isReady() && attempts++ < 150) Thread.sleep(100)
            assertTrue("Recreated Dart worker not ready", worker.isReady())
            val reboundLease = worker.debugWriterLeaseForTest()
            assertNotNull("DEBUG writer lease absent after rebind", reboundLease)
            assertTrue("Stale writer token reused after engine teardown",
                reboundLease!! > originalLease!!)
            val finished = CountDownLatch(1)
            var recoveryError: String? = null
            worker.debugCheckpoint(session, 71L, 9L, payload) { _, error ->
                recoveryError = error
                finished.countDown()
            }
            assertTrue(finished.await(30, TimeUnit.SECONDS))
            assertNotNull("New worker must reject automatic DEBUG recovery",
                recoveryError)

            // Even a different, apparently fresh session cannot bypass a
            // failed restart readback by switching the session identity.
            val freshDone = CountDownLatch(1)
            var freshError: String? = null
            worker.debugCheckpoint(
                "DBG_NEW_${android.os.SystemClock.elapsedRealtimeNanos()}",
                1L, 0L, payload
            ) { _, error ->
                freshError = error
                freshDone.countDown()
            }
            assertTrue(freshDone.await(30, TimeUnit.SECONDS))
            assertEquals("DEBUG_SESSION_PAUSED", freshError)
        } finally {
            context.unbindService(secondConnection)
        }
    }

}
