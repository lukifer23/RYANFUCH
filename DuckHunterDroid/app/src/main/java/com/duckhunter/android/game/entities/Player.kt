package com.duckhunter.android.game.entities

import com.duckhunter.android.game.GameMode

class Player(private val gameMode: GameMode) {

    // Stats
    var score = 0
        private set

    var lives = gameMode.maxLives
        private set

    var ammo = gameMode.maxAmmo
        private set

    // Weapon state
    private var isReloading = false
    private var reloadTime = 1.5f // seconds
    private var reloadProgress = 0f

    // Combo system
    private var comboCount = 0
    private var comboMultiplier = 1
    private var lastHitTime = 0L
    private val comboWindow = 2000L // 2 seconds in milliseconds

    // Statistics
    var totalShots = 0
        private set

    var totalHits = 0
        private set

    val accuracy: Float
        get() = if (totalShots > 0) totalHits.toFloat() / totalShots.toFloat() else 0f

    fun canShoot(): Boolean {
        return ammo > 0 && !isReloading && lives > 0
    }

    fun shoot(): Boolean {
        if (!canShoot()) return false

        ammo--
        totalShots++

        // Reset combo if no recent hits
        val currentTime = System.currentTimeMillis()
        if (currentTime - lastHitTime > comboWindow) {
            comboCount = 0
            comboMultiplier = 1
        }

        return true
    }

    fun addScore(points: Int) {
        val actualPoints = points * comboMultiplier
        score += actualPoints
        totalHits++

        // Update combo
        val currentTime = System.currentTimeMillis()
        if (currentTime - lastHitTime <= comboWindow) {
            comboCount++
            comboMultiplier = 1 + (comboCount / 3).coerceAtMost(4) // Max 5x multiplier
        } else {
            comboCount = 1
            comboMultiplier = 1
        }

        lastHitTime = currentTime
    }

    fun loseLife() {
        if (gameMode != GameMode.GOD) {
            lives--
            // Reset combo on life loss
            comboCount = 0
            comboMultiplier = 1
        }
    }

    fun reload() {
        if (ammo < gameMode.maxAmmo && !isReloading) {
            isReloading = true
            reloadProgress = 0f
        }
    }

    fun updateReload(deltaTime: Float) {
        if (isReloading) {
            reloadProgress += deltaTime

            if (reloadProgress >= reloadTime) {
                ammo = gameMode.maxAmmo
                isReloading = false
                reloadProgress = 0f
            }
        }
    }

    val isAlive: Boolean
        get() = lives > 0 || gameMode == GameMode.GOD

    val isInfiniteAmmo: Boolean
        get() = gameMode == GameMode.GOD

    val isInfiniteLives: Boolean
        get() = gameMode == GameMode.GOD

    val reloadProgressPercent: Float
        get() = if (isReloading) reloadProgress / reloadTime else 1f

    fun reset() {
        score = 0
        lives = gameMode.maxLives
        ammo = gameMode.maxAmmo
        isReloading = false
        reloadProgress = 0f
        comboCount = 0
        comboMultiplier = 1
        lastHitTime = 0L
        totalShots = 0
        totalHits = 0
    }

    override fun toString(): String {
        return "Player(score=$score, lives=$lives, ammo=$ammo, accuracy=${"%.1f".format(accuracy * 100)}%, combo=${comboCount}x)"
    }
}
