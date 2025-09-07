package com.duckhunter.android.game.core.graphics

import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.opengl.GLES30
import android.opengl.GLUtils
import android.util.Log
import java.nio.ByteBuffer
import java.nio.ByteOrder

class Texture(private val context: Context) {

    private val TAG = "Texture"

    var textureId: Int = 0
        private set

    var width: Int = 0
        private set

    var height: Int = 0
        private set

    private var disposed = false

    constructor(context: Context, resourceId: Int) : this(context) {
        loadFromResource(resourceId)
    }

    constructor(context: Context, assetPath: String) : this(context) {
        loadFromAsset(assetPath)
    }

    private fun loadFromResource(resourceId: Int) {
        val options = BitmapFactory.Options().apply {
            inScaled = false // Don't scale based on screen density
        }

        val bitmap = BitmapFactory.decodeResource(context.resources, resourceId, options)
        if (bitmap != null) {
            createTextureFromBitmap(bitmap)
            bitmap.recycle() // Free bitmap memory
        } else {
            Log.e(TAG, "Failed to load texture from resource: $resourceId")
        }
    }

    private fun loadFromAsset(assetPath: String) {
        try {
            val inputStream = context.assets.open(assetPath)
            val bitmap = BitmapFactory.decodeStream(inputStream)
            if (bitmap != null) {
                createTextureFromBitmap(bitmap)
                bitmap.recycle()
            } else {
                Log.e(TAG, "Failed to decode bitmap from asset: $assetPath")
            }
            inputStream.close()
        } catch (e: Exception) {
            Log.e(TAG, "Failed to load texture from asset: $assetPath", e)
        }
    }

    private fun createTextureFromBitmap(bitmap: Bitmap) {
        width = bitmap.width
        height = bitmap.height

        val textureIds = IntArray(1)
        GLES30.glGenTextures(1, textureIds, 0)
        textureId = textureIds[0]

        if (textureId == 0) {
            Log.e(TAG, "Failed to generate texture")
            return
        }

        // Bind texture
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, textureId)

        // Set texture parameters
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_MIN_FILTER, GLES30.GL_LINEAR)
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_MAG_FILTER, GLES30.GL_LINEAR)
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_WRAP_S, GLES30.GL_CLAMP_TO_EDGE)
        GLES30.glTexParameteri(GLES30.GL_TEXTURE_2D, GLES30.GL_TEXTURE_WRAP_T, GLES30.GL_CLAMP_TO_EDGE)

        // Load bitmap into texture
        GLUtils.texImage2D(GLES30.GL_TEXTURE_2D, 0, bitmap, 0)

        // Generate mipmaps for better performance
        GLES30.glGenerateMipmap(GLES30.GL_TEXTURE_2D)

        // Unbind texture
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, 0)

        Log.i(TAG, "Texture created: $textureId (${width}x${height})")
    }

    fun bind() {
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, textureId)
    }

    fun unbind() {
        GLES30.glBindTexture(GLES30.GL_TEXTURE_2D, 0)
    }

    fun dispose() {
        if (!disposed && textureId != 0) {
            val textureIds = intArrayOf(textureId)
            GLES30.glDeleteTextures(1, textureIds, 0)
            textureId = 0
            disposed = false
            Log.i(TAG, "Texture disposed: $textureId")
        }
    }

    // Static methods for creating common textures
    companion object {
        // Create a solid color texture
        fun createSolidColor(width: Int, height: Int, r: Float, g: Float, b: Float, a: Float = 1f): Texture? {
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)

            // Fill with color
            val pixels = IntArray(width * height)
            val colorInt = ((a * 255).toInt() shl 24) or
                          ((r * 255).toInt() shl 16) or
                          ((g * 255).toInt() shl 8) or
                          (b * 255).toInt()

            for (i in pixels.indices) {
                pixels[i] = colorInt
            }

            bitmap.setPixels(pixels, 0, width, 0, 0, width, height)

            return try {
                val texture = Texture()
                texture.createTextureFromBitmap(bitmap)
                bitmap.recycle()
                texture
            } catch (e: Exception) {
                Log.e("Texture", "Failed to create solid color texture", e)
                null
            }
        }

        // Create a procedural texture (like crosshair)
        fun createProcedural(width: Int, height: Int, generator: (Int, Int) -> Int): Texture? {
            val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
            val pixels = IntArray(width * height)

            for (y in 0 until height) {
                for (x in 0 until width) {
                    pixels[y * width + x] = generator(x, y)
                }
            }

            bitmap.setPixels(pixels, 0, width, 0, 0, width, height)

            return try {
                val texture = Texture()
                texture.createTextureFromBitmap(bitmap)
                bitmap.recycle()
                texture
            } catch (e: Exception) {
                Log.e("Texture", "Failed to create procedural texture", e)
                null
            }
        }
    }
}
