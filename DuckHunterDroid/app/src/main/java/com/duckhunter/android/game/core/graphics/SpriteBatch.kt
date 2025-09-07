package com.duckhunter.android.game.core.graphics

import android.opengl.GLES30
import java.nio.ByteBuffer
import java.nio.ByteOrder
import java.nio.FloatBuffer

class SpriteBatch(private val shaderProgram: ShaderProgram, maxSprites: Int = 1000) {

    private val TAG = "SpriteBatch"

    // Vertex data per sprite (position + texCoord)
    private val VERTICES_PER_SPRITE = 4
    private val VALUES_PER_VERTEX = 4 // x, y, u, v
    private val VERTICES_PER_SPRITE_WITH_VALUES = VERTICES_PER_SPRITE * VALUES_PER_VERTEX

    // Buffers
    private lateinit var vertexBuffer: FloatBuffer
    private lateinit var indexBuffer: ByteBuffer

    // OpenGL objects
    private var vaoId = 0
    private var vboId = 0
    private var eboId = 0

    // Rendering state
    private var isDrawing = false
    private var currentTextureId = -1
    private var spriteCount = 0

    // Sprite data
    private val vertices = FloatArray(maxSprites * VERTICES_PER_SPRITE_WITH_VALUES)
    private val indices = ByteArray(maxSprites * 6) // 6 indices per sprite (2 triangles)

    // Default color
    private var color = floatArrayOf(1f, 1f, 1f, 1f)

    init {
        initializeBuffers(maxSprites)
        createOpenGLObjects()
        setupQuadIndices(maxSprites)
    }

    private fun initializeBuffers(maxSprites: Int) {
        // Vertex buffer (position + texCoord per vertex)
        val vertexBufferSize = maxSprites * VERTICES_PER_SPRITE_WITH_VALUES * 4 // 4 bytes per float
        vertexBuffer = ByteBuffer.allocateDirect(vertexBufferSize)
            .order(ByteOrder.nativeOrder())
            .asFloatBuffer()

        // Index buffer
        val indexBufferSize = maxSprites * 6 // 6 indices per sprite
        indexBuffer = ByteBuffer.allocateDirect(indexBufferSize)
            .order(ByteOrder.nativeOrder())
    }

    private fun createOpenGLObjects() {
        val vaoIds = IntArray(1)
        val vboIds = IntArray(1)
        val eboIds = IntArray(1)

        // Create VAO
        GLES30.glGenVertexArrays(1, vaoIds, 0)
        vaoId = vaoIds[0]

        // Create VBO
        GLES30.glGenBuffers(1, vboIds, 0)
        vboId = vboIds[0]

        // Create EBO
        GLES30.glGenBuffers(1, eboIds, 0)
        eboId = eboIds[0]

        // Bind VAO
        GLES30.glBindVertexArray(vaoId)

        // Bind VBO
        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, vboId)
        GLES30.glBufferData(GLES30.GL_ARRAY_BUFFER, vertices.size * 4, null, GLES30.GL_DYNAMIC_DRAW)

        // Setup vertex attributes
        val positionAttrib = shaderProgram.positionAttribute
        val texCoordAttrib = shaderProgram.texCoordAttribute

        // Position attribute (x, y)
        GLES30.glEnableVertexAttribArray(positionAttrib)
        GLES30.glVertexAttribPointer(positionAttrib, 2, GLES30.GL_FLOAT, false, VALUES_PER_VERTEX * 4, 0)

        // Texture coordinate attribute (u, v)
        GLES30.glEnableVertexAttribArray(texCoordAttrib)
        GLES30.glVertexAttribPointer(texCoordAttrib, 2, GLES30.GL_FLOAT, false, VALUES_PER_VERTEX * 4, 8)

        // Bind EBO
        GLES30.glBindBuffer(GLES30.GL_ELEMENT_ARRAY_BUFFER, eboId)
        GLES30.glBufferData(GLES30.GL_ELEMENT_ARRAY_BUFFER, indices.size, indexBuffer, GLES30.GL_STATIC_DRAW)

        // Unbind
        GLES30.glBindVertexArray(0)
    }

    private fun setupQuadIndices(maxSprites: Int) {
        indexBuffer.clear()

        for (i in 0 until maxSprites) {
            val vertexIndex = (i * VERTICES_PER_SPRITE).toByte()
            val indices = byteArrayOf(
                vertexIndex, (vertexIndex + 1).toByte(), (vertexIndex + 2).toByte(),
                vertexIndex, (vertexIndex + 2).toByte(), (vertexIndex + 3).toByte()
            )

            this.indices[i * 6] = indices[0]
            this.indices[i * 6 + 1] = indices[1]
            this.indices[i * 6 + 2] = indices[2]
            this.indices[i * 6 + 3] = indices[3]
            this.indices[i * 6 + 4] = indices[4]
            this.indices[i * 6 + 5] = indices[5]
        }

        indexBuffer.put(this.indices)
        indexBuffer.flip()
    }

    fun begin(mvpMatrix: FloatArray) {
        if (isDrawing) {
            throw IllegalStateException("SpriteBatch is already drawing")
        }

        isDrawing = true
        spriteCount = 0
        currentTextureId = -1

        // Use shader program
        shaderProgram.use()

        // Set MVP matrix
        shaderProgram.setUniformMatrix4fv(shaderProgram.mvpMatrixUniform, mvpMatrix)

        // Set color
        shaderProgram.setUniform4f(shaderProgram.colorUniform, color[0], color[1], color[2], color[3])
    }

    fun draw(texture: Texture, x: Float, y: Float, width: Float, height: Float) {
        if (!isDrawing) {
            throw IllegalStateException("SpriteBatch is not drawing")
        }

        // Check if we need to flush due to texture change
        if (currentTextureId != texture.textureId) {
            if (spriteCount > 0) {
                flush()
            }
            currentTextureId = texture.textureId
        }

        // Check if we have space for another sprite
        if (spriteCount >= vertices.size / VERTICES_PER_SPRITE_WITH_VALUES) {
            flush()
        }

        // Add sprite vertices
        val vertexIndex = spriteCount * VERTICES_PER_SPRITE_WITH_VALUES

        // Bottom-left
        vertices[vertexIndex] = x
        vertices[vertexIndex + 1] = y
        vertices[vertexIndex + 2] = 0f
        vertices[vertexIndex + 3] = 1f

        // Bottom-right
        vertices[vertexIndex + 4] = x + width
        vertices[vertexIndex + 5] = y
        vertices[vertexIndex + 6] = 1f
        vertices[vertexIndex + 7] = 1f

        // Top-right
        vertices[vertexIndex + 8] = x + width
        vertices[vertexIndex + 9] = y + height
        vertices[vertexIndex + 10] = 1f
        vertices[vertexIndex + 11] = 0f

        // Top-left
        vertices[vertexIndex + 12] = x
        vertices[vertexIndex + 13] = y + height
        vertices[vertexIndex + 14] = 0f
        vertices[vertexIndex + 15] = 0f

        spriteCount++
    }

    fun draw(texture: Texture, x: Float, y: Float) {
        draw(texture, x, y, texture.width.toFloat(), texture.height.toFloat())
    }

    fun draw(texture: Texture, position: Vector2) {
        draw(texture, position.x, position.y)
    }

    private fun flush() {
        if (spriteCount == 0) return

        // Bind texture
        GLES30.glActiveTexture(GLES30.GL_TEXTURE0)
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, currentTextureId)
        shaderProgram.setUniform1i(shaderProgram.textureUniform, 0)

        // Update vertex buffer
        vertexBuffer.clear()
        vertexBuffer.put(vertices, 0, spriteCount * VERTICES_PER_SPRITE_WITH_VALUES)
        vertexBuffer.flip()

        GLES30.glBindBuffer(GLES30.GL_ARRAY_BUFFER, vboId)
        GLES30.glBufferSubData(GLES30.GL_ARRAY_BUFFER, 0, vertexBuffer.capacity() * 4, vertexBuffer)

        // Bind VAO and draw
        GLES30.glBindVertexArray(vaoId)
        GLES30.glDrawElements(GLES30.GL_TRIANGLES, spriteCount * 6, GLES30.GL_UNSIGNED_BYTE, 0)
        GLES30.glBindVertexArray(0)

        spriteCount = 0
    }

    fun end() {
        if (!isDrawing) {
            throw IllegalStateException("SpriteBatch is not drawing")
        }

        // Flush remaining sprites
        flush()

        isDrawing = false
    }

    fun setColor(r: Float, g: Float, b: Float, a: Float) {
        color[0] = r
        color[1] = g
        color[2] = b
        color[3] = a

        if (isDrawing) {
            shaderProgram.setUniform4f(shaderProgram.colorUniform, r, g, b, a)
        }
    }

    fun dispose() {
        val buffers = intArrayOf(vboId, eboId)
        val vaos = intArrayOf(vaoId)

        GLES30.glDeleteBuffers(2, buffers, 0)
        GLES30.glDeleteVertexArrays(1, vaos, 0)
    }
}
