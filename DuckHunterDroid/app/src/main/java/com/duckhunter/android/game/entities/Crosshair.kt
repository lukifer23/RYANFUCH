package com.duckhunter.android.game.entities

import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import com.duckhunter.android.game.core.graphics.SpriteBatch
import com.duckhunter.android.game.core.graphics.Vector2

class Crosshair {

    // Position
    var position = Vector2(0f, 0f)

    // Crosshair properties
    private val size = 60f
    private val hitRadius = 25f // Larger hit detection radius
    private var flashTimer = 0f
    private val flashDuration = 0.1f // 100ms flash

    // Paint objects for drawing
    private val crosshairPaint = Paint().apply {
        color = Color.WHITE
        style = Paint.Style.STROKE
        strokeWidth = 2f
        isAntiAlias = true
    }

    private val hitRadiusPaint = Paint().apply {
        color = Color.WHITE
        style = Paint.Style.STROKE
        strokeWidth = 1f
        alpha = 50 // Semi-transparent
        isAntiAlias = true
    }

    private val centerPaint = Paint().apply {
        color = Color.WHITE
        style = Paint.Style.FILL
        isAntiAlias = true
    }

    private val flashPaint = Paint().apply {
        color = Color.RED
        style = Paint.Style.FILL
        isAntiAlias = true
    }

    fun update(deltaTime: Float) {
        // Update flash timer
        if (flashTimer > 0f) {
            flashTimer -= deltaTime
        }
    }

    fun setPosition(x: Float, y: Float) {
        position.set(x, y)
    }

    fun flash() {
        flashTimer = flashDuration
    }

    fun getHitRadius(): Float = hitRadius

    fun render(spriteBatch: SpriteBatch) {
        val centerX = position.x
        val centerY = position.y

        // Choose color based on flash state
        val color = if (flashTimer > 0f) {
            floatArrayOf(1f, 0f, 0f, 1f) // Red flash
        } else {
            floatArrayOf(1f, 1f, 1f, 1f) // White normal
        }

        spriteBatch.setColor(color[0], color[1], color[2], color[3])

        // Draw outer circle (hit radius indicator)
        spriteBatch.drawQuad(centerX - hitRadius, centerY - hitRadius, hitRadius * 2, hitRadius * 2)

        // Draw inner circle
        spriteBatch.setColor(color[0], color[1], color[2], 0.8f)
        spriteBatch.drawQuad(centerX - 15f, centerY - 15f, 30f, 30f)

        // Draw cross lines (horizontal and vertical)
        val lineThickness = 3f
        // Horizontal line
        spriteBatch.drawQuad(centerX - 12f, centerY - lineThickness/2, 24f, lineThickness)
        // Vertical line
        spriteBatch.drawQuad(centerX - lineThickness/2, centerY - 12f, lineThickness, 24f)

        // Draw center dot
        spriteBatch.setColor(color[0], color[1], color[2], 1f)
        spriteBatch.drawQuad(centerX - 3f, centerY - 3f, 6f, 6f)
    }

    fun render(canvas: Canvas, showHitRadius: Boolean = false) {
        val centerX = position.x
        val centerY = position.y

        // Draw hit radius indicator when aiming at targets
        if (showHitRadius) {
            canvas.drawCircle(centerX, centerY, hitRadius, hitRadiusPaint)
        }

        // Choose paint based on flash state
        val currentPaint = if (flashTimer > 0f) flashPaint else crosshairPaint

        // Draw outer circle (hit radius indicator)
        canvas.drawCircle(centerX, centerY, hitRadius, currentPaint.apply {
            style = Paint.Style.STROKE
            strokeWidth = 2f
        })

        // Draw inner circle
        canvas.drawCircle(centerX, centerY, 15f, currentPaint.apply {
            style = Paint.Style.STROKE
            strokeWidth = 1f
        })

        // Draw cross lines (longer for better visibility)
        canvas.drawLine(centerX, centerY - 12f, centerX, centerY - 3f, currentPaint.apply { strokeWidth = 2f })
        canvas.drawLine(centerX, centerY + 3f, centerX, centerY + 12f, currentPaint.apply { strokeWidth = 2f })
        canvas.drawLine(centerX - 12f, centerY, centerX - 3f, centerY, currentPaint.apply { strokeWidth = 2f })
        canvas.drawLine(centerX + 3f, centerY, centerX + 12f, centerY, currentPaint.apply { strokeWidth = 2f })

        // Draw center dot
        canvas.drawCircle(centerX, centerY, 3f, currentPaint.apply { style = Paint.Style.FILL })
    }

    fun isPointInHitRadius(targetX: Float, targetY: Float): Boolean {
        val dx = targetX - position.x
        val dy = targetY - position.y
        val distance = kotlin.math.sqrt(dx * dx + dy * dy)
        return distance <= hitRadius
    }
}