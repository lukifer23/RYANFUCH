//
//  DuckSpawner.swift
//  DuckHunteriOS
//
//  Created by John Carmack
//  Copyright © 2024 Duck Hunter. All rights reserved.
//

import SpriteKit

class DuckSpawner {

    // MARK: - Properties
    private weak var scene: SKScene?
    private var ducks: [Duck] = []
    private var isSpawning = false

    // Spawning parameters
    private var spawnTimer: TimeInterval = 0
    private var baseSpawnInterval: TimeInterval = Constants.duckSpawnInterval
    private var currentSpawnInterval: TimeInterval = Constants.duckSpawnInterval

    // Difficulty scaling
    private var scoreBasedMultiplier: Double = 1.0
    private var maxConcurrentDucks: Int = Constants.maxConcurrentDucks

    // Duck type probabilities (weighted)
    private var duckTypeWeights: [Constants.DuckType: Int] = [
        .common: 60,
        .rare: 25,
        .golden: 10,
        .boss: 5
    ]

    // MARK: - Initialization
    init(scene: SKScene) {
        self.scene = scene
        reset()
        print("🦆 DuckSpawner initialized")
    }

    // MARK: - Spawning Control
    func startSpawning() {
        isSpawning = true
        spawnTimer = currentSpawnInterval * 0.5 // Start with half interval for immediate spawn
        print("🦆 Duck spawning started")
    }

    func stopSpawning() {
        isSpawning = false
        print("🦆 Duck spawning stopped")
    }

    func update(deltaTime: TimeInterval, score: Int) {
        guard isSpawning, let scene = scene else { return }

        // Update spawn timer
        spawnTimer -= deltaTime

        // Update difficulty based on score
        updateDifficulty(for: score)

        // Check if it's time to spawn
        if spawnTimer <= 0 && ducks.count < maxConcurrentDucks {
            spawnDuck()
            spawnTimer = currentSpawnInterval
        }

        // Clean up off-screen ducks
        ducks.removeAll { duck in
            if duck.position.x > Constants.screenWidth + 100 {
                duck.removeFromParent()
                return true
            }
            return false
        }
    }

    private func spawnDuck() {
        guard let scene = scene else { return }

        // Choose duck type based on current weights
        let duckType = chooseDuckType()

        // Random spawn position (left side, random height)
        let spawnY = CGFloat.random(in: 100...(Constants.screenHeight - 200))
        let spawnPosition = CGPoint(x: -50, y: spawnY)

        // Create duck
        let duck = Duck(duckType: duckType, initialPosition: spawnPosition)

        // Add to scene and tracking array
        scene.addChild(duck)
        ducks.append(duck)

        print("🦆 Spawned \(duckType) duck at (\(Int(spawnPosition.x)), \(Int(spawnPosition.y)))")
    }

    // MARK: - Duck Type Selection
    private func chooseDuckType() -> Constants.DuckType {
        let totalWeight = duckTypeWeights.values.reduce(0, +)
        var randomValue = Int.random(in: 1...totalWeight)

        for (duckType, weight) in duckTypeWeights {
            randomValue -= weight
            if randomValue <= 0 {
                return duckType
            }
        }

        return .common // Fallback
    }

    // MARK: - Difficulty Scaling
    private func updateDifficulty(for score: Int) {
        // Base difficulty scaling
        let scoreMultiplier = 1.0 + Double(score) / 5000.0

        // Update spawn interval (faster spawning at higher scores)
        currentSpawnInterval = max(0.3, baseSpawnInterval / scoreMultiplier)

        // Update duck type probabilities (more rare ducks at higher scores)
        let rarityBonus = min(20, score / 1000) // Cap bonus at 20

        duckTypeWeights[.rare] = min(35, 25 + rarityBonus)
        duckTypeWeights[.golden] = min(20, 10 + rarityBonus / 2)
        duckTypeWeights[.boss] = min(10, 5 + rarityBonus / 4)

        // Normalize weights to maintain total probability
        let totalWeight = duckTypeWeights.values.reduce(0, +)
        let scaleFactor = 100.0 / Double(totalWeight)

        duckTypeWeights = duckTypeWeights.mapValues { Int(Double($0) * scaleFactor) }

        // Update concurrent duck limit (more ducks at higher scores)
        maxConcurrentDucks = min(15, Constants.maxConcurrentDucks + Int(score / 2000))
    }

    // MARK: - Duck Management
    func getDucks() -> [Duck] {
        return ducks
    }

    func getFlyingDucks() -> [Duck] {
        return ducks.filter { $0.isFlying }
    }

    func removeDuck(_ duck: Duck) {
        if let index = ducks.firstIndex(where: { $0 === duck }) {
            ducks.remove(at: index)
        }
    }

    func clearAllDucks() {
        ducks.forEach { $0.removeFromParent() }
        ducks.removeAll()
        print("🧹 All ducks cleared")
    }

    // MARK: - Statistics
    var totalSpawnedDucks: Int {
        return ducks.count
    }

    var averageSpawnInterval: TimeInterval {
        return currentSpawnInterval
    }

    // MARK: - Reset
    func reset() {
        clearAllDucks()
        spawnTimer = 0
        currentSpawnInterval = baseSpawnInterval
        scoreBasedMultiplier = 1.0
        maxConcurrentDucks = Constants.maxConcurrentDucks

        // Reset duck type weights
        duckTypeWeights = [
            .common: 60,
            .rare: 25,
            .golden: 10,
            .boss: 5
        ]

        print("🔄 DuckSpawner reset")
    }

    // MARK: - Debug
    func debugInfo() -> String {
        return """
        DuckSpawner Debug:
        - Is Spawning: \(isSpawning)
        - Current Ducks: \(ducks.count)
        - Spawn Interval: \(String(format: "%.2f", currentSpawnInterval))s
        - Max Concurrent: \(maxConcurrentDucks)
        - Duck Weights: \(duckTypeWeights)
        """
    }
}

// MARK: - Ground Animal Spawner
class GroundAnimalSpawner {

    // MARK: - Properties
    private weak var scene: SKScene?
    private var groundAnimals: [GroundAnimal] = []
    private var isSpawning = false

    // Spawning parameters
    private var spawnTimer: TimeInterval = 0
    private var baseSpawnInterval: TimeInterval = Constants.groundAnimalSpawnInterval
    private var currentSpawnInterval: TimeInterval = Constants.groundAnimalSpawnInterval

    // Difficulty scaling
    private var maxConcurrentAnimals: Int = Constants.maxConcurrentGroundAnimals

    // Animal type probabilities (weighted)
    private var animalTypeWeights: [Constants.GroundAnimalType: Int] = [
        .rabbit: 40,
        .deer: 30,
        .wolf: 25,
        .moose: 20,
        .bear: 10,
        .dinosaur: 15
    ]

    // MARK: - Initialization
    init(scene: SKScene) {
        self.scene = scene
        reset()
        print("🐾 GroundAnimalSpawner initialized")
    }

    // MARK: - Spawning Control
    func startSpawning() {
        isSpawning = true
        spawnTimer = currentSpawnInterval * 0.7 // Start slightly sooner than ducks
        print("🐾 Ground animal spawning started")
    }

    func stopSpawning() {
        isSpawning = false
        print("🐾 Ground animal spawning stopped")
    }

    func update(deltaTime: TimeInterval, score: Int) {
        guard isSpawning, let scene = scene else { return }

        // Update spawn timer
        spawnTimer -= deltaTime

        // Update difficulty based on score
        updateDifficulty(for: score)

        // Check if it's time to spawn
        if spawnTimer <= 0 && groundAnimals.count < maxConcurrentAnimals {
            spawnGroundAnimal()
            spawnTimer = currentSpawnInterval
        }

        // Clean up off-screen animals
        groundAnimals.removeAll { animal in
            if animal.position.x < -100 {
                animal.removeFromParent()
                return true
            }
            return false
        }
    }

    private func spawnGroundAnimal() {
        guard let scene = scene else { return }

        // Choose animal type based on current weights
        let animalType = chooseAnimalType()

        // Create animal
        let animal = GroundAnimal(animalType: animalType)

        // Add to scene and tracking array
        scene.addChild(animal)
        groundAnimals.append(animal)

        print("🐾 Spawned \(animalType) at (\(Int(animal.position.x)), \(Int(animal.position.y)))")
    }

    // MARK: - Animal Type Selection
    private func chooseAnimalType() -> Constants.GroundAnimalType {
        let totalWeight = animalTypeWeights.values.reduce(0, +)
        var randomValue = Int.random(in: 1...totalWeight)

        for (animalType, weight) in animalTypeWeights {
            randomValue -= weight
            if randomValue <= 0 {
                return animalType
            }
        }

        return .rabbit // Fallback
    }

    // MARK: - Difficulty Scaling
    private func updateDifficulty(for score: Int) {
        // Faster spawning at higher scores
        let scoreMultiplier = 1.0 + Double(score) / 4000.0
        currentSpawnInterval = max(0.5, baseSpawnInterval / scoreMultiplier)

        // Update animal type probabilities (rarer animals at higher scores)
        let rarityBonus = min(25, score / 3000)

        animalTypeWeights[.moose] = min(35, 20 + rarityBonus)
        animalTypeWeights[.bear] = min(20, 10 + rarityBonus * 0.8)
        animalTypeWeights[.dinosaur] = min(25, 15 + rarityBonus * 0.6)

        // Normalize weights
        let totalWeight = animalTypeWeights.values.reduce(0, +)
        let scaleFactor = 100.0 / Double(totalWeight)

        animalTypeWeights = animalTypeWeights.mapValues { Int(Double($0) * scaleFactor) }

        // Update concurrent animal limit
        maxConcurrentAnimals = min(8, Constants.maxConcurrentGroundAnimals + Int(score / 2500))
    }

    // MARK: - Animal Management
    func getGroundAnimals() -> [GroundAnimal] {
        return groundAnimals
    }

    func getWalkingAnimals() -> [GroundAnimal] {
        return groundAnimals.filter { $0.isWalking }
    }

    func removeAnimal(_ animal: GroundAnimal) {
        if let index = groundAnimals.firstIndex(where: { $0 === animal }) {
            groundAnimals.remove(at: index)
        }
    }

    func clearAllAnimals() {
        groundAnimals.forEach { $0.removeFromParent() }
        groundAnimals.removeAll()
        print("🧹 All ground animals cleared")
    }

    // MARK: - Statistics
    var totalSpawnedAnimals: Int {
        return groundAnimals.count
    }

    // MARK: - Reset
    func reset() {
        clearAllAnimals()
        spawnTimer = 0
        currentSpawnInterval = baseSpawnInterval
        maxConcurrentAnimals = Constants.maxConcurrentGroundAnimals

        // Reset animal type weights
        animalTypeWeights = [
            .rabbit: 40,
            .deer: 30,
            .wolf: 25,
            .moose: 20,
            .bear: 10,
            .dinosaur: 15
        ]

        print("🔄 GroundAnimalSpawner reset")
    }
}
