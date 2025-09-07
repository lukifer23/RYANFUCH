//
//  UISystem.swift
//  DuckHunteriOS
//
//  Created by John Carmack
//  Copyright © 2024 Duck Hunter. All rights reserved.
//

import SpriteKit
import SwiftUI

class UISystem {

    // MARK: - Properties
    private weak var scene: SKScene?
    private var hudNode: SKNode?
    private var menuNode: SKNode?

    // HUD Elements
    private var scoreLabel: SKLabelNode?
    private var livesLabel: SKLabelNode?
    private var ammoLabel: SKLabelNode?
    private var fpsLabel: SKLabelNode?
    private var timerLabel: SKLabelNode?

    // Menu Elements
    private var menuBackground: SKShapeNode?
    private var menuTitle: SKLabelNode?
    private var menuButtons: [SKLabelNode] = []

    // State
    private var isHUDVisible = false
    private var isMenuVisible = false
    private var currentGameMode: Constants.GameMode = .normal
    private var godModeTimeLimit: TimeInterval = Constants.godModeTimeLimit

    // MARK: - Initialization
    init(scene: SKScene) {
        self.scene = scene
        setupHUD()
        setupMenu()
        print("🖥️ UI System initialized")
    }

    // MARK: - HUD Setup
    private func setupHUD() {
        hudNode = SKNode()
        hudNode?.name = "HUD"
        hudNode?.zPosition = 100

        // Score display (top-left)
        scoreLabel = createHUDLabel(text: "Score: 0", position: CGPoint(x: 30, y: Constants.screenHeight - 50))
        hudNode?.addChild(scoreLabel!)

        // Lives display (top-right)
        livesLabel = createHUDLabel(text: "Lives: 3", position: CGPoint(x: Constants.screenWidth - 30, y: Constants.screenHeight - 50))
        livesLabel?.horizontalAlignmentMode = .right
        hudNode?.addChild(livesLabel!)

        // Ammo display (bottom-left)
        ammoLabel = createHUDLabel(text: "Ammo: 8/8", position: CGPoint(x: 30, y: 30))
        hudNode?.addChild(ammoLabel!)

        // FPS counter (bottom-right) - optional
        #if DEBUG
        fpsLabel = createHUDLabel(text: "FPS: 60", position: CGPoint(x: Constants.screenWidth - 30, y: 30))
        fpsLabel?.horizontalAlignmentMode = .right
        fpsLabel?.fontSize = 16
        fpsLabel?.fontColor = .yellow
        hudNode?.addChild(fpsLabel!)
        #endif

        // Timer for God mode (top-center)
        timerLabel = createHUDLabel(text: "", position: CGPoint(x: Constants.screenWidth / 2, y: Constants.screenHeight - 50))
        timerLabel?.horizontalAlignmentMode = .center
        hudNode?.addChild(timerLabel!)
    }

    private func createHUDLabel(text: String, position: CGPoint) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: Constants.uiFontName)
        label.text = text
        label.fontSize = Constants.uiFontSize
        label.fontColor = Constants.uiTextColor
        label.position = position
        label.verticalAlignmentMode = .top
        return label
    }

    // MARK: - Menu Setup
    private func setupMenu() {
        menuNode = SKNode()
        menuNode?.name = "Menu"
        menuNode?.zPosition = 200

        // Semi-transparent background
        menuBackground = SKShapeNode(rectOf: CGSize(width: Constants.screenWidth, height: Constants.screenHeight))
        menuBackground?.fillColor = UIColor.black.withAlphaComponent(0.7)
        menuBackground?.strokeColor = .clear
        menuNode?.addChild(menuBackground!)

        // Title
        menuTitle = SKLabelNode(fontNamed: Constants.uiFontName)
        menuTitle?.text = "DUCK HUNTER"
        menuTitle?.fontSize = 48
        menuTitle?.fontColor = .white
        menuTitle?.position = CGPoint(x: Constants.screenWidth / 2, y: Constants.screenHeight * 0.75)
        menuTitle?.horizontalAlignmentMode = .center
        menuNode?.addChild(menuTitle!)

        // Menu buttons
        let buttonTexts = ["Easy Mode", "Normal Mode", "Hard Mode", "God Mode"]
        let buttonYPositions = [400, 320, 240, 160]

        for (index, text) in buttonTexts.enumerated() {
            let button = createMenuButton(text: text, position: CGPoint(x: Constants.screenWidth / 2, y: buttonYPositions[index]))
            menuButtons.append(button)
            menuNode?.addChild(button)
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

    // MARK: - HUD Updates
    func updateHUD(score: Int, lives: Int, ammo: Int, maxAmmo: Int, gameMode: Constants.GameMode, elapsedTime: TimeInterval = 0) {
        guard isHUDVisible else { return }

        // Update score
        scoreLabel?.text = "Score: \(score)"

        // Update lives (special display for God mode)
        if gameMode == .god {
            livesLabel?.text = "Lives: ∞"
        } else {
            livesLabel?.text = "Lives: \(lives)"
        }

        // Update ammo (special display for God mode)
        if gameMode == .god {
            ammoLabel?.text = "Ammo: ∞"
        } else {
            ammoLabel?.text = "Ammo: \(ammo)/\(maxAmmo)"
        }

        // Update God mode timer
        if gameMode == .god {
            let remainingTime = max(0, godModeTimeLimit - elapsedTime)
            let minutes = Int(remainingTime) / 60
            let seconds = Int(remainingTime) % 60

            timerLabel?.text = String(format: "Time: %02d:%02d", minutes, seconds)

            // Color coding for urgency
            if remainingTime < 60 {
                timerLabel?.fontColor = .red
            } else if remainingTime < 300 {
                timerLabel?.fontColor = .yellow
            } else {
                timerLabel?.fontColor = .white
            }
        } else {
            timerLabel?.text = ""
        }
    }

    func updateFPS(_ fps: Double) {
        #if DEBUG
        fpsLabel?.text = String(format: "FPS: %.0f", fps)
        #endif
    }

    // MARK: - Menu Management
    func showMainMenu() {
        guard let scene = scene, let menuNode = menuNode else { return }

        if !isMenuVisible {
            scene.addChild(menuNode)
            isMenuVisible = true
            print("📋 Main menu shown")
        }
    }

    func hideMenu() {
        guard let menuNode = menuNode else { return }

        if isMenuVisible {
            menuNode.removeFromParent()
            isMenuVisible = false
            print("📋 Menu hidden")
        }
    }

    func showHUD() {
        guard let scene = scene, let hudNode = hudNode else { return }

        if !isHUDVisible {
            scene.addChild(hudNode)
            isHUDVisible = true
            print("📊 HUD shown")
        }
    }

    func hideHUD() {
        guard let hudNode = hudNode else { return }

        if isHUDVisible {
            hudNode.removeFromParent()
            isHUDVisible = false
            print("📊 HUD hidden")
        }
    }

    func showHitFeedback() {
        // Visual feedback for successful hits
        guard let scene = scene else { return }

        let feedbackLabel = SKLabelNode(fontNamed: Constants.uiFontName)
        feedbackLabel.text = "HIT!"
        feedbackLabel.fontSize = 36
        feedbackLabel.fontColor = .green
        feedbackLabel.position = CGPoint(x: Constants.screenWidth / 2, y: Constants.screenHeight / 2)
        feedbackLabel.zPosition = 150

        scene.addChild(feedbackLabel)

        // Animate and remove
        let fadeAction = SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.5),
            SKAction.removeFromParent()
        ])
        feedbackLabel.run(fadeAction)
    }

    // MARK: - Menu Interactions
    func handleMenuTouch(at location: CGPoint) -> Constants.GameMode? {
        guard isMenuVisible else { return nil }

        for button in menuButtons {
            if button.contains(location) {
                // Button was tapped
                let buttonName = button.name ?? ""

                switch buttonName {
                case "easy_mode":
                    return .easy
                case "normal_mode":
                    return .normal
                case "hard_mode":
                    return .hard
                case "god_mode":
                    return .god
                default:
                    return nil
                }
            }
        }

        return nil
    }

    // MARK: - Update Loop
    func update(deltaTime: TimeInterval) {
        // Update any animated UI elements here
        // For now, this is mainly for future animations
    }

    // MARK: - Utility
    func getMenuButtonRects() -> [String: CGRect] {
        var buttonRects: [String: CGRect] = [:]

        for button in menuButtons {
            let rect = CGRect(x: button.position.x - 100,
                            y: button.position.y - 20,
                            width: 200,
                            height: 40)
            buttonRects[button.name ?? ""] = rect
        }

        return buttonRects
    }

    var isShowingMenu: Bool {
        return isMenuVisible
    }

    var isShowingHUD: Bool {
        return isHUDVisible
    }
}

// MARK: - SwiftUI HUD Overlay (Alternative Approach)
struct HUDOverlay: View {
    let score: Int
    let lives: Int
    let ammo: Int
    let maxAmmo: Int
    let gameMode: Constants.GameMode
    let elapsedTime: TimeInterval

    var body: some View {
        ZStack {
            // Top HUD
            VStack {
                HStack {
                    Text("Score: \(score)")
                        .foregroundColor(.white)
                        .font(.system(size: 24, weight: .bold))

                    Spacer()

                    if gameMode == .god {
                        Text("Lives: ∞")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .bold))
                    } else {
                        Text("Lives: \(lives)")
                            .foregroundColor(.white)
                            .font(.system(size: 24, weight: .bold))
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)

                Spacer()

                // God mode timer
                if gameMode == .god {
                    let remainingTime = max(0, Constants.godModeTimeLimit - elapsedTime)
                    let minutes = Int(remainingTime) / 60
                    let seconds = Int(remainingTime) % 60

                    Text(String(format: "%02d:%02d", minutes, seconds))
                        .foregroundColor(remainingTime < 60 ? .red : .white)
                        .font(.system(size: 32, weight: .bold))
                }

                Spacer()

                // Bottom HUD
                HStack {
                    if gameMode == .god {
                        Text("Ammo: ∞")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold))
                    } else {
                        Text("Ammo: \(ammo)/\(maxAmmo)")
                            .foregroundColor(.white)
                            .font(.system(size: 20, weight: .bold))
                    }

                    Spacer()

                    // FPS counter in debug mode
                    #if DEBUG
                    Text("FPS: --")
                        .foregroundColor(.yellow)
                        .font(.system(size: 16))
                    #endif
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
    }
}
