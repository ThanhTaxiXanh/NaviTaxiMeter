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
        @Volatile private var destroyedCount = 0L
        fun destructionCount(): Long = destroyedCount
    }

    private val mainHandler = Handler(Looper.getMainLooper())
    private val binder = ProbeBinder()
    private val callbackFence = HeadlessProbeCallbackFence()
    @Volatile private var ready = false
    private var checkpointFaulted = false
    private var debugWriterLease: Long? = null
    private var activeDebugFence: String? = null
    private var engine: FlutterEngine? = null
    private var channel: MethodChannel? = null

    inner class ProbeBinder : Binder() {
        fun isReady(): Boolean = ready

        /**
         * TEST ONLY: actual Kotlin -> headless Dart MethodChannel -> disposable
         * sqflite COMMIT/readback. No location, fares or production trip DB.
         * A timeout or unverified ACK faults this bound-service session.
         */
        fun debugCheckpoint(
            sessionId: String, generation: Long, sequence: Long,
            payloadHash: String, callback: (Any?, String?) -> Unit
        ) {
            mainHandler.post {
                if (!Regex("^DBG_[A-Za-z0-9_-]{1,72}$").matches(sessionId) ||
                    generation <= 0L || sequence < 0L ||
                    !Regex("^[0-9a-f]{64}$").matches(payloadHash)
                ) {
                    callback(null, "INVALID_DEBUG_PROPOSAL")
                    return@post
                }
                if (checkpointFaulted ||
                    debugWriterLease?.let { DebugWriterOwnershipRegistry.matches(it) } != true
                ) {
                    callback(null, "DEBUG_SESSION_PAUSED")
                    return@post
                }
                val requestedFence = "$sessionId/$generation"
                if (activeDebugFence != null && activeDebugFence != requestedFence) {
                    callback(null, "STALE_DEBUG_FENCE")
                    return@post
                }
                val endpoint = channel
                if (!ready || endpoint == null) {
                    callback(null, "DART_WORKER_NOT_READY")
                    return@post
                }
                val id = callbackFence.register(callback)
                if (id == null) {
                    callback(null, "SERVICE_DESTROYED")
                    return@post
                }
                if (activeDebugFence == null) activeDebugFence = requestedFence
                val wire = mapOf(
                    "type" to "debug.checkpoint.proposal.v1",
                    "sessionId" to sessionId,
                    "generation" to generation,
                    "sequence" to sequence,
                    "payloadHash" to payloadHash
                )
                mainHandler.postDelayed({
                    if (callbackFence.resolve(id, null, "DEBUG_ACK_TIMEOUT")) {
                        checkpointFaulted = true
                    }
                }, 20000L)
                try {
                    endpoint.invokeMethod("debugCheckpoint", wire,
                        object : MethodChannel.Result {
                            override fun success(result: Any?) {
                                mainHandler.post {
                                    val ack = result as? Map<*, *>
                                    val valid = ack?.get("type") == "debug.checkpoint.ack.v1" &&
                                        ack["sessionId"] == sessionId &&
                                        (ack["generation"] as? Number)?.toLong() == generation &&
                                        (ack["sequence"] as? Number)?.toLong() == sequence &&
                                        ack["payloadHash"] == payloadHash &&
                                        (ack["checkpointId"] as? String)?.isNotBlank() == true &&
                                        ack["probeOnly"] == true &&
                                        ack["passengerFareEnabled"] == false
                                    if (!valid) checkpointFaulted = true
                                    callbackFence.resolve(
                                        id,
                                        if (valid && !checkpointFaulted) result else null,
                                        if (valid && !checkpointFaulted) null
                                        else "DEBUG_ACK_UNVERIFIED_OR_PAUSED"
                                    )
                                }
                            }
                            override fun error(
                                code: String, message: String?, details: Any?
                            ) {
                                mainHandler.post {
                                    checkpointFaulted = true
                                    callbackFence.resolve(id, null, "DEBUG_WORKER_ERROR: $code")
                                }
                            }
                            override fun notImplemented() {
                                mainHandler.post {
                                    checkpointFaulted = true
                                    callbackFence.resolve(id, null, "DEBUG_METHOD_MISSING")
                                }
                            }
                        })
                } catch (_: RuntimeException) {
                    checkpointFaulted = true
                    callbackFence.resolve(id, null, "DEBUG_CHANNEL_FAILED")
                }
            }
        }


        fun writeAndRead(callback: (Any?, String?) -> Unit) {
            mainHandler.post {
                val endpoint = channel
                if (!ready || endpoint == null) {
                    callback(null, "DART_WORKER_NOT_READY")
                    return@post
                }
                // Register BEFORE dispatch. Any engine teardown fails pending
                // requests; a late Dart callback can never report success.
                val requestId = callbackFence.register(callback)
                if (requestId == null) {
                    callback(null, "SERVICE_DESTROYED")
                    return@post
                }
                try {
                    endpoint.invokeMethod("writeAndRead", null,
                        object : MethodChannel.Result {
                            override fun success(result: Any?) {
                                mainHandler.post {
                                    callbackFence.resolve(requestId, result, null)
                                }
                            }
                            override fun error(
                                code: String, message: String?, details: Any?
                            ) {
                                val description = code +
                                    (if (message.isNullOrBlank()) "" else ": " + message)
                                mainHandler.post {
                                    callbackFence.resolve(requestId, null, description)
                                }
                            }
                            override fun notImplemented() {
                                mainHandler.post {
                                    callbackFence.resolve(requestId, null, "NOT_IMPLEMENTED")
                                }
                            }
                        })
                } catch (_: RuntimeException) {
                    callbackFence.resolve(requestId, null, "DART_CHANNEL_FAILED")
                }
            }
        }
    }

    override fun onBind(intent: Intent?): IBinder = binder

    override fun onCreate() {
        super.onCreate()
        callbackFence.open()
        // A second headless engine in this process must never create a
        // competing SQLite writer. Refuse to launch Dart when lease is held.
        debugWriterLease = DebugWriterOwnershipRegistry.claim()
        if (debugWriterLease == null) {
            checkpointFaulted = true
            return
        }
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
        checkpointFaulted = true
        activeDebugFence = null
        callbackFence.close()
        channel?.setMethodCallHandler(null)
        channel = null
        engine?.destroy()
        engine = null
        debugWriterLease?.let { DebugWriterOwnershipRegistry.release(it) }
        debugWriterLease = null
        destroyedCount += 1
        super.onDestroy()
    }
}
