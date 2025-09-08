//
//  GameScene.swift
//  DuckHunteriOS_Full
//
//  SpriteKit scene for Duck Hunter game
//

import SpriteKit
import AVFoundation
import CoreGraphics
#if os(macOS)
import AppKit
#endif

class GameScene: SKScene {

    // MARK: - Properties
    private var gameEngine: GameEngine!
    private var lastUpdateTime: TimeInterval = 0
    private var crosshairNode: SKSpriteNode!
    private var backgroundNode: SKSpriteNode!

    // Game state
    private var isGameActive = false
    private var gamePaused = false

    // MARK: - Initialization
    override init(size: CGSize) {
        super.init(size: size)
        setupScene()
        setupNotifications()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupScene() {
        // Set up scene properties
        backgroundColor = Constants.backgroundColor
        scaleMode = .aspectFill

        // Initialize game engine
        gameEngine = GameEngine()

        // Create background
        setupBackground()

        // Create crosshair
        setupCrosshair()

        print("� Duck Hunter iOS - Game Scene Initialized")
    }

    private func setupBackground() {
        backgroundNode = SKSpriteNode(color: Constants.backgroundColor, size: size)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.zPosition = -1
        addChild(backgroundNode)
    }

    private func setupCrosshair() {
        let crosshairSize = CGSize(width: 60, height: 60)
        crosshairNode = SKSpriteNode(color: .white, size: crosshairSize)
        crosshairNode.zPosition = 100
        addChild(crosshairNode)
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(startGame), name: NSNotification.Name("StartGame"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name: NSNotification.Name("PauseGame"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeGame), name: NSNotification.Name("ResumeGame"), object: nil)
    }

    // MARK: - Game Control
    @objc private func startGame() {
        isGameActive = true
        gamePaused = false
        gameEngine.startGame()
        print("🎮 Game Started")
    }

    @objc private func pauseGame() {
        gamePaused = true
        print("⏸️ Game Paused")
    }

    @objc private func resumeGame() {
        gamePaused = false
        print("▶️ Game Resumed")
    }

    // MARK: - Touch Handling
    func handleTouches(_ touches: Set<UITouch>, in view: UIView) {
        guard isGameActive && !gamePaused else { return }

        for touch in touches {
            let location = touch.location(in: view)
            let gameLocation = convertPoint(fromView: location)

            // Update crosshair position
            crosshairNode.position = gameLocation

            // Handle shooting
            if touch.phase == .began {
                handleShoot(at: gameLocation)
            }
        }
    }

    // MARK: - Mouse Handling (macOS)
    func handleMouse(_ event: NSEvent, in view: NSView) {
        guard isGameActive && !gamePaused else { return }

        let location = event.locationInWindow
        let gameLocation = convertPoint(fromView: location)

        // Update crosshair position
        crosshairNode.position = gameLocation

        // Handle shooting on mouse down
        if event.type == .leftMouseDown {
            handleShoot(at: gameLocation)
        }
    }

    private func handleShoot(at location: CGPoint) {
        // Convert SpriteKit coordinates to game coordinates
        let gameX = location.x
        let gameY = size.height - location.y // Flip Y coordinate for iOS

        // Trigger shot in game engine
        gameEngine.handleShoot(atX: gameX, y: gameY)
    }

    // MARK: - Update Loop
    override func update(_ currentTime: TimeInterval) {
        guard isGameActive && !gamePaused else { return }

        // Calculate delta time
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update game engine
        gameEngine.update(deltaTime: deltaTime)

        // Update visual elements
        updateVisualElements()
    }

    private func updateVisualElements() {
        // Update ducks
        updateDuckSprites()

        // Update ground animals
        updateGroundAnimalSprites()

        // Update particles
        updateParticleEffects()

        // Update UI
        updateUIElements()
    }

    private func updateDuckSprites() {
        // Get ducks from game engine and update their SpriteKit representations
        let ducks = gameEngine.getDucks()

        for duck in ducks {
            // Create or update duck sprite
            let duckNode = getOrCreateDuckNode(for: duck)
            duckNode.position = CGPoint(x: duck.position.x, y: size.height - duck.position.y)
            // Update animation, etc.
        }
    }

    private func updateGroundAnimalSprites() {
        // Similar to ducks
        let animals = gameEngine.getGroundAnimals()

        for animal in animals {
            let animalNode = getOrCreateAnimalNode(for: animal)
            animalNode.position = CGPoint(x: animal.position.x, y: size.height - animal.position.y)
        }
    }

    private func updateParticleEffects() {
        // Handle particle effects for hits, etc.
        let particles = gameEngine.getParticles()

        for particle in particles {
            let particleNode = getOrCreateParticleNode(for: particle)
            particleNode.position = CGPoint(x: particle.position.x, y: size.height - particle.position.y)
        }
    }

    private func updateUIElements() {
        // Update score, ammo, etc.
        // This would update UIKit overlay elements
    }

    // MARK: - Sprite Management
    private func getOrCreateDuckNode(for duck: Duck) -> SKSpriteNode {
        // Find existing node or create new one
        let nodeName = "duck_\(duck.id)"
        if let existingNode = childNode(withName: nodeName) as? SKSpriteNode {
            return existingNode
        }

        // Create new duck node
        let duckNode = SKSpriteNode(color: .brown, size: CGSize(width: 40, height: 30))
        duckNode.name = nodeName
        duckNode.zPosition = 10
        addChild(duckNode)

        return duckNode
    }

    private func getOrCreateAnimalNode(for animal: GroundAnimal) -> SKSpriteNode {
        let nodeName = "animal_\(animal.id)"
        if let existingNode = childNode(withName: nodeName) as? SKSpriteNode {
            return existingNode
        }

        let animalNode = SKSpriteNode(color: .green, size: CGSize(width: 50, height: 40))
        animalNode.name = nodeName
        animalNode.zPosition = 5
        addChild(animalNode)

        return animalNode
    }

    private func getOrCreateParticleNode(for particle: Particle) -> SKSpriteNode {
        let nodeName = "particle_\(particle.id)"
        if let existingNode = childNode(withName: nodeName) as? SKSpriteNode {
            return existingNode
        }

        let particleNode = SKSpriteNode(color: .yellow, size: CGSize(width: 5, height: 5))
        particleNode.name = nodeName
        particleNode.zPosition = 15
        addChild(particleNode)

        return particleNode
    }

    // MARK: - Cleanup
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

    // MARK: - Entity Management
    func addEntity(_ entity: Any, named name: String) {
        entities[name] = entity
        print("➕ Added entity: \(name)")
    }

    func removeEntity(named name: String) {
        if entities.removeValue(forKey: name) != nil {
            print("➖ Removed entity: \(name)")
        }
    }

    func getEntity(named name: String) -> Any? {
        return entities[name]
    }

    // MARK: - Scene Properties
    func getSize() -> CGSize {
        return sceneSize
    }

    func setSize(_ size: CGSize) {
        self.sceneSize = size
        print("📏 Scene size updated to: \(size)")
    }
