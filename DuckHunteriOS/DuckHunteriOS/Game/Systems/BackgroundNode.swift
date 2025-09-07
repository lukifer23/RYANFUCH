//
//  BackgroundNode.swift
//  DuckHunteriOS
//
//  Created by John Carmack
//  Copyright © 2024 Duck Hunter. All rights reserved.
//

import SpriteKit

class BackgroundNode: SKNode {

    // MARK: - Properties
    private var backgroundLayers: [SKSpriteNode] = []
    private var cloudLayers: [SKSpriteNode] = []
    private var parallaxSpeed: [CGFloat] = [0.2, 0.4, 0.6, 0.8] // Different speeds for each layer
    private var cloudSpeed: [CGFloat] = [0.1, 0.15, 0.25]

    private var sceneSize: CGSize
    private var lastUpdateTime: TimeInterval = 0

    // MARK: - Initialization
    init(size: CGSize) {
        self.sceneSize = size
        super.init()

        setupBackground()
        setupClouds()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupBackground() {
        // Create multiple background layers for parallax effect
        for i in 0..<4 {
            let layer = createBackgroundLayer(layerIndex: i)
            backgroundLayers.append(layer)
            addChild(layer)
        }

        print("🏞️ Background system initialized with \(backgroundLayers.count) layers")
    }

    private func setupClouds() {
        // Create cloud layers
        for i in 0..<3 {
            let cloudLayer = createCloudLayer(layerIndex: i)
            cloudLayers.append(cloudLayer)
            addChild(cloudLayer)
        }

        print("☁️ Cloud system initialized with \(cloudLayers.count) layers")
    }

    // MARK: - Background Layer Creation
    private func createBackgroundLayer(layerIndex: Int) -> SKSpriteNode {
        let layerHeight = sceneSize.height
        let layerWidth = sceneSize.width * 2 // Double width for seamless scrolling

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: layerWidth, height: layerHeight))

        let image = renderer.image { context in
            let cgContext = context.cgContext

            // Sky gradient
            let skyGradient = createSkyGradient(for: layerIndex)
            skyGradient.draw(in: CGRect(x: 0, y: 0, width: layerWidth, height: layerHeight))

            // Background elements based on layer
            switch layerIndex {
            case 0: // Backmost layer - distant mountains/hills
                drawDistantHills(in: cgContext, size: CGSize(width: layerWidth, height: layerHeight))
            case 1: // Middle-back layer - closer hills
                drawCloserHills(in: cgContext, size: CGSize(width: layerWidth, height: layerHeight))
            case 2: // Middle-front layer - trees and bushes
                drawTreesAndBushes(in: cgContext, size: CGSize(width: layerWidth, height: layerHeight))
            case 3: // Front layer - ground and grass
                drawGroundAndGrass(in: cgContext, size: CGSize(width: layerWidth, height: layerHeight))
            default:
                break
            }
        }

        let texture = SKTexture(image: image)
        let layer = SKSpriteNode(texture: texture)
        layer.position = CGPoint(x: layerWidth / 4, y: layerHeight / 2) // Center the layer
        layer.zPosition = CGFloat(-10 + layerIndex) // Backmost layers have lowest z-position

        return layer
    }

    private func createSkyGradient(for layerIndex: Int) -> UIImage {
        let size = CGSize(width: 1, height: sceneSize.height)
        let renderer = UIGraphicsImageRenderer(size: size)

        return renderer.image { context in
            let cgContext = context.cgContext

            // Sky colors (gradient from top to bottom)
            let skyColors = [
                UIColor(red: 0.4, green: 0.6, blue: 1.0, alpha: 1.0), // Light blue at top
                UIColor(red: 0.7, green: 0.8, blue: 1.0, alpha: 1.0), // Lighter blue
                UIColor(red: 0.9, green: 0.9, blue: 1.0, alpha: 1.0), // Very light blue at bottom
            ]

            // Create gradient
            let colorSpace = CGColorSpaceCreateDeviceRGB()
            let colors = skyColors.map { $0.cgColor } as CFArray
            let locations: [CGFloat] = [0.0, 0.5, 1.0]

            if let gradient = CGGradient(colorsSpace: colorSpace, colors: colors, locations: locations) {
                cgContext.drawLinearGradient(gradient,
                                           start: CGPoint(x: 0, y: size.height),
                                           end: CGPoint(x: 0, y: 0),
                                           options: [])
            }
        }
    }

    // MARK: - Background Element Drawing
    private func drawDistantHills(in context: CGContext, size: CGSize) {
        context.setFillColor(UIColor(red: 0.3, green: 0.5, blue: 0.3, alpha: 1.0).cgColor)

        // Draw distant hills with gentle curves
        let hillPath = CGMutablePath()
        hillPath.move(to: CGPoint(x: 0, y: 100))

        // Create wavy hill silhouette
        for x in stride(from: 0, to: Int(size.width), by: 50) {
            let y = 100 + sin(CGFloat(x) * 0.01) * 30 + CGFloat.random(in: -10...10)
            hillPath.addLine(to: CGPoint(x: CGFloat(x), y: y))
        }

        hillPath.addLine(to: CGPoint(x: size.width, y: 0))
        hillPath.addLine(to: CGPoint(x: 0, y: 0))
        hillPath.closeSubpath()

        context.addPath(hillPath)
        context.fillPath()
    }

    private func drawCloserHills(in context: CGContext, size: CGSize) {
        context.setFillColor(UIColor(red: 0.2, green: 0.4, blue: 0.2, alpha: 1.0).cgColor)

        // Draw closer hills with more detail
        let hillPath = CGMutablePath()
        hillPath.move(to: CGPoint(x: 0, y: 150))

        for x in stride(from: 0, to: Int(size.width), by: 40) {
            let y = 150 + sin(CGFloat(x) * 0.015) * 40 + CGFloat.random(in: -15...15)
            hillPath.addLine(to: CGPoint(x: CGFloat(x), y: y))
        }

        hillPath.addLine(to: CGPoint(x: size.width, y: 0))
        hillPath.addLine(to: CGPoint(x: 0, y: 0))
        hillPath.closeSubpath()

        context.addPath(hillPath)
        context.fillPath()
    }

    private func drawTreesAndBushes(in context: CGContext, size: CGSize) {
        // Draw scattered trees and bushes
        for _ in 0..<8 {
            let x = CGFloat.random(in: 0...size.width)
            let treeType = Int.random(in: 0...2)

            switch treeType {
            case 0: drawPineTree(at: CGPoint(x: x, y: 200), in: context)
            case 1: drawOakTree(at: CGPoint(x: x, y: 200), in: context)
            case 2: drawBush(at: CGPoint(x: x, y: 180), in: context)
            default: break
            }
        }
    }

    private func drawGroundAndGrass(in context: CGContext, size: CGSize) {
        // Draw ground
        context.setFillColor(UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0).cgColor)
        context.fill(CGRect(x: 0, y: 0, width: size.width, height: 120))

        // Draw grass on top
        context.setFillColor(UIColor(red: 0.2, green: 0.6, blue: 0.2, alpha: 1.0).cgColor)
        context.fill(CGRect(x: 0, y: 110, width: size.width, height: 20))

        // Add grass details
        context.setStrokeColor(UIColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 1.0).cgColor)
        context.setLineWidth(1.0)

        for x in stride(from: 0, to: Int(size.width), by: 10) {
            let grassHeight = CGFloat.random(in: 5...15)
            context.move(to: CGPoint(x: CGFloat(x), y: 120))
            context.addLine(to: CGPoint(x: CGFloat(x) + 2, y: 120 + grassHeight))
        }
        context.strokePath()
    }

    // MARK: - Tree and Bush Drawing
    private func drawPineTree(at position: CGPoint, in context: CGContext) {
        // Tree trunk
        context.setFillColor(UIColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1.0).cgColor)
        context.fill(CGRect(x: position.x - 3, y: position.y, width: 6, height: 20))

        // Pine branches (triangles)
        context.setFillColor(UIColor(red: 0.1, green: 0.3, blue: 0.1, alpha: 1.0).cgColor)

        let trianglePath = CGMutablePath()
        trianglePath.move(to: CGPoint(x: position.x, y: position.y + 20))
        trianglePath.addLine(to: CGPoint(x: position.x - 8, y: position.y + 10))
        trianglePath.addLine(to: CGPoint(x: position.x + 8, y: position.y + 10))
        trianglePath.closeSubpath()
        context.addPath(trianglePath)
        context.fillPath()
    }

    private func drawOakTree(at position: CGPoint, in context: CGContext) {
        // Tree trunk
        context.setFillColor(UIColor(red: 0.4, green: 0.2, blue: 0.1, alpha: 1.0).cgColor)
        context.fill(CGRect(x: position.x - 4, y: position.y, width: 8, height: 25))

        // Tree canopy (circle)
        context.setFillColor(UIColor(red: 0.1, green: 0.4, blue: 0.1, alpha: 1.0).cgColor)
        context.fillEllipse(in: CGRect(x: position.x - 12, y: position.y + 15, width: 24, height: 20))
    }

    private func drawBush(at position: CGPoint, in context: CGContext) {
        // Bush (rounded rectangle)
        context.setFillColor(UIColor(red: 0.1, green: 0.5, blue: 0.1, alpha: 1.0).cgColor)
        let bushPath = CGPath(roundedRect: CGRect(x: position.x - 8, y: position.y, width: 16, height: 12),
                             cornerWidth: 6, cornerHeight: 6, transform: nil)
        context.addPath(bushPath)
        context.fillPath()
    }

    // MARK: - Cloud Layer Creation
    private func createCloudLayer(layerIndex: Int) -> SKSpriteNode {
        let layerWidth = sceneSize.width * 2
        let layerHeight = sceneSize.height * 0.4 // Clouds in upper portion

        let renderer = UIGraphicsImageRenderer(size: CGSize(width: layerWidth, height: layerHeight))

        let image = renderer.image { context in
            let cgContext = context.cgContext

            // Draw clouds
            for _ in 0..<5 {
                let x = CGFloat.random(in: 0...layerWidth)
                let y = CGFloat.random(in: layerHeight * 0.2...layerHeight * 0.8)
                drawCloud(at: CGPoint(x: x, y: y), in: cgContext)
            }
        }

        let texture = SKTexture(image: image)
        let layer = SKSpriteNode(texture: texture)
        layer.position = CGPoint(x: layerWidth / 4, y: sceneSize.height * 0.7)
        layer.zPosition = CGFloat(-5 + layerIndex)

        return layer
    }

    private func drawCloud(at position: CGPoint, in context: CGContext) {
        context.setFillColor(UIColor.white.withAlphaComponent(0.8).cgColor)

        // Draw cloud as combination of circles
        let cloudParts = [
            (center: CGPoint(x: position.x, y: position.y), radius: 15),
            (center: CGPoint(x: position.x - 12, y: position.y), radius: 12),
            (center: CGPoint(x: position.x + 12, y: position.y), radius: 12),
            (center: CGPoint(x: position.x - 6, y: position.y - 8), radius: 10),
            (center: CGPoint(x: position.x + 6, y: position.y - 8), radius: 10)
        ]

        for part in cloudParts {
            context.fillEllipse(in: CGRect(x: part.center.x - part.radius,
                                         y: part.center.y - part.radius,
                                         width: part.radius * 2,
                                         height: part.radius * 2))
        }
    }

    // MARK: - Update Loop
    func update(deltaTime: TimeInterval) {
        // Update background layers (parallax scrolling)
        for (index, layer) in backgroundLayers.enumerated() {
            let speed = parallaxSpeed[index]
            layer.position.x -= speed * CGFloat(deltaTime) * 50 // Adjust speed multiplier as needed

            // Reset position for seamless scrolling
            if layer.position.x <= -layer.size.width / 2 {
                layer.position.x = layer.size.width / 2
            }
        }

        // Update cloud layers
        for (index, cloudLayer) in cloudLayers.enumerated() {
            let speed = cloudSpeed[index]
            cloudLayer.position.x -= speed * CGFloat(deltaTime) * 30

            // Reset position for seamless scrolling
            if cloudLayer.position.x <= -cloudLayer.size.width / 2 {
                cloudLayer.position.x = cloudLayer.size.width / 2
            }
        }
    }

    // MARK: - Configuration
    func setParallaxSpeed(_ speeds: [CGFloat]) {
        parallaxSpeed = speeds
    }

    func setCloudSpeed(_ speeds: [CGFloat]) {
        cloudSpeed = speeds
    }

    func setTimeOfDay(_ hour: Int) {
        // Future: Adjust colors based on time of day
        // This would modify the sky gradient and lighting
    }
}
