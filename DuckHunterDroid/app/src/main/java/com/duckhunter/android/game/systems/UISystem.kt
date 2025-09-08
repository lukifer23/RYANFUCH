package com.duckhunter.android.game.systems

import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import com.duckhunter.android.game.GameMode
import com.duckhunter.android.game.entities.Player
import com.duckhunter.android.game.utils.Constants
import kotlin.math.max

class UISystem {

    private val paint = Paint().apply {
        isAntiAlias = true
        textSize = 32f
        color = Color.WHITE
        typeface = Typeface.DEFAULT_BOLD
    }

    private val backgroundPaint = Paint().apply {
        color = Color.argb(150, 0, 0, 0) // Semi-transparent black
        style = Paint.Style.FILL
    }

    private val shadowPaint = Paint().apply {
        color = Color.argb(100, 0, 0, 0) // Shadow color
        style = Paint.Style.FILL
    }

    // UI element positions
    private val scoreTextPos = Pair(50f, 80f)
    private val ammoTextPos = Pair(Constants.SCREEN_WIDTH - 200f, 80f)
    private val livesTextPos = Pair(Constants.SCREEN_WIDTH - 200f, 120f)
    private val timerTextPos = Pair(Constants.SCREEN_WIDTH / 2f - 100f, 80f)
    private val fpsTextPos = Pair(50f, Constants.SCREEN_HEIGHT - 50f)

    // Game state
    private var gameStartTime = 0L
    private var currentGameMode = GameMode.NORMAL
    private var showFPS = true // Can be toggled in settings

    fun setGameMode(gameMode: GameMode) {
        currentGameMode = gameMode
        gameStartTime = System.currentTimeMillis()
    }

    fun render(canvas: Canvas, player: Player, deltaTime: Float) {
        // Draw HUD background
        drawHUDBackground(canvas)

        // Draw main HUD elements
        drawScore(canvas, player.score)
        drawAmmo(canvas, player.ammo, player.gameMode.maxAmmo)
        drawLives(canvas, player.lives, player.gameMode.maxLives)

        // Draw timer for God mode
        if (currentGameMode == GameMode.GOD) {
            val elapsedTime = (System.currentTimeMillis() - gameStartTime) / 1000f
            val remainingTime = max(0f, 300f - elapsedTime) // 5 minutes for God mode
            drawTimer(canvas, remainingTime)
        }

        // Draw FPS counter
        if (showFPS) {
            drawFPS(canvas, 1f / deltaTime)
        }

        // Draw game mode indicator
        drawGameMode(canvas, currentGameMode)

        // Draw crosshair hit radius indicator (subtle)
        drawCrosshairGuide(canvas)
    }

    private fun drawHUDBackground(canvas: Canvas) {
        // Top HUD bar
        canvas.drawRect(0f, 0f, Constants.SCREEN_WIDTH.toFloat(), 120f, backgroundPaint)

        // Bottom HUD bar (for FPS and other info)
        canvas.drawRect(0f, Constants.SCREEN_HEIGHT - 80f,
                       Constants.SCREEN_WIDTH.toFloat(), Constants.SCREEN_HEIGHT.toFloat(), backgroundPaint)
    }

    private fun drawScore(canvas: Canvas, score: Int) {
        val scoreText = "Score: $score"

        // Draw shadow
        paint.color = Color.BLACK
        paint.textSize = 36f
        canvas.drawText(scoreText, scoreTextPos.first + 2f, scoreTextPos.second + 2f, paint)

        // Draw main text
        paint.color = Color.WHITE
        canvas.drawText(scoreText, scoreTextPos.first, scoreTextPos.second, paint)
    }

    private fun drawAmmo(canvas: Canvas, currentAmmo: Int, maxAmmo: Int) {
        val ammoText = "Ammo: $currentAmmo/$maxAmmo"
        val color = when {
            currentAmmo == 0 -> Color.RED
            currentAmmo <= maxAmmo / 4 -> Color.YELLOW
            else -> Color.WHITE
        }

        // Draw shadow
        paint.color = Color.BLACK
        paint.textSize = 32f
        canvas.drawText(ammoText, ammoTextPos.first + 2f, ammoTextPos.second + 2f, paint)

        // Draw main text
        paint.color = color
        canvas.drawText(ammoText, ammoTextPos.first, ammoTextPos.second, paint)
    }

    private fun drawLives(canvas: Canvas, currentLives: Int, maxLives: Int) {
        val livesText = if (currentGameMode == GameMode.GOD) {
            "Lives: ∞"
        } else {
            "Lives: $currentLives/$maxLives"
        }

        val color = when {
            currentLives == 0 && currentGameMode != GameMode.GOD -> Color.RED
            currentLives == 1 && currentGameMode != GameMode.GOD -> Color.YELLOW
            else -> Color.WHITE
        }

        // Draw shadow
        paint.color = Color.BLACK
        paint.textSize = 28f
        canvas.drawText(livesText, livesTextPos.first + 2f, livesTextPos.second + 2f, paint)

        // Draw main text
        paint.color = color
        canvas.drawText(livesText, livesTextPos.first, livesTextPos.second, paint)
    }

    private fun drawTimer(canvas: Canvas, remainingTime: Float) {
        val minutes = (remainingTime / 60).toInt()
        val seconds = (remainingTime % 60).toInt()
        val timerText = String.format("Time: %02d:%02d", minutes, seconds)

        val color = when {
            remainingTime <= 30f -> Color.RED // Last 30 seconds
            remainingTime <= 60f -> Color.YELLOW // Last minute
            else -> Color.GREEN
        }

        // Draw shadow
        paint.color = Color.BLACK
        paint.textSize = 32f
        canvas.drawText(timerText, timerTextPos.first + 2f, timerTextPos.second + 2f, paint)

        // Draw main text
        paint.color = color
        canvas.drawText(timerText, timerTextPos.first, timerTextPos.second, paint)
    }

    private fun drawFPS(canvas: Canvas, fps: Float) {
        val fpsText = String.format("FPS: %.1f", fps)

        // Draw shadow
        paint.color = Color.BLACK
        paint.textSize = 24f
        canvas.drawText(fpsText, fpsTextPos.first + 1f, fpsTextPos.second + 1f, paint)

        // Draw main text
        paint.color = Color.YELLOW
        canvas.drawText(fpsText, fpsTextPos.first, fpsTextPos.second, paint)
    }

    private fun drawGameMode(canvas: Canvas, gameMode: GameMode) {
        val modeText = gameMode.displayName

        // Draw in top center
        paint.color = Color.CYAN
        paint.textSize = 28f
        paint.textAlign = Paint.Align.CENTER

        val centerX = Constants.SCREEN_WIDTH / 2f
        canvas.drawText(modeText, centerX, 50f, paint)

        // Reset text alignment
        paint.textAlign = Paint.Align.LEFT
    }

    private fun drawCrosshairGuide(canvas: Canvas) {
        // Draw a subtle guide showing the crosshair hit area
        val guidePaint = Paint().apply {
            color = Color.argb(30, 255, 255, 255) // Very transparent white
            style = Paint.Style.STROKE
            strokeWidth = 2f
        }

        // This would be positioned based on current crosshair position
        // For now, just show a general guide
        val centerX = Constants.SCREEN_WIDTH / 2f
        val centerY = Constants.SCREEN_HEIGHT / 2f
        val radius = 50f // Typical hit radius

        canvas.drawCircle(centerX, centerY, radius, guidePaint)
    }

    // Pause screen
    fun drawPauseScreen(canvas: Canvas) {
        // Semi-transparent overlay
        val overlayPaint = Paint().apply {
            color = Color.argb(180, 0, 0, 0)
            style = Paint.Style.FILL
        }
        canvas.drawRect(0f, 0f, Constants.SCREEN_WIDTH.toFloat(), Constants.SCREEN_HEIGHT.toFloat(), overlayPaint)

        // Pause text
        paint.color = Color.WHITE
        paint.textSize = 72f
        paint.textAlign = Paint.Align.CENTER

        val centerX = Constants.SCREEN_WIDTH / 2f
        val centerY = Constants.SCREEN_HEIGHT / 2f

        // Draw shadow
        paint.color = Color.BLACK
        canvas.drawText("PAUSED", centerX + 3f, centerY + 3f, paint)

        // Draw main text
        paint.color = Color.WHITE
        canvas.drawText("PAUSED", centerX, centerY, paint)

        // Instructions
        paint.textSize = 32f
        val instructions = arrayOf(
            "Tap to resume",
            "Double tap to quit"
        )

        for (i in instructions.indices) {
            val y = centerY + 100f + (i * 40f)
            canvas.drawText(instructions[i], centerX, y, paint)
        }

        paint.textAlign = Paint.Align.LEFT
    }

    // Game over screen
    fun drawGameOverScreen(canvas: Canvas, finalScore: Int, gameMode: GameMode) {
        // Semi-transparent overlay
        val overlayPaint = Paint().apply {
            color = Color.argb(200, 0, 0, 0)
            style = Paint.Style.FILL
        }
        canvas.drawRect(0f, 0f, Constants.SCREEN_WIDTH.toFloat(), Constants.SCREEN_HEIGHT.toFloat(), overlayPaint)

        paint.textAlign = Paint.Align.CENTER
        val centerX = Constants.SCREEN_WIDTH / 2f
        val centerY = Constants.SCREEN_HEIGHT / 2f

        // Game Over title
        paint.color = Color.RED
        paint.textSize = 64f

        // Shadow
        paint.color = Color.BLACK
        canvas.drawText("GAME OVER", centerX + 3f, centerY - 100f + 3f, paint)

        // Main text
        paint.color = Color.RED
        canvas.drawText("GAME OVER", centerX, centerY - 100f, paint)

        // Final score
        paint.color = Color.WHITE
        paint.textSize = 48f
        canvas.drawText("Final Score: $finalScore", centerX, centerY - 20f, paint)

        // Game mode
        paint.textSize = 32f
        canvas.drawText("Mode: ${gameMode.displayName}", centerX, centerY + 30f, paint)

        // Instructions
        paint.textSize = 28f
        val instructions = arrayOf(
            "Tap to play again",
            "Double tap for menu"
        )

        for (i in instructions.indices) {
            val y = centerY + 100f + (i * 35f)
            canvas.drawText(instructions[i], centerX, y, paint)
        }

        paint.textAlign = Paint.Align.LEFT
    }

    fun toggleFPS() {
        showFPS = !showFPS
    }
}
