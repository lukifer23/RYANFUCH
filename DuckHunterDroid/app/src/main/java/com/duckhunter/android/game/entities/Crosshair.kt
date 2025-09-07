package com.duckhunter.android.game.entities

import com.duckhunter.android.game.core.graphics.SpriteBatch
import com.duckhunter.android.game.core.graphics.Texture
import com.duckhunter.android.game.core.graphics.Vector2
import android.content.Context

class Crosshair(private val context: Context) {

    // Position
    private var position = Vector2(960f, 540f) // Center of screen initially
    private var targetPosition = Vector2(960f, 540f)

    // Visual properties
    private val size = Vector2(60f, 60f)
    private val hitRadius = 25f

    // Animation properties
    private var scale = 1f
    private var alpha = 1f
    private var hitEffectTime = 0f
    private val hitEffectDuration = 0.2f

    // Colors
    private val normalColor = floatArrayOf(1f, 1f, 1f, 1f) // White
    private val hitColor = floatArrayOf(1f, 0.5f, 0f, 1f) // Orange/red

    private var texture: Texture? = null

    init {
        texture = Texture.createSolidColor(context, 1, 1, 1f, 1f, 1f)
    }

    fun update(deltaTime: Float) {
        // Smooth movement towards target position
        val smoothing = 10f // Higher = faster following
        val deltaX = (targetPosition.x - position.x) * smoothing * deltaTime
        val deltaY = (targetPosition.y - position.y) * smoothing * deltaTime

        position.x += deltaX
        position.y += deltaY

        // Update hit effect
        if (hitEffectTime > 0f) {
            hitEffectTime -= deltaTime
            scale = 1f + (hitEffectTime / hitEffectDuration) * 0.3f
            alpha = 0.8f + (hitEffectTime / hitEffectDuration) * 0.2f
        } else {
            scale = 1f
            alpha = 1f
        }
    }

    fun render(spriteBatch: SpriteBatch) {
        // Set color based on hit effect
        val currentColor = if (hitEffectTime > 0f) hitColor else normalColor
        spriteBatch.setColor(currentColor[0], currentColor[1], currentColor[2], currentColor[3] * alpha)

        // Render crosshair as geometric shapes
        // In full implementation, would use texture
        renderCrosshairGeometry(spriteBatch)
    }

    private fun renderCrosshairGeometry(spriteBatch: SpriteBatch) {
        texture?.let {
            val scaledSize = Vector2(size.x * scale, size.y * scale)
            val halfWidth = scaledSize.x / 2f
            val halfHeight = scaledSize.y / 2f

            // Render hit radius circle (semi-transparent)
            spriteBatch.setColor(1f, 1f, 1f, 0.3f * alpha)
            // Circle rendering would be implemented with geometry shader or multiple quads

            // Reset to main color
            val currentColor = if (hitEffectTime > 0f) hitColor else normalColor
            spriteBatch.setColor(currentColor[0], currentColor[1], currentColor[2], currentColor[3] * alpha)
            spriteBatch.draw(it, position.x - halfWidth, position.y - halfHeight, scaledSize.x, scaledSize.y)
        }
    }

    fun setPosition(x: Float, y: Float) {
        targetPosition.set(x, y)
    }

    fun setPosition(position: Vector2) {
        targetPosition.set(position)
    }

    fun triggerHitEffect() {
        hitEffectTime = hitEffectDuration
    }

    fun getPosition(): Vector2 = position

    fun getHitRadius(): Float = hitRadius

    fun getBounds(): android.graphics.RectF {
        return android.graphics.RectF(
            position.x - hitRadius,
            position.y - hitRadius,
            position.x + hitRadius,
            position.y + hitRadius
        )
    }

    fun isPointInHitRadius(point: Vector2): Boolean {
        val distance = position.distance(point)
        return distance <= hitRadius
    }
}
