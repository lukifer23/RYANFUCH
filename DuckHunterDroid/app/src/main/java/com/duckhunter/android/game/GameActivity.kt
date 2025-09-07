package com.duckhunter.android.game

import android.app.ActivityManager
import android.content.Context
import android.content.pm.ConfigurationInfo
import android.opengl.GLSurfaceView
import android.os.Bundle
import android.util.Log
import android.view.MotionEvent
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.duckhunter.android.R
import com.duckhunter.android.game.core.GameEngine
import com.duckhunter.android.game.core.GameRenderer
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10

class GameActivity : AppCompatActivity() {

    private lateinit var glSurfaceView: GLSurfaceView
    private lateinit var gameEngine: GameEngine
    private lateinit var gameRenderer: GameRenderer
    private var gameMode: GameMode = GameMode.NORMAL

    private val TAG = "GameActivity"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        try {
            // Get game mode from intent
            val gameModeString = intent.getStringExtra("GAME_MODE") ?: "NORMAL"
            gameMode = GameMode.fromString(gameModeString)

            Log.i(TAG, "Starting game in ${gameMode.displayName} mode")

            // Check for OpenGL ES 3.0 support
            if (!supportsOpenGLES3()) {
                Log.e(TAG, "OpenGL ES 3.0 not supported on this device")
                runOnUiThread {
                    Toast.makeText(this, "OpenGL ES 3.0 not supported. This device may not support the game.", Toast.LENGTH_LONG).show()
                    finish()
                }
                return
            }

            // Initialize game engine FIRST
            gameEngine = GameEngine(this, gameMode)

            // Initialize OpenGL surface AFTER game engine is ready
            initializeOpenGL()

            Log.i(TAG, "GameActivity initialized successfully")

        } catch (e: Exception) {
            Log.e(TAG, "Error initializing GameActivity", e)
            runOnUiThread {
                Toast.makeText(this, "Error starting game: ${e.message}", Toast.LENGTH_LONG).show()
                finish()
            }
        }
    }

    private fun supportsOpenGLES3(): Boolean {
        return try {
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            val configurationInfo = activityManager.deviceConfigurationInfo

            val supported = configurationInfo.reqGlEsVersion >= 0x30000
            Log.i(TAG, "OpenGL ES version: 0x${configurationInfo.reqGlEsVersion.toString(16)}, ES 3.0 supported: $supported")
            supported
        } catch (e: Exception) {
            Log.e(TAG, "Error checking OpenGL ES support", e)
            false
        }
    }

    private fun initializeOpenGL() {
        try {
            glSurfaceView = GLSurfaceView(this).apply {
                // Try OpenGL ES 3.0 first, fallback to 2.0
                try {
                    setEGLContextClientVersion(3)
                    Log.i(TAG, "Requesting OpenGL ES 3.0")
                } catch (e: Exception) {
                    Log.w(TAG, "OpenGL ES 3.0 failed, trying 2.0", e)
                    try {
                        setEGLContextClientVersion(2)
                        Log.i(TAG, "Requesting OpenGL ES 2.0")
                    } catch (e2: Exception) {
                        Log.e(TAG, "OpenGL ES 2.0 also failed", e2)
                        throw RuntimeException("No supported OpenGL ES version found")
                    }
                }

                // Set renderer
                gameRenderer = GameRenderer(this@GameActivity, gameEngine)
                setRenderer(gameRenderer)

                // Render only when needed to save battery
                renderMode = GLSurfaceView.RENDERMODE_CONTINUOUSLY

                // Handle touch events
                setOnTouchListener { _, event -> handleTouch(event) }
            }

            setContentView(glSurfaceView)
            Log.i(TAG, "OpenGL surface initialized successfully")

        } catch (e: Exception) {
            Log.e(TAG, "Error initializing OpenGL", e)
            runOnUiThread {
                Toast.makeText(this, "Error initializing graphics: ${e.message}", Toast.LENGTH_LONG).show()
                finish()
            }
        }
    }

    private fun handleTouch(event: MotionEvent): Boolean {
        when (event.actionMasked) {
            MotionEvent.ACTION_DOWN, MotionEvent.ACTION_POINTER_DOWN -> {
                val pointerIndex = event.actionIndex
                val x = event.getX(pointerIndex)
                val y = event.getY(pointerIndex)
                gameEngine.handleTouchDown(x, y)
                return true
            }

            MotionEvent.ACTION_MOVE -> {
                // Handle multi-touch for crosshair movement
                for (i in 0 until event.pointerCount) {
                    val x = event.getX(i)
                    val y = event.getY(i)
                    gameEngine.handleTouchMove(x, y)
                }
                return true
            }

            MotionEvent.ACTION_UP, MotionEvent.ACTION_POINTER_UP -> {
                val pointerIndex = event.actionIndex
                val x = event.getX(pointerIndex)
                val y = event.getY(pointerIndex)
                gameEngine.handleTouchUp(x, y)
                return true
            }
        }
        return false
    }

    override fun onResume() {
        super.onResume()
        glSurfaceView.onResume()
        gameEngine.onResume()
    }

    override fun onPause() {
        super.onPause()
        glSurfaceView.onPause()
        gameEngine.onPause()
    }

    override fun onDestroy() {
        super.onDestroy()
        gameEngine.onDestroy()
    }

    override fun onBackPressed() {
        // Handle back button for pause menu
        if (!gameEngine.isPaused()) {
            gameEngine.pauseGame()
        } else {
            super.onBackPressed()
        }
    }

    // Public methods for renderer to communicate with activity
    fun finishGame() {
        runOnUiThread {
            finish()
        }
    }

    fun showToast(message: String) {
        runOnUiThread {
            Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
        }
    }
}
