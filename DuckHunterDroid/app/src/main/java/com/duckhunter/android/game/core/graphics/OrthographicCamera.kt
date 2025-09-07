package com.duckhunter.android.game.core.graphics

import android.opengl.Matrix

class OrthographicCamera(
    private var viewportWidth: Float = 1920f,
    private var viewportHeight: Float = 1080f
) {

    private val projectionMatrix = FloatArray(16)
    private val viewMatrix = FloatArray(16)
    val combined = FloatArray(16)

    private var position = Vector2(0f, 0f)
    private var zoom = 1f
    private var rotation = 0f

    init {
        updateMatrices()
    }

    fun resize(width: Float, height: Float) {
        viewportWidth = width
        viewportHeight = height
        updateProjection()
        updateCombined()
    }

    private fun updateProjection() {
        val left = -viewportWidth / 2f * zoom
        val right = viewportWidth / 2f * zoom
        val bottom = -viewportHeight / 2f * zoom
        val top = viewportHeight / 2f * zoom

        Matrix.orthoM(projectionMatrix, 0, left, right, bottom, top, -1f, 1f)
    }

    private fun updateView() {
        Matrix.setIdentityM(viewMatrix, 0)

        // Apply transformations
        if (rotation != 0f) {
            Matrix.rotateM(viewMatrix, 0, rotation, 0f, 0f, 1f)
        }

        Matrix.translateM(viewMatrix, 0, -position.x, -position.y, 0f)
    }

    private fun updateMatrices() {
        updateProjection()
        updateView()
        updateCombined()
    }

    private fun updateCombined() {
        Matrix.multiplyMM(combined, 0, projectionMatrix, 0, viewMatrix, 0)
    }

    fun update() {
        updateMatrices()
    }

    // Camera controls
    fun setPosition(x: Float, y: Float) {
        position.set(x, y)
        updateView()
        updateCombined()
    }

    fun translate(dx: Float, dy: Float) {
        position.x += dx
        position.y += dy
        updateView()
        updateCombined()
    }

    fun setZoom(zoom: Float) {
        this.zoom = zoom.coerceIn(0.1f, 10f)
        updateProjection()
        updateCombined()
    }

    fun zoomIn(factor: Float = 1.1f) {
        setZoom(zoom * factor)
    }

    fun zoomOut(factor: Float = 1.1f) {
        setZoom(zoom / factor)
    }

    fun setRotation(rotation: Float) {
        this.rotation = rotation
        updateView()
        updateCombined()
    }

    fun rotate(deltaRotation: Float) {
        this.rotation += deltaRotation
        updateView()
        updateCombined()
    }

    // Getters
    fun getPosition(): Vector2 = position
    fun getZoom(): Float = zoom
    fun getRotation(): Float = rotation
    fun getViewportWidth(): Float = viewportWidth
    fun getViewportHeight(): Float = viewportHeight

    // Utility methods
    fun screenToWorld(screenX: Float, screenY: Float): Vector2 {
        // Convert screen coordinates to world coordinates
        val worldX = screenX - viewportWidth / 2f
        val worldY = (viewportHeight - screenY) - viewportHeight / 2f
        return Vector2(worldX, worldY)
    }

    fun worldToScreen(worldX: Float, worldY: Float): Vector2 {
        // Convert world coordinates to screen coordinates
        val screenX = worldX + viewportWidth / 2f
        val screenY = viewportHeight - (worldY + viewportHeight / 2f)
        return Vector2(screenX, screenY)
    }

    fun isVisible(worldX: Float, worldY: Float, width: Float, height: Float): Boolean {
        val left = position.x - viewportWidth / 2f * zoom
        val right = position.x + viewportWidth / 2f * zoom
        val bottom = position.y - viewportHeight / 2f * zoom
        val top = position.y + viewportHeight / 2f * zoom

        return !(worldX + width < left || worldX > right ||
                worldY + height < bottom || worldY > top)
    }
}

// Simple 2D vector class
class Vector2(var x: Float = 0f, var y: Float = 0f) {

    constructor(other: Vector2) : this(other.x, other.y)

    fun set(x: Float, y: Float) {
        this.x = x
        this.y = y
    }

    fun set(other: Vector2) {
        set(other.x, other.y)
    }

    fun add(other: Vector2): Vector2 {
        return Vector2(x + other.x, y + other.y)
    }

    fun add(dx: Float, dy: Float): Vector2 {
        return Vector2(x + dx, y + dy)
    }

    fun subtract(other: Vector2): Vector2 {
        return Vector2(x - other.x, y - other.y)
    }

    fun multiply(scalar: Float): Vector2 {
        return Vector2(x * scalar, y * scalar)
    }

    fun length(): Float {
        return kotlin.math.sqrt(x * x + y * y)
    }

    fun normalize(): Vector2 {
        val len = length()
        return if (len != 0f) Vector2(x / len, y / len) else Vector2(0f, 0f)
    }

    fun distance(other: Vector2): Float {
        val dx = x - other.x
        val dy = y - other.y
        return kotlin.math.sqrt(dx * dx + dy * dy)
    }

    override fun toString(): String {
        return "($x, $y)"
    }
}
