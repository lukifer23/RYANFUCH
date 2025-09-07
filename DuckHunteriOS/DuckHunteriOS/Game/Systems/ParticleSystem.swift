//
//  ParticleSystem.swift
//  DuckHunteriOS
//
//  Created by John Carmack
//  Copyright © 2024 Duck Hunter. All rights reserved.
//

import SpriteKit

class Particle: SKSpriteNode {
    private var lifetime: TimeInterval
    private var age: TimeInterval = 0
    private var velocity: CGVector

    init(position: CGPoint, color: UIColor, size: CGSize, velocity: CGVector, lifetime: TimeInterval) {
        self.lifetime = lifetime
        self.velocity = velocity

        super.init(texture: nil, color: color, size: size)

        self.position = position

        // Create circular particle
        let path = CGMutablePath()
        path.addEllipse(in: CGRect(x: -size.width/2, y: -size.height/2, width: size.width, height: size.height))
        let shape = SKShapeNode(path: path)
        shape.fillColor = color
        shape.strokeColor = .clear
        addChild(shape)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func update(deltaTime: TimeInterval) {
        // Update position
        position.x += velocity.dx * CGFloat(deltaTime)
        position.y += velocity.dy * CGFloat(deltaTime)

        // Update age
        age += deltaTime

        // Fade out as we age
        let alpha = 1.0 - (age / lifetime)
        self.alpha = max(0, alpha)

        // Remove when lifetime is exceeded
        if age >= lifetime {
            removeFromParent()
        }
    }

    var isAlive: Bool {
        return age < lifetime
    }
}

class ParticleSystem: SKNode {

    private var particles: [Particle] = []
    private var maxParticles: Int = Constants.maxConcurrentParticles

    override init() {
        super.init()
        print("✨ ParticleSystem initialized")
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Particle Emission
    func emitFeathers(at position: CGPoint) {
        let featherColor = UIColor.white
        let particleCount = 20

        for _ in 0..<particleCount {
            let velocity = CGVector(
                dx: CGFloat.random(in: -150...150),
                dy: CGFloat.random(in: -200...0)
            )
            let size = CGSize(width: CGFloat.random(in: 2...5), height: CGFloat.random(in: 2...5))
            let lifetime = TimeInterval.random(in: 0.5...1.5)

            let particle = Particle(
                position: position,
                color: featherColor,
                size: size,
                velocity: velocity,
                lifetime: lifetime
            )

            addChild(particle)
            particles.append(particle)
        }

        print("🪶 Emitted \(particleCount) feather particles")
    }

    func emitHitSparks(at position: CGPoint) {
        let sparkColor = UIColor.yellow
        let particleCount = 10

        for _ in 0..<particleCount {
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 50...150)
            let velocity = CGVector(
                dx: cos(angle) * speed,
                dy: sin(angle) * speed
            )
            let size = CGSize(width: 2, height: 2)
            let lifetime = TimeInterval.random(in: 0.3...0.8)

            let particle = Particle(
                position: position,
                color: sparkColor,
                size: size,
                velocity: velocity,
                lifetime: lifetime
            )

            addChild(particle)
            particles.append(particle)
        }
    }

    func emitMuzzleFlash(at position: CGPoint) {
        let flashColor = UIColor.orange
        let particleCount = 5

        for _ in 0..<particleCount {
            let velocity = CGVector(
                dx: CGFloat.random(in: -50...50),
                dy: CGFloat.random(in: -50...50)
            )
            let size = CGSize(width: CGFloat.random(in: 3...8), height: CGFloat.random(in: 3...8))
            let lifetime = TimeInterval.random(in: 0.1...0.3)

            let particle = Particle(
                position: position,
                color: flashColor,
                size: size,
                velocity: velocity,
                lifetime: lifetime
            )

            addChild(particle)
            particles.append(particle)
        }
    }

    // MARK: - Update Loop
    func update(deltaTime: TimeInterval) {
        // Update all particles
        particles.forEach { $0.update(deltaTime) }

        // Remove dead particles
        particles.removeAll { !$0.isAlive }

        // Limit particle count for performance
        if particles.count > maxParticles {
            let excessCount = particles.count - maxParticles
            for _ in 0..<excessCount {
                if let particle = particles.first {
                    particle.removeFromParent()
                    particles.removeFirst()
                }
            }
        }
    }

    // MARK: - Management
    func clearAllParticles() {
        particles.forEach { $0.removeFromParent() }
        particles.removeAll()
        print("🧹 Cleared all particles")
    }

    var particleCount: Int {
        return particles.count
    }

    func setMaxParticles(_ max: Int) {
        maxParticles = max
    }
}

// MARK: - Convenience Extensions
extension ParticleSystem {
    func emit(at position: CGPoint, type: ParticleType, count: Int = 10) {
        switch type {
        case .feathers:
            emitFeathers(at: position)
        case .sparks:
            emitHitSparks(at: position)
        case .muzzleFlash:
            emitMuzzleFlash(at: position)
        }
    }
}

enum ParticleType {
    case feathers
    case sparks
    case muzzleFlash
}
