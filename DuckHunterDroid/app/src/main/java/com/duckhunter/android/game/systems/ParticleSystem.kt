package com.duckhunter.android.game.systems

import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import com.duckhunter.android.game.core.graphics.SpriteBatch
import com.duckhunter.android.game.core.graphics.Vector2
import kotlin.math.sin
import kotlin.random.Random

class ParticleSystem {

    private data class Particle(
        val position: Vector2,
        var velocity: Vector2,
        val color: Int,
        val size: Float,
        var life: Float,
        val maxLife: Float,
        val type: ParticleType
    )

    private enum class ParticleType {
        FEATHER, SPARK, SMOKE
    }

    private val particles = mutableListOf<Particle>()
    private val paint = Paint().apply {
        style = Paint.Style.FILL
        isAntiAlias = true
    }

    fun update(deltaTime: Float) {
        // Update all particles
        val iterator = particles.iterator()
        while (iterator.hasNext()) {
            val particle = iterator.next()

            // Update position
            particle.position.x += particle.velocity.x * deltaTime
            particle.position.y += particle.velocity.y * deltaTime

            // Apply gravity to feathers
            if (particle.type == ParticleType.FEATHER) {
                particle.velocity.y += 200f * deltaTime // Gravity
                // Add some floating motion
                particle.velocity.x += sin(particle.life * 10f) * 20f * deltaTime
            }

            // Update life
            particle.life -= deltaTime

            // Remove dead particles
            if (particle.life <= 0f) {
                iterator.remove()
            }
        }
    }

    fun render(canvas: Canvas) {
        particles.forEach { particle ->
            val alpha = (particle.life / particle.maxLife * 255).toInt().coerceIn(0, 255)
            val colorWithAlpha = Color.argb(alpha, Color.red(particle.color),
                                          Color.green(particle.color), Color.blue(particle.color))

            paint.color = colorWithAlpha

            when (particle.type) {
                ParticleType.FEATHER -> {
                    // Draw feather as a small rectangle with slight rotation
                    val rotation = particle.velocity.x * 0.1f
                    canvas.save()
                    canvas.rotate(rotation, particle.position.x, particle.position.y)
                    canvas.drawRect(
                        particle.position.x - particle.size/2,
                        particle.position.y - particle.size,
                        particle.position.x + particle.size/2,
                        particle.position.y + particle.size/2,
                        paint
                    )
                    canvas.restore()
                }
                ParticleType.SPARK -> {
                    // Draw spark as a small circle
                    canvas.drawCircle(particle.position.x, particle.position.y, particle.size, paint)
                }
                ParticleType.SMOKE -> {
                    // Draw smoke as a soft circle
                    paint.alpha = (alpha * 0.5f).toInt()
                    canvas.drawCircle(particle.position.x, particle.position.y, particle.size, paint)
                }
            }
        }
    }

    // Alternative render method for SpriteBatch
    fun render(spriteBatch: SpriteBatch) {
        // This would be used for OpenGL rendering in the future
        // For now, we use the Canvas-based rendering above
    }

    fun emitFeathers(position: Vector2) {
        // Create feather particles when a duck is hit
        val featherColors = arrayOf(
            Color.rgb(255, 255, 255), // White
            Color.rgb(245, 245, 220), // Beige
            Color.rgb(255, 250, 205)  // Light yellow
        )

        for (i in 0..8) { // 9 feathers
            val angle = (i / 8f) * 360f
            val speed = 50f + Random.nextFloat() * 100f
            val velocity = Vector2(
                kotlin.math.cos(angle * Math.PI.toFloat() / 180f) * speed,
                kotlin.math.sin(angle * Math.PI.toFloat() / 180f) * speed - 30f // Slight upward bias
            )

            val particle = Particle(
                position = Vector2(position.x, position.y),
                velocity = velocity,
                color = featherColors.random(),
                size = 3f + Random.nextFloat() * 4f,
                life = 1f + Random.nextFloat() * 2f, // 1-3 seconds
                maxLife = 3f,
                type = ParticleType.FEATHER
            )

            particles.add(particle)
        }
    }

    fun emitHitSparks(position: Vector2) {
        // Create spark particles when hitting ground animals
        val sparkColors = arrayOf(
            Color.rgb(255, 255, 0),  // Yellow
            Color.rgb(255, 165, 0),  // Orange
            Color.rgb(255, 69, 0)    // Red
        )

        for (i in 0..12) { // 13 sparks
            val angle = Random.nextFloat() * 360f
            val speed = 100f + Random.nextFloat() * 200f
            val velocity = Vector2(
                kotlin.math.cos(angle * Math.PI.toFloat() / 180f) * speed,
                kotlin.math.sin(angle * Math.PI.toFloat() / 180f) * speed
            )

            val particle = Particle(
                position = Vector2(position.x, position.y),
                velocity = velocity,
                color = sparkColors.random(),
                size = 2f + Random.nextFloat() * 3f,
                life = 0.3f + Random.nextFloat() * 0.4f, // 0.3-0.7 seconds
                maxLife = 0.7f,
                type = ParticleType.SPARK
            )

            particles.add(particle)
        }
    }

    fun emitSmoke(position: Vector2) {
        // Create smoke particles (could be used for muzzle flash, etc.)
        for (i in 0..6) {
            val angle = Random.nextFloat() * 360f
            val speed = 20f + Random.nextFloat() * 40f
            val velocity = Vector2(
                kotlin.math.cos(angle * Math.PI.toFloat() / 180f) * speed,
                kotlin.math.sin(angle * Math.PI.toFloat() / 180f) * speed - 10f // Slight upward bias
            )

            val particle = Particle(
                position = Vector2(position.x, position.y),
                velocity = velocity,
                color = Color.rgb(100, 100, 100), // Gray
                size = 8f + Random.nextFloat() * 12f,
                life = 2f + Random.nextFloat() * 3f, // 2-5 seconds
                maxLife = 5f,
                type = ParticleType.SMOKE
            )

            particles.add(particle)
        }
    }

    fun clearAllParticles() {
        particles.clear()
    }

    fun getParticleCount(): Int = particles.size
}
