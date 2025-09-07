package com.duckhunter.android.game.entities

import android.content.Context
import com.duckhunter.android.game.core.graphics.SpriteBatch
import com.duckhunter.android.game.core.graphics.Vector2
import kotlin.random.Random

class GroundAnimal(private val context: Context, val animalType: AnimalType, startX: Float, startY: Float) {

    // Position and movement
    var position = Vector2(startX, startY)
    private var velocity = Vector2(-100f, 0f) // Move left at 100 pixels/second

    // Animation properties
    private var animationTime = 0f
    private var currentFrame = 0
    private val frameCount = 2
    private val frameDuration = 0.3f

    // State
    private var state = AnimalState.WALKING
    private var isActive = true
    private var hitTime = 0f

    // Visuals
    private var texture: Texture? = null

    // Size based on animal type
    private var size = when (animalType) {
        AnimalType.RABBIT -> Vector2(32f, 24f)
        AnimalType.DEER -> Vector2(48f, 36f)
        AnimalType.WOLF -> Vector2(56f, 40f)
        AnimalType.MOOSE -> Vector2(64f, 48f)
        AnimalType.BEAR -> Vector2(72f, 52f)
        AnimalType.DINOSAUR -> Vector2(80f, 60f)
    }

    enum class AnimalType(val pointValue: Int) {
        RABBIT(150),
        DEER(200),
        WOLF(600),
        MOOSE(800),
        BEAR(1000),
        DINOSAUR(1500)
    }

    enum class AnimalState {
        WALKING, HIT, DEAD
    }

    val pointValue: Int
        get() = animalType.pointValue

    init {
        texture = Texture.createSolidColor(context, 1, 1, 1f, 1f, 1f)
    }

    fun update(deltaTime: Float) {
        if (!isActive) return

        animationTime += deltaTime
        if (animationTime >= frameDuration) {
            animationTime = 0f
            currentFrame = (currentFrame + 1) % frameCount
        }

        when (state) {
            AnimalState.WALKING -> updateWalking(deltaTime)
            AnimalState.HIT -> updateHit(deltaTime)
            AnimalState.DEAD -> updateDead(deltaTime)
        }
    }

    private fun updateWalking(deltaTime: Float) {
        // Move left across screen
        position.x += velocity.x * deltaTime

        // Add slight vertical bobbing for walking effect
        val bobAmount = 2f
        val bobSpeed = 4f
        position.y = position.y + bobAmount * kotlin.math.sin(animationTime * bobSpeed)

        // Check if off-screen
        if (position.x < -200f) {
            isActive = false
        }
    }

    private fun updateHit(deltaTime: Float) {
        hitTime += deltaTime

        // Simple hit animation - animal stops and fades
        velocity.x = 0f

        if (hitTime >= 1f) { // Hit animation duration
            state = AnimalState.DEAD
            hitTime = 0f
        }
    }

    private fun updateDead(deltaTime: Float) {
        hitTime += deltaTime

        // Stay dead for a moment, then disappear
        if (hitTime >= 1.5f) {
            isActive = false
        }
    }

    fun render(spriteBatch: SpriteBatch) {
        if (!isActive) return

        // Set color based on animal type and state
        val color = when (animalType) {
            AnimalType.RABBIT -> floatArrayOf(0.8f, 0.8f, 0.8f, 1f) // White/gray
            AnimalType.DEER -> floatArrayOf(0.6f, 0.4f, 0.2f, 1f) // Brown
            AnimalType.WOLF -> floatArrayOf(0.4f, 0.4f, 0.4f, 1f) // Gray
            AnimalType.MOOSE -> floatArrayOf(0.5f, 0.3f, 0.2f, 1f) // Dark brown
            AnimalType.BEAR -> floatArrayOf(0.4f, 0.3f, 0.2f, 1f) // Brown
            AnimalType.DINOSAUR -> floatArrayOf(0.2f, 0.5f, 0.2f, 1f) // Green
        }

        // Adjust alpha for hit/dead states
        val alpha = when (state) {
            AnimalState.WALKING -> 1f
            AnimalState.HIT -> 0.7f
            AnimalState.DEAD -> 0.3f
        }

        spriteBatch.setColor(color[0], color[1], color[2], alpha)

        // Walking animation effect
        val walkOffset = when (state) {
            AnimalState.WALKING -> if (currentFrame == 0) 0f else 4f
            else -> 0f
        }

        // Render as colored rectangle for now
        // In full implementation, would use actual texture atlas
        texture?.let {
            spriteBatch.draw(it, position.x + walkOffset, position.y, size.x, size.y)
        }
    }

    fun hit() {
        if (state == AnimalState.WALKING) {
            state = AnimalState.HIT
            hitTime = 0f
        }
    }

    fun isOffScreen(): Boolean {
        return !isActive || position.x < -200f || position.y > 1200f
    }

    fun getBounds(): android.graphics.RectF {
        return android.graphics.RectF(
            position.x,
            position.y,
            position.x + size.x,
            position.y + size.y
        )
    }
}
