//
//  GroundAnimal.swift
//  DuckHunteriOS
//
//  Created by John Carmack
//  Copyright © 2024 Duck Hunter. All rights reserved.
//

import SpriteKit

class GroundAnimal: SKSpriteNode {

    // MARK: - Properties
    private(set) var animalType: Constants.GroundAnimalType
    private(set) var state: AnimalState = .walking
    private(set) var pointValue: Int

    // Movement
    private var speed: CGFloat
    private var direction: CGFloat = 1.0 // 1 for right, -1 for left

    // Animation
    private var animationTextures: [SKTexture] = []
    private var currentAnimation: SKAction?

    // MARK: - Initialization
    init(animalType: Constants.GroundAnimalType) {
        self.animalType = animalType
        self.pointValue = animalType.pointValue

        // Set speed based on animal type
        self.speed = CGFloat.random(in: animalType.speedRange)

        // Create procedural texture
        let initialTexture = createProceduralTexture(for: .walking, frame: 0)

        super.init(texture: initialTexture, color: .clear, size: initialTexture.size())

        self.name = "ground_animal"

        setupAnimal()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupAnimal() {
        // Create animation textures
        createAnimationTextures()

        // Start walking animation
        setAnimation(.walking)

        // Set initial position (spawn from right side)
        self.position = CGPoint(x: Constants.screenWidth + 50, y: Constants.groundY)

        // Setup physics
        setupPhysics()

        print("🐾 Created \(animalType) with \(pointValue) points")
    }

    // MARK: - Animation
    private func createAnimationTextures() {
        // Create walking animation frames
        for frame in 0..<2 {
            let texture = createProceduralTexture(for: .walking, frame: frame)
            animationTextures.append(texture)
        }

        // Create hit texture (for death animation)
        let hitTexture = createProceduralTexture(for: .hit, frame: 0)
        animationTextures.append(hitTexture)
    }

    private func createProceduralTexture(for state: AnimalState, frame: Int) -> SKTexture {
        let size = CGSize(width: 64, height: 48)

        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let cgContext = context.cgContext

            // Get color scheme
            let colors = getAnimalColorScheme()

            switch state {
            case .walking:
                drawWalkingFrame(frame: frame, colors: colors, in: cgContext, size: size)
            case .hit:
                drawHitFrame(colors: colors, in: cgContext, size: size)
            }
        }

        return SKTexture(image: image)
    }

    private func getAnimalColorScheme() -> [UIColor] {
        switch animalType {
        case .rabbit:
            return [UIColor(red: 0.8, green: 0.8, blue: 0.8, alpha: 1.0), // body
                    UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0), // ears
                    UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0), // details
                    UIColor.black] // eyes
        case .deer:
            return [UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0), // body
                    UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0), // antlers
                    UIColor(red: 0.8, green: 0.6, blue: 0.4, alpha: 1.0), // spots
                    UIColor.black] // eyes
        case .wolf:
            return [UIColor(red: 0.4, green: 0.4, blue: 0.4, alpha: 1.0), // body
                    UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 1.0), // ears
                    UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1.0), // tail
                    UIColor.red] // eyes
        case .moose:
            return [UIColor(red: 0.5, green: 0.3, blue: 0.2, alpha: 1.0), // body
                    UIColor(red: 0.3, green: 0.2, blue: 0.1, alpha: 1.0), // antlers
                    UIColor(red: 0.7, green: 0.5, blue: 0.3, alpha: 1.0), // legs
                    UIColor.black] // eyes
        case .bear:
            return [UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0), // body
                    UIColor(red: 0.2, green: 0.1, blue: 0.1, alpha: 1.0), // ears
                    UIColor(red: 0.6, green: 0.4, blue: 0.2, alpha: 1.0), // paws
                    UIColor.black] // eyes
        case .dinosaur:
            return [UIColor(red: 0.2, green: 0.5, blue: 0.2, alpha: 1.0), // body
                    UIColor(red: 0.4, green: 0.7, blue: 0.4, alpha: 1.0), // spikes
                    UIColor(red: 0.1, green: 0.3, blue: 0.1, alpha: 1.0), // legs
                    UIColor.red] // eyes
        }
    }

    private func drawWalkingFrame(frame: Int, colors: [UIColor], in context: CGContext, size: CGSize) {
        switch animalType {
        case .rabbit:
            drawRabbit(frame: frame, colors: colors, in: context, size: size)
        case .deer:
            drawDeer(frame: frame, colors: colors, in: context, size: size)
        case .wolf:
            drawWolf(frame: frame, colors: colors, in: context, size: size)
        case .moose:
            drawMoose(frame: frame, colors: colors, in: context, size: size)
        case .bear:
            drawBear(frame: frame, colors: colors, in: context, size: size)
        case .dinosaur:
            drawDinosaur(frame: frame, colors: colors, in: context, size: size)
        }
    }

    private func drawHitFrame(colors: [UIColor], in context: CGContext, size: CGSize) {
        // Draw X eyes for death
        context.setFillColor(colors[3].cgColor) // eye color

        // Left eye X
        context.fillEllipse(in: CGRect(x: size.width * 0.3 - 2, y: size.height * 0.6 - 2, width: 4, height: 4))
        context.fillEllipse(in: CGRect(x: size.width * 0.4 - 2, y: size.height * 0.7 - 2, width: 4, height: 4))

        // Right eye X
        context.fillEllipse(in: CGRect(x: size.width * 0.6 - 2, y: size.height * 0.6 - 2, width: 4, height: 4))
        context.fillEllipse(in: CGRect(x: size.width * 0.7 - 2, y: size.height * 0.7 - 2, width: 4, height: 4))
    }

    // MARK: - Individual Animal Drawings
    private func drawRabbit(frame: Int, colors: [UIColor], in context: CGContext, size: CGSize) {
        // Body
        context.setFillColor(colors[0].cgColor)
        context.fillEllipse(in: CGRect(x: 8, y: 8, width: 40, height: 24))

        // Head
        context.fillEllipse(in: CGRect(x: 40, y: 12, width: 16, height: 16))

        // Ears
        context.setFillColor(colors[1].cgColor)
        context.fillEllipse(in: CGRect(x: 44, y: 20, width: 4, height: 12))
        context.fillEllipse(in: CGRect(x: 48, y: 20, width: 4, height: 12))

        // Legs (animated)
        let legOffset = frame == 0 ? 0 : 4
        context.fillRect(CGRect(x: 12 + legOffset, y: 0, width: 3, height: 8))
        context.fillRect(CGRect(x: 20 + legOffset, y: 0, width: 3, height: 8))
        context.fillRect(CGRect(x: 36 - legOffset, y: 0, width: 3, height: 8))
        context.fillRect(CGRect(x: 44 - legOffset, y: 0, width: 3, height: 8))

        // Eyes
        context.setFillColor(colors[3].cgColor)
        context.fillEllipse(in: CGRect(x: 42, y: 16, width: 2, height: 2))
        context.fillEllipse(in: CGRect(x: 50, y: 16, width: 2, height: 2))

        // Tail
        context.setFillColor(colors[1].cgColor)
        context.fillEllipse(in: CGRect(x: 4, y: 12, width: 6, height: 6))
    }

    private func drawDeer(frame: Int, colors: [UIColor], in context: CGContext, size: CGSize) {
        // Body
        context.setFillColor(colors[0].cgColor)
        context.fillEllipse(in: CGRect(x: 8, y: 8, width: 48, height: 28))

        // Head
        context.fillEllipse(in: CGRect(x: 48, y: 16, width: 16, height: 16))

        // Antlers
        context.setFillColor(colors[1].cgColor)
        context.fillRect(CGRect(x: 52, y: 28, width: 2, height: 8))
        context.fillRect(CGRect(x: 56, y: 28, width: 2, height: 8))

        // Legs (animated)
        let legOffset = frame == 0 ? 0 : 3
        for i in 0..<4 {
            context.fillRect(CGRect(x: 12 + i * 8 + legOffset, y: 0, width: 3, height: 10))
        }

        // Spots
        context.setFillColor(colors[2].cgColor)
        context.fillEllipse(in: CGRect(x: 16, y: 16, width: 4, height: 4))
        context.fillEllipse(in: CGRect(x: 32, y: 20, width: 4, height: 4))

        // Eyes
        context.setFillColor(colors[3].cgColor)
        context.fillEllipse(in: CGRect(x: 50, y: 20, width: 2, height: 2))
        context.fillEllipse(in: CGRect(x: 58, y: 20, width: 2, height: 2))
    }

    private func drawWolf(frame: Int, colors: [UIColor], in context: CGContext, size: CGSize) {
        // Body
        context.setFillColor(colors[0].cgColor)
        context.fillEllipse(in: CGRect(x: 8, y: 8, width: 44, height: 26))

        // Head
        context.fillEllipse(in: CGRect(x: 44, y: 12, width: 16, height: 16))

        // Ears
        context.setFillColor(colors[1].cgColor)
        context.fillEllipse(in: CGRect(x: 46, y: 22, width: 4, height: 8))
        context.fillEllipse(in: CGRect(x: 54, y: 22, width: 4, height: 8))

        // Legs (animated)
        let legOffset = frame == 0 ? 0 : 4
        for i in 0..<4 {
            context.fillRect(CGRect(x: 12 + i * 7 + legOffset, y: 0, width: 3, height: 10))
        }

        // Tail
        context.setFillColor(colors[2].cgColor)
        context.fillEllipse(in: CGRect(x: 4, y: 12, width: 8, height: 6))

        // Eyes
        context.setFillColor(colors[3].cgColor)
        context.fillEllipse(in: CGRect(x: 46, y: 16, width: 2, height: 2))
        context.fillEllipse(in: CGRect(x: 54, y: 16, width: 2, height: 2))
    }

    private func drawMoose(frame: Int, colors: [UIColor], in context: CGContext, size: CGSize) {
        // Body
        context.setFillColor(colors[0].cgColor)
        context.fillEllipse(in: CGRect(x: 8, y: 8, width: 48, height: 30))

        // Head
        context.fillEllipse(in: CGRect(x: 48, y: 20, width: 16, height: 16))

        // Large antlers
        context.setFillColor(colors[1].cgColor)
        context.fillRect(CGRect(x: 50, y: 32, width: 2, height: 12))
        context.fillRect(CGRect(x: 56, y: 32, width: 2, height: 12))
        // Antler branches
        context.fillRect(CGRect(x: 48, y: 38, width: 6, height: 2))
        context.fillRect(CGRect(x: 54, y: 38, width: 6, height: 2))

        // Legs (animated)
        let legOffset = frame == 0 ? 0 : 3
        for i in 0..<4 {
            context.fillRect(CGRect(x: 12 + i * 8 + legOffset, y: 0, width: 4, height: 12))
        }

        // Eyes
        context.setFillColor(colors[3].cgColor)
        context.fillEllipse(in: CGRect(x: 50, y: 24, width: 2, height: 2))
        context.fillEllipse(in: CGRect(x: 58, y: 24, width: 2, height: 2))
    }

    private func drawBear(frame: Int, colors: [UIColor], in context: CGContext, size: CGSize) {
        // Body
        context.setFillColor(colors[0].cgColor)
        context.fillEllipse(in: CGRect(x: 8, y: 8, width: 48, height: 32))

        // Head
        context.fillEllipse(in: CGRect(x: 48, y: 16, width: 16, height: 16))

        // Ears
        context.setFillColor(colors[1].cgColor)
        context.fillEllipse(in: CGRect(x: 50, y: 28, width: 4, height: 6))
        context.fillEllipse(in: CGRect(x: 58, y: 28, width: 4, height: 6))

        // Legs (animated)
        let legOffset = frame == 0 ? 0 : 5
        for i in 0..<4 {
            context.fillRect(CGRect(x: 12 + i * 8 + legOffset, y: 0, width: 5, height: 12))
        }

        // Eyes
        context.setFillColor(colors[3].cgColor)
        context.fillEllipse(in: CGRect(x: 50, y: 20, width: 2, height: 2))
        context.fillEllipse(in: CGRect(x: 58, y: 20, width: 2, height: 2))
    }

    private func drawDinosaur(frame: Int, colors: [UIColor], in context: CGContext, size: CGSize) {
        // Body
        context.setFillColor(colors[0].cgColor)
        context.fillEllipse(in: CGRect(x: 8, y: 8, width: 48, height: 28))

        // Head
        context.fillEllipse(in: CGRect(x: 48, y: 16, width: 16, height: 16))

        // Spikes along back
        context.setFillColor(colors[1].cgColor)
        for i in 0..<6 {
            let x = 12 + i * 6
            context.fillEllipse(in: CGRect(x: x, y: 32, width: 4, height: 8))
        }

        // Legs (animated)
        let legOffset = frame == 0 ? 0 : 4
        for i in 0..<2 {
            context.fillRect(CGRect(x: 16 + i * 16 + legOffset, y: 0, width: 6, height: 14))
        }

        // Eyes
        context.setFillColor(colors[3].cgColor)
        context.fillEllipse(in: CGRect(x: 50, y: 20, width: 2, height: 2))
        context.fillEllipse(in: CGRect(x: 58, y: 20, width: 2, height: 2))
    }

    // MARK: - Animation Control
    private func setAnimation(_ newState: AnimalState) {
        guard state != newState else { return }

        state = newState

        // Stop current animation
        removeAction(forKey: "animalAnimation")

        switch newState {
        case .walking:
            let walkTextures = [animationTextures[0], animationTextures[1]]
            let walkAnimation = SKAction.animate(with: walkTextures, timePerFrame: 0.3)
            currentAnimation = SKAction.repeatForever(walkAnimation)
            run(currentAnimation!, withKey: "animalAnimation")

        case .hit:
            texture = animationTextures[2] // Hit texture
            // Stop walking animation
            removeAction(forKey: "animalAnimation")
        }
    }

    // MARK: - Physics
    private func setupPhysics() {
        let physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 0.8, height: size.height * 0.6))
        physicsBody.categoryBitMask = PhysicsCategory.groundAnimal
        physicsBody.contactTestBitMask = PhysicsCategory.none
        physicsBody.collisionBitMask = PhysicsCategory.ground
        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = false

        self.physicsBody = physicsBody
    }

    // MARK: - Update Loop
    func update(deltaTime: TimeInterval) {
        switch state {
        case .walking:
            updateWalking(deltaTime: deltaTime)
        case .hit:
            // No movement when hit
            break
        }
    }

    private func updateWalking(deltaTime: TimeInterval) {
        // Move left across screen
        position.x -= speed * CGFloat(deltaTime)

        // Remove when off-screen
        if position.x < -100 {
            removeFromParent()
        }
    }

    // MARK: - Actions
    func shootHit() {
        guard state == .walking else { return }

        print("💥 Animal hit! \(animalType) - \(pointValue) points")
        setAnimation(.hit)

        // Optional: Add death animation or effects here
        run(SKAction.sequence([
            SKAction.wait(forDuration: 0.5),
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))
    }

    // MARK: - Utility
    var isWalking: Bool { state == .walking }
    var isHit: Bool { state == .hit }
}

// MARK: - Supporting Types
enum AnimalState {
    case walking
    case hit
}
