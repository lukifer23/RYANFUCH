//
//  Player.swift
//  DuckHunteriOS
//
//  Created by John Carmack
//  Copyright © 2024 Duck Hunter. All rights reserved.
//

import Foundation

class Player {

    // MARK: - Properties
    private(set) var gameMode: Constants.GameMode
    private(set) var score: Int = 0
    private(set) var lives: Int
    private(set) var weapon: Weapon

    // Game statistics
    private(set) var ducksHit: Int = 0
    private(set) var shotsFired: Int = 0
    private(set) var accuracy: Double = 0.0

    // Multipliers and bonuses
    private var scoreMultiplier: Int = 1
    private var comboCount: Int = 0
    private var lastHitTime: TimeInterval = 0

    // MARK: - Initialization
    init(gameMode: Constants.GameMode) {
        self.gameMode = gameMode
        self.lives = gameMode.maxLives
        self.weapon = Weapon(maxAmmo: gameMode.maxAmmo)

        print("🎮 Player initialized in \(gameMode.displayName) mode")
    }

    // MARK: - Score Management
    func addScore(_ points: Int) {
        let actualPoints = points * scoreMultiplier
        score += actualPoints
        ducksHit += 1
        shotsFired += 1 // This should be moved to weapon.fire()

        updateAccuracy()

        // Handle combo system
        let currentTime = CACurrentMediaTime()
        if currentTime - lastHitTime < 2.0 { // 2 second combo window
            comboCount += 1
            scoreMultiplier = min(5, 1 + (comboCount / 3)) // Increase multiplier every 3 hits
        } else {
            comboCount = 1
            scoreMultiplier = 1
        }
        lastHitTime = currentTime

        print("🎯 Hit! +\(actualPoints) points (Multiplier: x\(scoreMultiplier), Combo: \(comboCount))")
    }

    func addMiss() {
        shotsFired += 1
        updateAccuracy()

        // Reset combo on miss
        comboCount = 0
        scoreMultiplier = 1

        print("❌ Miss! Combo reset")
    }

    private func updateAccuracy() {
        accuracy = shotsFired > 0 ? Double(ducksHit) / Double(shotsFired) : 0.0
    }

    // MARK: - Life Management
    func loseLife() {
        guard gameMode != .god else { return } // God mode doesn't lose lives

        lives -= 1
        print("💔 Life lost! Lives remaining: \(lives)")

        if lives <= 0 {
            print("💀 Game Over! Final Score: \(score)")
        }
    }

    func addLife() {
        guard lives < gameMode.maxLives else { return }
        lives += 1
        print("❤️ Life gained! Lives: \(lives)")
    }

    // MARK: - Weapon Interaction
    func canShoot() -> Bool {
        return weapon.canShoot()
    }

    func shoot() -> Bool {
        return weapon.shoot()
    }

    func reload() {
        weapon.reload()
        print("🔄 Weapon reloaded")
    }

    // MARK: - Game Mode Specific Logic
    func isGodMode() -> Bool {
        return gameMode == .god
    }

    func hasInfiniteAmmo() -> Bool {
        return gameMode == .god
    }

    func hasInfiniteLives() -> Bool {
        return gameMode == .god
    }

    // MARK: - Statistics
    var hitRatio: Double {
        return accuracy
    }

    var totalShots: Int {
        return shotsFired
    }

    var totalHits: Int {
        return ducksHit
    }

    var currentMultiplier: Int {
        return scoreMultiplier
    }

    var currentCombo: Int {
        return comboCount
    }

    // MARK: - Reset
    func reset() {
        score = 0
        lives = gameMode.maxLives
        ducksHit = 0
        shotsFired = 0
        accuracy = 0.0
        scoreMultiplier = 1
        comboCount = 0
        lastHitTime = 0

        weapon.reset()

        print("🔄 Player stats reset")
    }

    // MARK: - Persistence (Future Implementation)
    func saveProgress() {
        // Future: Save high scores, achievements, etc.
        let progress = [
            "highScore": score,
            "totalDucksHit": ducksHit,
            "accuracy": accuracy
        ]

        UserDefaults.standard.set(progress, forKey: "playerProgress")
    }

    func loadProgress() {
        // Future: Load saved progress
        if let progress = UserDefaults.standard.dictionary(forKey: "playerProgress") {
            // Load saved data
            print("📊 Progress loaded: \(progress)")
        }
    }
}

// MARK: - Weapon Class
class Weapon {

    // MARK: - Properties
    private(set) var maxAmmo: Int
    private(set) var currentAmmo: Int
    private var isReloading = false
    private var reloadTime: TimeInterval = 1.5 // seconds
    private var reloadTimer: TimeInterval = 0

    // Weapon statistics
    private(set) var totalShotsFired: Int = 0
    private(set) var totalReloads: Int = 0

    // MARK: - Initialization
    init(maxAmmo: Int = 8) {
        self.maxAmmo = maxAmmo
        self.currentAmmo = maxAmmo
    }

    // MARK: - Shooting Logic
    func canShoot() -> Bool {
        return currentAmmo > 0 && !isReloading
    }

    func shoot() -> Bool {
        guard canShoot() else {
            if isReloading {
                print("🔄 Still reloading...")
            } else {
                print("💨 Out of ammo!")
            }
            return false
        }

        currentAmmo -= 1
        totalShotsFired += 1

        print("🔫 Shot fired! Ammo: \(currentAmmo)/\(maxAmmo)")

        // Auto-reload if empty (optional feature)
        if currentAmmo == 0 {
            startReload()
        }

        return true
    }

    // MARK: - Reloading
    func reload() {
        guard !isReloading else { return }
        startReload()
    }

    private func startReload() {
        guard currentAmmo < maxAmmo else { return }

        isReloading = true
        reloadTimer = reloadTime
        totalReloads += 1

        print("🔄 Reloading... (\(reloadTime)s)")
    }

    func updateReload(deltaTime: TimeInterval) {
        guard isReloading else { return }

        reloadTimer -= deltaTime

        if reloadTimer <= 0 {
            finishReload()
        }
    }

    private func finishReload() {
        currentAmmo = maxAmmo
        isReloading = false
        reloadTimer = 0

        print("✅ Reload complete! Ammo: \(currentAmmo)/\(maxAmmo)")
    }

    // MARK: - Weapon Upgrades (Future Feature)
    func upgradeCapacity(_ additionalAmmo: Int) {
        maxAmmo += additionalAmmo
        print("⬆️ Weapon capacity upgraded to \(maxAmmo)")
    }

    func upgradeReloadSpeed(_ speedMultiplier: Double) {
        reloadTime = max(0.5, reloadTime / speedMultiplier)
        print("⚡ Reload speed upgraded: \(reloadTime)s")
    }

    // MARK: - Status
    var ammoCount: Int {
        return currentAmmo
    }

    var isFull: Bool {
        return currentAmmo == maxAmmo
    }

    var reloadProgress: Double {
        guard isReloading else { return 1.0 }
        return 1.0 - (reloadTimer / reloadTime)
    }

    // MARK: - Reset
    func reset() {
        currentAmmo = maxAmmo
        isReloading = false
        reloadTimer = 0
        totalShotsFired = 0
        totalReloads = 0
    }
}
