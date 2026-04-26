package com.dhandha.swing.swing_live

import android.content.Context
import android.util.Log
import android.view.View
import android.view.ViewGroup
import android.view.SurfaceHolder
import android.view.WindowManager
import android.content.Intent
import android.os.Build
import android.os.Handler
import android.os.Looper
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import io.flutter.plugin.common.EventChannel
import com.pedro.library.rtmp.RtmpCamera2
import com.pedro.common.ConnectChecker
import com.pedro.library.view.OpenGlView
import com.pedro.encoder.input.video.CameraHelper

class MainActivity : FlutterActivity(), ConnectChecker {
    private val TAG = "SwingElite"
    private val CHANNEL = "com.dhandha.swing/camera"
    private val EVENT_CHANNEL = "com.dhandha.swing/camera/events"

    companion object {
        // Elite Persistent Engine
        private var rtmpCamera: RtmpCamera2? = null
        private var persistentOpenGlView: OpenGlView? = null
    }
    
    private var eventSink: EventChannel.EventSink? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    private var streamWidth = 1280
    private var streamHeight = 720
    private var streamFps = 30
    private var streamBitrate = 2500000
    private var streamIsVertical = true

    private var previewRequested = false
    private var originalBrightness: Float = -1.0f

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        Log.i(TAG, "Elite Engine: Flutter Engine configured")

        flutterEngine.platformViewsController.registry.registerViewFactory(
            "com.dhandha.swing/camera_view", CameraViewFactory()
        )

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            handleMethodCall(call, result)
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, EVENT_CHANNEL).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
            }
            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
    }

    private fun handleMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> {
                streamWidth = call.argument<Int>("width") ?: 1280
                streamHeight = call.argument<Int>("height") ?: 720
                streamFps = call.argument<Int>("fps") ?: 30
                streamBitrate = call.argument<Int>("bitrate") ?: 2500000
                streamIsVertical = call.argument<Boolean>("isVertical") ?: true

                if (persistentOpenGlView != null) {
                    setupCamera()
                }
                result.success(mapOf("status" to "ok"))
            }
            "startPreview" -> {
                previewRequested = true
                if (rtmpCamera != null && persistentOpenGlView?.holder?.surface?.isValid == true) {
                    startCameraPreview()
                }
                result.success(null)
            }
            "startStreaming" -> {
                val url = call.argument<String>("url") ?: ""
                // Swap dimensions for portrait so the encoder matches what the camera delivers.
                // A portrait phone feeds 1080-wide × 1920-tall frames; encoding 1920×1080
                // without swapping causes the stretching/blur seen at the receiver.
                val encodeWidth  = if (streamIsVertical) streamHeight else streamWidth
                val encodeHeight = if (streamIsVertical) streamWidth  else streamHeight
                val rotation     = if (streamIsVertical) 90 else 0
                if (rtmpCamera?.prepareVideo(encodeWidth, encodeHeight, streamFps, streamBitrate, rotation) == true &&
                    rtmpCamera?.prepareAudio() == true) {
                    startEliteService()
                    rtmpCamera?.startStream(url)
                    result.success(null)
                } else {
                    result.error("STREAM_ERROR", "Failed to prepare Elite Encoder", null)
                }
            }
            "pauseStream" -> {
                rtmpCamera?.pauseStream()
                result.success(null)
            }
            "resumeStream" -> {
                rtmpCamera?.resumeStream()
                result.success(null)
            }
            "stopStreaming" -> {
                rtmpCamera?.stopStream()
                stopEliteService()
                setBatteryShield(false)
                result.success(null)
            }
            "setZoomRatio" -> {
                val ratio = call.argument<Double>("ratio")?.toFloat() ?: 1.0f
                rtmpCamera?.zoom = ratio
                result.success(null)
            }
            "setBatteryShield" -> {
                val enabled = call.argument<Boolean>("enabled") ?: false
                setBatteryShield(enabled)
                result.success(null)
            }
            "switchCamera" -> {
                rtmpCamera?.switchCamera()
                result.success(null)
            }
            "dispose" -> {
                rtmpCamera?.stopStream()
                rtmpCamera?.stopPreview()
                result.success(null)
            }
            else -> result.notImplemented()
        }
    }

    private fun setupCamera() {
        val view = persistentOpenGlView ?: return
        if (rtmpCamera == null) {
            Log.i(TAG, "Elite: Creating Persistent Engine instance")
            rtmpCamera = RtmpCamera2(view, this)
        }
        if (previewRequested && view.holder.surface.isValid) {
            startCameraPreview()
        }
    }

    private fun startCameraPreview() {
        val camera = rtmpCamera ?: return
        if (!camera.isOnPreview) {
            Log.i(TAG, "Elite: Firing Persistent Hardware Preview")
            try {
                camera.startPreview(CameraHelper.Facing.BACK)
            } catch (e: Exception) {
                Log.e(TAG, "Elite: Hardware Preview Failed: ${e.message}")
            }
        }
    }

    private fun startEliteService() {
        val intent = Intent(this, StreamForegroundService::class.java)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            startForegroundService(intent)
        } else {
            startService(intent)
        }
    }

    private fun stopEliteService() {
        stopService(Intent(this, StreamForegroundService::class.java))
    }

    private fun setBatteryShield(enabled: Boolean) {
        val layoutParams = window.attributes
        if (enabled) {
            if (originalBrightness == -1.0f) {
                originalBrightness = layoutParams.screenBrightness
            }
            layoutParams.screenBrightness = 0.05f
        } else {
            if (originalBrightness != -1.0f) {
                layoutParams.screenBrightness = originalBrightness
                originalBrightness = -1.0f
            }
        }
        window.attributes = layoutParams
    }

    inner class CameraViewFactory : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
        override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
            return CameraPlatformView(context)
        }
    }

    inner class CameraPlatformView(context: Context) : PlatformView, SurfaceHolder.Callback {
        private var currentView: OpenGlView? = null

        init {
            if (persistentOpenGlView == null) {
                Log.i(TAG, "Elite: Initializing NEW Persistent OpenGlView")
                persistentOpenGlView = OpenGlView(context)
                persistentOpenGlView!!.holder.addCallback(this)
                persistentOpenGlView!!.setZOrderMediaOverlay(true)
            } else {
                Log.i(TAG, "Elite: DETACHING and REUSING Existing Persistent OpenGlView")
                Log.w(TAG, "Elite: DETACH stack trace", Throwable("detach-origin"))
                // Stop preview before detaching to release the GL surface cleanly
                // and prevent BufferQueue abandoned errors
                if (rtmpCamera?.isOnPreview == true && rtmpCamera?.isStreaming != true) {
                    rtmpCamera?.stopPreview()
                    previewRequested = true
                }
                (persistentOpenGlView!!.parent as? ViewGroup)?.removeView(persistentOpenGlView)
            }
            currentView = persistentOpenGlView
        }

        override fun getView(): View = currentView!!
        
        override fun surfaceCreated(holder: SurfaceHolder) {
            Log.i(TAG, "Elite: Persistent Surface Created")
            setupCamera()
        }

        override fun surfaceChanged(holder: SurfaceHolder, format: Int, width: Int, height: Int) {}
        override fun surfaceDestroyed(holder: SurfaceHolder) {
            Log.i(TAG, "Elite: Persistent Surface Detached")
        }

        override fun dispose() {
            Log.i(TAG, "Elite: Flutter requested dispose, detaching view to keep engine alive")
            Log.w(TAG, "Elite: DISPOSE stack trace", Throwable("dispose-origin"))
            mainHandler.post {
                if (rtmpCamera?.isOnPreview == true && rtmpCamera?.isStreaming != true) {
                    rtmpCamera?.stopPreview()
                    previewRequested = true
                }
                (persistentOpenGlView?.parent as? ViewGroup)?.removeView(persistentOpenGlView)
            }
        }
    }

    override fun onConnectionStarted(url: String) { sendEvent("connecting") }
    override fun onConnectionSuccess() { sendEvent("connected") }
    override fun onConnectionFailed(reason: String) { 
        sendEvent("connectionFailed", reason) 
        stopEliteService()
    }
    override fun onDisconnect() { 
        sendEvent("disconnected") 
        stopEliteService()
    }
    override fun onAuthError() { sendEvent("error", "Auth error") }
    override fun onAuthSuccess() {}

    private fun sendEvent(type: String, message: String? = null) {
        mainHandler.post {
            val event = mutableMapOf<String, Any>()
            event["type"] = type
            if (message != null) event["message"] = message
            eventSink?.success(event)
        }
    }

    override fun onDestroy() {
        Log.i(TAG, "Elite: App Destroyed, Cleaning up Persistent Engine")
        rtmpCamera?.stopStream()
        rtmpCamera?.stopPreview()
        rtmpCamera = null
        persistentOpenGlView = null
        super.onDestroy()
    }
}
