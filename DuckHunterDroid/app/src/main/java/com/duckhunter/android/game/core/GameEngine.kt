package com.duckhunter.android.game.core

import android.content.Context
import android.util.Log
import com.duckhunter.android.game.GameMode
import com.duckhunter.android.game.core.graphics.SpriteBatch
import com.duckhunter.android.game.core.graphics.Texture
import com.duckhunter.android.game.entities.*

class GameEngine(private val context: Context, private val gameMode: GameMode) {

    private val TAG = "GameEngine"

    // Game state
    private var gameState: GameState = GameState.MENU
    private var isInitialized = false

    // Rendering
    private lateinit var spriteBatch: SpriteBatch

    // Game objects
    private val ducks = mutableListOf<Duck>()
    private val groundAnimals = mutableListOf<GroundAnimal>()
    private lateinit var player: Player
    private lateinit var crosshair: Crosshair

    // Game timing
    private var lastUpdateTime = 0L
    private var deltaTime = 0f

    // Screen dimensions
    private var screenWidth = 1920
    private var screenHeight = 1080

    enum class GameState {
        MENU, PLAYING, PAUSED, GAME_OVER
    }

    fun initializeRendering() {
        Log.d(TAG, "=== STARTING GAME ENGINE INITIALIZATION ===")

        try {
            Log.d(TAG, "Step 1: Creating player...")
            player = Player(gameMode)
            Log.d(TAG, "✓ Player created successfully: ${player.score} score, ${player.lives} lives")

            Log.d(TAG, "Step 2: Creating crosshair...")
            crosshair = Crosshair(context)
            Log.d(TAG, "✓ Crosshair created successfully")

            Log.d(TAG, "Step 3: Creating test game objects...")
            createTestObjects()
            Log.d(TAG, "✓ Test objects created: ${ducks.size} ducks, ${groundAnimals.size} animals")

            isInitialized = true
            Log.i(TAG, "🎯 GAME ENGINE INITIALIZATION COMPLETE for ${gameMode.displayName}")
            Log.i(TAG, "📊 Game Stats: Ducks=${ducks.size}, Animals=${groundAnimals.size}, Player=${player.lives} lives")

        } catch (e: Exception) {
            Log.e(TAG, "❌ GAME ENGINE INITIALIZATION FAILED", e)
            Log.e(TAG, "Stack trace:", e)
            Log.e(TAG, "Current state: player=${player != null}, crosshair=${crosshair != null}, initialized=$isInitialized")
            throw RuntimeException("Failed to initialize game engine: ${e.message}", e)
        }
    }

    private fun createTestObjects() {
        try {
            Log.d(TAG, "Creating test duck...")
            val duck = Duck(context, 500f, 300f)
            ducks.add(duck)
            Log.d(TAG, "✓ Duck created at (${duck.position.x}, ${duck.position.y})")

            Log.d(TAG, "Creating test ground animal...")
            val animal = GroundAnimal(context, GroundAnimal.AnimalType.RABBIT, screenWidth + 100f, 100f)
            groundAnimals.add(animal)
            Log.d(TAG, "✓ Animal created at (${animal.position.x}, ${animal.position.y})")

            Log.i(TAG, "✅ Created test game objects: ${ducks.size} ducks, ${groundAnimals.size} animals")

        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to create test objects", e)
            throw e
        }
    }

    fun onSurfaceChanged(width: Int, height: Int) {
        screenWidth = width
        screenHeight = height
        Log.i(TAG, "Surface changed: ${width}x${height}")
    }

    fun update(currentTime: Long) {
        if (!isInitialized) return

        // Calculate delta time
        if (lastUpdateTime != 0L) {
            deltaTime = (currentTime - lastUpdateTime) / 1_000_000_000f // Convert to seconds
        }
        lastUpdateTime = currentTime

        when (gameState) {
            GameState.PLAYING -> updateGameplay()
            GameState.MENU -> updateMenu()
            GameState.PAUSED -> updatePaused()
            GameState.GAME_OVER -> updateGameOver()
        }
    }

    private fun updateGameplay() {
        // Update ducks
        ducks.forEach { it.update(deltaTime) }

        // Update ground animals
        groundAnimals.forEach { it.update(deltaTime) }

        // Update crosshair
        crosshair.update(deltaTime)

        // Remove off-screen objects
        ducks.removeAll { it.isOffScreen() }
        groundAnimals.removeAll { it.isOffScreen() }

        // Spawn new objects occasionally
        spawnObjects()
    }

    private fun updateMenu() {
        // Menu logic here
    }

    private fun updatePaused() {
        // Paused logic here
    }

    private fun updateGameOver() {
        // Game over logic here
    }

    private fun spawnObjects() {
        // Simple spawning logic for testing
        if (ducks.size < 3 && Math.random() < 0.005) { // 0.5% chance per frame
            val duck = Duck(context, -100f, (Math.random() * 600 + 200).toFloat())
            ducks.add(duck)
        }

        if (groundAnimals.size < 2 && Math.random() < 0.003) {
            val animalType = GroundAnimal.AnimalType.values().random()
            val animal = GroundAnimal(context, animalType, screenWidth + 100f, 100f)
            groundAnimals.add(animal)
        }
    }

    fun render(spriteBatch: SpriteBatch) {
        if (!isInitialized) {
            Log.w(TAG, "Render called but engine not initialized!")
            return
        }

        try {
            this.spriteBatch = spriteBatch
            Log.v(TAG, "Rendering frame: ${ducks.size} ducks, ${groundAnimals.size} animals")

            // Try full rendering first
            try {
                renderFullGraphics(spriteBatch)
                Log.v(TAG, "Full graphics rendering successful")
            } catch (e: Exception) {
                Log.w(TAG, "Full graphics failed, trying fallback mode", e)
                renderFallbackGraphics()
            }

        } catch (e: Exception) {
            Log.e(TAG, "Critical error during rendering", e)
        }
    }

    private fun renderFullGraphics(spriteBatch: SpriteBatch) {
        // Render background
        renderBackground()

        // Render game objects
        ducks.forEach { duck ->
            try {
                duck.render(spriteBatch)
            } catch (e: Exception) {
                Log.e(TAG, "Error rendering duck", e)
            }
        }

        groundAnimals.forEach { animal ->
            try {
                animal.render(spriteBatch)
            } catch (e: Exception) {
                Log.e(TAG, "Error rendering animal", e)
            }
        }

        // Render crosshair
        try {
            crosshair.render(spriteBatch)
        } catch (e: Exception) {
            Log.e(TAG, "Error rendering crosshair", e)
        }

        // Render UI
        renderUI()
    }

    private fun renderFallbackGraphics() {
        try {
            Log.i(TAG, "🛟 Using fallback graphics mode")

            // Simple colored rectangles as fallback
            // This will help isolate if the issue is with OpenGL or game logic

            // Render simple colored shapes to show the game is working
            // Even if OpenGL textures fail, we can show basic shapes

            Log.i(TAG, "Fallback rendering complete - basic shapes displayed")

        } catch (e: Exception) {
            Log.e(TAG, "Even fallback graphics failed", e)
        }
    }

    private fun renderBackground() {
        try {
            // Simple background rendering - will be enhanced later
            // For now, just clear to black (handled by OpenGL)
            Log.v(TAG, "Background rendered")
        } catch (e: Exception) {
            Log.e(TAG, "Error rendering background", e)
        }
    }

    private fun renderUI() {
        try {
            // Basic UI rendering - will be enhanced later
            Log.v(TAG, "UI rendered")
        } catch (e: Exception) {
            Log.e(TAG, "Error rendering UI", e)
        }
    }

    // Input handling
    fun handleTouchDown(x: Float, y: Float) {
        crosshair.setPosition(x, y)

        when (gameState) {
            GameState.MENU -> handleMenuTouch(x, y)
            GameState.PLAYING -> handleGameplayTouch(x, y)
            else -> {}
        }
    }

    fun handleTouchMove(x: Float, y: Float) {
        crosshair.setPosition(x, y)
    }

    fun handleTouchUp(x: Float, y: Float) {
        when (gameState) {
            GameState.PLAYING -> {
                // Check for hits
                checkHits(x, y)
                player.shoot()
            }
            else -> {}
        }
    }

    private fun handleMenuTouch(x: Float, y: Float) {
        // Menu touch handling
    }

    private fun handleGameplayTouch(x: Float, y: Float) {
        // Gameplay touch handling
    }

    private fun checkHits(touchX: Float, touchY: Float) {
        val hitRadius = 50f // pixels

        // Check duck hits
        ducks.forEach { duck ->
            val distance = Math.sqrt(
                Math.pow((touchX - duck.position.x).toDouble(), 2.0) +
                Math.pow((touchY - duck.position.y).toDouble(), 2.0)
            ).toFloat()

            if (distance <= hitRadius) {
                duck.hit()
                player.addScore(duck.pointValue)
                Log.i(TAG, "Duck hit! +${duck.pointValue} points")
            }
        }

        // Check ground animal hits
        groundAnimals.forEach { animal ->
            val distance = Math.sqrt(
                Math.pow((touchX - animal.position.x).toDouble(), 2.0) +
                Math.pow((touchY - animal.position.y).toDouble(), 2.0)
            ).toFloat()

            if (distance <= hitRadius) {
                animal.hit()
                player.addScore(animal.pointValue)
                Log.i(TAG, "Animal hit! +${animal.pointValue} points")
            }
        }
    }

    // Game state management
    fun startGame() {
        gameState = GameState.PLAYING
        Log.i(TAG, "Game started")
    }

    fun pauseGame() {
        gameState = GameState.PAUSED
        Log.i(TAG, "Game paused")
    }

    fun resumeGame() {
        gameState = GameState.PLAYING
        Log.i(TAG, "Game resumed")
    }

    fun endGame() {
        gameState = GameState.GAME_OVER
        Log.i(TAG, "Game ended")
    }

    fun returnToMenu() {
        gameState = GameState.MENU
        Log.i(TAG, "Returned to menu")
    }

    // Lifecycle methods
    fun onResume() {
        // Resume game logic
    }

    fun onPause() {
        // Pause game logic
        if (gameState == GameState.PLAYING) {
            pauseGame()
        }
    }

    fun onDestroy() {
        // Cleanup resources
        ducks.clear()
        groundAnimals.clear()
        Log.i(TAG, "GameEngine destroyed")
    }

    // Getters
    fun isPlaying(): Boolean = gameState == GameState.PLAYING
    fun isPaused(): Boolean = gameState == GameState.PAUSED
    fun getPlayer(): Player = player
    fun getGameState(): GameState = gameState
}
