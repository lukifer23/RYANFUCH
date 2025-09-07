//
//  Duck.swift
//  DuckHunteriOS
//
//  Created by John Carmack
//  Copyright © 2024 Duck Hunter. All rights reserved.
//

import SpriteKit

class Duck: SKSpriteNode {

    // MARK: - Properties
    private(set) var duckType: Constants.DuckType
    private(set) var state: DuckState = .flying
    private(set) var pointValue: Int

    // AI Properties
    private var speed: CGFloat
    private var amplitude: CGFloat
    private var frequency: CGFloat
    private var initialY: CGFloat
    private var fallSpeed: CGFloat = 0

    // Animation
    private var animationTextures: [SKTexture] = []
    private var currentAnimation: SKAction?

    // Physics
    private var physicsBodySetup = false

    // MARK: - Initialization
    init(duckType: Constants.DuckType, initialPosition: CGPoint) {
        self.duckType = duckType
        self.pointValue = duckType.pointValue

        // Set AI properties based on duck type
        self.speed = CGFloat.random(in: duckType.speedRange)
        self.amplitude = CGFloat.random(in: duckType.amplitudeRange)
        self.frequency = CGFloat.random(in: duckType.frequencyRange)
        self.initialY = initialPosition.y

        // Create procedural texture
        let initialTexture = createProceduralTexture(for: .flying, frame: 0)

        super.init(texture: initialTexture, color: .clear, size: initialTexture.size())

        self.position = initialPosition
        self.name = "duck"

        setupDuck()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupDuck() {
        // Create animation textures
        createAnimationTextures()

        // Start flying animation
        setAnimation(.flying)

        // Setup physics for falling
        setupPhysics()

        print("🦆 Created \(duckType) duck with \(pointValue) points")
    }

    // MARK: - Animation
    private func createAnimationTextures() {
        // Create flying animation frames
        for frame in 0..<2 {
            let texture = createProceduralTexture(for: .flying, frame: frame)
            animationTextures.append(texture)
        }

        // Create falling texture
        let fallTexture = createProceduralTexture(for: .falling, frame: 0)
        animationTextures.append(fallTexture)
    }

    private func createProceduralTexture(for state: DuckState, frame: Int) -> SKTexture {
        let size = CGSize(width: 48, height: 32)

        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let cgContext = context.cgContext

            // Get color scheme
            let colors = UIColor.duckColorSchemes[duckType.colorSchemeIndex]

            switch state {
            case .flying:
                drawFlyingFrame(frame: frame, colors: colors, in: cgContext, size: size)
            case .falling:
                drawFallingFrame(colors: colors, in: cgContext, size: size)
            }
        }

        return SKTexture(image: image)
    }

    private func drawFlyingFrame(frame: Int, colors: [UIColor], in context: CGContext, size: CGSize) {
        // Body (main ellipse)
        context.setFillColor(colors[0].cgColor) // body color
        let bodyRect = CGRect(x: 4, y: 12, width: 32, height: 16)
        context.fillEllipse(in: bodyRect)

        // Head
        context.setFillColor(colors[1].cgColor) // head color
        let headRect = CGRect(x: 36, y: 12, width: 8, height: 8)
        context.fillEllipse(in: headRect)

        // Wing (alternate frames)
        context.setFillColor(colors[2].cgColor) // wing color
        let wingY = frame == 0 ? 8 : 16
        let wingRect = CGRect(x: 12, y: wingY, width: 16, height: 12)
        context.fillEllipse(in: wingRect)

        // Beak
        context.setFillColor(colors[3].cgColor) // beak color
        let beakPoints: [CGPoint] = [
            CGPoint(x: 44, y: 12),
            CGPoint(x: 48, y: 10),
            CGPoint(x: 48, y: 14)
        ]
        context.addLines(between: beakPoints)
        context.closePath()
        context.fillPath()

        // Eye
        context.setFillColor(colors[4].cgColor) // eye color
        let eyeRect = CGRect(x: 38, y: 9, width: 2, height: 2)
        context.fillEllipse(in: eyeRect)

        // Wing detail
        context.setFillColor(colors[2].withAlphaComponent(0.7).cgColor)
        let detailY = frame == 0 ? 10 : 18
        let detailRect = CGRect(x: 14, y: detailY, width: 12, height: 8)
        context.fillEllipse(in: detailRect)
    }

    private func drawFallingFrame(colors: [UIColor], in context: CGContext, size: CGSize) {
        // Body (main ellipse)
        context.setFillColor(colors[0].cgColor)
        let bodyRect = CGRect(x: 4, y: 12, width: 32, height: 16)
        context.fillEllipse(in: bodyRect)

        // Head
        context.setFillColor(colors[1].cgColor)
        let headRect = CGRect(x: 36, y: 12, width: 8, height: 8)
        context.fillEllipse(in: headRect)

        // Wings (spread out for falling)
        context.setFillColor(colors[2].cgColor)
        let wingRect1 = CGRect(x: 8, y: 10, width: 20, height: 8)
        let wingRect2 = CGRect(x: 8, y: 16, width: 20, height: 8)
        context.fillEllipse(in: wingRect1)
        context.fillEllipse(in: wingRect2)

        // Beak
        context.setFillColor(colors[3].cgColor)
        let beakPoints: [CGPoint] = [
            CGPoint(x: 44, y: 12),
            CGPoint(x: 48, y: 10),
            CGPoint(x: 48, y: 14)
        ]
        context.addLines(between: beakPoints)
        context.closePath()
        context.fillPath()

        // X eyes (dead)
        context.setStrokeColor(UIColor.red.cgColor)
        context.setLineWidth(2)
        context.move(to: CGPoint(x: 34, y: 8))
        context.addLine(to: CGPoint(x: 38, y: 12))
        context.move(to: CGPoint(x: 38, y: 8))
        context.addLine(to: CGPoint(x: 34, y: 12))
        context.strokePath()
    }

    private func setAnimation(_ newState: DuckState) {
        guard state != newState else { return }

        state = newState

        // Stop current animation
        removeAction(forKey: "duckAnimation")

        switch newState {
        case .flying:
            let flyTextures = [animationTextures[0], animationTextures[1]]
            let flyAnimation = SKAction.animate(with: flyTextures, timePerFrame: Constants.duckFlapDuration)
            currentAnimation = SKAction.repeatForever(flyAnimation)
            run(currentAnimation!, withKey: "duckAnimation")

        case .falling:
            texture = animationTextures[2] // Falling texture
            // Setup physics for falling
            setupFallingPhysics()
        }
    }

    // MARK: - Physics
    private func setupPhysics() {
        // Basic physics setup for collision detection
        let physicsBody = SKPhysicsBody(circleOfRadius: size.width / 3)
        physicsBody.categoryBitMask = PhysicsCategory.duck
        physicsBody.contactTestBitMask = PhysicsCategory.ground | PhysicsCategory.bullet
        physicsBody.collisionBitMask = PhysicsCategory.ground
        physicsBody.isDynamic = true
        physicsBody.affectedByGravity = false // We'll handle gravity manually for flying
        physicsBody.allowsRotation = true

        self.physicsBody = physicsBody
        physicsBodySetup = true
    }

    private func setupFallingPhysics() {
        guard let physicsBody = self.physicsBody else { return }

        physicsBody.affectedByGravity = true
        physicsBody.velocity = CGVector(dx: 0, dy: -Constants.duckFallSpeed)
        fallSpeed = Constants.duckFallSpeed
    }

    // MARK: - AI Behavior
    func update(deltaTime: TimeInterval) {
        switch state {
        case .flying:
            updateFlying(deltaTime: deltaTime)
        case .falling:
            updateFalling(deltaTime: deltaTime)
        }
    }

    private func updateFlying(deltaTime: TimeInterval) {
        // Horizontal movement
        position.x += speed * CGFloat(deltaTime)

        // Vertical sine wave movement
        let time = position.x * frequency
        position.y = initialY + amplitude * sin(time)

        // Remove if flown off screen
        if position.x > Constants.screenWidth + 100 {
            removeFromParent()
        }
    }

    private func updateFalling(deltaTime: TimeInterval) {
        // Apply gravity
        fallSpeed += Constants.gravity * CGFloat(deltaTime)
        position.y -= fallSpeed * CGFloat(deltaTime)

        // Simple rotation effect
        zRotation = min(.pi / 2, fallSpeed * 0.1)

        // Remove if fallen off screen
        if position.y < -100 {
            removeFromParent()
        }
    }

    // MARK: - Actions
    func shootDown() {
        guard state == .flying else { return }

        print("💥 Duck hit! \(duckType) - \(pointValue) points")
        setAnimation(.falling)

        // Add screen shake effect
        if let scene = self.scene {
            scene.run(SKAction.screenShake(duration: Constants.screenShakeDuration,
                                          amplitude: Constants.screenShakeIntensity))
        }
    }

    func hitGround() {
        guard state == .falling else { return }

        // Stop falling animation
        removeAction(forKey: "duckAnimation")

        // Optional: Add ground hit effect
        print("🌍 Duck hit ground")
    }

    // MARK: - Utility
    var isFlying: Bool { state == .flying }
    var isFalling: Bool { state == .falling }
}

// MARK: - Supporting Types
enum DuckState {
    case flying
    case falling
}

// MARK: - Physics Categories
struct PhysicsCategory {
    static let none: UInt32 = 0
    static let duck: UInt32 = 0b1
    static let ground: UInt32 = 0b10
    static let bullet: UInt32 = 0b100
    static let groundAnimal: UInt32 = 0b1000
}

// MARK: - SKAction Extension for Screen Shake
extension SKAction {
    static func screenShake(duration: TimeInterval, amplitude: CGFloat) -> SKAction {
        let shakeCount = Int(duration / 0.05)
        var actions: [SKAction] = []

        for _ in 0..<shakeCount {
            let x = CGFloat.random(in: -amplitude...amplitude)
            let y = CGFloat.random(in: -amplitude...amplitude)
            let moveAction = SKAction.moveBy(x: x, y: y, duration: 0.05)
            let reverseAction = moveAction.reversed()
            actions.append(moveAction)
            actions.append(reverseAction)
        }

        let resetAction = SKAction.move(to: .zero, duration: 0.05)
        actions.append(resetAction)

        return SKAction.sequence(actions)
    }
}
