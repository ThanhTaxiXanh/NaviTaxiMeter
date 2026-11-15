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
                        try {
                            val intent = Intent(this, LocationSafetyService::class.java)
                                .setAction(LocationSafetyService.ACTION_START)
                            if (Build.VERSION.SDK_INT >= 26) {
                                startForegroundService(intent)
                            } else {
                                startService(intent)
                            }
                            // Dispatch only; status() must confirm actual start.
                            result.success(true)
                        } catch (e: Exception) {
                            result.error("FGS_START_FAILED", e.message, null)
                        }
                    }
                    "stop" -> {
                        stopService(Intent(this, LocationSafetyService::class.java))
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
