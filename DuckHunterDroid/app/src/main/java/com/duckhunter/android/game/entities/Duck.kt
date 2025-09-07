package com.duckhunter.android.game.entities

import android.content.Context
import com.duckhunter.android.game.core.graphics.SpriteBatch
import com.duckhunter.android.game.core.graphics.Texture
import com.duckhunter.android.game.core.graphics.Vector2
import kotlin.math.PI
import kotlin.math.sin
import kotlin.random.Random

class Duck(private val context: Context, startX: Float, startY: Float) {

    // Position and movement
    var position = Vector2(startX, startY)
    private var velocity = Vector2(150f, 0f) // Move right at 150 pixels/second

    // Animation properties
    private var amplitude = Random.nextFloat() * 40f + 20f // 20-60 pixel wave
    private var frequency = Random.nextFloat() * 0.001f + 0.001f // Wave frequency
    private var initialY = startY
    private var time = 0f

    // State
    private var state = DuckState.FLYING
    private var isActive = true
    private var hitTime = 0f

    // Duck type (affects points and appearance)
    enum class DuckType(val pointValue: Int) {
        COMMON(100),
        RARE(500),
        GOLDEN(1000),
        BOSS(2000)
    }

    private var duckType = DuckType.values().random()

    // Visual properties
    private var size = Vector2(64f, 48f) // Duck sprite size
    private var rotation = 0f

    // Animation frames (simple for now)
    private var animationTime = 0f
    private var currentFrame = 0
    private val frameCount = 2
    private val frameDuration = 0.2f

    val pointValue: Int
        get() = duckType.pointValue

    fun update(deltaTime: Float) {
        if (!isActive) return

        time += deltaTime

        when (state) {
            DuckState.FLYING -> updateFlying(deltaTime)
            DuckState.FALLING -> updateFalling(deltaTime)
            DuckState.DEAD -> updateDead(deltaTime)
        }

        // Update animation
        animationTime += deltaTime
        if (animationTime >= frameDuration) {
            animationTime = 0f
            currentFrame = (currentFrame + 1) % frameCount
        }
    }

    private fun updateFlying(deltaTime: Float) {
        // Move horizontally
        position.x += velocity.x * deltaTime

        // Sine wave vertical movement
        position.y = initialY + amplitude * sin(time * frequency * 2 * PI.toFloat())

        // Add slight rotation based on vertical movement
        val verticalVelocity = amplitude * frequency * 2 * PI.toFloat() * cos(time * frequency * 2 * PI.toFloat())
        rotation = verticalVelocity * 0.1f // Subtle rotation

        // Check if off-screen
        if (position.x > 2000f) { // Assuming screen width ~1920
            isActive = false
        }
    }

    private fun updateFalling(deltaTime: Float) {
        // Apply gravity
        velocity.y += 980f * deltaTime // Gravity: 980 pixels/second²

        // Update position
        position.x += velocity.x * deltaTime
        position.y += velocity.y * deltaTime

        // Increase rotation for falling effect
        rotation += 360f * deltaTime // Spin while falling

        // Check if hit ground
        if (position.y <= 120f) { // Ground level
            position.y = 120f
            velocity.y = 0f
            state = DuckState.DEAD
            hitTime = 0f
        }
    }

    private fun updateDead(deltaTime: Float) {
        hitTime += deltaTime
        if (hitTime >= 2f) { // Stay dead for 2 seconds
            isActive = false
        }
    }

    fun render(spriteBatch: SpriteBatch) {
        if (!isActive) return

        // For now, render as colored rectangle
        // In full implementation, would use actual texture
        when (state) {
            DuckState.FLYING -> renderFlying(spriteBatch)
            DuckState.FALLING -> renderFalling(spriteBatch)
            DuckState.DEAD -> renderDead(spriteBatch)
        }
    }

    private fun renderFlying(spriteBatch: SpriteBatch) {
        // Simple colored rectangle for now
        val color = when (duckType) {
            DuckType.COMMON -> floatArrayOf(0.55f, 0.27f, 0.07f, 1f) // Brown
            DuckType.RARE -> floatArrayOf(0.5f, 0.5f, 0.5f, 1f) // Gray
            DuckType.GOLDEN -> floatArrayOf(1f, 0.84f, 0f, 1f) // Gold
            DuckType.BOSS -> floatArrayOf(0f, 0.39f, 0f, 1f) // Green
        }

        // Wing flapping effect
        val wingOffset = if (currentFrame == 0) 0f else 8f

        // Draw duck body
        spriteBatch.setColor(color[0], color[1], color[2], color[3])
        // Note: This would use actual texture in full implementation
        // For demo, we'll skip actual rendering until textures are implemented
    }

    private fun renderFalling(spriteBatch: SpriteBatch) {
        // Falling duck (rotated, X eyes)
        spriteBatch.setColor(0.8f, 0.8f, 0.8f, 1f)
        // Add X eyes effect for dead duck
    }

    private fun renderDead(spriteBatch: SpriteBatch) {
        // Dead duck on ground
        spriteBatch.setColor(0.4f, 0.4f, 0.4f, 1f)
    }

    fun hit() {
        if (state == DuckState.FLYING) {
            state = DuckState.FALLING
            velocity.y = -200f // Initial upward velocity when hit
            velocity.x *= 0.5f // Slow down horizontal movement
        }
    }

    fun isOffScreen(): Boolean {
        return !isActive || position.x < -200f || position.y < -200f
    }

    enum class DuckState {
        FLYING, FALLING, DEAD
    }
}
