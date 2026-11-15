package vn.navitaximeter

import android.app.Service
import android.content.Intent
import android.os.Binder
import android.os.Handler
import android.os.IBinder
import android.os.Looper
import io.flutter.FlutterInjector
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.engine.dart.DartExecutor
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

/**
 * DEBUG-MANIFEST ONLY, bound-service lifecycle spike (issue #3).
 *
 * No location permission, location foreground service, GNSS, tariff,
 * real-trip database or production ACK. It owns one headless FlutterEngine
 * and can only call a Dart method that writes a separate probe-only DB.
 * A bound service here is NOT proof of a service surviving Doze/OEM/kill.
 */
class HeadlessSqliteProbeService : Service() {
    companion object {
        const val CHANNEL = "vn.navitaximeter/headless_sqlite_probe"
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private val binder = ProbeBinder()
    @Volatile private var ready = false
    private var engine: FlutterEngine? = null
    private var channel: MethodChannel? = null

    inner class ProbeBinder : Binder() {
        fun isReady(): Boolean = ready

        fun writeAndRead(callback: (Any?, String?) -> Unit) {
            mainHandler.post {
                val endpoint = channel
                if (!ready || endpoint == null) {
                    callback(null, "DART_WORKER_NOT_READY")
                    return@post
                }
                endpoint.invokeMethod("writeAndRead", null, object : MethodChannel.Result {
                    override fun success(result: Any?) = callback(result, null)
                    override fun error(code: String, message: String?, details: Any?) {
                        callback(null, "$code: ${message ?: "unknown"}")
                    }
                    override fun notImplemented() = callback(null, "NOT_IMPLEMENTED")
                })
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder = binder

    override fun onCreate() {
        super.onCreate()
        val loader = FlutterInjector.instance().flutterLoader()
        loader.startInitialization(applicationContext)
        loader.ensureInitializationComplete(applicationContext, null)

        val ownedEngine = FlutterEngine(applicationContext)
        engine = ownedEngine
        val endpoint = MethodChannel(ownedEngine.dartExecutor.binaryMessenger, CHANNEL)
        channel = endpoint
        endpoint.setMethodCallHandler { call: MethodCall, result: MethodChannel.Result ->
            if (call.method == "ready") {
                ready = true
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
        ownedEngine.dartExecutor.executeDartEntrypoint(
            DartExecutor.DartEntrypoint(
                loader.findAppBundlePath(), "headlessSqliteProbeMain"
            )
        )
    }

    override fun onDestroy() {
        ready = false
        channel?.setMethodCallHandler(null)
        channel = null
        engine?.destroy()
        engine = null
        super.onDestroy()
    }
}
