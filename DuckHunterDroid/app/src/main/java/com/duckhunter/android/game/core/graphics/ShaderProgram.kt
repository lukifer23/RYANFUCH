package com.duckhunter.android.game.core.graphics

import android.content.Context
import android.opengl.GLES30
import android.util.Log

class ShaderProgram(private val context: Context) {

    private val TAG = "ShaderProgram"

    var programId: Int = 0
        private set

    // Attribute locations
    var positionAttribute: Int = 0
        private set

    var texCoordAttribute: Int = 0
        private set

    // Uniform locations
    var mvpMatrixUniform: Int = 0
        private set

    var textureUniform: Int = 0
        private set

    var colorUniform: Int = 0
        private set

    init {
        createProgram()
    }

    private fun createProgram() {
        // Vertex shader source
        val vertexShaderSource = """
            uniform mat4 uMVPMatrix;
            attribute vec4 aPosition;
            attribute vec2 aTexCoord;
            varying vec2 vTexCoord;

            void main() {
                gl_Position = uMVPMatrix * aPosition;
                vTexCoord = aTexCoord;
            }
        """.trimIndent()

        // Fragment shader source
        val fragmentShaderSource = """
            precision mediump float;
            uniform sampler2D uTexture;
            uniform vec4 uColor;
            varying vec2 vTexCoord;

            void main() {
                vec4 texColor = texture2D(uTexture, vTexCoord);
                gl_FragColor = texColor * uColor;
            }
        """.trimIndent()

        // Create shaders
        val vertexShader = loadShader(GLES30.GL_VERTEX_SHADER, vertexShaderSource)
        val fragmentShader = loadShader(GLES30.GL_FRAGMENT_SHADER, fragmentShaderSource)

        // Create program
        programId = GLES30.glCreateProgram()

        if (programId == 0) {
            Log.e(TAG, "Could not create program")
            return
        }

        // Attach shaders
        GLES30.glAttachShader(programId, vertexShader)
        GLES30.glAttachShader(programId, fragmentShader)

        // Link program
        GLES30.glLinkProgram(programId)

        // Check link status
        val linkStatus = IntArray(1)
        GLES30.glGetProgramiv(programId, GLES30.GL_LINK_STATUS, linkStatus, 0)

        if (linkStatus[0] == 0) {
            val infoLog = GLES30.glGetProgramInfoLog(programId)
            Log.e(TAG, "Could not link program: $infoLog")
            GLES30.glDeleteProgram(programId)
            programId = 0
            return
        }

        // Get attribute locations
        positionAttribute = GLES30.glGetAttribLocation(programId, "aPosition")
        texCoordAttribute = GLES30.glGetAttribLocation(programId, "aTexCoord")

        // Get uniform locations
        mvpMatrixUniform = GLES30.glGetUniformLocation(programId, "uMVPMatrix")
        textureUniform = GLES30.glGetUniformLocation(programId, "uTexture")
        colorUniform = GLES30.glGetUniformLocation(programId, "uColor")

        // Clean up shaders
        GLES30.glDeleteShader(vertexShader)
        GLES30.glDeleteShader(fragmentShader)

        Log.i(TAG, "Shader program created successfully")
    }

    private fun loadShader(type: Int, source: String): Int {
        val shader = GLES30.glCreateShader(type)

        if (shader == 0) {
            Log.e(TAG, "Could not create shader")
            return 0
        }

        // Load source
        GLES30.glShaderSource(shader, source)

        // Compile shader
        GLES30.glCompileShader(shader)

        // Check compile status
        val compileStatus = IntArray(1)
        GLES30.glGetShaderiv(shader, GLES30.GL_COMPILE_STATUS, compileStatus, 0)

        if (compileStatus[0] == 0) {
            val infoLog = GLES30.glGetShaderInfoLog(shader)
            Log.e(TAG, "Could not compile shader: $infoLog")
            GLES30.glDeleteShader(shader)
            return 0
        }

        return shader
    }

    fun use() {
        GLES30.glUseProgram(programId)
    }

    fun dispose() {
        if (programId != 0) {
            GLES30.glDeleteProgram(programId)
            programId = 0
        }
    }

    // Utility methods for setting uniforms
    fun setUniformMatrix4fv(location: Int, matrix: FloatArray) {
        GLES30.glUniformMatrix4fv(location, 1, false, matrix, 0)
    }

    fun setUniform1i(location: Int, value: Int) {
        GLES30.glUniform1i(location, value)
    }

    fun setUniform4f(location: Int, r: Float, g: Float, b: Float, a: Float) {
        GLES30.glUniform4f(location, r, g, b, a)
    }
}
