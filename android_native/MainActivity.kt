package vn.navitaximeter

import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.location.LocationManager
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Only an Activity in RESUMED state may start the safety FGS.
 * This prevents accidental background starts on Android 14+.
 */
class MainActivity : FlutterActivity() {
    private var resumed = false
    private val channelName = "vn.navitaximeter/safety_location_service"
    private val notificationRequestCode = 8106

    override fun onResume() {
        super.onResume()
        resumed = true
    }

    override fun onPause() {
        resumed = false
        super.onPause()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "status" -> result.success(LocationSafetyService.snapshot())
                    "ownerStatus" -> result.success(LocationOwnerRegistry.snapshot())
                    "acquire" -> {
                        val owner = call.argument<String>("owner")
                        if (!resumed) {
                            result.error("NOT_VISIBLE", "Activity must be resumed", null)
                        } else if (owner != "preview" && owner != "lab") {
                            result.error("INVALID_OWNER", "Only test GPS modes may claim", null)
                        } else {
                            val lease = LocationOwnerRegistry.claim(owner)
                            if (lease == null) {
                                result.error("GPS_BUSY", "Location service already owned", null)
                            } else {
                                result.success(mapOf("owner" to owner, "leaseId" to lease))
                            }
                        }
                    }
                    "release" -> {
                        val owner = call.argument<String>("owner")
                        val lease = call.argument<Number>("leaseId")?.toLong()
                        result.success(
                            if (owner == null || lease == null) false
                            else LocationOwnerRegistry.release(owner, lease)
                        )
                    }
                    "start" -> {
                        if (!resumed) {
                            result.error("NOT_VISIBLE", "Activity must be visible", null)
                            return@setMethodCallHandler
                        }
                        val fine = checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) ==
                            PackageManager.PERMISSION_GRANTED
                        val coarse = checkSelfPermission(Manifest.permission.ACCESS_COARSE_LOCATION) ==
                            PackageManager.PERMISSION_GRANTED
                        if (!fine && !coarse) {
                            result.error("LOCATION_PERMISSION", "Location permission needed", null)
                            return@setMethodCallHandler
                        }
                        val lm = getSystemService(LOCATION_SERVICE) as LocationManager
                        val enabled = (fine && lm.isProviderEnabled(LocationManager.GPS_PROVIDER)) ||
                            lm.isProviderEnabled(LocationManager.NETWORK_PROVIDER)
                        if (!enabled) {
                            result.error("LOCATION_DISABLED", "Enable device location", null)
                            return@setMethodCallHandler
                        }
                        if (Build.VERSION.SDK_INT >= 33 &&
                            checkSelfPermission(Manifest.permission.POST_NOTIFICATIONS) !=
                            PackageManager.PERMISSION_GRANTED
                        ) {
                            requestPermissions(
                                arrayOf(Manifest.permission.POST_NOTIFICATIONS),
                                notificationRequestCode
                            )
                            result.error("NOTIFICATION_PERMISSION",
                                "Allow notifications, then tap Start again", null)
                            return@setMethodCallHandler
                        }
                        val lease = LocationOwnerRegistry.claim("native_safety")
                        if (lease == null) {
                            result.error("GPS_BUSY", "Location service already owned", null)
                            return@setMethodCallHandler
                        }
                        try {
                            val intent = Intent(this, LocationSafetyService::class.java)
                                .setAction(LocationSafetyService.ACTION_START)
                                .putExtra(LocationSafetyService.EXTRA_LEASE_ID, lease)
                            if (Build.VERSION.SDK_INT >= 26) {
                                startForegroundService(intent)
                            } else {
                                startService(intent)
                            }
                            // Dispatch is NOT startup ACK: verify status & heartbeat.
                            result.success(mapOf("requestAccepted" to true, "leaseId" to lease))
                        } catch (e: Exception) {
                            LocationOwnerRegistry.release("native_safety", lease)
                            result.error("FGS_START_FAILED", e.message, null)
                        }
                    }
                    "stop" -> {
                        val expected = call.argument<Number>("leaseId")?.toLong()
                        if (expected == null || expected <= 0L) {
                            result.error("LEASE_REQUIRED", "Exact safety lease required", null)
                            return@setMethodCallHandler
                        }
                        if (!LocationOwnerRegistry.matches("native_safety", expected)) {
                            result.success(false)
                            return@setMethodCallHandler
                        }
                        try {
                            stopService(Intent(this, LocationSafetyService::class.java))
                            // Destroy releases a live service. Only a still-pending
                            // request may be invalidated here, with its exact token.
                            if (LocationSafetyService.snapshot()["active"] != true) {
                                LocationOwnerRegistry.cancelPendingSafety(expected)
                            }
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("FGS_STOP_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
