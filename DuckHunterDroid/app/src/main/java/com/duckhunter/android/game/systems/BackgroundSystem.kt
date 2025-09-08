package com.duckhunter.android.game.systems

import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import com.duckhunter.android.game.core.graphics.SpriteBatch
import com.duckhunter.android.game.utils.Constants
import kotlin.math.sin

class BackgroundSystem {

    // Sky gradient colors
    private val skyTopColor = Color.rgb(135, 206, 235) // Sky blue
    private val skyBottomColor = Color.rgb(255, 255, 150) // Light yellow (sunset)

    // Cloud properties
    private data class Cloud(var x: Float, var y: Float, val speed: Float, val size: Float)

    private var clouds = mutableListOf<Cloud>()
    private var cloudTimer = 0f
    private val cloudSpawnInterval = 3f // seconds

    // Ground properties
    private val groundColor = Color.rgb(34, 139, 34) // Forest green
    private val groundHeight = 120f

    // Tree properties
    private data class Tree(var x: Float, var height: Float, val layer: Int)

    private var trees = mutableListOf<Tree>()
    private var treeSpawnTimer = 0f
    private val treeSpawnInterval = 2f

    // Parallax scrolling speeds (pixels per second)
    private val cloudSpeed = 20f
    private val treeSpeedNear = 80f
    private val treeSpeedFar = 40f

    // Sky movement (subtle)
    private var skyOffset = 0f
    private val skyScrollSpeed = 5f

    init {
        // Initialize with some starting clouds and trees
        initializeBackgroundElements()
    }

    private fun initializeBackgroundElements() {
        // Add some initial clouds
        for (i in 0..5) {
            val x = (Constants.SCREEN_WIDTH * i / 5).toFloat()
            val y = (50f + kotlin.random.Random.nextFloat() * 150f)
            val speed = cloudSpeed * (0.8f + kotlin.random.Random.nextFloat() * 0.4f)
            val size = 0.8f + kotlin.random.Random.nextFloat() * 0.4f
            clouds.add(Cloud(x, y, speed, size))
        }

        // Add some initial trees
        for (i in 0..8) {
            val x = (Constants.SCREEN_WIDTH * i / 8).toFloat()
            val height = 60f + kotlin.random.Random.nextFloat() * 40f
            val layer = if (kotlin.random.Random.nextFloat() < 0.3f) 0 else 1 // 30% near, 70% far
            trees.add(Tree(x, height, layer))
        }
    }

    fun update(deltaTime: Float) {
        // Update sky subtle movement
        skyOffset += skyScrollSpeed * deltaTime
        if (skyOffset > Constants.SCREEN_WIDTH) {
            skyOffset = 0f
        }

        // Update clouds
        updateClouds(deltaTime)

        // Update trees
        updateTrees(deltaTime)

        // Spawn new elements occasionally
        spawnNewElements(deltaTime)
    }

    private fun updateClouds(deltaTime: Float) {
        clouds.forEach { cloud ->
            // Move cloud to the left
            cloud.x -= cloud.speed * deltaTime

            // Wrap around screen
            if (cloud.x < -100f) {
                cloud.x = Constants.SCREEN_WIDTH + 100f
                // Randomize height slightly when wrapping
                cloud.y = 50f + kotlin.random.Random.nextFloat() * 150f
            }
        }
    }

    private fun updateTrees(deltaTime: Float) {
        trees.forEach { tree ->
            val speed = if (tree.layer == 0) treeSpeedNear else treeSpeedFar
            tree.x -= speed * deltaTime

            // Wrap around screen
            if (tree.x < -50f) {
                tree.x = Constants.SCREEN_WIDTH + 50f
                tree.height = 60f + kotlin.random.Random.nextFloat() * 40f
            }
        }
    }

    private fun spawnNewElements(deltaTime: Float) {
        cloudTimer += deltaTime
        if (cloudTimer >= cloudSpawnInterval) {
            cloudTimer = 0f

            // Spawn new cloud off-screen
            val y = 50f + kotlin.random.Random.nextFloat() * 150f
            val speed = cloudSpeed * (0.8f + kotlin.random.Random.nextFloat() * 0.4f)
            val size = 0.8f + kotlin.random.Random.nextFloat() * 0.4f
            clouds.add(Cloud(Constants.SCREEN_WIDTH + 100f, y, speed, size))

            // Remove old clouds to prevent buildup
            if (clouds.size > 10) {
                clouds.removeAt(0)
            }
        }
    }

    fun render(canvas: Canvas) {
        // Draw sky gradient
        drawSky(canvas)

        // Draw clouds
        drawClouds(canvas)

        // Draw trees (far layer first, then near layer)
        drawTrees(canvas, 1) // Far trees
        drawTrees(canvas, 0) // Near trees

        // Draw ground
        drawGround(canvas)
    }

    private fun drawSky(canvas: Canvas) {
        val paint = Paint().apply {
            style = Paint.Style.FILL
        }

        // Create sky gradient
        val skyGradient = android.graphics.LinearGradient(
            0f, 0f, 0f, Constants.SCREEN_HEIGHT.toFloat(),
            skyTopColor, skyBottomColor,
            android.graphics.Shader.TileMode.CLAMP
        )
        paint.shader = skyGradient

        canvas.drawRect(0f, 0f, Constants.SCREEN_WIDTH.toFloat(),
                       Constants.SCREEN_HEIGHT - groundHeight, paint)
    }

    private fun drawClouds(canvas: Canvas) {
        val cloudPaint = Paint().apply {
            color = Color.WHITE
            style = Paint.Style.FILL
            alpha = 180 // Semi-transparent
        }

        clouds.forEach { cloud ->
            val baseSize = 60f * cloud.size
            val x = cloud.x
            val y = cloud.y

            // Draw cloud as series of overlapping circles
            canvas.drawCircle(x, y, baseSize * 0.8f, cloudPaint)
            canvas.drawCircle(x - baseSize * 0.6f, y, baseSize * 0.6f, cloudPaint)
            canvas.drawCircle(x + baseSize * 0.6f, y, baseSize * 0.6f, cloudPaint)
            canvas.drawCircle(x, y - baseSize * 0.4f, baseSize * 0.5f, cloudPaint)
            canvas.drawCircle(x - baseSize * 0.3f, y - baseSize * 0.3f, baseSize * 0.4f, cloudPaint)
            canvas.drawCircle(x + baseSize * 0.3f, y - baseSize * 0.3f, baseSize * 0.4f, cloudPaint)
        }
    }

    private fun drawTrees(canvas: Canvas, layer: Int) {
        val treePaint = Paint().apply {
            style = Paint.Style.FILL
        }

        // Different colors for different layers
        val trunkColor = if (layer == 0) Color.rgb(139, 69, 19) else Color.rgb(101, 67, 33)
        val foliageColor = if (layer == 0) Color.rgb(34, 139, 34) else Color.rgb(25, 100, 25)

        trees.filter { it.layer == layer }.forEach { tree ->
            val x = tree.x
            val groundY = Constants.SCREEN_HEIGHT - groundHeight
            val trunkHeight = tree.height * 0.6f
            val trunkWidth = tree.height * 0.15f
            val foliageSize = tree.height * 0.8f

            // Draw trunk
            treePaint.color = trunkColor
            canvas.drawRect(x - trunkWidth/2, groundY - trunkHeight,
                           x + trunkWidth/2, groundY, treePaint)

            // Draw foliage (triangle)
            treePaint.color = foliageColor
            val path = android.graphics.Path().apply {
                moveTo(x, groundY - trunkHeight - foliageSize)
                lineTo(x - foliageSize/2, groundY - trunkHeight)
                lineTo(x + foliageSize/2, groundY - trunkHeight)
                close()
            }
            canvas.drawPath(path, treePaint)
        }
    }

    private fun drawGround(canvas: Canvas) {
        val groundPaint = Paint().apply {
            color = groundColor
            style = Paint.Style.FILL
        }

        val groundY = Constants.SCREEN_HEIGHT - groundHeight
        canvas.drawRect(0f, groundY, Constants.SCREEN_WIDTH.toFloat(),
                       Constants.SCREEN_HEIGHT.toFloat(), groundPaint)

        // Add some ground texture/detail
        val detailPaint = Paint().apply {
            color = Color.rgb(20, 100, 20)
            style = Paint.Style.FILL
        }

        // Draw some grass blades
        for (i in 0..20) {
            val x = (Constants.SCREEN_WIDTH * i / 20).toFloat()
            val height = 5f + kotlin.random.Random.nextFloat() * 10f
            canvas.drawRect(x - 1f, groundY - height, x + 1f, groundY, detailPaint)
        }
    }

    // OpenGL SpriteBatch rendering method
    fun render(spriteBatch: SpriteBatch) {
        // For now, we'll implement a simple colored background
        // In full implementation, this would render proper sky gradient and background elements

        // Set a simple sky blue background color
        // The actual background rendering will be handled by OpenGL clear color
        // This method is called but doesn't need to do anything for basic background
    }

    fun reset() {
        clouds.clear()
        trees.clear()
        cloudTimer = 0f
        skyOffset = 0f
        initializeBackgroundElements()
    }
}
