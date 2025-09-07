//
//  MenuSystem.swift
//  DuckHunteriOS
//
//  Created by John Carmack
//  Copyright © 2024 Duck Hunter. All rights reserved.
//

import SpriteKit

class MenuSystem {

    // MARK: - Properties
    private weak var scene: SKScene?
    private var menuState: MenuState = .mainMenu
    private var selectedGameMode: Constants.GameMode?

    // Menu nodes
    private var mainMenuNode: SKNode?
    private var gameOverNode: SKNode?
    private var pauseMenuNode: SKNode?

    // Game state
    private var isPlaying = false
    private var finalScore = 0

    // MARK: - Initialization
    init(scene: SKScene) {
        self.scene = scene
        setupMenus()
        print("📋 Menu System initialized")
    }

    private func setupMenus() {
        setupMainMenu()
        setupGameOverMenu()
        setupPauseMenu()
    }

    // MARK: - Main Menu
    private func setupMainMenu() {
        mainMenuNode = SKNode()
        mainMenuNode?.name = "MainMenu"
        mainMenuNode?.zPosition = 200

        // Background overlay
        let background = SKShapeNode(rectOf: CGSize(width: Constants.screenWidth, height: Constants.screenHeight))
        background.fillColor = UIColor.black.withAlphaComponent(0.8)
        background.strokeColor = .clear
        mainMenuNode?.addChild(background)

        // Title
        let titleLabel = SKLabelNode(fontNamed: Constants.uiFontName)
        titleLabel.text = "DUCK HUNTER"
        titleLabel.fontSize = 48
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: Constants.screenWidth / 2, y: Constants.screenHeight * 0.8)
        titleLabel.horizontalAlignmentMode = .center
        mainMenuNode?.addChild(titleLabel)

        // Subtitle
        let subtitleLabel = SKLabelNode(fontNamed: Constants.uiFontName)
        subtitleLabel.text = "Touch to Hunt!"
        subtitleLabel.fontSize = 24
        subtitleLabel.fontColor = .gray
        subtitleLabel.position = CGPoint(x: Constants.screenWidth / 2, y: Constants.screenHeight * 0.75)
        subtitleLabel.horizontalAlignmentMode = .center
        mainMenuNode?.addChild(subtitleLabel)

        // Game mode buttons
        let gameModes: [(String, Constants.GameMode, String)] = [
            ("Easy Mode", .easy, "10 lives, 15 ammo"),
            ("Normal Mode", .normal, "3 lives, 8 ammo"),
            ("Hard Mode", .hard, "1 life, 5 ammo"),
            ("God Mode", .god, "∞ lives, ∞ ammo (5 min)")
        ]

        for (index, modeData) in gameModes.enumerated() {
            let button = createGameModeButton(
                title: modeData.0,
                mode: modeData.1,
                description: modeData.2,
                position: CGPoint(x: Constants.screenWidth / 2, y: Constants.screenHeight * 0.6 - CGFloat(index) * 80)
            )
            mainMenuNode?.addChild(button)
        }

        // Instructions
        let instructionsLabel = SKLabelNode(fontNamed: Constants.uiFontName)
        instructionsLabel.text = "Tap a mode to start hunting!"
        instructionsLabel.fontSize = 18
        instructionsLabel.fontColor = .lightGray
        instructionsLabel.position = CGPoint(x: Constants.screenWidth / 2, y: Constants.screenHeight * 0.15)
        instructionsLabel.horizontalAlignmentMode = .center
        mainMenuNode?.addChild(instructionsLabel)
    }

    private func createGameModeButton(title: String, mode: Constants.GameMode, description: String, position: CGPoint) -> SKNode {
        let buttonNode = SKNode()
        buttonNode.name = mode.displayName.lowercased().replacingOccurrences(of: " ", with: "_")
        buttonNode.position = position

        // Button background
        let buttonBg = SKShapeNode(rectOf: CGSize(width: 300, height: 60), cornerRadius: 10)
        buttonBg.fillColor = UIColor.white.withAlphaComponent(0.1)
        buttonBg.strokeColor = UIColor.white.withAlphaComponent(0.3)
        buttonBg.lineWidth = 2
        buttonNode.addChild(buttonBg)

        // Title
        let titleLabel = SKLabelNode(fontNamed: Constants.uiFontName)
        titleLabel.text = title
        titleLabel.fontSize = 24
        titleLabel.fontColor = .white
        titleLabel.position = CGPoint(x: 0, y: 10)
        titleLabel.horizontalAlignmentMode = .center
        buttonNode.addChild(titleLabel)

        // Description
        let descLabel = SKLabelNode(fontNamed: Constants.uiFontName)
        descLabel.text = description
        descLabel.fontSize = 14
        descLabel.fontColor = .gray
        descLabel.position = CGPoint(x: 0, y: -15)
        descLabel.horizontalAlignmentMode = .center
        buttonNode.addChild(descLabel)

        return buttonNode
    }

    // MARK: - Game Over Menu
    private func setupGameOverMenu() {
        gameOverNode = SKNode()
        gameOverNode?.name = "GameOverMenu"
        gameOverNode?.zPosition = 200

        // Background overlay
        let background = SKShapeNode(rectOf: CGSize(width: Constants.screenWidth, height: Constants.screenHeight))
        background.fillColor = UIColor.black.withAlphaComponent(0.9)
        background.strokeColor = .clear
        gameOverNode?.addChild(background)

        // Game Over title
        let gameOverLabel = SKLabelNode(fontNamed: Constants.uiFontName)
        gameOverLabel.text = "GAME OVER"
        gameOverLabel.fontSize = 48
        gameOverLabel.fontColor = .red
        gameOverLabel.position = CGPoint(x: Constants.screenWidth / 2, y: Constants.screenHeight * 0.7)
        gameOverLabel.horizontalAlignmentMode = .center
        gameOverNode?.addChild(gameOverLabel)

        // Final score
        let scoreLabel = SKLabelNode(fontNamed: Constants.uiFontName)
        scoreLabel.text = "Final Score: 0"
        scoreLabel.fontSize = 32
        scoreLabel.fontColor = .white
        scoreLabel.position = CGPoint(x: Constants.screenWidth / 2, y: Constants.screenHeight * 0.6)
        scoreLabel.horizontalAlignmentMode = .center
        scoreLabel.name = "finalScore"
        gameOverNode?.addChild(scoreLabel)

        // Play again button
        let playAgainButton = createMenuButton(
            text: "Play Again",
            position: CGPoint(x: Constants.screenWidth / 2, y: Constants.screenHeight * 0.4)
        )
        playAgainButton.name = "play_again"
        gameOverNode?.addChild(playAgainButton)

        // Main menu button
        let mainMenuButton = createMenuButton(
            text: "Main Menu",
            position: CGPoint(x: Constants.screenWidth / 2, y: Constants.screenHeight * 0.3)
        )
        mainMenuButton.name = "main_menu"
        gameOverNode?.addChild(mainMenuButton)
    }

    // MARK: - Pause Menu
    private func setupPauseMenu() {
        pauseMenuNode = SKNode()
        pauseMenuNode?.name = "PauseMenu"
        pauseMenuNode?.zPosition = 200

        // Background overlay
        let background = SKShapeNode(rectOf: CGSize(width: Constants.screenWidth, height: Constants.screenHeight))
        background.fillColor = UIColor.black.withAlphaComponent(0.7)
        background.strokeColor = .clear
        pauseMenuNode?.addChild(background)

        // Paused title
        let pausedLabel = SKLabelNode(fontNamed: Constants.uiFontName)
        pausedLabel.text = "PAUSED"
        pausedLabel.fontSize = 48
        pausedLabel.fontColor = .yellow
        pausedLabel.position = CGPoint(x: Constants.screenWidth / 2, y: Constants.screenHeight * 0.6)
        pausedLabel.horizontalAlignmentMode = .center
        pauseMenuNode?.addChild(pausedLabel)

        // Resume button
        let resumeButton = createMenuButton(
            text: "Resume",
            position: CGPoint(x: Constants.screenWidth / 2, y: Constants.screenHeight * 0.45)
        )
        resumeButton.name = "resume"
        pauseMenuNode?.addChild(resumeButton)

        // Restart button
        let restartButton = createMenuButton(
            text: "Restart",
            position: CGPoint(x: Constants.screenWidth / 2, y: Constants.screenHeight * 0.35)
        )
        restartButton.name = "restart"
        pauseMenuNode?.addChild(restartButton)

        // Main menu button
        let mainMenuButton = createMenuButton(
            text: "Main Menu",
            position: CGPoint(x: Constants.screenWidth / 2, y: Constants.screenHeight * 0.25)
        )
        mainMenuButton.name = "main_menu"
        pauseMenuNode?.addChild(mainMenuButton)

        // Instructions
        let instructions = [
            "Tap Resume to continue",
            "Tap Restart for new game",
            "Tap Main Menu to quit"
        ]

        for (index, text) in instructions.enumerated() {
            let instructionLabel = SKLabelNode(fontNamed: Constants.uiFontName)
            instructionLabel.text = text
            instructionLabel.fontSize = 16
            instructionLabel.fontColor = .lightGray
            instructionLabel.position = CGPoint(x: Constants.screenWidth / 2, y: Constants.screenHeight * 0.15 - CGFloat(index) * 20)
            instructionLabel.horizontalAlignmentMode = .center
            pauseMenuNode?.addChild(instructionLabel)
        }
    }

    private func createMenuButton(text: String, position: CGPoint) -> SKLabelNode {
        let button = SKLabelNode(fontNamed: Constants.uiFontName)
        button.text = text
        button.fontSize = 28
        button.fontColor = .white
        button.position = position
        button.horizontalAlignmentMode = .center
        button.name = text.lowercased().replacingOccurrences(of: " ", with: "_")
        return button
    }

    // MARK: - Menu State Management
    func showMainMenu() {
        guard let scene = scene else { return }

        hideAllMenus()

        if let mainMenuNode = mainMenuNode {
            scene.addChild(mainMenuNode)
            menuState = .mainMenu
            print("📋 Main menu displayed")
        }
    }

    func showGameOver(score: Int) {
        guard let scene = scene else { return }

        hideAllMenus()
        finalScore = score

        if let gameOverNode = gameOverNode {
            // Update final score
            if let scoreLabel = gameOverNode.childNode(withName: "finalScore") as? SKLabelNode {
                scoreLabel.text = "Final Score: \(score)"
            }

            scene.addChild(gameOverNode)
            menuState = .gameOver
            print("💀 Game over menu displayed with score: \(score)")
        }
    }

    func showPauseMenu() {
        guard let scene = scene else { return }

        hideAllMenus()

        if let pauseMenuNode = pauseMenuNode {
            scene.addChild(pauseMenuNode)
            menuState = .paused
            print("⏸️ Pause menu displayed")
        }
    }

    private func hideAllMenus() {
        mainMenuNode?.removeFromParent()
        gameOverNode?.removeFromParent()
        pauseMenuNode?.removeFromParent()
    }

    // MARK: - Touch Handling
    func handleTouch(at location: CGPoint) -> MenuAction? {
        switch menuState {
        case .mainMenu:
            return handleMainMenuTouch(at: location)
        case .gameOver:
            return handleGameOverTouch(at: location)
        case .paused:
            return handlePauseMenuTouch(at: location)
        }
    }

    private func handleMainMenuTouch(at location: CGPoint) -> MenuAction? {
        guard let mainMenuNode = mainMenuNode else { return nil }

        // Check game mode buttons
        let gameModes: [Constants.GameMode] = [.easy, .normal, .hard, .god]

        for mode in gameModes {
            let buttonName = mode.displayName.lowercased().replacingOccurrences(of: " ", with: "_")
            if let button = mainMenuNode.childNode(withName: buttonName) {
                if button.contains(location) {
                    selectedGameMode = mode
                    return .startGame(mode: mode)
                }
            }
        }

        return nil
    }

    private func handleGameOverTouch(at location: CGPoint) -> MenuAction? {
        guard let gameOverNode = gameOverNode else { return nil }

        // Check play again button
        if let playAgainButton = gameOverNode.childNode(withName: "play_again") {
            if playAgainButton.contains(location) {
                return .startGame(mode: selectedGameMode ?? .normal)
            }
        }

        // Check main menu button
        if let mainMenuButton = gameOverNode.childNode(withName: "main_menu") {
            if mainMenuButton.contains(location) {
                return .showMainMenu
            }
        }

        return nil
    }

    private func handlePauseMenuTouch(at location: CGPoint) -> MenuAction? {
        guard let pauseMenuNode = pauseMenuNode else { return nil }

        // Check resume button
        if let resumeButton = pauseMenuNode.childNode(withName: "resume") {
            if resumeButton.contains(location) {
                return .resumeGame
            }
        }

        // Check restart button
        if let restartButton = pauseMenuNode.childNode(withName: "restart") {
            if restartButton.contains(location) {
                return .startGame(mode: selectedGameMode ?? .normal)
            }
        }

        // Check main menu button
        if let mainMenuButton = pauseMenuNode.childNode(withName: "main_menu") {
            if mainMenuButton.contains(location) {
                return .showMainMenu
            }
        }

        return nil
    }

    // MARK: - Game State
    func setPlaying(_ playing: Bool) {
        isPlaying = playing
        if playing {
            hideAllMenus()
        }
    }

    func isPlaying() -> Bool {
        return isPlaying
    }

    // MARK: - Update Loop
    func update(deltaTime: TimeInterval) {
        // Update any animated menu elements here
        // For now, mainly for future animations
    }
}

// MARK: - Supporting Types
enum MenuState {
    case mainMenu
    case gameOver
    case paused
}

enum MenuAction {
    case startGame(mode: Constants.GameMode)
    case resumeGame
    case showMainMenu
}
