package vn.navitaximeter

import android.Manifest
import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.PendingIntent
import android.app.Service
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.content.pm.ServiceInfo
import android.location.Location
import android.location.LocationListener
import android.location.LocationManager
import android.os.Build
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import android.os.SystemClock

/**
 * Independently owned, safety-only location foreground service.
 *
 * It observes Android LocationManager GPS updates and exposes aggregate health.
 * It NEVER calculates a fare, sends coordinates to Flutter, or writes SQLite.
 * Activity backgrounding cannot start or restart it. START_NOT_STICKY prevents
 * silent OS restarts after process death. Stop from the persistent notification.
 */
class LocationSafetyService : Service(), LocationListener {
    companion object {
        const val ACTION_START = "vn.navitaximeter.action.SAFETY_START"
        const val ACTION_STOP = "vn.navitaximeter.action.SAFETY_STOP"
        const val EXTRA_LEASE_ID = "locationOwnerLeaseId"
        private const val CHANNEL = "navi_gps_safety_v1"
        private const val NOTIFICATION_ID = 8104

        @Volatile private var active = false
        @Volatile private var acceptedCount = 0L
        @Volatile private var latestAcceptedElapsedMs = 0L
        @Volatile private var state = "stopped"
        @Volatile private var serviceLeaseId = -1L
        @Volatile private var lastHeartbeatElapsedMs = 0L

        fun snapshot(): Map<String, Any> {
            val last = latestAcceptedElapsedMs
            val age = if (last == 0L) -1L else
                (SystemClock.elapsedRealtime() - last).coerceAtLeast(0L)
            val heartbeatTime = lastHeartbeatElapsedMs
            val heartbeatAge = if (heartbeatTime == 0L) -1L else
                (SystemClock.elapsedRealtime() - heartbeatTime).coerceAtLeast(0L)
            val acknowledged = active &&
                LocationOwnerRegistry.matches("native_safety", serviceLeaseId) &&
                heartbeatAge in 0..7000
            return mapOf(
                "active" to active,
                "acknowledged" to acknowledged,
                "owner" to LocationOwnerRegistry.currentOwner(),
                "leaseId" to serviceLeaseId,
                "heartbeatAgeMs" to heartbeatAge,
                "acceptedCount" to acceptedCount,
                "lastTrustedAgeMs" to age,
                "fresh" to (acknowledged && age in 0..12000),
                "state" to state,
                "billingEnabled" to false,
                "coordinatesExported" to false
            )
        }
    }

    private var manager: LocationManager? = null
    private var updatesRegistered = false
    private val heartbeatHandler = Handler(Looper.getMainLooper())
    private val heartbeat = object : Runnable {
        override fun run() {
            if (active && LocationOwnerRegistry.matches("native_safety", serviceLeaseId)) {
                lastHeartbeatElapsedMs = SystemClock.elapsedRealtime()
                heartbeatHandler.postDelayed(this, 3000L)
            } else {
                state = "owner_lost"
                stopSelf()
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder? = null

    private fun hasLocationPermission(): Boolean =
        checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED ||
        checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED

    private fun notification(): Notification {
        val notifications = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        if (Build.VERSION.SDK_INT >= 26) {
            notifications.createNotificationChannel(
                NotificationChannel(
                    CHANNEL, "NaviTaxiMeter · Kiểm thử GPS hệ thống",
                    NotificationManager.IMPORTANCE_LOW
                )
            )
        }

        val stopIntent = Intent(this, LocationSafetyService::class.java).apply {
            action = ACTION_STOP
        }
        val flags = PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        val stopAction = PendingIntent.getService(this, 8105, stopIntent, flags)
        val builder = if (Build.VERSION.SDK_INT >= 26) {
            Notification.Builder(this, CHANNEL)
        } else {
            @Suppress("DEPRECATION")
            Notification.Builder(this)
        }
        return builder
            .setSmallIcon(android.R.drawable.ic_menu_mylocation)
            .setContentTitle("NaviTaxiMeter · Theo dõi an toàn")
            .setContentText("Chỉ đo sức khỏe GPS; KHÔNG tính cước.")
            .setOngoing(true)
            .setShowWhen(false)
            .addAction(android.R.drawable.ic_menu_close_clear_cancel,
                "Dừng GPS an toàn", stopAction)
            .build()
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent?.action == ACTION_STOP) {
            stopSelf()
            return START_NOT_STICKY
        }
        val requestedLease = intent?.getLongExtra(EXTRA_LEASE_ID, -1L) ?: -1L
        if (intent?.action != ACTION_START ||
            !LocationOwnerRegistry.matches("native_safety", requestedLease)
        ) {
            state = "owner_missing"
            stopSelf(startId)
            return START_NOT_STICKY
        }
        if (active && serviceLeaseId == requestedLease) return START_NOT_STICKY
        serviceLeaseId = requestedLease
        if (!hasLocationPermission()) {
            state = "permission_missing"
            stopSelf()
            return START_NOT_STICKY
        }
        val lm = getSystemService(Context.LOCATION_SERVICE) as LocationManager
        val provider = if (checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) ==
            PackageManager.PERMISSION_GRANTED && lm.isProviderEnabled(LocationManager.GPS_PROVIDER)
        ) LocationManager.GPS_PROVIDER else if (
            lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
        ) LocationManager.NETWORK_PROVIDER else null
        if (provider == null) {
            state = "provider_disabled"
            stopSelf()
            return START_NOT_STICKY
        }

        try {
            // Foreground begins before location access; notification is always
            // visible in the OS foreground service manager.
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                startForeground(
                    NOTIFICATION_ID, notification(),
                    ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION
                )
            } else {
                startForeground(NOTIFICATION_ID, notification())
            }
            manager = lm
            acceptedCount = 0L
            latestAcceptedElapsedMs = 0L
            state = "acquiring"
            active = true
            @Suppress("DEPRECATION")
            lm.requestLocationUpdates(provider, 3000L, 0f, this, Looper.getMainLooper())
            updatesRegistered = true
            lastHeartbeatElapsedMs = SystemClock.elapsedRealtime()
            heartbeatHandler.postDelayed(heartbeat, 3000L)
        } catch (_: SecurityException) {
            state = "permission_revoked"
            stopSelf()
        } catch (_: IllegalStateException) {
            state = "service_unavailable"
            stopSelf()
        } catch (_: IllegalArgumentException) {
            state = "provider_unavailable"
            stopSelf()
        }
        return START_NOT_STICKY
    }

    override fun onLocationChanged(location: Location) {
        if (!active || !LocationOwnerRegistry.matches("native_safety", serviceLeaseId) ||
            !hasLocationPermission()) {
            if (!hasLocationPermission()) {
                state = "permission_revoked"
                stopSelf()
            }
            return
        }
        val mock = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            location.isMock
        } else {
            @Suppress("DEPRECATION")
            location.isFromMockProvider
        }
        // Monotonic timing avoids counting a changed device wall clock as GPS.
        val elapsed = SystemClock.elapsedRealtime()
        val gpsAge = elapsed - location.elapsedRealtimeNanos / 1000000L
        if (mock || !location.hasAccuracy() ||
            !location.accuracy.isFinite() || location.accuracy < 0 ||
            location.accuracy > 30f || gpsAge !in 0..12000 ||
            location.latitude !in -90.0..90.0 ||
            location.longitude !in -180.0..180.0
        ) {
            state = "untrusted_gps"
            return
        }
        acceptedCount += 1
        latestAcceptedElapsedMs = elapsed
        state = "trusted_gps"
        // Location latitude/longitude is deliberately never cached, logged,
        // sent over MethodChannel or billed from this safety monitor.
    }

    override fun onProviderDisabled(provider: String) {
        state = "provider_disabled"
        stopSelf()
    }

    override fun onDestroy() {
        heartbeatHandler.removeCallbacks(heartbeat)
        if (updatesRegistered) {
            try { manager?.removeUpdates(this) } catch (_: SecurityException) { }
            updatesRegistered = false
        }
        active = false
        latestAcceptedElapsedMs = 0L
        lastHeartbeatElapsedMs = 0L
        LocationOwnerRegistry.release("native_safety", serviceLeaseId)
        serviceLeaseId = -1L
        state = "stopped"
        super.onDestroy()
    }
}
