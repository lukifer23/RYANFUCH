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
    var state = AnimalState.WALKING
        private set
    private var isActive = true
    private var hitTime = 0f

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
            AnimalType.RABBIT -> floatArrayOf(1f, 1f, 1f, 1f) // White
            AnimalType.DEER -> floatArrayOf(0.55f, 0.27f, 0.07f, 1f) // Brown
            AnimalType.WOLF -> floatArrayOf(0.5f, 0.5f, 0.5f, 1f) // Gray
            AnimalType.MOOSE -> floatArrayOf(0.4f, 0.26f, 0.13f, 1f) // Dark brown
            AnimalType.BEAR -> floatArrayOf(0.4f, 0.3f, 0.2f, 1f) // Brown
            AnimalType.DINOSAUR -> floatArrayOf(0f, 0.5f, 0f, 1f) // Green
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

        // Try to render procedural sprite first
        val animalBitmap = createProceduralGroundAnimal()
        if (animalBitmap != null) {
            // In full implementation, this would convert bitmap to texture and render
            // For now, render as a simple colored quad
            renderSimpleAnimal(spriteBatch, walkOffset)
        } else {
            // Fallback to simple colored rectangle
            renderSimpleAnimal(spriteBatch, walkOffset)
        }
    }

    private fun renderSimpleAnimal(spriteBatch: SpriteBatch, walkOffset: Float) {
        // Render as colored rectangle representing the animal
        spriteBatch.drawQuad(position.x + walkOffset, position.y, size.x, size.y)
    }

    private fun createProceduralGroundAnimal(): android.graphics.Bitmap? {
        return try {
            val width = size.x.toInt()
            val height = size.y.toInt()
            val bitmap = android.graphics.Bitmap.createBitmap(width, height, android.graphics.Bitmap.Config.ARGB_8888)
            val canvas = android.graphics.Canvas(bitmap)

            val paint = android.graphics.Paint().apply {
                isAntiAlias = true
                style = android.graphics.Paint.Style.FILL
            }

            when (animalType) {
                AnimalType.RABBIT -> createRabbitSprite(canvas, paint)
                AnimalType.DEER -> createDeerSprite(canvas, paint)
                AnimalType.WOLF -> createWolfSprite(canvas, paint)
                AnimalType.MOOSE -> createMooseSprite(canvas, paint)
                AnimalType.BEAR -> createBearSprite(canvas, paint)
                AnimalType.DINOSAUR -> createDinosaurSprite(canvas, paint)
            }

            bitmap
        } catch (e: Exception) {
            android.util.Log.e("GroundAnimal", "Error creating procedural animal", e)
            null
        }
    }

    private fun createRabbitSprite(canvas: android.graphics.Canvas, paint: android.graphics.Paint) {
        // Rabbit body (white)
        paint.color = android.graphics.Color.rgb(255, 255, 255)
        canvas.drawOval(8f, 12f, 24f, 20f, paint)

        // Rabbit head
        canvas.drawCircle(28f, 14f, 6f, paint)

        // Rabbit ears (long and upright)
        paint.color = android.graphics.Color.rgb(255, 255, 255)
        canvas.drawRect(26f, 4f, 30f, 12f, paint)
        canvas.drawRect(26.5f, 4.5f, 29.5f, 11.5f, paint)

        // Rabbit eyes
        paint.color = android.graphics.Color.BLACK
        canvas.drawCircle(30f, 12f, 1f, paint)

        // Rabbit nose
        paint.color = android.graphics.Color.rgb(255, 192, 203)
        canvas.drawCircle(32f, 14f, 0.5f, paint)

        // Rabbit feet
        paint.color = android.graphics.Color.rgb(255, 255, 255)
        canvas.drawOval(12f, 18f, 16f, 22f, paint)
        canvas.drawOval(16f, 18f, 20f, 22f, paint)
    }

    private fun createDeerSprite(canvas: android.graphics.Canvas, paint: android.graphics.Paint) {
        // Deer body (brown)
        paint.color = android.graphics.Color.rgb(139, 69, 19)
        canvas.drawOval(6f, 10f, 28f, 20f, paint)

        // Deer head
        canvas.drawOval(24f, 8f, 32f, 16f, paint)

        // Deer antlers
        paint.color = android.graphics.Color.rgb(101, 67, 33)
        canvas.drawRect(26f, 4f, 28f, 8f, paint)
        canvas.drawRect(28f, 4f, 30f, 8f, paint)

        // Deer eyes
        paint.color = android.graphics.Color.BLACK
        canvas.drawCircle(28f, 10f, 1f, paint)

        // Deer nose
        paint.color = android.graphics.Color.rgb(160, 82, 45)
        canvas.drawCircle(32f, 12f, 0.5f, paint)

        // Deer legs
        paint.color = android.graphics.Color.rgb(139, 69, 19)
        canvas.drawRect(10f, 16f, 12f, 20f, paint)
        canvas.drawRect(14f, 16f, 16f, 20f, paint)
        canvas.drawRect(18f, 16f, 20f, 20f, paint)
        canvas.drawRect(22f, 16f, 24f, 20f, paint)
    }

    private fun createWolfSprite(canvas: android.graphics.Canvas, paint: android.graphics.Paint) {
        // Wolf body (gray)
        paint.color = android.graphics.Color.rgb(128, 128, 128)
        canvas.drawOval(8f, 12f, 28f, 20f, paint)

        // Wolf head
        canvas.drawOval(24f, 8f, 32f, 18f, paint)

        // Wolf ears
        paint.color = android.graphics.Color.rgb(64, 64, 64)
        val path = android.graphics.Path().apply {
            moveTo(26f, 8f)
            lineTo(28f, 4f)
            lineTo(30f, 8f)
            close()
        }
        canvas.drawPath(path, paint)

        // Wolf eyes (yellow)
        paint.color = android.graphics.Color.rgb(255, 255, 0)
        canvas.drawCircle(28f, 12f, 1.5f, paint)

        // Wolf pupils
        paint.color = android.graphics.Color.BLACK
        canvas.drawCircle(28f, 12f, 0.5f, paint)

        // Wolf nose
        paint.color = android.graphics.Color.BLACK
        canvas.drawCircle(32f, 14f, 0.5f, paint)

        // Wolf tail
        paint.color = android.graphics.Color.rgb(128, 128, 128)
        canvas.drawOval(4f, 14f, 10f, 18f, paint)
    }

    private fun createMooseSprite(canvas: android.graphics.Canvas, paint: android.graphics.Paint) {
        // Moose body (dark brown)
        paint.color = android.graphics.Color.rgb(101, 67, 33)
        canvas.drawOval(4f, 12f, 32f, 22f, paint)

        // Moose head
        canvas.drawOval(26f, 6f, 36f, 18f, paint)

        // Moose antlers (large and palmate)
        paint.color = android.graphics.Color.rgb(139, 69, 19)
        canvas.drawOval(24f, 2f, 38f, 10f, paint)

        // Moose eyes
        paint.color = android.graphics.Color.BLACK
        canvas.drawCircle(30f, 10f, 1f, paint)

        // Moose nose
        paint.color = android.graphics.Color.rgb(160, 82, 45)
        canvas.drawCircle(36f, 14f, 0.5f, paint)

        // Moose legs (thick)
        paint.color = android.graphics.Color.rgb(101, 67, 33)
        canvas.drawRect(8f, 18f, 12f, 24f, paint)
        canvas.drawRect(14f, 18f, 18f, 24f, paint)
        canvas.drawRect(20f, 18f, 24f, 24f, paint)
        canvas.drawRect(26f, 18f, 30f, 24f, paint)
    }

    private fun createBearSprite(canvas: android.graphics.Canvas, paint: android.graphics.Paint) {
        // Bear body (brown)
        paint.color = android.graphics.Color.rgb(139, 69, 19)
        canvas.drawOval(6f, 14f, 30f, 24f, paint)

        // Bear head (round)
        canvas.drawCircle(32f, 16f, 8f, paint)

        // Bear ears
        canvas.drawCircle(28f, 10f, 2f, paint)
        canvas.drawCircle(36f, 10f, 2f, paint)

        // Bear eyes
        paint.color = android.graphics.Color.BLACK
        canvas.drawCircle(30f, 14f, 1f, paint)
        canvas.drawCircle(34f, 14f, 1f, paint)

        // Bear nose
        paint.color = android.graphics.Color.rgb(101, 67, 33)
        canvas.drawCircle(32f, 18f, 0.5f, paint)

        // Bear legs
        paint.color = android.graphics.Color.rgb(139, 69, 19)
        canvas.drawRect(10f, 20f, 14f, 26f, paint)
        canvas.drawRect(16f, 20f, 20f, 26f, paint)
        canvas.drawRect(22f, 20f, 26f, 26f, paint)
        canvas.drawRect(28f, 20f, 32f, 26f, paint)
    }

    private fun createDinosaurSprite(canvas: android.graphics.Canvas, paint: android.graphics.Paint) {
        // Dinosaur body (green)
        paint.color = android.graphics.Color.rgb(0, 128, 0)
        canvas.drawOval(8f, 14f, 28f, 22f, paint)

        // Dinosaur head (triangular)
        val headPath = android.graphics.Path().apply {
            moveTo(28f, 8f)
            lineTo(36f, 14f)
            lineTo(28f, 20f)
            close()
        }
        canvas.drawPath(headPath, paint)

        // Dinosaur spikes along back
        paint.color = android.graphics.Color.rgb(0, 100, 0)
        for (i in 0..3) {
            val x = 10f + i * 6f
            canvas.drawTriangle(x, 12f, x + 2f, 8f, x + 4f, 12f, paint)
        }

        // Dinosaur eyes
        paint.color = android.graphics.Color.YELLOW
        canvas.drawCircle(30f, 12f, 1.5f, paint)

        // Dinosaur pupils
        paint.color = android.graphics.Color.BLACK
        canvas.drawCircle(30f, 12f, 0.5f, paint)

        // Dinosaur legs (powerful)
        paint.color = android.graphics.Color.rgb(0, 128, 0)
        canvas.drawRect(12f, 20f, 16f, 26f, paint)
        canvas.drawRect(20f, 20f, 24f, 26f, paint)
    }

    // Helper function to draw triangles
    private fun android.graphics.Canvas.drawTriangle(x1: Float, y1: Float, x2: Float, y2: Float, x3: Float, y3: Float, paint: android.graphics.Paint) {
        val path = android.graphics.Path().apply {
            moveTo(x1, y1)
            lineTo(x2, y2)
            lineTo(x3, y3)
            close()
        }
        drawPath(path, paint)
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
