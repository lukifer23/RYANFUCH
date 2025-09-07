//
//  CrosshairNode.swift
//  DuckHunteriOS
//
//  Created by John Carmack
//  Copyright © 2024 Duck Hunter. All rights reserved.
//

import SpriteKit

class CrosshairNode: SKNode {

    // MARK: - Properties
    private var crosshairSprite: SKSpriteNode!
    private var hitRadiusIndicator: SKShapeNode!
    private var flashTimer: TimeInterval = 0
    private var showHitRadius = false

    private var currentPosition: CGPoint = .zero
    private var targetPosition: CGPoint = .zero

    // MARK: - Initialization
    override init() {
        super.init()
        setupCrosshair()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupCrosshair() {
        // Create main crosshair sprite
        let crosshairSize = Constants.crosshairSize
        let crosshairTexture = createCrosshairTexture(size: crosshairSize)
        crosshairSprite = SKSpriteNode(texture: crosshairTexture)
        addChild(crosshairSprite)

        // Create hit radius indicator
        hitRadiusIndicator = createHitRadiusIndicator()
        addChild(hitRadiusIndicator)

        // Initially hide hit radius
        hitRadiusIndicator.isHidden = true

        print("🎯 Crosshair created with \(Constants.crosshairHitRadius)pt hit radius")
    }

    private func createCrosshairTexture(size: CGSize) -> SKTexture {
        let renderer = UIGraphicsImageRenderer(size: size)

        let image = renderer.image { context in
            let cgContext = context.cgContext

            // Set drawing properties
            cgContext.setStrokeColor(UIColor.white.cgColor)
            cgContext.setLineWidth(2.0)
            cgContext.setLineCap(.round)

            let centerX = size.width / 2
            let centerY = size.height / 2

            // Draw outer circle (hit radius indicator)
            cgContext.setStrokeColor(UIColor.white.withAlphaComponent(0.5).cgColor)
            cgContext.setLineWidth(1.0)
            cgContext.strokeEllipse(in: CGRect(x: centerX - Constants.crosshairHitRadius,
                                             y: centerY - Constants.crosshairHitRadius,
                                             width: Constants.crosshairHitRadius * 2,
                                             height: Constants.crosshairHitRadius * 2))

            // Draw inner circle
            cgContext.setStrokeColor(UIColor.white.cgColor)
            cgContext.setLineWidth(1.0)
            cgContext.strokeEllipse(in: CGRect(x: centerX - 15, y: centerY - 15, width: 30, height: 30))

            // Draw cross lines
            cgContext.setLineWidth(2.0)

            // Vertical line
            cgContext.move(to: CGPoint(x: centerX, y: centerY - 12))
            cgContext.addLine(to: CGPoint(x: centerX, y: centerY - 25))
            cgContext.move(to: CGPoint(x: centerX, y: centerY + 12))
            cgContext.addLine(to: CGPoint(x: centerX, y: centerY + 25))

            // Horizontal line
            cgContext.move(to: CGPoint(x: centerX - 12, y: centerY))
            cgContext.addLine(to: CGPoint(x: centerX - 25, y: centerY))
            cgContext.move(to: CGPoint(x: centerX + 12, y: centerY))
            cgContext.addLine(to: CGPoint(x: centerX, y: centerY + 25))

            cgContext.strokePath()

            // Draw center dot
            cgContext.setFillColor(UIColor.white.cgColor)
            cgContext.fillEllipse(in: CGRect(x: centerX - 3, y: centerY - 3, width: 6, height: 6))
        }

        return SKTexture(image: image)
    }

    private func createHitRadiusIndicator() -> SKShapeNode {
        let radius = Constants.crosshairHitRadius
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(x: -radius, y: -radius, width: radius * 2, height: radius * 2))

        let indicator = SKShapeNode(path: path)
        indicator.strokeColor = UIColor.white.withAlphaComponent(0.3)
        indicator.lineWidth = 1.5
        indicator.fillColor = .clear
        indicator.name = "hitRadius"

        return indicator
    }

    // MARK: - Position Updates
    func updatePosition(to position: CGPoint) {
        targetPosition = position

        // Smooth movement (optional - for more responsive feel, we could remove this)
        let moveAction = SKAction.move(to: position, duration: 0.05)
        moveAction.timingMode = .easeOut
        run(moveAction)

        currentPosition = position
    }

    // MARK: - Visual Feedback
    func showHitFeedback() {
        flashTimer = Constants.hitFeedbackDuration

        // Flash effect
        let flashAction = SKAction.sequence([
            SKAction.colorize(with: .red, colorBlendFactor: 0.5, duration: 0.1),
            SKAction.colorize(withColorBlendFactor: 0.0, duration: 0.1)
        ])
        crosshairSprite.run(flashAction)

        // Scale effect
        let scaleAction = SKAction.sequence([
            SKAction.scale(to: 1.2, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ])
        crosshairSprite.run(scaleAction)
    }

    func setHitRadiusVisible(_ visible: Bool) {
        showHitRadius = visible
        hitRadiusIndicator.isHidden = !visible

        if visible {
            // Pulse animation for hit radius
            let pulseAction = SKAction.sequence([
                SKAction.fadeAlpha(to: 0.6, duration: 0.3),
                SKAction.fadeAlpha(to: 0.2, duration: 0.3)
            ])
            hitRadiusIndicator.run(SKAction.repeatForever(pulseAction))
        } else {
            hitRadiusIndicator.removeAllActions()
            hitRadiusIndicator.alpha = 0.3
        }
    }

    // MARK: - Update Loop
    func update(deltaTime: TimeInterval) {
        // Update flash timer
        if flashTimer > 0 {
            flashTimer -= deltaTime
        }

        // Auto-hide hit radius after a delay
        if showHitRadius && flashTimer <= 0 {
            // Keep visible for a moment after shooting
        }
    }

    // MARK: - Touch Following
    func followTouch(at location: CGPoint, sensitivity: Float = 1.0) {
        let sensitivityMultiplier = CGFloat(sensitivity)
        let adjustedLocation = CGPoint(
            x: location.x * sensitivityMultiplier,
            y: location.y * sensitivityMultiplier
        )
        updatePosition(to: adjustedLocation)
    }

    // MARK: - Aim Assist
    func applyAimAssist(target: CGPoint) {
        // Snap to target if within aim assist range
        let distance = currentPosition.distance(to: target)
        if distance <= Constants.crosshairHitRadius * 0.8 { // Slightly smaller than hit radius
            updatePosition(to: target)
        }
    }

    // MARK: - Configuration
    func setSize(_ size: CGSize) {
        crosshairSprite.size = size
        // Recreate texture with new size
        crosshairSprite.texture = createCrosshairTexture(size: size)
    }

    func setColor(_ color: UIColor) {
        crosshairSprite.color = color
        crosshairSprite.colorBlendFactor = 1.0
    }

    // MARK: - Utility
    var position: CGPoint {
        get { currentPosition }
        set { updatePosition(to: newValue) }
    }

    var hitRadius: CGFloat {
        return Constants.crosshairHitRadius
    }

    var isFlashing: Bool {
        return flashTimer > 0
    }
}

// MARK: - Crosshair Style Presets
extension CrosshairNode {
    static func createClassicStyle() -> CrosshairNode {
        let crosshair = CrosshairNode()
        crosshair.setColor(.white)
        return crosshair
    }

    static func createModernStyle() -> CrosshairNode {
        let crosshair = CrosshairNode()
        crosshair.setColor(.cyan)
        crosshair.setSize(CGSize(width: 50, height: 50))
        return crosshair
    }

    static func createPrecisionStyle() -> CrosshairNode {
        let crosshair = CrosshairNode()
        crosshair.setColor(.red)
        crosshair.setSize(CGSize(width: 40, height: 40))
        return crosshair
    }
}
