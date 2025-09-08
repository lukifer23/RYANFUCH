package com.duckhunter.android.game.core

import android.content.Context
import android.graphics.Canvas
import android.util.Log
import com.duckhunter.android.game.GameMode
import com.duckhunter.android.game.core.graphics.SpriteBatch
import com.duckhunter.android.game.core.graphics.Texture
import com.duckhunter.android.game.entities.*
import com.duckhunter.android.game.systems.DuckSpawnManager
import com.duckhunter.android.game.systems.GroundAnimalSpawnManager
import com.duckhunter.android.game.systems.UISystem
import com.duckhunter.android.game.systems.BackgroundSystem
import com.duckhunter.android.game.systems.ParticleSystem
import com.duckhunter.android.game.core.AudioManager
import com.duckhunter.android.game.MenuManager

class GameEngine(private val context: Context, private val gameMode: GameMode) {

    private val TAG = "GameEngine"

    // Game state
    private var gameState: GameState = GameState.MENU
    private var isInitialized = false
    private var hasStartedGame = false

    // Rendering
    private lateinit var spriteBatch: SpriteBatch

    // Game objects
    private val ducks = mutableListOf<Duck>()
    private val groundAnimals = mutableListOf<GroundAnimal>()
    private var player: Player? = null
    private lateinit var crosshair: Crosshair

    // Spawn managers
    private lateinit var duckSpawnManager: DuckSpawnManager
    private lateinit var groundAnimalSpawnManager: GroundAnimalSpawnManager

    // Visual systems
    private lateinit var uiSystem: UISystem
    private lateinit var backgroundSystem: BackgroundSystem
    private lateinit var particleSystem: ParticleSystem

    // Audio system
    private lateinit var audioManager: AudioManager

    // Menu system
    private lateinit var menuManager: MenuManager

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
            Log.d(TAG, "✓ Player created successfully: ${player?.score} score, ${player?.lives} lives")

            Log.d(TAG, "Step 2: Creating crosshair...")
            crosshair = Crosshair()
            Log.d(TAG, "✓ Crosshair created successfully")

            Log.d(TAG, "Step 3: Creating spawn managers...")
            duckSpawnManager = DuckSpawnManager(ducks, player!!)
            groundAnimalSpawnManager = GroundAnimalSpawnManager(context, groundAnimals, player!!)
            Log.d(TAG, "✓ Spawn managers created")

            Log.d(TAG, "Step 4: Creating visual systems...")
            uiSystem = UISystem()
            uiSystem.setGameMode(player?.gameMode ?: gameMode)
            backgroundSystem = BackgroundSystem()
            particleSystem = ParticleSystem()
            Log.d(TAG, "✓ Visual systems created")

            Log.d(TAG, "Step 5: Creating audio system...")
            audioManager = AudioManager(context)
            Log.d(TAG, "✓ Audio system created")

            Log.d(TAG, "Step 6: Creating menu system...")
            menuManager = MenuManager(context, audioManager)
            Log.d(TAG, "✓ Menu system created")

            // Don't create initial game objects yet - wait for menu selection
            Log.d(TAG, "Game engine initialized - waiting for menu selection")

            isInitialized = true
            Log.i(TAG, "🎯 GAME ENGINE INITIALIZATION COMPLETE - MENU MODE")

        } catch (e: Exception) {
            Log.e(TAG, "❌ GAME ENGINE INITIALIZATION FAILED", e)
            Log.e(TAG, "Stack trace:", e)
            Log.e(TAG, "Current state: player=${player != null}, crosshair=${crosshair != null}, initialized=$isInitialized")
            throw RuntimeException("Failed to initialize game engine: ${e.message}", e)
        }
    }

    private fun createInitialObjects() {
        try {
            Log.d(TAG, "Creating initial duck...")
            val duck = Duck(Duck.DuckType.COMMON, 500f, 300f)
            ducks.add(duck)
            Log.d(TAG, "✓ Duck created at (${duck.position.x}, ${duck.position.y}) - Type: ${duck.duckType.displayName}, Points: ${duck.pointValue}")

            Log.d(TAG, "Creating initial ground animal...")
            val animal = GroundAnimal(context, GroundAnimal.AnimalType.RABBIT, screenWidth + 100f, 100f)
            groundAnimals.add(animal)
            Log.d(TAG, "✓ Animal created at (${animal.position.x}, ${animal.position.y}) - Type: ${animal.animalType.name}")

            Log.i(TAG, "✅ Created initial game objects: ${ducks.size} ducks, ${groundAnimals.size} animals")

        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to create initial objects", e)
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
        // Update spawn managers
        player?.let {
            duckSpawnManager.update(deltaTime)
            groundAnimalSpawnManager.update(deltaTime)
        }

        // Update visual systems
        backgroundSystem.update(deltaTime)
        particleSystem.update(deltaTime)

        // Update ducks
        ducks.forEach { it.update(deltaTime) }

        // Update ground animals
        groundAnimals.forEach { it.update(deltaTime) }

        // Update crosshair
        crosshair.update(deltaTime)

        // Update player (reload mechanics)
        player?.updateReload(deltaTime)

        // Remove off-screen objects
        ducks.removeAll { it.isOffScreen() }
        groundAnimals.removeAll { it.isOffScreen() }
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


    fun render(spriteBatch: SpriteBatch) {
        if (!isInitialized) {
            Log.w(TAG, "Render called but engine not initialized!")
            return
        }

        try {
            this.spriteBatch = spriteBatch
            Log.v(TAG, "Rendering frame: ${ducks.size} ducks, ${groundAnimals.size} animals")

            when (gameState) {
                GameState.PLAYING -> renderPlaying(spriteBatch)
                GameState.MENU -> renderMenu(spriteBatch)
                GameState.PAUSED -> renderPaused(spriteBatch)
                GameState.GAME_OVER -> renderGameOver(spriteBatch)
            }

            // Always render menu on top if in menu state
            if (menuManager.isInMenu()) {
                // Menu rendering will be handled by the GameRenderer via renderCanvas
            }

        } catch (e: Exception) {
            Log.e(TAG, "Critical error during rendering", e)
        }
    }

    // Canvas-based rendering method for UI and background
    fun renderCanvas(canvas: Canvas, screenWidth: Int, screenHeight: Int) {
        if (!isInitialized) return

        try {
            // Render background
            backgroundSystem.render(canvas)

            // Render menu if in menu state
            if (menuManager.isInMenu()) {
                menuManager.render(canvas, screenWidth, screenHeight)
                return // Don't render game UI when in menu
            }

            // Render UI
            when (gameState) {
                GameState.PLAYING -> {
                    player?.let { uiSystem.render(canvas, it, deltaTime) }
                }
                GameState.PAUSED -> {
                    uiSystem.drawPauseScreen(canvas)
                }
                GameState.GAME_OVER -> {
                    player?.let { uiSystem.drawGameOverScreen(canvas, it.score, it.gameMode) }
                }
                else -> {}
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error in Canvas rendering", e)
        }
    }

    private fun renderPlaying(spriteBatch: SpriteBatch) {
        // Render ducks
        ducks.forEach { duck ->
            try {
                duck.render(spriteBatch)
            } catch (e: Exception) {
                Log.e(TAG, "Error rendering duck", e)
            }
        }

        // Render ground animals
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

        // Render particles
        try {
            particleSystem.render(spriteBatch)
        } catch (e: Exception) {
            Log.e(TAG, "Error rendering particles", e)
        }
    }

    private fun renderMenu(spriteBatch: SpriteBatch) {
        // Menu rendering would go here
        // For now, just render background
        backgroundSystem.render(spriteBatch)
    }

    private fun renderPaused(spriteBatch: SpriteBatch) {
        renderPlaying(spriteBatch) // Render game in background
        // Pause overlay would be rendered here
    }

    private fun renderGameOver(spriteBatch: SpriteBatch) {
        renderPlaying(spriteBatch) // Render game in background
        // Game over overlay would be rendered here
    }


    // Input handling
    fun handleTouchDown(x: Float, y: Float) {
        crosshair.setPosition(x, y)

        // Handle menu input first if in menu
        if (gameState == GameState.MENU) {
            if (menuManager.handleTouch(x, y, screenWidth, screenHeight)) {
                // Menu handled the input
                if (menuManager.shouldStartGame()) {
                    // Start the game with selected difficulty
                    val selectedMode = menuManager.getSelectedDifficulty()
                    // Change state to playing
                    gameState = GameState.PLAYING
                    Log.i(TAG, "Menu selection made - switching to game mode: ${selectedMode.displayName}")
                    return
                }
            }
        }

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
                player?.let {
                    if (it.shoot()) {
                        // Player successfully shot
                        audioManager.playShotSound()
                        checkHits(x, y)
                        Log.d(TAG, "Shot fired! Ammo: ${it.ammo}/${it.gameMode.maxAmmo}")
                    } else {
                        // Player couldn't shoot (no ammo, reloading, etc.)
                        if (it.ammo == 0) {
                            audioManager.playEmptyClickSound()
                        } else if (it.isReloading) {
                            audioManager.playReloadSound()
                        }
                        Log.d(TAG, "Cannot shoot - Ammo: ${it.ammo}, Reloading: ${it.isReloading}")
                    }
                }
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
        // Use crosshair hit radius for more accurate detection
        val hitRadius = crosshair.getHitRadius()
        var hitSomething = false

        // Check duck hits
        ducks.forEach { duck ->
            val distance = kotlin.math.sqrt(
                (touchX - duck.position.x) * (touchX - duck.position.x) +
                (touchY - duck.position.y) * (touchY - duck.position.y)
            )

            if (distance <= hitRadius && duck.state == Duck.DuckState.FLYING) {
                duck.hit()
                player?.addScore(duck.pointValue)
                crosshair.flash() // Visual feedback
                particleSystem.emitFeathers(duck.position) // Particle effect
                audioManager.playHitSound() // Audio feedback
                hitSomething = true
                Log.i(TAG, "Duck hit! ${duck.duckType.name} duck: +${duck.pointValue} points")
            }
        }

        // Check ground animal hits
        groundAnimals.forEach { animal ->
            val distance = kotlin.math.sqrt(
                (touchX - animal.position.x) * (touchX - animal.position.x) +
                (touchY - animal.position.y) * (touchY - animal.position.y)
            )

            if (distance <= hitRadius && animal.state == GroundAnimal.AnimalState.WALKING) {
                animal.hit()
                player?.addScore(animal.pointValue)
                crosshair.flash() // Visual feedback
                particleSystem.emitHitSparks(animal.position) // Particle effect
                audioManager.playHitSound() // Audio feedback
                hitSomething = true
                Log.i(TAG, "Animal hit! ${animal.animalType.name}: +${animal.pointValue} points")
            }
        }

        // If nothing was hit, play miss sound
        if (!hitSomething) {
            audioManager.playMissSound()
            Log.d(TAG, "Shot missed - no targets in range")
        }
    }

    // Game state management
    fun startGame() {
        gameState = GameState.PLAYING
        Log.i(TAG, "Game started")
    }

    fun startGameWithMode(gameMode: GameMode) {
        if (hasStartedGame) {
            Log.w(TAG, "Game already started, ignoring duplicate start request")
            return
        }

        try {
            Log.i(TAG, "Starting game with mode: ${gameMode.displayName}")

            // Update player with new game mode
            player = Player(gameMode)
            val playerInstance = player!!
            playerInstance.reset()

            // Reset game state
            gameState = GameState.PLAYING
            ducks.clear()
            groundAnimals.clear()

            // Reset spawn managers with new game mode
            duckSpawnManager = DuckSpawnManager(ducks, playerInstance)
            groundAnimalSpawnManager = GroundAnimalSpawnManager(context, groundAnimals, playerInstance)

            // Create initial objects
            createInitialObjects()

            hasStartedGame = true
            Log.i(TAG, "✅ Game successfully started with mode: ${gameMode.displayName}")

        } catch (e: Exception) {
            Log.e(TAG, "❌ Failed to start game with mode: ${gameMode.displayName}", e)
            gameState = GameState.MENU // Revert to menu on error
        }
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
        audioManager.dispose()
        Log.i(TAG, "GameEngine destroyed")
    }

    // Getters
    fun isPlaying(): Boolean = gameState == GameState.PLAYING
    fun isPaused(): Boolean = gameState == GameState.PAUSED
    fun getPlayer(): Player? = player
    fun getGameState(): GameState = gameState
}
