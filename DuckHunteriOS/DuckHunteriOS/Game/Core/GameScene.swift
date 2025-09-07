//
//  GameScene.swift
//  DuckHunteriOS
//
//  Created by John Carmack
//  Copyright © 2024 Duck Hunter. All rights reserved.
//

import SpriteKit
import AVFoundation

class GameScene: SKScene {

    // MARK: - Properties
    private var gameEngine: GameEngine!
    private var lastUpdateTime: TimeInterval = 0
    private var crosshair: CrosshairNode!
    private var background: BackgroundNode!

    // MARK: - Initialization
    override func didMove(to view: SKView) {
        super.didMove(to: view)

        // Setup the game scene
        setupScene()
        setupGameSystems()

        print("🎯 Duck Hunter iOS - Game Scene Loaded")
    }

    private func setupScene() {
        // Configure scene properties
        self.backgroundColor = .black
        self.physicsWorld.gravity = CGVector(dx: 0, dy: -980) // Gravity for falling ducks
        self.physicsWorld.contactDelegate = self

        // Enable user interaction
        self.isUserInteractionEnabled = true
    }

    private func setupGameSystems() {
        // Initialize game engine
        gameEngine = GameEngine(scene: self)

        // Create background
        background = BackgroundNode(size: self.size)
        background.position = CGPoint(x: self.size.width / 2, y: self.size.height / 2)
        addChild(background)

        // Create crosshair
        crosshair = CrosshairNode()
        addChild(crosshair)

        print("🎮 Game systems initialized successfully")
    }

    // MARK: - Touch Controls
    private var currentTouch: UITouch?

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        if currentTouch == nil, let touch = touches.first {
            currentTouch = touch
            let location = touch.location(in: self.view)
            let sceneLocation = convertPoint(fromView: location)
            crosshair.updatePosition(to: sceneLocation)
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        if let touch = touches.first, touch == currentTouch {
            let location = touch.location(in: self.view)
            let sceneLocation = convertPoint(fromView: location)
            crosshair.updatePosition(to: sceneLocation)
        }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)

        if let touch = touches.first, touch == currentTouch {
            let location = touch.location(in: self.view)
            let sceneLocation = convertPoint(fromView: location)

            // Handle shooting
            gameEngine.handleShoot(at: sceneLocation)

            currentTouch = nil
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)

        if let touch = touches.first, touch == currentTouch {
            currentTouch = nil
        }
    }

    // MARK: - Game Loop
    override func update(_ currentTime: TimeInterval) {
        // Calculate delta time
        let deltaTime = lastUpdateTime == 0 ? 0 : currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        // Update game systems
        gameEngine.update(deltaTime: deltaTime)

        // Update background
        background.update(deltaTime: deltaTime)

        // Update crosshair
        crosshair.update(deltaTime: deltaTime)
    }

    // MARK: - Public Interface
    func startNewGame(mode: Constants.GameMode) {
        gameEngine.startNewGame(mode: mode)
    }

    func pauseGame() {
        gameEngine.pauseGame()
    }

    func resumeGame() {
        // Handled by game engine
    }

    func quitToMenu() {
        gameEngine.quitToMenu()
    }

    // MARK: - Physics Contact
    func didBegin(_ contact: SKPhysicsContact) {
        gameEngine.handlePhysicsContact(contact)
    }
}

// MARK: - SKPhysicsContactDelegate
extension GameScene: SKPhysicsContactDelegate {
    // Physics contact handling is delegated to game engine
}
