package com.dhandha.swing.swing_live

import android.content.Context
import android.os.Build
import android.os.PowerManager
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.view.SurfaceHolder
import android.view.WindowManager
import android.content.Intent
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import com.pedro.library.rtmp.RtmpCamera2
import com.pedro.library.view.OpenGlView
import com.pedro.encoder.input.video.CameraHelper
import com.pedro.encoder.input.gl.render.filters.`object`.ImageObjectFilterRender
import com.pedro.encoder.input.gl.render.filters.AndroidViewFilterRender
import com.pedro.encoder.utils.gl.TranslateTo
import com.pedro.common.ConnectChecker
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import org.json.JSONObject

class MainActivity : FlutterActivity(), ConnectChecker {
    private val TAG = "SwingElite"
    private val CHANNEL = "com.dhandha.swing/camera"
    private val EVENT_CHANNEL = "com.dhandha.swing/camera/events"

    private var rtmpCamera: RtmpCamera2? = null
    private var cameraInstanceId = 0

    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    // Thermal-status listener kept at class scope so onCancel can
    // unregister it. API 29+ only — null on older devices.
    private var thermalListener: PowerManager.OnThermalStatusChangedListener? = null

    private var streamWidth = 1920
    private var streamHeight = 1080
    private var streamFps = 30
    private var streamBitrate = 4000000
    private var streamIsVertical = true
    private var previewRequested = false
    private var surfaceCreated = false

    // Live overlay filter — Pedro composites this bitmap on every encoded
    // frame so YouTube viewers actually see the scorebar/event flashes.
    // Re-used (setImage swapped in place) instead of recreated each tick to
    // avoid GL allocation churn during long matches.
    // Legacy bitmap-based overlay filter — kept for the `setOverlayBitmap`
    // method handler that older Dart builds still call. The active code
    // path uses [overlayViewFilter] below.
    private var overlayFilter: ImageObjectFilterRender? = null
    private var overlayBitmap: Bitmap? = null

    // Active overlay: an Android View hosted off-screen and rendered into
    // the encoded frame by Pedro's AndroidViewFilterRender. Standard
    // Android text/image rasterisation = pixel-perfect at 1920×1080,
    // hardware accelerated by the view system, no bitmap shuffling over
    // MethodChannel. Future Rive animations drop into the view tree as
    // a RiveAnimationView child.
    private var overlayView: BroadcastOverlayView? = null
    private var overlayViewFilter: AndroidViewFilterRender? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Ensure the activity window itself is black to prevent bleed-through
        window.setBackgroundDrawable(android.graphics.drawable.ColorDrawable(android.graphics.Color.BLACK))

        flutterEngine.platformViewsController.registry.registerViewFactory(
            "com.dhandha.swing/camera_view", CameraViewFactory()
        )
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            handleMethodCall(call, result)
        }
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) { eventSink = events }
            override fun onCancel(arguments: Any?) { eventSink = null }
        })

        // Thermal-status stream. Cricket streams run for hours — Studio
        // Mode subscribes here to auto-throttle resolution/fps when the
        // SoC gets hot. Pre-Q devices just get a single 0 (NONE) and no
        // listener is registered.
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, "swing.thermal").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                    val listener = PowerManager.OnThermalStatusChangedListener { status ->
                        mainHandler.post { events?.success(status) }
                    }
                    thermalListener = listener
                    pm.addThermalStatusListener(mainExecutor, listener)
                    // Emit the current level immediately so Dart doesn't
                    // wait for the next OS transition.
                    mainHandler.post { events?.success(pm.currentThermalStatus) }
                } else {
                    mainHandler.post { events?.success(0) }
                }
            }
            override fun onCancel(arguments: Any?) {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                    val pm = getSystemService(Context.POWER_SERVICE) as PowerManager
                    thermalListener?.let { pm.removeThermalStatusListener(it) }
                }
                thermalListener = null
            }
        })
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                streamWidth = call.argument<Int>("width") ?: 1920
                streamHeight = call.argument<Int>("height") ?: 1080
                streamFps = call.argument<Int>("fps") ?: 30
                streamBitrate = call.argument<Int>("bitrate") ?: 4000000
                streamIsVertical = call.argument<Boolean>("isVertical") ?: true
                
                // Bump the generation. Any subsequent calls from an older
                // SwingCamera bridge instance (e.g. a delayed dispose()
                // during hard-resume) will be ignored if they don't match
                // this ID.
                val id = ++cameraInstanceId
                
                Log.d(TAG, "initialize: new instanceId=$id dims=${streamWidth}x${streamHeight}")

                if (surfaceCreated) {
                    mainHandler.post {
                        eventSink?.success(mapOf("type" to "previewReady"))
                    }
                }
                result.success(mapOf("status" to "ok", "instanceId" to id))
            }
            "startPreview" -> {
                previewRequested = true
                startCameraPreview()
                result.success(null)
            }
            "startStreaming" -> {
                val url = call.argument<String>("url") ?: ""
                // Pedro's prepareVideo(width, height, fps, bitrate, rotation)
                // expects rotation = CameraHelper.getCameraOrientation(activity).
                // That helper combines the camera sensor orientation with the
                // current Display.getRotation() and yields the exact number of
                // degrees needed to make the sensor frame upright for the
                // device's current physical orientation.
                //
                // Why this matters: a hardcoded `if (vertical) 90 else 0`
                // only works for landscape-LEFT. In landscape-RIGHT we need
                // 180°; in portrait-down we need 270°. Otherwise content
                // shows up rotated 90° or upside down on YouTube.
                //
                // Pedro also internally SWAPS width/height when rotation is
                // 90 or 270, so we always pass landscape capture dims
                // (1920×1080) and Pedro emits portrait if the rotation
                // calls for it.
                val rotation = CameraHelper.getCameraOrientation(this@MainActivity)
                Log.d(TAG, "startStreaming: computed rotation=$rotation isVertical=$streamIsVertical dims=${streamWidth}x${streamHeight}")

                val cam = rtmpCamera
                if (cam == null) {
                    result.error("STREAM_ERROR", "Camera not initialized", null)
                    return
                }
                if (!surfaceCreated) {
                    result.error("STREAM_ERROR", "GL surface not ready", null)
                    return
                }

                // Stop any existing stream from a prior session.
                try { 
                    if (cam.isStreaming) {
                        Log.d(TAG, "startStreaming: stopping already-running stream")
                        cam.stopStream() 
                    }
                } catch (t: Throwable) {
                    Log.w(TAG, "startStreaming: stopStream failed: ${t.message}")
                }

                // Use HEVC (H.265) for better thermal efficiency and quality
                try {
                    Log.d(TAG, "startStreaming: setting H.265 codec")
                    cam.setVideoCodec(com.pedro.common.VideoCodec.H265)
                } catch (t: Throwable) {
                    Log.w(TAG, "startStreaming: could not set H.265: ${t.message}")
                }

                // Advanced Tuning: Long GOP for thermal savings was attempted via
                // `cam.setGop(...)` but that method doesn't exist on RtmpCamera2 in
                // Pedro 2.5.2 — keyframe interval is controlled internally by
                // prepareVideo's default 2s GOP. Leaving the optimisation as a TODO
                // until we upgrade Pedro or thread the encoder directly.

                // NOTE: do NOT call cam.stopPreview() here. Pedro's
                // `stopStream` does not kill the camera — preview stays
                // alive across pause/resume. The earlier stopPreview +
                // sleep + startPreview cycle was thrashing Camera2 and
                // producing the black screen on resume. We trust the
                // existing preview and only kick startPreview below if
                // it genuinely isn't running.

                // Make sure preview is running — pedro needs a live camera
                // source to feed prepareVideo's encoder. Retry up to 3
                // times to absorb Camera2 release-and-reacquire jitter
                // (camera-plugin disposing on the other thread).
                var previewStarted = cam.isOnPreview
                if (!previewStarted) {
                    // PERFORMANCE OPTIMIZATION:
                    // Stream at 1080p but preview at 720p. Rendering 1080p
                    // frames to the phone screen is a major heat source.
                    // Most phone screens don't even benefit from >720p
                    // in a small preview window.
                    val previewWidth = if (streamWidth > 1280) 1280 else streamWidth
                    val previewHeight = if (streamHeight > 720) 720 else streamHeight
                    
                    val previewRotation = rotation
                    // CRITICAL: `return@repeat` is Kotlin's `continue`, not
                    // `break`. We were calling startPreview 3 times even
                    // when the first attempt succeeded — that thrashed the
                    // Camera2 session and left the encoder pointing at a
                    // freshly-recreated camera in a half-initialised state,
                    // which is why pause/resume produced a black feed.
                    // Use a plain for-loop so we can actually break out.
                    for (attempt in 1..3) {
                        try {
                            cam.startPreview(
                                CameraHelper.Facing.BACK,
                                previewWidth,
                                previewHeight,
                                previewRotation,
                            )
                            previewStarted = true
                            Log.d(TAG, "startStreaming: preview started on attempt $attempt dims=${previewWidth}x${previewHeight}")
                            break
                        } catch (t: Throwable) {
                            Log.w(TAG, "startStreaming: preview attempt $attempt failed: ${t.message}")
                            Thread.sleep(250)
                        }
                    }
                }
                if (!previewStarted) {
                    result.error("STREAM_ERROR", "Camera busy — could not start preview", null)
                    return
                }

                if (cam.prepareVideo(streamWidth, streamHeight, streamFps, streamBitrate, rotation) &&
                    cam.prepareAudio()) {
                    // ABR (`setBitrateAdapter`) doesn't exist on RtmpCamera2 in
                    // Pedro 2.5.2. Bitrate adaptation in this build is handled
                    // Dart-side via the reconnect ladder in StreamController.
                    startEliteService()
                    try {
                        cam.startStream(url)
                        result.success(null)
                    } catch (t: Throwable) {
                        Log.e(TAG, "startStream threw", t)
                        result.error("STREAM_ERROR", "startStream: ${t.message}", null)
                    }
                } else {
                    result.error("STREAM_ERROR", "Failed to prepare encoder", null)
                }
            }
            "stopStreaming" -> {
                rtmpCamera?.stopStream()
                rtmpCamera?.stopPreview()
                detachOverlayFilter()
                stopEliteService()
                result.success(null)
            }
            "pauseStream" -> {
                rtmpCamera?.stopStream()
                rtmpCamera?.stopPreview()
                detachOverlayFilter()
                result.success(null)
            }
            "resumeStream" -> {
                result.success(null)
            }
            "setMuted" -> {
                val isMuted = call.argument<Boolean>("isMuted") ?: false
                if (isMuted) rtmpCamera?.disableAudio() else rtmpCamera?.enableAudio()
                result.success(null)
            }
            "setBatteryShield" -> {
                // Future optimization: lower bitrate/fps to save power
                result.success(null)
            }
            "setBitrate" -> {
                val bitrate = call.argument<Int>("bitrate") ?: 4000000
                streamBitrate = bitrate
                rtmpCamera?.setVideoBitrateOnFly(bitrate)
                result.success(null)
            }
            "setOrientation" -> {
                // Just record the desired orientation; it's applied at
                // startStreaming via prepareVideo(rotation=...). Restarting the
                // preview here causes "Surface was abandoned" races on every
                // device rotation tick — OpenGlView's Fill aspect handles visuals.
                streamIsVertical = call.argument<Boolean>("isVertical") ?: true
                result.success(null)
            }
            "setZoomRatio" -> {
                val ratio = call.argument<Double>("ratio")?.toFloat() ?: 1.0f
                rtmpCamera?.zoom = ratio
                result.success(null)
            }
            "switchCamera" -> {
                rtmpCamera?.switchCamera()
                result.success(null)
            }
            "isPreviewReady" -> {
                // Polled by Dart before startStream. We only require the
                // GL surface to exist — pedro's `isOnPreview` is unreliable
                // during the camera-plugin → pedro handoff (the flag can
                // stay false even though the underlying surface is fine).
                // `startStreaming` below kicks preview itself if needed.
                Log.d(TAG, "isPreviewReady: surfaceCreated=$surfaceCreated cam=${rtmpCamera != null} onPreview=${rtmpCamera?.isOnPreview}")
                result.success(surfaceCreated && rtmpCamera != null)
            }
            "setOverlayState" -> {
                val jsonStr = call.argument<String>("state")
                if (jsonStr == null) {
                    result.error("ARG", "missing state", null)
                    return
                }
                try {
                    ensureOverlayView()
                    mainHandler.post {
                        try {
                            overlayView?.setState(JSONObject(jsonStr))
                        } catch (t: Throwable) {
                            Log.e(TAG, "overlayView.setState failed", t)
                        }
                    }
                    result.success(null)
                } catch (t: Throwable) {
                    Log.e(TAG, "setOverlayState failed", t)
                    result.error("OVERLAY", t.message, null)
                }
            }
            "triggerOverlayEvent" -> {
                val jsonStr = call.argument<String>("event")
                if (jsonStr == null) {
                    result.error("ARG", "missing event", null)
                    return
                }
                try {
                    ensureOverlayView()
                    mainHandler.post {
                        try {
                            overlayView?.triggerEvent(JSONObject(jsonStr))
                        } catch (t: Throwable) {
                            Log.e(TAG, "overlayView.triggerEvent failed", t)
                        }
                    }
                    result.success(null)
                } catch (t: Throwable) {
                    Log.e(TAG, "triggerOverlayEvent failed", t)
                    result.error("OVERLAY", t.message, null)
                }
            }
            "setOverlayActive" -> {
                // false → tear down (called on stop/pause).
                // true  → ensure view exists; filter attaches on
                //         onConnectionSuccess once GL/encoder is live.
                val active = call.argument<Boolean>("active") ?: false
                if (!active) {
                    releaseOverlayFilter()
                    overlayView?.reset()
                    overlayView = null
                } else {
                    ensureOverlayView()
                    // If we're already live (match paired mid-stream), attach now.
                    if (rtmpCamera?.isStreaming == true) {
                        mainHandler.post { attachOverlayFilter() }
                    }
                }
                result.success(null)
            }
            "setOverlayBitmap" -> {
                // Dart pushes a RGBA-encoded snapshot of the overlay subtree
                // every ~1000ms. We decode + swap it into the GL filter chain
                // so it's composited on the encoded video stream. Passing
                // null tears the filter down (called on stop/pause).
                val bytes = call.argument<ByteArray>("bytes")
                val width = call.argument<Int>("width") ?: 0
                val height = call.argument<Int>("height") ?: 0
                val cam = rtmpCamera
                if (cam == null) {
                    result.success(null)
                    return
                }
                if (bytes == null || width == 0 || height == 0) {
                    overlayFilter?.let {
                        try { cam.glInterface.removeFilter(it) } catch (_: Throwable) {}
                    }
                    overlayFilter = null
                    result.success(null)
                    return
                }
                try {
                    var bmp = overlayBitmap
                    if (bmp == null || bmp.width != width || bmp.height != height) {
                        bmp = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                        overlayBitmap = bmp
                    }
                    bmp.copyPixelsFromBuffer(java.nio.ByteBuffer.wrap(bytes))
                    var filter = overlayFilter
                    if (filter == null) {
                        filter = ImageObjectFilterRender()
                        overlayFilter = filter
                        cam.glInterface.addFilter(filter)
                        filter.setScale(100f, 100f)
                        filter.setPosition(TranslateTo.CENTER)
                        Log.d(TAG, "setOverlayBitmap: filter attached, first bitmap ${bmp.width}x${bmp.height}")
                    }
                    filter.setImage(bmp)
                    result.success(null)
                } catch (t: Throwable) {
                    Log.e(TAG, "setOverlayBitmap failed", t)
                    result.error("OVERLAY", t.message, null)
                }
            }
            "resetCamera" -> {
                try {
                    rtmpCamera?.stopStream()
                    rtmpCamera?.stopPreview()
                    releaseOverlayFilter()
                    rtmpCamera = null
                    surfaceCreated = false
                    cameraInstanceId = 0
                    Log.d(TAG, "resetCamera: RtmpCamera2 + filter released, ID reset")
                } catch (t: Throwable) {
                    Log.w(TAG, "resetCamera: $t")
                }
                result.success(null)
            }
            "dispose" -> {
                val id = call.argument<Int>("instanceId") ?: 0
                if (id == 0 || id == cameraInstanceId) {
                    Log.d(TAG, "dispose: instanceId=$id matches active ($cameraInstanceId) -> stopping preview")
                    rtmpCamera?.stopPreview()
                } else {
                    Log.d(TAG, "dispose: IGNORING stale dispose (id=$id, active=$cameraInstanceId)")
                }
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    /** Create the overlay View (if not yet built). Idempotent. */
    private fun ensureOverlayView() {
        if (overlayView != null) return
        overlayView = BroadcastOverlayView(this@MainActivity)
        Log.d(TAG, "overlay view created")
    }

    /** Attach the AndroidViewFilterRender to Pedro's active filter chain.
     *  Called from `onConnectionSuccess` so the GL/encoder is live by then. */
    private fun attachOverlayFilter() {
        val cam = rtmpCamera ?: run {
            Log.w(TAG, "attachOverlayFilter: rtmpCamera null")
            return
        }
        val view = overlayView ?: run {
            Log.w(TAG, "attachOverlayFilter: overlayView null")
            return
        }

        try {
            // ALWAYS create a fresh filter instance when attaching. Pedro's
            // filters (especially AndroidViewFilterRender) are tied to the
            // GL context they were created in. Re-using one across a
            // stopStream/startStream cycle results in black frames because
            // the internal GL textures are tied to the old context.
            releaseOverlayFilter() // Ensure clean slate
            
            val filter = AndroidViewFilterRender().apply {
                setHardwareMode(false) // Software mode for off-screen views
                setScale(100f, 100f)
                setPosition(TranslateTo.CENTER)
                setView(view)
            }
            cam.glInterface.addFilter(filter)
            overlayViewFilter = filter
            
            // Force-invalidate the view so its current state pushes
            // through the freshly-attached filter.
            view.invalidate()
            Log.d(TAG, "overlay AndroidViewFilterRender CREATED and ATTACHED")
        } catch (t: Throwable) {
            Log.e(TAG, "attachOverlayFilter failed", t)
        }
    }

    private fun detachOverlayFilter() {
        val cam = rtmpCamera
        val filter = overlayViewFilter
        
        if (filter != null) {
            if (cam != null) {
                try {
                    cam.glInterface.removeFilter(filter)
                } catch (t: Throwable) {
                    Log.w(TAG, "removeFilter failed: $t")
                }
            }
            
            // To prevent "Error during updateTexImage" (GL thread still 
            // drawing) and "Surface was not locked" (HandlerThread still 
            // capturing), we must decouple the removal from the release.
            // 1. We've already removed it from the chain above.
            // 2. We null the reference so no new calls use it.
            overlayViewFilter = null

            // 3. We release the internal resources after a delay to ensure
            // the GL thread has finished its current frame and seen the removal.
            val filterToRelease = filter
            mainHandler.postDelayed({
                try {
                    filterToRelease.release()
                    Log.d(TAG, "overlay filter RELEASED after safety delay")
                } catch (t: Throwable) {
                    Log.w(TAG, "filter.release failed: $t")
                }
            }, 1000)
            
            Log.d(TAG, "overlay filter REMOVED from chain (release scheduled)")
        }

        // Also drop the legacy bitmap filter if it was attached.
        overlayFilter?.let {
            if (cam != null) {
                try { cam.glInterface.removeFilter(it) } catch (_: Throwable) {}
            }
            overlayFilter = null
            overlayBitmap = null
        }
    }

    /** Hard release of GL resources. Idempotent. */
    private fun releaseOverlayFilter() {
        detachOverlayFilter()
        // detachOverlayFilter already nulls/releases overlayViewFilter
        overlayFilter = null
        overlayBitmap = null
    }

    private fun startCameraPreview() {
        val camera = rtmpCamera ?: return
        if (!camera.isOnPreview && surfaceCreated) {
            // Use 720p for preview to save heat, even if stream is 1080p
            val previewWidth = if (streamWidth > 1280) 1280 else streamWidth
            val previewHeight = if (streamHeight > 720) 720 else streamHeight
            
            // Use Pedro's CameraHelper, which reads Display.getRotation()
            // and combines it with the sensor orientation. Works correctly
            // for portrait, portrait-down, landscape-left, landscape-right.
            val previewRotation = CameraHelper.getCameraOrientation(this@MainActivity)
            try {
                camera.startPreview(
                    CameraHelper.Facing.BACK,
                    previewWidth,
                    previewHeight,
                    previewRotation,
                )
                Log.d(TAG, "startCameraPreview: rotation=$previewRotation dims=${previewWidth}x${previewHeight}")
            } catch (t: Throwable) {
                Log.e(TAG, "startCameraPreview FAILED", t)
            }
            mainHandler.post {
                eventSink?.success(mapOf("type" to "previewReady"))
            }
        } else {
            Log.d(TAG, "startCameraPreview: skipped (onPreview=${camera.isOnPreview} surfaceCreated=$surfaceCreated)")
        }
    }

    private fun startEliteService() {
        startService(Intent(this, StreamForegroundService::class.java))
    }

    private fun stopEliteService() {
        stopService(Intent(this, StreamForegroundService::class.java))
    }

    inner class CameraViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        override fun create(context: Context, viewId: Int, args: Any?): PlatformView = CameraPlatformView(context)
    }

    inner class CameraPlatformView(context: Context) : PlatformView, SurfaceHolder.Callback {
        private val view: OpenGlView = OpenGlView(context)
        // True if we need to call rtmpCamera.replaceView(view) once the
        // SurfaceTexture is actually created. Calling replaceView before
        // surfaceCreated throws NPE inside pedro because
        // OpenGlView.getSurfaceTexture() returns null until the underlying
        // GL surface comes up.
        private var pendingReplace = false

        init {
            view.layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
            // Use Adjust mode to avoid 'zoom' (cropping). 
            // It will letterbox if the view size doesn't match perfectly.
            // Fill = crop to fill the view bounds. Phone screens in
            // landscape are ~19.5:9 but the camera captures 16:9, so
            // `Adjust` letterboxed the camera into a smaller centred
            // box. `Fill` crops a bit off top/bottom but feels like a
            // real viewfinder. The encoded YouTube output stays 16:9
            // either way — this only affects the in-app preview.
            view.setAspectRatioMode(com.pedro.encoder.utils.gl.AspectRatioMode.Fill)
            view.holder.addCallback(this)
            view.setZOrderMediaOverlay(true)

            val camera = rtmpCamera
            if (camera == null) {
                // First mount of pedro view: create RtmpCamera2 *with* the
                // view so it binds once the surface arrives.
                val cam = RtmpCamera2(view, this@MainActivity)
                rtmpCamera = cam
                // `setLogs(true)` doesn't exist on RtmpCamera2 in Pedro 2.5.2 —
                // pedro logging is controlled at the SDK level, not per-camera.
            } else {
                // Remount: defer replaceView until surfaceCreated fires.
                pendingReplace = true
            }
        }

        override fun getView(): View = view
        override fun surfaceCreated(holder: SurfaceHolder) {
            surfaceCreated = true
            if (pendingReplace) {
                pendingReplace = false
                try {
                    rtmpCamera?.replaceView(view)
                } catch (t: Throwable) {
                    Log.e(TAG, "replaceView failed", t)
                }
            }
            mainHandler.post {
                startCameraPreview()
            }
        }
        override fun surfaceChanged(holder: SurfaceHolder, f: Int, w: Int, h: Int) {}
        override fun surfaceDestroyed(holder: SurfaceHolder) {
            Log.d(TAG, "surfaceDestroyed: releasing surface state")
            surfaceCreated = false
            // Kill any active filter rendering before the GL surface is gone.
            detachOverlayFilter()
            rtmpCamera?.stopPreview()
        }
        override fun dispose() {
            // Native cleanup handled by OS
        }
    }

    override fun onConnectionStarted(url: String) {}
    override fun onConnectionSuccess() {
        mainHandler.post {
            eventSink?.success(mapOf("type" to "connected"))
            // GL/encoder is now live → attach the overlay filter to the
            // active filter chain. Doing this before startStream caused
            // filters to silently no-op in Pedro 2.5.2.
            attachOverlayFilter()
        }
    }
    override fun onConnectionFailed(reason: String) {
        stopEliteService()
        mainHandler.post {
            // Don't detach the filter here — Pedro's reconnect ladder
            // will retry the same stream. Keep the filter ready in the
            // chain so the overlay reappears the instant we're back.
            // Explicit detach happens only on user-driven stopStreaming.
            eventSink?.success(mapOf("type" to "connectionFailed", "message" to reason))
        }
    }
    override fun onDisconnect() {
        stopEliteService()
        mainHandler.post {
            // Same reasoning as onConnectionFailed — the OpenGlView's
            // filter chain survives a disconnect, and on reconnect we
            // want the overlay back instantly without re-init churn.
            eventSink?.success(mapOf("type" to "disconnected"))
        }
    }
    override fun onAuthError() {}
    override fun onAuthSuccess() {}

    override fun onDestroy() {
        releaseOverlayFilter()
        rtmpCamera?.stopStream()
        rtmpCamera?.stopPreview()
        rtmpCamera = null
        super.onDestroy()
    }
}
