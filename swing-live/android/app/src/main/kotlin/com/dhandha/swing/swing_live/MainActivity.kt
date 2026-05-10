package com.dhandha.swing.swing_live

import android.content.Context
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
import com.pedro.common.ConnectChecker

class MainActivity : FlutterActivity(), ConnectChecker {
    private val TAG = "SwingElite"
    private val CHANNEL = "com.dhandha.swing/camera"
    private val EVENT_CHANNEL = "com.dhandha.swing/camera/events"

    companion object {
        private var rtmpCamera: RtmpCamera2? = null
    }

    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    private var streamWidth = 1920
    private var streamHeight = 1080
    private var streamFps = 30
    private var streamBitrate = 4000000
    private var streamIsVertical = true
    private var previewRequested = false
    private var surfaceCreated = false

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
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                streamWidth = call.argument<Int>("width") ?: 1920
                streamHeight = call.argument<Int>("height") ?: 1080
                streamFps = call.argument<Int>("fps") ?: 30
                streamBitrate = call.argument<Int>("bitrate") ?: 4000000
                streamIsVertical = call.argument<Boolean>("isVertical") ?: true
                surfaceCreated = false
                result.success(mapOf("status" to "ok"))
            }
            "startPreview" -> {
                previewRequested = true
                startCameraPreview()
                result.success(null)
            }
            "startStreaming" -> {
                val url = call.argument<String>("url") ?: ""
                val encodeWidth  = if (streamIsVertical) streamHeight else streamWidth
                val encodeHeight = if (streamIsVertical) streamWidth  else streamHeight
                val rotation     = if (streamIsVertical) 90 else 0
                
                // Stop any existing stream/preview if we're re-preparing
                rtmpCamera?.stopStream()
                
                if (rtmpCamera?.prepareVideo(encodeWidth, encodeHeight, streamFps, streamBitrate, rotation) == true &&
                    rtmpCamera?.prepareAudio() == true) {
                    startEliteService()
                    rtmpCamera?.startStream(url)
                    result.success(null)
                } else {
                    result.error("STREAM_ERROR", "Failed to prepare Elite Encoder", null)
                }
            }
            "stopStreaming" -> {
                rtmpCamera?.stopStream()
                stopEliteService()
                result.success(null)
            }
            "pauseStream" -> {
                // Pedro doesn't have a native "pause" for RTMP (it's a TCP stream).
                // We can stop sending video/audio or just stop the stream.
                // For now, stopStream is the safest "pause" to preserve battery.
                rtmpCamera?.stopStream()
                result.success(null)
            }
            "resumeStream" -> {
                // Re-start the stream. If we were truly pausing/resuming,
                // we'd need the last URL. For now, this is a no-op or re-start.
                // The Dart side handles re-calling startStreaming if needed.
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
            "dispose" -> {
                rtmpCamera?.stopPreview()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun startCameraPreview() {
        val camera = rtmpCamera ?: return
        if (!camera.isOnPreview && surfaceCreated) {
            // Let the library choose the most optimal preview size matching our
            // target resolution. Passing specific W/H can cause some sensors to
            // fallback to low-res (poor quality) if they don't support the exact pair.
            camera.startPreview(CameraHelper.Facing.BACK, streamWidth, streamHeight)
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

        init {
            view.layoutParams = ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT)
            // Use 'Adjust' to avoid blurriness caused by stretching
            view.setAspectRatioMode(com.pedro.encoder.utils.gl.AspectRatioMode.Adjust)
            view.holder.addCallback(this)
            view.setZOrderMediaOverlay(true)
            
            val camera = rtmpCamera
            if (camera == null) {
                rtmpCamera = RtmpCamera2(view, this@MainActivity)
            } else {
                camera.replaceView(view)
            }
        }

        override fun getView(): View = view
        override fun surfaceCreated(holder: SurfaceHolder) {
            surfaceCreated = true
            mainHandler.post {
                startCameraPreview()
            }
        }
        override fun surfaceChanged(holder: SurfaceHolder, f: Int, w: Int, h: Int) {}
        override fun surfaceDestroyed(holder: SurfaceHolder) {
            surfaceCreated = false
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
        }
    }
    override fun onConnectionFailed(reason: String) {
        stopEliteService()
        mainHandler.post {
            eventSink?.success(mapOf("type" to "connectionFailed", "message" to reason))
        }
    }
    override fun onDisconnect() {
        stopEliteService()
        mainHandler.post {
            eventSink?.success(mapOf("type" to "disconnected"))
        }
    }
    override fun onAuthError() {}
    override fun onAuthSuccess() {}

    override fun onDestroy() {
        rtmpCamera?.stopStream()
        rtmpCamera?.stopPreview()
        rtmpCamera = null
        super.onDestroy()
    }
}
