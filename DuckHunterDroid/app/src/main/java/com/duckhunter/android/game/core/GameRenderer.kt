package com.duckhunter.android.game.core

import android.content.Context
import android.opengl.GLES30
import android.opengl.GLSurfaceView
import android.opengl.Matrix
import android.util.Log
import com.duckhunter.android.game.GameActivity
import com.duckhunter.android.game.core.graphics.*
import javax.microedition.khronos.egl.EGLConfig
import javax.microedition.khronos.opengles.GL10

class GameRenderer(
    private val context: Context,
    private val gameEngine: GameEngine
) : GLSurfaceView.Renderer {

    private val TAG = "GameRenderer"

    // Matrix components
    private val viewMatrix = FloatArray(16)
    private val projectionMatrix = FloatArray(16)
    private val mvpMatrix = FloatArray(16)

    // Rendering components
    private lateinit var shaderProgram: ShaderProgram
    private lateinit var spriteBatch: SpriteBatch
    private lateinit var camera: OrthographicCamera

    // Screen dimensions
    private var screenWidth = 1920
    private var screenHeight = 1080
    private var aspectRatio = screenWidth.toFloat() / screenHeight.toFloat()

    override fun onSurfaceCreated(gl: GL10?, config: EGLConfig?) {
        Log.i(TAG, "OpenGL Surface Created")

        // Set the background color
        GLES30.glClearColor(0.0f, 0.0f, 0.0f, 1.0f)

        // Enable blending for transparency
        GLES30.glEnable(GLES30.GL_BLEND)
        GLES30.glBlendFunc(GLES30.GL_SRC_ALPHA, GLES30.GL_ONE_MINUS_SRC_ALPHA)

        // Enable depth testing
        GLES30.glEnable(GLES30.GL_DEPTH_TEST)
        GLES30.glDepthFunc(GLES30.GL_LEQUAL)

        // Create shader program
        shaderProgram = ShaderProgram(context)

        // Create sprite batch for efficient rendering
        spriteBatch = SpriteBatch(shaderProgram, 1000)

        // Setup camera
        camera = OrthographicCamera(screenWidth.toFloat(), screenHeight.toFloat())

        // Initialize game engine rendering AFTER OpenGL pipeline is ready
        Log.i(TAG, "Initializing game engine rendering...")
        try {
            gameEngine.initializeRendering()
            Log.i(TAG, "Game engine rendering initialized successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize game engine rendering", e)
            throw RuntimeException("Game engine rendering initialization failed", e)
        }

        Log.i(TAG, "OpenGL initialized successfully")
    }

    override fun onDrawFrame(gl: GL10?) {
        // Clear the screen
        GLES30.glClear(GLES30.GL_COLOR_BUFFER_BIT or GLES30.GL_DEPTH_BUFFER_BIT)

        // Update camera
        camera.update()

        // Setup model-view-projection matrix
        Matrix.multiplyMM(mvpMatrix, 0, projectionMatrix, 0, viewMatrix, 0)

        // Begin sprite batch rendering
        spriteBatch.begin(camera.combined)

        // Render game objects
        gameEngine.render(spriteBatch)

        // End sprite batch
        spriteBatch.end()

        // Check for OpenGL errors
        val error = GLES30.glGetError()
        if (error != GLES30.GL_NO_ERROR) {
            Log.e(TAG, "OpenGL Error: $error")
        }
    }

    override fun onSurfaceChanged(gl: GL10?, width: Int, height: Int) {
        Log.i(TAG, "Surface changed: ${width}x$height")

        screenWidth = width
        screenHeight = height
        aspectRatio = width.toFloat() / height.toFloat()

        // Set the viewport
        GLES30.glViewport(0, 0, width, height)

        // Update camera
        camera.resize(width.toFloat(), height.toFloat())

        // Update projection matrix for landscape orientation
        if (width > height) {
            // Landscape mode
            Matrix.orthoM(projectionMatrix, 0, 0f, width.toFloat(), height.toFloat(), 0f, -1f, 1f)
        } else {
            // Portrait mode (fallback)
            Matrix.orthoM(projectionMatrix, 0, 0f, height.toFloat(), width.toFloat(), 0f, -1f, 1f)
        }

        // Setup view matrix (identity for 2D)
        Matrix.setIdentityM(viewMatrix, 0)

        // Notify game engine of surface change
        gameEngine.onSurfaceChanged(width, height)
    }

    // Public methods for accessing rendering components
    fun getShaderProgram(): ShaderProgram = shaderProgram
    fun getSpriteBatch(): SpriteBatch = spriteBatch
    fun getCamera(): OrthographicCamera = camera
    fun getScreenWidth(): Int = screenWidth
    fun getScreenHeight(): Int = screenHeight

    // Cleanup
    fun cleanup() {
        spriteBatch.dispose()
        shaderProgram.dispose()
    }
}
