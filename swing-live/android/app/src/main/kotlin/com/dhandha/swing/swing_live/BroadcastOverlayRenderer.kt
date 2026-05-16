package com.dhandha.swing.swing_live

import android.content.Context
import android.content.res.AssetManager
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.LinearGradient
import android.graphics.Paint
import android.graphics.Path
import android.graphics.PorterDuff
import android.graphics.Rect
import android.graphics.RectF
import android.graphics.Shader
import android.graphics.Typeface
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import kotlin.math.cos
import kotlin.math.max
import kotlin.math.min
import kotlin.math.sin
import org.json.JSONObject

/**
 * Star-Sports-grade broadcast overlay, drawn natively at the full encoded
 * frame resolution (1920×1080) and handed to Pedro as a Bitmap each render
 * tick. This sidesteps the Flutter→PNG→shader-stretch chain that was
 * making the scorebar text + logos look blurry on YouTube.
 *
 * Architecture:
 *   - Dart sends `setState(json)` whenever score/batter/bowler/etc changes.
 *     We re-render once and push to Pedro.
 *   - Dart sends `triggerEvent(json)` on a boundary/wicket — we run a
 *     30fps animation loop that re-renders + pushes for the flash duration
 *     (~1.6s), then idles.
 *   - When idle (no flash), we only re-render on state change. No render
 *     loop running = no thermal cost.
 *
 * The bitmap itself is reused — `setImage` on Pedro's filter takes a
 * Bitmap reference; we mutate-in-place rather than allocating each tick.
 */
class BroadcastOverlayRenderer(
    private val context: Context,
    private val onBitmapReady: (Bitmap) -> Unit,
) {
    companion object {
        private const val TAG = "BroadcastOverlay"
        private const val FRAME_W = 1920
        private const val FRAME_H = 1080

        // English broadcast palette — same as Flutter's PremiumATheme so
        // local preview and YouTube output read as one design.
        private const val BG_DEEP = 0xFF0F1B2D.toInt()   // midnight navy
        private const val BONE = 0xFFECE6D7.toInt()      // bone (cream off-white)
        private const val MUSTARD = 0xFFE6B544.toInt()   // mustard accent
        private const val BURGUNDY = 0xFFC42531.toInt()  // burgundy danger
        private const val HAIRLINE = 0x33ECE6D7.toInt()  // bone @ 20%
        private const val OVERLAY_DIM = 0xCC0F1B2D.toInt() // navy @ 80%

        // Animation timings (ms). Flash lifecycle = in → hold → out.
        private const val FLASH_IN_MS = 220L
        private const val FLASH_HOLD_MS = 1100L
        private const val FLASH_OUT_MS = 320L
        private const val FLASH_TOTAL_MS = FLASH_IN_MS + FLASH_HOLD_MS + FLASH_OUT_MS
    }

    private val bitmap: Bitmap = Bitmap.createBitmap(FRAME_W, FRAME_H, Bitmap.Config.ARGB_8888)
    private val canvas = Canvas(bitmap)
    private val handler = Handler(Looper.getMainLooper())

    // Loaded once from flutter_assets/.
    private val logoBitmap: Bitmap? = decodeAsset("flutter_assets/assets/logo.png")
    private val sponsorBitmap: Bitmap? = decodeAsset("flutter_assets/assets/sponsor.png")

    // Current scoreboard state. JSON keys mirror the public-overlay payload
    // for easy plumbing from Dart's MatchState.
    private var teamCodeBatting: String = "—"
    private var teamCodeBowling: String = "—"
    private var score: Int = 0
    private var wickets: Int = 0
    private var oversDisplay: String = "0.0"
    private var target: Int? = null
    private var strikerName: String = "—"
    private var strikerRuns: Int = 0
    private var strikerBalls: Int = 0
    private var nonStrikerName: String = "—"
    private var nonStrikerRuns: Int = 0
    private var nonStrikerBalls: Int = 0
    private var bowlerName: String = "—"
    private var bowlerOvers: String = "0.0"
    private var bowlerRuns: Int = 0
    private var bowlerWickets: Int = 0
    private var venue: String = ""
    private var matchLabel: String = ""

    // Active flash (null when none). Stored as (kind, text, subtext, startMs).
    private data class Flash(
        val kind: String,
        val text: String,
        val sub: String,
        val startMs: Long,
    )
    private var flash: Flash? = null
    private var animScheduled: Boolean = false

    /** Render-and-push entry point. Idempotent. */
    @Synchronized
    fun setState(json: JSONObject) {
        teamCodeBatting = json.optString("teamCodeBatting", teamCodeBatting)
        teamCodeBowling = json.optString("teamCodeBowling", teamCodeBowling)
        score = json.optInt("score", score)
        wickets = json.optInt("wickets", wickets)
        oversDisplay = json.optString("oversDisplay", oversDisplay)
        target = if (json.has("target") && !json.isNull("target")) json.optInt("target") else null
        strikerName = json.optString("strikerName", strikerName)
        strikerRuns = json.optInt("strikerRuns", strikerRuns)
        strikerBalls = json.optInt("strikerBalls", strikerBalls)
        nonStrikerName = json.optString("nonStrikerName", nonStrikerName)
        nonStrikerRuns = json.optInt("nonStrikerRuns", nonStrikerRuns)
        nonStrikerBalls = json.optInt("nonStrikerBalls", nonStrikerBalls)
        bowlerName = json.optString("bowlerName", bowlerName)
        bowlerOvers = json.optString("bowlerOvers", bowlerOvers)
        bowlerRuns = json.optInt("bowlerRuns", bowlerRuns)
        bowlerWickets = json.optInt("bowlerWickets", bowlerWickets)
        venue = json.optString("venue", venue)
        matchLabel = json.optString("matchLabel", matchLabel)
        renderAndPush()
    }

    /** Kick off a transient flash (FOUR/SIX/OUT/DUCK). Re-triggers reset. */
    @Synchronized
    fun triggerEvent(json: JSONObject) {
        val kind = json.optString("kind", "FOUR")
        val text = json.optString("text", kind)
        val sub = json.optString("sub", "")
        flash = Flash(kind, text, sub, SystemClock.uptimeMillis())
        scheduleAnimFrame()
    }

    /** Force a re-render with the currently-stored state. Used when the
     *  RTMP camera comes online after the renderer was already created —
     *  the first render fired with rtmpCamera=null and the filter never
     *  attached. Calling this from `onConnectionSuccess` makes the
     *  overlay appear the instant the stream goes live. */
    @Synchronized
    fun repaint() {
        renderAndPush()
    }

    /** Clear all state + remove the filter. Called from MainActivity on stop. */
    @Synchronized
    fun clear() {
        flash = null
        animScheduled = false
        handler.removeCallbacksAndMessages(null)
    }

    private fun scheduleAnimFrame() {
        if (animScheduled) return
        animScheduled = true
        handler.post(animationTick)
    }

    private val animationTick = object : Runnable {
        override fun run() {
            animScheduled = false
            val current = flash ?: return
            val elapsed = SystemClock.uptimeMillis() - current.startMs
            if (elapsed >= FLASH_TOTAL_MS) {
                flash = null
                renderAndPush()
                return
            }
            renderAndPush()
            // ~30fps anim loop. Cheaper than 60fps and visually fine for
            // a 1.6s flash. The phone hardware encoder is already at 30fps
            // so there's no benefit to drawing faster than that.
            animScheduled = true
            handler.postDelayed(this, 33L)
        }
    }

    @Synchronized
    private fun renderAndPush() {
        // Clear to fully transparent — bitmap is composited over the camera
        // frame, so anything we don't draw shows the live feed.
        canvas.drawColor(Color.TRANSPARENT, PorterDuff.Mode.CLEAR)

        drawScorebar()
        drawLogoPlate()
        drawSponsorPlate()
        flash?.let { drawFlash(it) }

        onBitmapReady(bitmap)
    }

    // ── Scorebar ─────────────────────────────────────────────────────────
    private val paintBg = Paint(Paint.ANTI_ALIAS_FLAG)
    private val paintHairline = Paint().apply {
        color = MUSTARD
        strokeWidth = 2f
    }
    private val paintTextScore = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = BONE
        textSize = 56f
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        textAlign = Paint.Align.LEFT
    }
    private val paintTextCode = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = BONE
        textSize = 38f
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        textAlign = Paint.Align.LEFT
        letterSpacing = 0.08f
    }
    private val paintTextOvers = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = MUSTARD
        textSize = 28f
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        letterSpacing = 0.06f
    }
    private val paintTextBatter = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = BONE
        textSize = 24f
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        letterSpacing = 0.04f
    }
    private val paintTextStats = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = BONE
        textSize = 24f
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
    }
    private val paintTextMeta = Paint(Paint.ANTI_ALIAS_FLAG).apply {
        color = MUSTARD
        textSize = 20f
        typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
        letterSpacing = 0.12f
    }

    private fun drawScorebar() {
        // Bottom bar — two rows. Anchored to true frame bottom so it always
        // reaches the edge regardless of phone aspect (no Flutter stretch).
        val barH = 156
        val top = FRAME_H - barH
        val r = RectF(0f, top.toFloat(), FRAME_W.toFloat(), FRAME_H.toFloat())

        // Solid gradient navy — no BackdropFilter (which was flickering
        // in the Flutter version). Slight darker at the bottom for weight.
        paintBg.shader = LinearGradient(
            0f, top.toFloat(), 0f, FRAME_H.toFloat(),
            0xF20F1B2D.toInt(), 0xF80B1422.toInt(),
            Shader.TileMode.CLAMP,
        )
        canvas.drawRect(r, paintBg)
        paintBg.shader = null

        // Mustard top hairline — broadcast signature.
        canvas.drawRect(0f, top.toFloat(), FRAME_W.toFloat(), (top + 2).toFloat(), paintHairline)

        // ROW 1 (score block) — team code · score/wkts · overs · target chip.
        val row1Y = top + 60f
        val padL = 36f

        canvas.drawText(teamCodeBatting, padL, row1Y, paintTextCode)
        val codeW = paintTextCode.measureText(teamCodeBatting)

        val scoreText = "$score-$wickets"
        canvas.drawText(scoreText, padL + codeW + 22f, row1Y + 8f, paintTextScore)
        val scoreW = paintTextScore.measureText(scoreText)

        val oversText = "($oversDisplay)"
        canvas.drawText(oversText, padL + codeW + 22f + scoreW + 18f, row1Y + 2f, paintTextOvers)

        // Target chip, right-aligned.
        target?.let { t ->
            val need = max(0, t - score)
            val chipText = "NEED $need"
            val chipW = paintTextMeta.measureText(chipText) + 36f
            val chipR = FRAME_W - 36f
            val chipL = chipR - chipW
            val chipRect = RectF(chipL, row1Y - 30f, chipR, row1Y + 8f)
            val chipBg = Paint(Paint.ANTI_ALIAS_FLAG).apply { color = MUSTARD }
            canvas.drawRoundRect(chipRect, 4f, 4f, chipBg)
            val chipTextPaint = Paint(paintTextMeta).apply { color = BG_DEEP }
            canvas.drawText(chipText, chipL + 18f, row1Y - 4f, chipTextPaint)
        }

        // ROW 2 (player stats) — striker · non-striker · bowler.
        val row2Y = top + 120f
        canvas.drawText(strikerName, padL, row2Y, paintTextBatter)
        val sNameW = paintTextBatter.measureText(strikerName)
        val strikerStats = "$strikerRuns($strikerBalls)*"
        canvas.drawText(strikerStats, padL + sNameW + 12f, row2Y, paintTextStats)

        val nsStart = padL + 380f
        canvas.drawText(nonStrikerName, nsStart, row2Y, paintTextBatter)
        val nsNameW = paintTextBatter.measureText(nonStrikerName)
        val nsStats = "$nonStrikerRuns($nonStrikerBalls)"
        canvas.drawText(nsStats, nsStart + nsNameW + 12f, row2Y, paintTextStats)

        val bStart = padL + 760f
        canvas.drawText(bowlerName, bStart, row2Y, paintTextBatter)
        val bNameW = paintTextBatter.measureText(bowlerName)
        val bowlerFigures = "$bowlerOvers-$bowlerRuns-$bowlerWickets"
        canvas.drawText(bowlerFigures, bStart + bNameW + 12f, row2Y, paintTextStats)
    }

    // ── Logo / sponsor plates ────────────────────────────────────────────
    private val paintPlate = Paint().apply { color = BG_DEEP }
    private val plateH = 64
    private val plateImageH = 44

    private fun drawLogoPlate() {
        val bmp = logoBitmap ?: return
        drawBrandPlate(bmp, leftAnchored = true)
    }

    private fun drawSponsorPlate() {
        val bmp = sponsorBitmap ?: return
        drawBrandPlate(bmp, leftAnchored = false)
    }

    private fun drawBrandPlate(bmp: Bitmap, leftAnchored: Boolean) {
        // Compute image draw rect with aspect preserved at plateImageH tall.
        val aspect = bmp.width.toFloat() / bmp.height.toFloat()
        val drawH = plateImageH.toFloat()
        val drawW = drawH * aspect
        val plateWidth = drawW + 36f // 18px padding each side

        val plateTop = 36f
        val plateBottom = plateTop + plateH
        val plateLeft: Float
        val plateRight: Float
        if (leftAnchored) {
            plateLeft = 36f
            plateRight = plateLeft + plateWidth
        } else {
            plateRight = FRAME_W - 36f
            plateLeft = plateRight - plateWidth
        }

        // Plate background (semi-opaque navy so logo edges blend with feed).
        val plateBg = Paint().apply { color = 0xE60F1B2D.toInt() }
        canvas.drawRect(plateLeft, plateTop, plateRight, plateBottom, plateBg)

        // Mustard top hairline.
        canvas.drawRect(plateLeft, plateTop, plateRight, plateTop + 2f, paintHairline)

        val imageTop = plateTop + (plateH - drawH) / 2f
        val src = Rect(0, 0, bmp.width, bmp.height)
        val dst = RectF(
            plateLeft + 18f,
            imageTop,
            plateLeft + 18f + drawW,
            imageTop + drawH,
        )
        val imagePaint = Paint(Paint.FILTER_BITMAP_FLAG or Paint.ANTI_ALIAS_FLAG)
        canvas.drawBitmap(bmp, src, dst, imagePaint)
    }

    // ── Flash overlays (FOUR / SIX / OUT / DUCK) ─────────────────────────
    private fun drawFlash(f: Flash) {
        val elapsed = SystemClock.uptimeMillis() - f.startMs
        val alpha: Float = when {
            elapsed < FLASH_IN_MS -> elapsed.toFloat() / FLASH_IN_MS
            elapsed < FLASH_IN_MS + FLASH_HOLD_MS -> 1f
            else -> {
                val out = elapsed - FLASH_IN_MS - FLASH_HOLD_MS
                1f - (out.toFloat() / FLASH_OUT_MS).coerceIn(0f, 1f)
            }
        }.coerceIn(0f, 1f)

        val cx = FRAME_W / 2f
        val cy = FRAME_H * 0.42f
        val color = when (f.kind) {
            "SIX" -> MUSTARD
            "OUT", "WICKET" -> BURGUNDY
            "DUCK" -> MUSTARD
            else -> BONE // FOUR
        }

        // Backdrop bloom — radial mustard/burgundy that lifts the wordmark
        // off the camera feed without an opaque banner (per user spec —
        // "innovate, no full-width bands").
        val bloomR = 460f * (0.6f + 0.4f * alpha)
        val bloomPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            shader = android.graphics.RadialGradient(
                cx, cy, bloomR,
                intArrayOf(
                    (color and 0x00FFFFFF) or ((alpha * 0.55f * 255).toInt() shl 24),
                    (color and 0x00FFFFFF) or ((alpha * 0.18f * 255).toInt() shl 24),
                    0x00000000,
                ),
                floatArrayOf(0f, 0.55f, 1f),
                Shader.TileMode.CLAMP,
            )
        }
        canvas.drawCircle(cx, cy, bloomR, bloomPaint)

        // SIX: confetti rain
        if (f.kind == "SIX") drawConfetti(elapsed, alpha)

        // Wordmark.
        val scale = when {
            elapsed < FLASH_IN_MS -> 0.7f + 0.3f * (elapsed.toFloat() / FLASH_IN_MS)
            elapsed < FLASH_IN_MS + 220 -> 1.06f
            else -> 1.0f
        }
        val wordPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
            this.color = color
            this.alpha = (alpha * 255).toInt().coerceIn(0, 255)
            textSize = 220f * scale
            typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
            textAlign = Paint.Align.CENTER
            letterSpacing = 0.06f
            setShadowLayer(18f, 0f, 6f, 0x66000000)
        }
        canvas.drawText(f.text, cx, cy + (wordPaint.textSize / 3f), wordPaint)

        // Sub-line (dismissed batter name on OUT).
        if (f.sub.isNotEmpty()) {
            val subPaint = Paint(Paint.ANTI_ALIAS_FLAG).apply {
                this.color = BONE
                this.alpha = (alpha * 230).toInt().coerceIn(0, 255)
                textSize = 42f
                typeface = Typeface.create(Typeface.DEFAULT, Typeface.BOLD)
                textAlign = Paint.Align.CENTER
                letterSpacing = 0.18f
            }
            canvas.drawText(f.sub, cx, cy + (wordPaint.textSize / 3f) + 64f, subPaint)
        }

        // Burgundy "boundary rope" line for FOUR — thin line streaking
        // across the centre, suggesting the ball racing to the rope.
        if (f.kind == "FOUR") {
            val ropePaint = Paint().apply {
                this.color = BURGUNDY
                this.alpha = (alpha * 200).toInt().coerceIn(0, 255)
                strokeWidth = 3f
            }
            val streakProg = (elapsed.toFloat() / FLASH_IN_MS).coerceIn(0f, 1f)
            val startX = -200f + streakProg * (FRAME_W + 400f)
            canvas.drawLine(startX - 200f, cy + 110f, startX, cy + 110f, ropePaint)
        }
    }

    private fun drawConfetti(elapsed: Long, alpha: Float) {
        // Deterministic confetti — same seed each flash so the result is
        // identical across renders within the same flash, avoiding any
        // strobe artifacts that random-per-tick would produce.
        val rnd = java.util.Random(42L)
        val confettiPaint = Paint(Paint.ANTI_ALIAS_FLAG)
        for (i in 0 until 80) {
            val xCol = rnd.nextFloat() * FRAME_W
            val phase = rnd.nextFloat()
            val fall = (elapsed / 1400f + phase) % 1f
            val y = -40f + fall * (FRAME_H + 80f)
            val size = 10f + rnd.nextFloat() * 14f
            val rot = (elapsed / 6f + phase * 360f) % 360f
            val palette = intArrayOf(MUSTARD, BONE, BURGUNDY)
            confettiPaint.color = palette[i % palette.size]
            confettiPaint.alpha = (alpha * 220).toInt().coerceIn(0, 255)
            canvas.save()
            canvas.translate(xCol, y)
            canvas.rotate(rot)
            canvas.drawRect(-size / 2f, -size / 8f, size / 2f, size / 8f, confettiPaint)
            canvas.restore()
        }
    }

    private fun decodeAsset(path: String): Bitmap? {
        return try {
            context.assets.open(path).use { BitmapFactory.decodeStream(it) }
        } catch (t: Throwable) {
            Log.w(TAG, "asset $path missing: ${t.message}")
            null
        }
    }
}
