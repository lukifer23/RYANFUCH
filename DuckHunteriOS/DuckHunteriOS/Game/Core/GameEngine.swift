//
//  GameEngine.swift
//  DuckHunteriOS
//
//  Created by John Carmack
//  Copyright © 2024 Duck Hunter. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameEngine {

    // MARK: - Properties
    private weak var scene: SKScene!
    private var gameState: GameState = .menu

    // Game systems
    private var resourceManager: ResourceManager!
    private var audioManager: AudioManager!
    private var inputManager: InputManager!
    private var uiSystem: UISystem!
    private var menuSystem: MenuSystem!
    private var particleSystem: ParticleSystem!

    // Game objects
    private var ducks: [Duck] = []
    private var groundAnimals: [GroundAnimal] = []
    private var player: Player!
    private var weapon: Weapon!

    // Spawners
    private var duckSpawner: DuckSpawner!
    private var groundAnimalSpawner: GroundAnimalSpawner!

    // Timing
    private var gameStartTime: TimeInterval = 0
    private var lastUpdateTime: TimeInterval = 0

    // MARK: - Initialization
    init(scene: SKScene) {
        self.scene = scene
        initializeGameSystems()
        print("🚀 Game Engine initialized")
    }

    private func initializeGameSystems() {
        // Initialize core systems
        resourceManager = ResourceManager.shared
        audioManager = AudioManager.shared
        inputManager = InputManager()

        // Initialize UI systems
        uiSystem = UISystem(scene: scene)
        menuSystem = MenuSystem(scene: scene)

        // Initialize particle system
        particleSystem = ParticleSystem()
        scene.addChild(particleSystem)

        // Initialize game objects
        player = Player(gameMode: .normal)
        weapon = Weapon()

        // Initialize spawners
        duckSpawner = DuckSpawner(scene: scene)
        groundAnimalSpawner = GroundAnimalSpawner(scene: scene)

        // Set initial game state
        setGameState(.menu)
    }

    // MARK: - Game State Management
    private func setGameState(_ newState: GameState) {
        let oldState = gameState
        gameState = newState

        print("🎮 Game state changed: \(oldState) → \(newState)")

        switch newState {
        case .menu:
            handleMenuState()
        case .playing:
            handlePlayingState()
        case .paused:
            handlePausedState()
        case .gameOver:
            handleGameOverState()
        }
    }

    private func handleMenuState() {
        // Show main menu
        menuSystem.showMainMenu()
        uiSystem.hideHUD()

        // Clear game objects
        clearGameObjects()
    }

    private func handlePlayingState() {
        // Hide menu and show game HUD
        menuSystem.hideMenu()
        uiSystem.showHUD()

        // Reset game timer
        gameStartTime = CACurrentMediaTime()

        // Start spawning
        duckSpawner.startSpawning()
        groundAnimalSpawner.startSpawning()

        print("🎯 Game started!")
    }

    private func handlePausedState() {
        // Show pause menu
        menuSystem.showPauseMenu()

        // Stop spawning
        duckSpawner.stopSpawning()
        groundAnimalSpawner.stopSpawning()
    }

    private func handleGameOverState() {
        // Show game over screen
        menuSystem.showGameOver(score: player.score)

        // Stop spawning
        duckSpawner.stopSpawning()
        groundAnimalSpawner.stopSpawning()

        print("💀 Game Over! Final Score: \(player.score)")
    }

    // MARK: - Update Loop
    func update(deltaTime: TimeInterval) {
        lastUpdateTime = deltaTime

        switch gameState {
        case .menu:
            menuSystem.update(deltaTime: deltaTime)
        case .playing:
            updatePlayingState(deltaTime: deltaTime)
        case .paused:
            // Paused - minimal updates
            uiSystem.update(deltaTime: deltaTime)
        case .gameOver:
            // Game over - minimal updates
            uiSystem.update(deltaTime: deltaTime)
        }
    }

    private func updatePlayingState(deltaTime: TimeInterval) {
        // Update spawners
        duckSpawner.update(deltaTime: deltaTime, score: player.score)
        groundAnimalSpawner.update(deltaTime: deltaTime, score: player.score)

        // Update game objects
        updateDucks(deltaTime: deltaTime)
        updateGroundAnimals(deltaTime: deltaTime)

        // Update systems
        uiSystem.update(deltaTime: deltaTime)
        particleSystem.update(deltaTime: deltaTime)

        // Check win/lose conditions
        checkGameConditions()
    }

    private func updateDucks(deltaTime: TimeInterval) {
        ducks.forEach { duck in
            duck.update(deltaTime: deltaTime)
        }

        // Remove off-screen ducks
        ducks.removeAll { duck in
            if duck.position.x > scene.size.width + 100 {
                scene.removeChildren(in: [duck])
                player.loseLife()
                return true
            }
            return false
        }
    }

    private func updateGroundAnimals(deltaTime: TimeInterval) {
        groundAnimals.forEach { animal in
            animal.update(deltaTime: deltaTime)
        }

        // Remove off-screen animals
        groundAnimals.removeAll { animal in
            if animal.position.x < -100 {
                scene.removeChildren(in: [animal])
                return true
            }
            return false
        }
    }

    private func checkGameConditions() {
        // Check for game over
        if player.lives <= 0 {
            setGameState(.gameOver)
            return
        }

        // Check for God mode time limit
        if player.gameMode == .god {
            let elapsedTime = CACurrentMediaTime() - gameStartTime
            if elapsedTime >= Constants.godModeTimeLimit {
                setGameState(.gameOver)
                return
            }
        }
    }

    // MARK: - Input Handling
    func handleShoot(at position: CGPoint) {
        guard gameState == .playing else { return }

        if weapon.shoot() {
            // Play shot sound
            audioManager.playSound(.shotgun)

            // Check for hits
            let hitTargets = checkHits(at: position)

            if !hitTargets.isEmpty {
                // Hit feedback
                audioManager.playSound(.hit)
                uiSystem.showHitFeedback()

                // Process hits
                for target in hitTargets {
                if let duck = target as? Duck {
                    duck.shootDown()
                    player.addScore(duck.pointValue)
                    ducks.removeAll { $0 === duck }

                    // Emit feather particles
                    particleSystem.emitFeathers(at: duck.position)
                } else if let animal = target as? GroundAnimal {
                    animal.shootHit()
                    player.addScore(animal.pointValue)
                    groundAnimals.removeAll { $0 === animal }

                    // Emit hit sparks
                    particleSystem.emitHitSparks(at: animal.position)
                }
                }
            } else {
                // Miss feedback
                audioManager.playSound(.miss)
            }
        } else {
            // Out of ammo
            audioManager.playSound(.emptyClick)
        }
    }

    private func checkHits(at position: CGPoint) -> [SKNode] {
        let hitRadius = Constants.crosshairHitRadius
        var hitTargets: [SKNode] = []

        // Check ducks
        for duck in ducks where duck.state == .flying {
            let distance = position.distance(to: duck.position)
            if distance <= hitRadius {
                hitTargets.append(duck)
            }
        }

        // Check ground animals
        for animal in groundAnimals where animal.state == .walking {
            let distance = position.distance(to: animal.position)
            if distance <= hitRadius {
                hitTargets.append(animal)
            }
        }

        // Return closest target if multiple hits
        return hitTargets.sorted { a, b in
            a.position.distance(to: position) < b.position.distance(to: position)
        }.first.map { [$0] } ?? []
    }

    func handlePhysicsContact(_ contact: SKPhysicsContact) {
        // Handle physics-based collisions
        let bodyA = contact.bodyA.node
        let bodyB = contact.bodyB.node

        // Handle duck-ground collisions
        if let duck = bodyA as? Duck, bodyB?.name == "ground" {
            duck.hitGround()
        } else if let duck = bodyB as? Duck, bodyA?.name == "ground" {
            duck.hitGround()
        }
    }

    // MARK: - Game Control Methods
    func startNewGame(mode: GameMode) {
        // Reset game state
        clearGameObjects()
        player = Player(gameMode: mode)
        weapon = Weapon()

        // Reset spawners
        duckSpawner.reset()
        groundAnimalSpawner.reset()

        // Clear particles
        particleSystem.clearAllParticles()

        setGameState(.playing)
    }

    func pauseGame() {
        if gameState == .playing {
            setGameState(.paused)
        } else if gameState == .paused {
            setGameState(.playing)
        }
    }

    func quitToMenu() {
        setGameState(.menu)
    }

    private func clearGameObjects() {
        // Remove all ducks and animals from scene
        scene.removeChildren(in: ducks)
        scene.removeChildren(in: groundAnimals)

        ducks.removeAll()
        groundAnimals.removeAll()
    }

    // MARK: - Public Accessors
    var currentGameState: GameState { gameState }
    var currentPlayer: Player { player }
    var currentWeapon: Weapon { weapon }
}

// MARK: - Supporting Types
enum GameState {
    case menu
    case playing
    case paused
    case gameOver
}

enum GameMode {
    case easy
    case normal
    case hard
    case god
}
