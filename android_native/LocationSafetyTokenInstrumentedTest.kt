package vn.navitaximeter

import android.Manifest
import android.app.NotificationManager
import android.app.PendingIntent
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.location.LocationManager
import android.os.Build
import android.os.SystemClock
import androidx.test.core.app.ActivityScenario
import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Real Android location-FGS lifecycle/notification regression on a disposable
 * test emulator. No fake GNSS fix, fare, trip DB, or coordinates are used.
 *
 * Permissions are granted by the Android instrumentation runner on its test
 * emulator, NOT bypassed in the service or automatically granted to users.
 * These tests do not certify physical GNSS or production trip ownership.
 */
@RunWith(AndroidJUnit4::class)
class LocationSafetyTokenInstrumentedTest {
    private val instrumentation = InstrumentationRegistry.getInstrumentation()
    private val context: Context get() = instrumentation.targetContext

    private fun waitUntil(
        description: String,
        timeoutMs: Long = 15_000L,
        condition: () -> Boolean
    ) {
        val deadline = SystemClock.elapsedRealtime() + timeoutMs
        while (SystemClock.elapsedRealtime() < deadline) {
            if (condition()) return
            Thread.sleep(100L)
        }
        assertTrue("Timed out: $description", condition())
    }

    private fun prepareAuthorizedEmulatorPermissions() {
        val packageName = context.packageName
        // Valid OS runtime permission grants only, restricted to instrumentation.
        val grant = instrumentation.uiAutomation
        grant.grantRuntimePermission(packageName, Manifest.permission.ACCESS_COARSE_LOCATION)
        grant.grantRuntimePermission(packageName, Manifest.permission.ACCESS_FINE_LOCATION)
        if (Build.VERSION.SDK_INT >= 33) {
            grant.grantRuntimePermission(packageName, Manifest.permission.POST_NOTIFICATIONS)
        }
        assertEquals(
            PackageManager.PERMISSION_GRANTED,
            context.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION)
        )
        val manager = context.getSystemService(Context.LOCATION_SERVICE) as LocationManager
        assertTrue(
            "Location provider must be enabled on test emulator; no bypass",
            manager.isProviderEnabled(LocationManager.GPS_PROVIDER)
        )
    }

    private fun startIntent(lease: Long) =
        Intent(context, LocationSafetyService::class.java)
            .setAction(LocationSafetyService.ACTION_START)
            .putExtra(LocationSafetyService.EXTRA_LEASE_ID, lease)

    private fun stopServiceFrom(activity: MainActivity) {
        activity.stopService(Intent(activity, LocationSafetyService::class.java))
    }

    private fun awaitStopped() {
        waitUntil("service teardown must release its own native lease") {
            LocationOwnerRegistry.currentOwner() == "none" &&
                LocationSafetyService.snapshot()["active"] == false
        }
        assertEquals(false, LocationSafetyService.snapshot()["acknowledged"])
    }

    private fun awaitServiceAck(lease: Long) {
        waitUntil("matching service heartbeat for current lease") {
            val status = LocationSafetyService.snapshot()
            status["active"] == true &&
                status["acknowledged"] == true &&
                status["leaseId"] == lease &&
                status["owner"] == "native_safety"
        }
        assertEquals(false, LocationSafetyService.snapshot()["billingEnabled"])
        assertEquals(false, LocationSafetyService.snapshot()["coordinatesExported"])
    }

    @Test
    fun savedRealNotificationStopFromOldLeaseCannotStopNewFgService() {
        prepareAuthorizedEmulatorPermissions()
        assertEquals("none", LocationOwnerRegistry.currentOwner())
        ActivityScenario.launch(MainActivity::class.java).use { scenario ->
            try {
                val oldLease = requireNotNull(LocationOwnerRegistry.claim("native_safety"))
                scenario.onActivity { activity ->
                    activity.startForegroundService(startIntent(oldLease))
                }
                awaitServiceAck(oldLease)

                val notifications = context.getSystemService(
                    Context.NOTIFICATION_SERVICE
                ) as NotificationManager
                var oldStop: PendingIntent? = null
                waitUntil("old notification must expose a real PendingIntent STOP") {
                    oldStop = notifications.activeNotifications
                        .firstOrNull { it.id == 8104 }
                        ?.notification?.actions
                        ?.firstOrNull { it.title.toString() == "Dừng GPS an toàn" }
                        ?.actionIntent
                    oldStop != null
                }
                val savedOldStop = requireNotNull(oldStop)

                // End the old service normally; onDestroy releases the lease.
                scenario.onActivity { activity -> stopServiceFrom(activity) }
                awaitStopped()

                val newLease = requireNotNull(LocationOwnerRegistry.claim("native_safety"))
                assertTrue("A new generation is required", newLease > oldLease)
                scenario.onActivity { activity ->
                    activity.startForegroundService(startIntent(newLease))
                }
                awaitServiceAck(newLease)

                // This is the PendingIntent saved from the ACTUAL old Android
                // notification, not a handcrafted STOP or the new notification.
                savedOldStop.send()
                Thread.sleep(1000L) // allow Android Service command delivery

                assertTrue(LocationOwnerRegistry.matches("native_safety", newLease))
                assertFalse(LocationOwnerRegistry.safetyStopRequested(newLease))
                assertNull(LocationOwnerRegistry.claim("preview"))
                assertNull(LocationOwnerRegistry.claim("lab"))
                awaitServiceAck(newLease)
            } finally {
                scenario.onActivity { activity -> stopServiceFrom(activity) }
                awaitStopped()
            }
        }
    }

    @Test
    fun preAckStopKeepsLeaseUntilTeardownAndRejectsStaleStart() {
        prepareAuthorizedEmulatorPermissions()
        assertEquals("none", LocationOwnerRegistry.currentOwner())
        ActivityScenario.launch(MainActivity::class.java).use { scenario ->
            try {
                val pendingLease = requireNotNull(LocationOwnerRegistry.claim("native_safety"))
                // Simulate cancellation after native reservation, BEFORE
                // onStartCommand gets its first chance to publish an ACK.
                assertTrue(LocationOwnerRegistry.requestSafetyStop(pendingLease))
                assertNull(LocationOwnerRegistry.claim("preview"))
                assertNull(LocationOwnerRegistry.claim("lab"))
                assertFalse(LocationSafetyService.snapshot()["acknowledged"] as Boolean)
                scenario.onActivity { activity ->
                    activity.startForegroundService(startIntent(pendingLease))
                }
                awaitStopped()
                assertEquals(false, LocationSafetyService.snapshot()["fresh"])

                val nextLease = requireNotNull(LocationOwnerRegistry.claim("native_safety"))
                assertTrue(nextLease > pendingLease)
                scenario.onActivity { activity ->
                    activity.startForegroundService(startIntent(nextLease))
                }
                awaitServiceAck(nextLease)

                // An old queued START cannot tear down the newer live service.
                scenario.onActivity { activity ->
                    activity.startService(startIntent(pendingLease))
                }
                Thread.sleep(1000L)
                assertFalse(LocationOwnerRegistry.safetyStopRequested(nextLease))
                assertNull(LocationOwnerRegistry.claim("preview"))
                awaitServiceAck(nextLease)
            } finally {
                scenario.onActivity { activity -> stopServiceFrom(activity) }
                awaitStopped()
            }
        }
    }
}
