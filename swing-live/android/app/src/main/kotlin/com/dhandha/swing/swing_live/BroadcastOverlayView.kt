package com.dhandha.swing.swing_live

import android.animation.ValueAnimator
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.Color
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.widget.FrameLayout
import android.widget.ImageView
import android.widget.TextView
import org.json.JSONObject
import kotlin.math.max

/**
 * Native broadcast-overlay view fed to Pedro's AndroidViewFilterRender.
 *
 * Visual spec is shared with the Flutter PremiumAScorebar so the in-app
 * preview matches what YouTube viewers see. See `broadcast_overlay.xml`
 * for the canonical layout (split TV-feed style: top-corner logo +
 * sponsor plates, single-row bottom scorebar with accent strip / score /
 * players / bowler / target chip).
 *
 * State flow:
 *   1. Dart's NativeOverlayBridge serialises MatchState → JSON
 *   2. setOverlayState method handler in MainActivity feeds it here
 *   3. setState() binds text/visibility to view fields
 *   4. Pedro's AndroidViewFilterRender reads the view's surface each
 *      encoded frame — no Bitmap shuffle, no copy.
 */
class BroadcastOverlayView(context: Context) : FrameLayout(context) {

    companion object {
        private const val TAG = "BroadcastOverlay"
        private const val FRAME_W = 1920
        private const val FRAME_H = 1080

        // Palette (kept in sync with PremiumATheme + Flutter scorebar).
        private const val BONE = 0xFFECE6D7.toInt()
        private const val MUSTARD = 0xFFE6B544.toInt()
        private const val BURGUNDY = 0xFFC42531.toInt()

        // Flash lifecycle (ms). Total ≈ 3.2s — long enough that viewers
        // actually catch and read it. Cricket balls are typically 30s
        // apart so this leaves plenty of headroom before the next event.
        private const val FLASH_IN = 300L
        private const val FLASH_HOLD = 2500L
        private const val FLASH_OUT = 400L
        private const val FLASH_TOTAL = FLASH_IN + FLASH_HOLD + FLASH_OUT
    }

    // Scorebar fields.
    private val teamAccent: View
    private val teamCodeBatting: TextView
    private val scoreText: TextView
    private val oversText: TextView
    private val crrText: TextView
    private val strikerName: TextView
    private val strikerStats: TextView
    private val nonStrikerName: TextView
    private val nonStrikerStats: TextView
    private val bowlerName: TextView
    private val bowlerFigures: TextView
    private val bowlerEco: TextView
    private val targetChipContainer: View
    private val targetChipValue: TextView
    private val targetChipRrr: TextView

    // Plates + flash overlay.
    private val logoImage: ImageView
    private val sponsorImage: ImageView
    private val flashContainer: FrameLayout
    private val flashText: TextView
    private val flashSub: TextView

    private var flashAnimator: ValueAnimator? = null

    // Cached for economy calc (Dart sends bowlerOvers + bowlerRuns but
    // not eco — we derive it natively so Dart doesn't need to know about
    // the visual layout).
    private var lastBowlerOvers: Float = 0f
    private var lastBowlerRuns: Int = 0

    init {
        LayoutInflater.from(context).inflate(R.layout.broadcast_overlay, this, true)
        teamAccent = findViewById(R.id.team_accent)
        teamCodeBatting = findViewById(R.id.team_code_batting)
        scoreText = findViewById(R.id.score_text)
        oversText = findViewById(R.id.overs_text)
        crrText = findViewById(R.id.crr_text)
        strikerName = findViewById(R.id.striker_name)
        strikerStats = findViewById(R.id.striker_stats)
        nonStrikerName = findViewById(R.id.non_striker_name)
        nonStrikerStats = findViewById(R.id.non_striker_stats)
        bowlerName = findViewById(R.id.bowler_name)
        bowlerFigures = findViewById(R.id.bowler_figures)
        bowlerEco = findViewById(R.id.bowler_eco)
        targetChipContainer = findViewById(R.id.target_chip_container)
        targetChipValue = findViewById(R.id.target_chip_value)
        targetChipRrr = findViewById(R.id.target_chip_rrr)
        logoImage = findViewById(R.id.logo_image)
        sponsorImage = findViewById(R.id.sponsor_image)
        flashContainer = findViewById(R.id.flash_container)
        flashText = findViewById(R.id.flash_text)
        flashSub = findViewById(R.id.flash_sub)

        loadBrandImages()
        measureForFilter()
    }

    /** Required for off-screen view: the standard measure/layout pass
     *  doesn't run, so we measure at exact 1920×1080 pixel size manually.
     *  Re-run whenever state changes a measure-affecting child (target
     *  chip visibility, flash visibility). */
    private fun measureForFilter() {
        measure(
            MeasureSpec.makeMeasureSpec(FRAME_W, MeasureSpec.EXACTLY),
            MeasureSpec.makeMeasureSpec(FRAME_H, MeasureSpec.EXACTLY),
        )
        layout(0, 0, FRAME_W, FRAME_H)
    }

    /** Update scorebar text fields from the Dart JSON payload. */
    fun setState(json: JSONObject) {
        // Cap team codes at 3 chars to match cricket broadcast convention
        // (IND, AUS, RCB...). The backend sometimes ships longer
        // "shortNames" like "SWING G" that wrap the slab on 2 lines.
        teamCodeBatting.text =
            json.optString("teamCodeBatting", "—").take(3).uppercase()

        val score = json.optInt("score", 0)
        val wickets = json.optInt("wickets", 0)
        scoreText.text = "$score-$wickets"

        val oversDisplay = json.optString("oversDisplay", "0.0")
        oversText.text = "$oversDisplay OV"

        // Current run rate — derived from oversDisplay + score on the
        // native side. Dart doesn't ship CRR explicitly.
        val oversFloat = oversToBalls(oversDisplay).let { balls ->
            if (balls == 0) 0f else score.toFloat() / (balls / 6f)
        }
        crrText.text = "CRR ${"%.2f".format(oversFloat)}"

        // Striker block.
        strikerName.text = json.optString("strikerName", "—")
        val sRuns = json.optInt("strikerRuns")
        val sBalls = json.optInt("strikerBalls")
        strikerStats.text = "$sRuns($sBalls)"

        // Non-striker block.
        nonStrikerName.text = json.optString("nonStrikerName", "—")
        nonStrikerStats.text =
            "${json.optInt("nonStrikerRuns")}(${json.optInt("nonStrikerBalls")})"

        // Bowler block + economy.
        bowlerName.text = json.optString("bowlerName", "—")
        val bOvers = json.optString("bowlerOvers", "0.0")
        val bRuns = json.optInt("bowlerRuns")
        val bWickets = json.optInt("bowlerWickets")
        bowlerFigures.text = "$bOvers-$bWickets-$bRuns"
        val bBalls = oversToBalls(bOvers)
        val eco = if (bBalls == 0) 0f else bRuns.toFloat() / (bBalls / 6f)
        bowlerEco.text = "ECO ${"%.2f".format(eco)}"
        lastBowlerOvers = parseOvers(bOvers)
        lastBowlerRuns = bRuns

        // Target chip — visible during a chase. RRR computed from
        // (target - score) and balls remaining.
        if (json.has("target") && !json.isNull("target")) {
            val target = json.optInt("target")
            val need = max(0, target - score)
            targetChipValue.text = "$need"
            // Balls remaining = total balls in innings (assume 20-over T20
            // for compute fallback; if Dart sends overs limit later we'll
            // use that). Conservative: 120 balls.
            val ballsBowled = oversToBalls(oversDisplay)
            val ballsRemaining = (120 - ballsBowled).coerceAtLeast(1)
            val rrr = (need * 6f) / ballsRemaining
            targetChipRrr.text = "RRR ${"%.2f".format(rrr)}"
            targetChipContainer.visibility = View.VISIBLE
        } else {
            targetChipContainer.visibility = View.GONE
        }

        measureForFilter()
    }

    /** Fire a transient FOUR / SIX / OUT / DUCK flash. */
    fun triggerEvent(json: JSONObject) {
        val kind = json.optString("kind", "FOUR")
        val text = json.optString("text", kind)
        val sub = json.optString("sub", "")
        Log.d(TAG, "triggerEvent: kind=$kind text=$text sub=$sub")

        flashAnimator?.cancel()

        flashText.text = text
        flashText.setTextColor(
            when (kind) {
                "SIX" -> MUSTARD
                "OUT", "WICKET" -> BURGUNDY
                "DUCK" -> MUSTARD
                else -> BONE
            }
        )

        // NOTE: Both flash_container and flash_sub are permanently
        // visibility=VISIBLE in XML — we show/hide them via alpha. Mixing
        // visibility=GONE with off-screen views caused stuck-at-zero
        // layouts (no ViewRootImpl → no automatic re-layout pass).
        if (sub.isNotEmpty()) {
            flashSub.text = sub
            flashSub.alpha = 1f
        } else {
            flashSub.alpha = 0f
        }
        // flashContainer.alpha starts at 0f; the animator below brings it
        // up. Layout never changes so we don't re-measure here.

        flashAnimator = ValueAnimator.ofFloat(0f, 1f).apply {
            duration = FLASH_TOTAL
            addUpdateListener { anim ->
                val elapsed = (anim.animatedValue as Float) * FLASH_TOTAL
                val alpha = when {
                    elapsed < FLASH_IN -> elapsed / FLASH_IN.toFloat()
                    elapsed < FLASH_IN + FLASH_HOLD -> 1f
                    else -> {
                        val out = elapsed - FLASH_IN - FLASH_HOLD
                        (1f - (out / FLASH_OUT.toFloat())).coerceIn(0f, 1f)
                    }
                }
                flashContainer.alpha = alpha.coerceIn(0f, 1f)
                val scale = when {
                    elapsed < FLASH_IN -> 0.7f + 0.3f * (elapsed / FLASH_IN.toFloat())
                    elapsed < FLASH_IN + 220 -> 1.06f
                    else -> 1f
                }
                flashText.scaleX = scale
                flashText.scaleY = scale
                // CRITICAL: the scorebar TextViews show up on YouTube
                // because setState() calls measureForFilter() each
                // update. Pedro's AndroidViewFilterRender appears to
                // re-read the view's draw output only after a
                // measure+layout pass — without it the alpha/scale
                // changes here happen in Android's view state but
                // never make it into the encoded frame. Re-measuring
                // on every animator tick (~30/s for 1.6s = ~50 calls)
                // forces the filter to pick up each frame of the
                // animation.
                measureForFilter()
            }
            doOnEnd {
                // Keep visibility=VISIBLE (drives layout stability),
                // hide via alpha=0 instead.
                flashContainer.alpha = 0f
                flashText.scaleX = 1f
                flashText.scaleY = 1f
                measureForFilter()
            }
            start()
        }
    }

    fun reset() {
        flashAnimator?.cancel()
        flashAnimator = null
        flashContainer.alpha = 0f
    }

    private fun loadBrandImages() {
        decodeAsset("flutter_assets/assets/logo.png")?.let { logoImage.setImageBitmap(it) }
        decodeAsset("flutter_assets/assets/sponsor.png")?.let { sponsorImage.setImageBitmap(it) }
    }

    private fun decodeAsset(path: String): Bitmap? {
        return try {
            context.assets.open(path).use { BitmapFactory.decodeStream(it) }
        } catch (t: Throwable) {
            Log.w(TAG, "asset $path missing: ${t.message}")
            null
        }
    }

    /** "18.2" → 110 balls. Cricket overs use a `.b` notation where b is
     *  the ball-of-over in [0,5]. */
    private fun oversToBalls(overs: String): Int {
        val parts = overs.split('.')
        val whole = parts.getOrNull(0)?.toIntOrNull() ?: 0
        val ball = parts.getOrNull(1)?.toIntOrNull() ?: 0
        return whole * 6 + ball
    }

    private fun parseOvers(overs: String): Float =
        overs.toFloatOrNull() ?: 0f
}

/** Tiny extension so we don't pull androidx.core for one helper. */
private fun ValueAnimator.doOnEnd(block: () -> Unit) {
    addListener(object : android.animation.AnimatorListenerAdapter() {
        override fun onAnimationEnd(animation: android.animation.Animator) = block()
    })
}
