package com.duckhunter.android.game.entities

import android.content.Context
import com.duckhunter.android.game.core.graphics.SpriteBatch
import com.duckhunter.android.game.core.graphics.Texture
import com.duckhunter.android.game.core.graphics.Vector2
import kotlin.math.PI
import kotlin.math.cos
import kotlin.math.sin
import kotlin.random.Random

class Duck(duckType: DuckType = DuckType.COMMON, startX: Float, startY: Float) {

    // Duck type properties - data-driven from Python version
    private val typeData = getDuckTypeData(duckType)
    var duckType = duckType

    // Position and movement
    var position = Vector2(startX, startY)
    var speed = Random.nextFloat() * (typeData.speedRange.second - typeData.speedRange.first) + typeData.speedRange.first
    private var velocity = Vector2(speed, 0f)

    // AI properties (based on duck type)
    private var amplitude = Random.nextFloat() * (typeData.amplitudeRange.second - typeData.amplitudeRange.first) + typeData.amplitudeRange.first
    private var frequency = Random.nextFloat() * (typeData.frequencyRange.second - typeData.frequencyRange.first) + typeData.frequencyRange.first
    private var initialY = startY
    private var time = 0f

    // State
    var state = DuckState.FLYING
        private set
    private var isActive = true
    private var hitTime = 0f

    // Duck type data class
    data class DuckTypeData(
        val points: Int,
        val speedRange: Pair<Float, Float>,
        val amplitudeRange: Pair<Float, Float>,
        val frequencyRange: Pair<Float, Float>,
        val colorScheme: Int // 0-3 for different colors
    )

    // Duck types with properties matching Python version
    enum class DuckType(val displayName: String) {
        COMMON("Common"),
        RARE("Rare"),
        GOLDEN("Golden"),
        BOSS("Boss")
    }

    // Visual properties
    private var size = Vector2(64f, 48f) // Duck sprite size
    private var rotation = 0f

    // Animation frames (simple for now)
    private var animationTime = 0f
    private var currentFrame = 0
    private val frameCount = 2
    private val frameDuration = 0.2f

    val pointValue: Int
        get() = typeData.points

    // Get duck type data - matching Python implementation
    private fun getDuckTypeData(duckType: DuckType): DuckTypeData {
        return when (duckType) {
            DuckType.COMMON -> DuckTypeData(
                points = 100,
                speedRange = Pair(150f, 250f),
                amplitudeRange = Pair(20f, 60f),
                frequencyRange = Pair(0.01f, 0.02f),
                colorScheme = 0 // Brown duck
            )
            DuckType.RARE -> DuckTypeData(
                points = 500,
                speedRange = Pair(200f, 350f),
                amplitudeRange = Pair(30f, 80f),
                frequencyRange = Pair(0.015f, 0.025f),
                colorScheme = 1 // Gray duck
            )
            DuckType.GOLDEN -> DuckTypeData(
                points = 1000,
                speedRange = Pair(300f, 450f),
                amplitudeRange = Pair(40f, 100f),
                frequencyRange = Pair(0.02f, 0.03f),
                colorScheme = 2 // Golden duck
            )
            DuckType.BOSS -> DuckTypeData(
                points = 2000,
                speedRange = Pair(100f, 200f),
                amplitudeRange = Pair(10f, 30f),
                frequencyRange = Pair(0.005f, 0.01f),
                colorScheme = 3 // Green duck
            )
        }
    }

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
        // Get colors based on duck type - matching Python implementation
        val colors = getDuckColors()

        // Create procedural duck sprite
        val duckBitmap = createProceduralDuckFlying(colors)
        if (duckBitmap != null) {
            // Convert to texture and render
            // For now, render as colored rectangle with proper shape
            renderProceduralDuck(spriteBatch, colors, false)
        } else {
            // Fallback to simple colored rectangle
            renderSimpleDuck(spriteBatch, colors, false)
        }
    }

    private fun renderFalling(spriteBatch: SpriteBatch) {
        // Get colors based on duck type
        val colors = getDuckColors()

        // Create procedural falling duck sprite (with X eyes)
        val duckBitmap = createProceduralDuckFalling(colors)
        if (duckBitmap != null) {
            renderProceduralDuck(spriteBatch, colors, true)
        } else {
            renderSimpleDuck(spriteBatch, colors, true)
        }
    }

    private fun getDuckColors(): DuckColors {
        return when (typeData.colorScheme) {
            0 -> DuckColors(0.55f, 0.27f, 0.07f, 0.72f, 0.33f, 0.20f, 1.0f, 0.65f, 0.0f, 0f, 0f, 0f) // Brown duck
            1 -> DuckColors(0.41f, 0.41f, 0.41f, 0.51f, 0.51f, 0.51f, 1.0f, 0.70f, 0.0f, 0f, 0f, 0f) // Gray duck
            2 -> DuckColors(1.0f, 0.84f, 0.0f, 1.0f, 0.89f, 0.0f, 1.0f, 0.35f, 0.0f, 0f, 0f, 0f) // Golden duck
            3 -> DuckColors(0.0f, 0.39f, 0.0f, 0.0f, 0.51f, 0.0f, 1.0f, 0.08f, 0.59f, 0f, 0f, 0f) // Green duck
            else -> DuckColors(0.55f, 0.27f, 0.07f, 0.72f, 0.33f, 0.20f, 1.0f, 0.65f, 0.0f, 0f, 0f, 0f)
        }
    }

    private data class DuckColors(
        val bodyR: Float, val bodyG: Float, val bodyB: Float,
        val headR: Float, val headG: Float, val headB: Float,
        val wingR: Float, val wingG: Float, val wingB: Float,
        val beakR: Float, val beakG: Float, val beakB: Float
    )

    private fun createProceduralDuckFlying(colors: DuckColors): android.graphics.Bitmap? {
        return try {
            val width = 48
            val height = 32
            val bitmap = android.graphics.Bitmap.createBitmap(width, height, android.graphics.Bitmap.Config.ARGB_8888)
            val canvas = android.graphics.Canvas(bitmap)

            val paint = android.graphics.Paint().apply {
                isAntiAlias = true
                style = android.graphics.Paint.Style.FILL
            }

            // Frame 1: Wings up (currentFrame == 0) or Frame 2: Wings down (currentFrame == 1)
            val wingOffset = if (currentFrame == 0) 0f else 8f

            // Body (main ellipse)
            paint.color = android.graphics.Color.argb(255,
                (colors.bodyR * 255).toInt(),
                (colors.bodyG * 255).toInt(),
                (colors.bodyB * 255).toInt())
            canvas.drawOval(4f, 12f, 36f, 20f, paint)

            // Head
            paint.color = android.graphics.Color.argb(255,
                (colors.headR * 255).toInt(),
                (colors.headG * 255).toInt(),
                (colors.headB * 255).toInt())
            canvas.drawCircle(36f, 12f, 8f, paint)

            // Wing (position based on current frame)
            paint.color = android.graphics.Color.argb(255,
                (colors.wingR * 255).toInt(),
                (colors.wingG * 255).toInt(),
                (colors.wingB * 255).toInt())

            if (currentFrame == 0) {
                // Wings up
                canvas.drawOval(12f + wingOffset, 8f, 28f + wingOffset, 16f, paint)
            } else {
                // Wings down
                canvas.drawOval(12f + wingOffset, 16f, 28f + wingOffset, 24f, paint)
            }

            // Beak
            paint.color = android.graphics.Color.argb(255,
                (colors.beakR * 255).toInt(),
                (colors.beakG * 255).toInt(),
                (colors.beakB * 255).toInt())
            val beakPath = android.graphics.Path().apply {
                moveTo(44f, 12f)
                lineTo(48f, 10f)
                lineTo(48f, 14f)
                close()
            }
            canvas.drawPath(beakPath, paint)

            // Eye
            paint.color = android.graphics.Color.BLACK
            canvas.drawCircle(38f, 9f, 2f, paint)

            bitmap
        } catch (e: Exception) {
            android.util.Log.e("Duck", "Error creating procedural duck", e)
            null
        }
    }

    private fun createProceduralDuckFalling(colors: DuckColors): android.graphics.Bitmap? {
        return try {
            val width = 48
            val height = 32
            val bitmap = android.graphics.Bitmap.createBitmap(width, height, android.graphics.Bitmap.Config.ARGB_8888)
            val canvas = android.graphics.Canvas(bitmap)

            val paint = android.graphics.Paint().apply {
                isAntiAlias = true
                style = android.graphics.Paint.Style.FILL
            }

            // Body (main ellipse)
            paint.color = android.graphics.Color.argb(255,
                (colors.bodyR * 255).toInt(),
                (colors.bodyG * 255).toInt(),
                (colors.bodyB * 255).toInt())
            canvas.drawOval(4f, 12f, 36f, 20f, paint)

            // Head
            paint.color = android.graphics.Color.argb(255,
                (colors.headR * 255).toInt(),
                (colors.headG * 255).toInt(),
                (colors.headB * 255).toInt())
            canvas.drawCircle(36f, 12f, 8f, paint)

            // Wings (spread out for falling)
            paint.color = android.graphics.Color.argb(255,
                (colors.wingR * 255).toInt(),
                (colors.wingG * 255).toInt(),
                (colors.wingB * 255).toInt())
            canvas.drawOval(8f, 10f, 24f, 16f, paint) // Upper wing
            canvas.drawOval(8f, 16f, 24f, 22f, paint) // Lower wing

            // Beak
            paint.color = android.graphics.Color.argb(255,
                (colors.beakR * 255).toInt(),
                (colors.beakG * 255).toInt(),
                (colors.beakB * 255).toInt())
            val beakPath = android.graphics.Path().apply {
                moveTo(44f, 12f)
                lineTo(48f, 10f)
                lineTo(48f, 14f)
                close()
            }
            canvas.drawPath(beakPath, paint)

            // X eyes (dead duck)
            paint.color = android.graphics.Color.RED
            paint.strokeWidth = 2f
            paint.style = android.graphics.Paint.Style.STROKE

            // Left X
            canvas.drawLine(34f, 8f, 38f, 12f, paint)
            canvas.drawLine(38f, 8f, 34f, 12f, paint)

            bitmap
        } catch (e: Exception) {
            android.util.Log.e("Duck", "Error creating procedural falling duck", e)
            null
        }
    }

    private fun renderProceduralDuck(spriteBatch: SpriteBatch, colors: DuckColors, isFalling: Boolean) {
        // For now, render the procedural graphics as colored shapes
        // In full implementation, this would use the bitmap textures

        val baseColor = if (isFalling) {
            floatArrayOf(colors.bodyR * 0.8f, colors.bodyG * 0.8f, colors.bodyB * 0.8f, 1f)
        } else {
            floatArrayOf(colors.bodyR, colors.bodyG, colors.bodyB, 1f)
        }

        spriteBatch.setColor(baseColor[0], baseColor[1], baseColor[2], baseColor[3])

        // Apply rotation for falling duck
        val renderRotation = if (isFalling) rotation else 0f

        // Render as a colored ellipse representing the duck
        // In full implementation, this would render the actual bitmap texture
        renderSimpleDuck(spriteBatch, colors, isFalling)
    }

    private fun renderSimpleDuck(spriteBatch: SpriteBatch, colors: DuckColors, isFalling: Boolean) {
        val color = when (duckType) {
            DuckType.COMMON -> floatArrayOf(colors.bodyR, colors.bodyG, colors.bodyB, 1f)
            DuckType.RARE -> floatArrayOf(colors.headR, colors.headG, colors.headB, 1f)
            DuckType.GOLDEN -> floatArrayOf(colors.wingR, colors.wingG, colors.wingB, 1f)
            DuckType.BOSS -> floatArrayOf(0f, colors.wingG, 0f, 1f)
        }

        // Adjust alpha for falling/dead states
        val alpha = when (state) {
            DuckState.FLYING -> 1f
            DuckState.FALLING -> 0.9f
            DuckState.DEAD -> 0.6f
        }

        spriteBatch.setColor(color[0], color[1], color[2], alpha)

        // Render duck as colored rectangle with proper aspect ratio
        // This represents the duck's body - in full implementation this would be the actual sprite
        // For now, render as a simple colored quad representing the duck shape

        val renderRotation = if (isFalling) rotation else 0f
        val scale = if (isFalling) 0.8f else 1.0f // Slightly smaller when falling

        // Render body (ellipse shape approximated with quad)
        spriteBatch.drawQuad(
            position.x - size.x/2 * scale,
            position.y - size.y/2 * scale,
            size.x * scale,
            size.y * scale,
            renderRotation
        )
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
