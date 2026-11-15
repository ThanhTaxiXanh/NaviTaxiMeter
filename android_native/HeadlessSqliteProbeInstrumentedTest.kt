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
        } finally {
            context.unbindService(connection)
        }
    }
}
