package com.duckhunter.android.game

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Typeface
import android.util.Log
import com.duckhunter.android.game.core.AudioManager
import com.duckhunter.android.game.core.GameEngine
import com.duckhunter.android.game.core.graphics.SpriteBatch
import com.duckhunter.android.game.utils.Constants

class MenuManager(private val context: Context, private val audioManager: AudioManager) {

    enum class MenuState {
        MAIN_MENU,
        DIFFICULTY_SELECTION,
        GAME_STARTING,
        PAUSED,
        GAME_OVER,
        QUIT_CONFIRMATION
    }

    private var currentState = MenuState.MAIN_MENU
    private var selectedOption = 0
    private var selectedDifficulty = GameMode.NORMAL

    // Menu items
    private val mainMenuItems = arrayOf("START GAME", "HIGH SCORES", "SETTINGS", "EXIT")
    private val difficultyItems = arrayOf("EASY", "NORMAL", "HARD", "GOD MODE")
    private val pauseMenuItems = arrayOf("RESUME", "RESTART", "MAIN MENU", "EXIT")
    private val gameOverItems = arrayOf("PLAY AGAIN", "MAIN MENU", "EXIT")

    // Paint objects
    private val titlePaint = Paint().apply {
        color = Color.WHITE
        textSize = 72f
        textAlign = Paint.Align.CENTER
        typeface = Typeface.DEFAULT_BOLD
        isAntiAlias = true
    }

    private val menuPaint = Paint().apply {
        color = Color.WHITE
        textSize = 48f
        textAlign = Paint.Align.CENTER
        typeface = Typeface.DEFAULT
        isAntiAlias = true
    }

    private val selectedPaint = Paint().apply {
        color = Color.YELLOW
        textSize = 48f
        textAlign = Paint.Align.CENTER
        typeface = Typeface.DEFAULT_BOLD
        isAntiAlias = true
    }

    private val subtitlePaint = Paint().apply {
        color = Color.LTGRAY
        textSize = 32f
        textAlign = Paint.Align.CENTER
        typeface = Typeface.DEFAULT
        isAntiAlias = true
    }

    private val backgroundPaint = Paint().apply {
        color = Color.argb(200, 0, 0, 0)
        style = Paint.Style.FILL
    }

    // Timing
    private var menuTimer = 0f
    private val menuDelay = 0.2f // Prevent rapid menu navigation

    fun update(deltaTime: Float) {
        menuTimer += deltaTime
    }

    fun handleTouch(x: Float, y: Float, screenWidth: Int, screenHeight: Int): Boolean {
        if (menuTimer < menuDelay) return false

        val centerX = screenWidth / 2f
        val centerY = screenHeight / 2f
        val menuSpacing = 80f

        when (currentState) {
            MenuState.MAIN_MENU -> {
                for (i in mainMenuItems.indices) {
                    val itemY = centerY - 100f + i * menuSpacing
                    if (y in (itemY - 30f)..(itemY + 30f)) {
                        selectedOption = i
                        selectMainMenuOption()
                        audioManager.playMenuSelectSound()
                        menuTimer = 0f
                        return true
                    }
                }
            }
            MenuState.DIFFICULTY_SELECTION -> {
                for (i in difficultyItems.indices) {
                    val itemY = centerY - 150f + i * menuSpacing
                    if (y in (itemY - 30f)..(itemY + 30f)) {
                        selectedDifficulty = when (i) {
                            0 -> GameMode.EASY
                            1 -> GameMode.NORMAL
                            2 -> GameMode.HARD
                            3 -> GameMode.GOD
                            else -> GameMode.NORMAL
                        }
                        audioManager.playMenuConfirmSound()
                        currentState = MenuState.GAME_STARTING
                        Log.i("MenuManager", "Game starting with mode: ${selectedDifficulty.displayName}")
                        menuTimer = 0f
                        return true
                    }
                }
            }
            MenuState.PAUSED -> {
                for (i in pauseMenuItems.indices) {
                    val itemY = centerY - 120f + i * menuSpacing
                    if (y in (itemY - 30f)..(itemY + 30f)) {
                        selectedOption = i
                        selectPauseMenuOption()
                        audioManager.playMenuSelectSound()
                        menuTimer = 0f
                        return true
                    }
                }
            }
            MenuState.GAME_OVER -> {
                for (i in gameOverItems.indices) {
                    val itemY = centerY - 80f + i * menuSpacing
                    if (y in (itemY - 30f)..(itemY + 30f)) {
                        selectedOption = i
                        selectGameOverOption()
                        audioManager.playMenuSelectSound()
                        menuTimer = 0f
                        return true
                    }
                }
            }
            else -> {}
        }

        return false
    }

    private fun selectMainMenuOption() {
        when (selectedOption) {
            0 -> { // START GAME
                currentState = MenuState.DIFFICULTY_SELECTION
                audioManager.playMenuConfirmSound()
            }
            1 -> { // HIGH SCORES
                // TODO: Implement high scores
                audioManager.playEmptyClickSound()
            }
            2 -> { // SETTINGS
                // TODO: Implement settings
                audioManager.playEmptyClickSound()
            }
            3 -> { // EXIT
                // TODO: Handle exit
                audioManager.playMenuConfirmSound()
            }
        }
    }

    private fun selectPauseMenuOption() {
        when (selectedOption) {
            0 -> { // RESUME
                currentState = MenuState.MAIN_MENU
            }
            1 -> { // RESTART
                currentState = MenuState.GAME_STARTING
            }
            2 -> { // MAIN MENU
                currentState = MenuState.MAIN_MENU
            }
            3 -> { // EXIT
                // TODO: Handle exit
            }
        }
    }

    private fun selectGameOverOption() {
        when (selectedOption) {
            0 -> { // PLAY AGAIN
                currentState = MenuState.GAME_STARTING
            }
            1 -> { // MAIN MENU
                currentState = MenuState.MAIN_MENU
            }
            2 -> { // EXIT
                // TODO: Handle exit
            }
        }
    }

    fun render(canvas: Canvas, screenWidth: Int, screenHeight: Int) {
        val centerX = screenWidth / 2f
        val centerY = screenHeight / 2f

        // Draw semi-transparent background
        canvas.drawRect(0f, 0f, screenWidth.toFloat(), screenHeight.toFloat(), backgroundPaint)

        when (currentState) {
            MenuState.MAIN_MENU -> renderMainMenu(canvas, centerX, centerY)
            MenuState.DIFFICULTY_SELECTION -> renderDifficultySelection(canvas, centerX, centerY)
            MenuState.PAUSED -> renderPauseMenu(canvas, centerX, centerY)
            MenuState.GAME_OVER -> renderGameOverMenu(canvas, centerX, centerY)
            else -> {}
        }
    }

    private fun renderMainMenu(canvas: Canvas, centerX: Float, centerY: Float) {
        // Title
        titlePaint.color = Color.WHITE
        canvas.drawText("DUCK HUNTER", centerX, centerY - 200f, titlePaint)

        // Subtitle
        subtitlePaint.color = Color.LTGRAY
        canvas.drawText("ANDROID EDITION", centerX, centerY - 150f, subtitlePaint)

        // Menu items
        val menuSpacing = 80f
        for (i in mainMenuItems.indices) {
            val paint = if (i == selectedOption) selectedPaint else menuPaint
            canvas.drawText(mainMenuItems[i], centerX, centerY - 100f + i * menuSpacing, paint)
        }

        // Instructions
        subtitlePaint.color = Color.GRAY
        canvas.drawText("TAP TO SELECT", centerX, centerY + 200f, subtitlePaint)
    }

    private fun renderDifficultySelection(canvas: Canvas, centerX: Float, centerY: Float) {
        // Title
        titlePaint.color = Color.WHITE
        canvas.drawText("SELECT DIFFICULTY", centerX, centerY - 250f, titlePaint)

        // Difficulty options
        val menuSpacing = 80f
        for (i in difficultyItems.indices) {
            val paint = menuPaint
            val color = when (i) {
                0 -> Color.GREEN    // Easy
                1 -> Color.YELLOW   // Normal
                2 -> 0xFFFFA500.toInt()   // Hard (Orange)
                3 -> Color.RED      // God Mode
                else -> Color.WHITE
            }
            paint.color = color
            canvas.drawText(difficultyItems[i], centerX, centerY - 150f + i * menuSpacing, paint)
        }

        // Reset paint color
        menuPaint.color = Color.WHITE
    }

    private fun renderPauseMenu(canvas: Canvas, centerX: Float, centerY: Float) {
        // Title
        titlePaint.color = Color.YELLOW
        canvas.drawText("PAUSED", centerX, centerY - 200f, titlePaint)

        // Menu items
        val menuSpacing = 80f
        for (i in pauseMenuItems.indices) {
            val paint = if (i == selectedOption) selectedPaint else menuPaint
            canvas.drawText(pauseMenuItems[i], centerX, centerY - 120f + i * menuSpacing, paint)
        }
    }

    private fun renderGameOverMenu(canvas: Canvas, centerX: Float, centerY: Float) {
        // Title
        titlePaint.color = Color.RED
        canvas.drawText("GAME OVER", centerX, centerY - 200f, titlePaint)

        // Menu items
        val menuSpacing = 80f
        for (i in gameOverItems.indices) {
            val paint = if (i == selectedOption) selectedPaint else menuPaint
            canvas.drawText(gameOverItems[i], centerX, centerY - 80f + i * menuSpacing, paint)
        }
    }

    // State management
    fun getCurrentState(): MenuState = currentState
    fun setState(state: MenuState) {
        currentState = state
        selectedOption = 0
        menuTimer = 0f
    }

    fun getSelectedDifficulty(): GameMode = selectedDifficulty

    fun isInMenu(): Boolean = currentState != MenuState.GAME_STARTING
    fun shouldStartGame(): Boolean = currentState == MenuState.GAME_STARTING
    fun shouldResumeGame(): Boolean = currentState == MenuState.MAIN_MENU
}
