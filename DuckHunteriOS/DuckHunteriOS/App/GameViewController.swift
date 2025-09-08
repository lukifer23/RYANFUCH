//
//  GameViewController.swift
//  DuckHunteriOS
//
//  Main game view controller with SpriteKit integration and menu system (macOS version)
//

import AppKit
import SpriteKit
import GameKit
import CloudKit

class GameViewController: NSViewController {

    // MARK: - Properties
    private var skView: SKView!
    private var gameScene: GameScene!
    private var menuOverlay: MenuOverlayView?

    // Game Center and iCloud
    private var gameCenterManager: GameCenterManager?
    private var iCloudManager: iCloudManager?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupSpriteKitView()
        setupGameScene()
        setupNotifications()
        setupMenuSystem()
        setupGameCenterAndICloud()

        print("🎮 Duck Hunter macOS - Game View Controller Loaded")
    }

    override func viewDidLayout() {
        super.viewDidLayout()

        // Update scene size when view layout changes
        if let scene = gameScene {
            scene.size = view.bounds.size
        }
    }

    // MARK: - Setup Methods
    private func setupSpriteKitView() {
        skView = SKView(frame: view.bounds)
        skView.autoresizingMask = [.width, .height]
        skView.ignoresSiblingOrder = true

        // Debug options (disable for production)
        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        skView.showsDrawCount = true
        #endif

        view.addSubview(skView)
    }

    private func setupGameScene() {
        gameScene = GameScene(size: view.bounds.size)
        gameScene.scaleMode = .aspectFill
        skView.presentScene(gameScene)
    }

    private func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(pauseGame), name: NSNotification.Name("PauseGame"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(resumeGame), name: NSNotification.Name("ResumeGame"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showMenu), name: NSNotification.Name("ShowMenu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(hideMenu), name: NSNotification.Name("HideMenu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showLeaderboard), name: NSNotification.Name("ShowLeaderboard"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAchievements), name: NSNotification.Name("ShowAchievements"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(syncData), name: NSNotification.Name("SyncData"), object: nil)
    }

    private func setupMenuSystem() {
        menuOverlay = MenuOverlayView(frame: view.bounds)
        menuOverlay?.autoresizingMask = [.width, .height]
        menuOverlay?.isHidden = true
        if let menuOverlay = menuOverlay {
            view.addSubview(menuOverlay)
        }
    }

    private func setupGameCenterAndICloud() {
        // Initialize managers lazily to avoid circular references
        gameCenterManager = GameCenterManager.shared
        iCloudManager = iCloudManager.shared

        // Game Center is initialized automatically when GameCenterManager.shared is accessed
        print("🏆 Game Center initialized")

        // iCloud is initialized automatically when iCloudManager.shared is accessed
        print("☁️ iCloud initialized")

        // Sync data on app launch
        iCloudManager?.syncData()
    }

    // MARK: - Game Control Methods
    @objc private func pauseGame() {
        gameScene?.isPaused = true
        showMenu()
    }

    @objc private func resumeGame() {
        gameScene?.isPaused = false
        hideMenu()
    }

    @objc private func showMenu() {
        menuOverlay?.isHidden = false
        menuOverlay?.fadeIn()
    }

    @objc private func hideMenu() {
        menuOverlay?.fadeOut()
    }

    @objc private func showLeaderboard() {
        gameCenterManager?.showLeaderboards(from: self)
    }

    @objc private func showAchievements() {
        gameCenterManager?.showAchievements(from: self)
    }

    @objc private func syncData() {
        iCloudManager?.syncData()
    }

    // MARK: - Mouse Event Handling
    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)

        // Handle menu clicks first
        if let menuOverlay = menuOverlay, !menuOverlay.isHidden {
            menuOverlay.handleMouse(event, in: view)
            return
        }

        // Handle game mouse events
        gameScene?.handleMouse(event, in: view)
    }

    override func mouseDragged(with event: NSEvent) {
        super.mouseDragged(with: event)
        gameScene?.handleMouse(event, in: view)
    }

    override func mouseUp(with event: NSEvent) {
        super.mouseUp(with: event)
        gameScene?.handleMouse(event, in: view)
    }

    // MARK: - Memory Management
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Menu Overlay View
class MenuOverlayView: NSView {

    private let menuView: NSView
    private let titleLabel: NSTextField
    private let playButton: NSButton
    private let settingsButton: NSButton
    private let leaderboardButton: NSButton
    private let achievementsButton: NSButton
    private let syncButton: NSButton

    override init(frame: CGRect) {
        // Create menu components
        menuView = NSView()
        titleLabel = NSTextField()
        playButton = NSButton()
        settingsButton = NSButton()
        leaderboardButton = NSButton()
        achievementsButton = NSButton()
        syncButton = NSButton()

        super.init(frame: frame)
        setupMenu()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupMenu() {
        wantsLayer = true
        layer?.backgroundColor = NSColor.black.withAlphaComponent(0.7).cgColor

        // Setup menu container
        menuView.wantsLayer = true
        menuView.layer?.backgroundColor = NSColor.white.withAlphaComponent(0.9).cgColor
        menuView.layer?.cornerRadius = 20
        menuView.layer?.masksToBounds = true
        addSubview(menuView)

        // Setup title
        titleLabel.stringValue = "🎯 Duck Hunter"
        titleLabel.font = NSFont.boldSystemFont(ofSize: 32)
        titleLabel.alignment = .center
        titleLabel.isEditable = false
        titleLabel.isBordered = false
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
        menuView.addSubview(titleLabel)

        // Setup buttons
        setupButton(playButton, title: "🎮 Play Game", action: #selector(playGame))
        setupButton(settingsButton, title: "⚙️ Settings", action: #selector(showSettings))
        setupButton(leaderboardButton, title: "🏆 Leaderboard", action: #selector(showLeaderboard))
        setupButton(achievementsButton, title: "🎖️ Achievements", action: #selector(showAchievements))
        setupButton(syncButton, title: "☁️ Sync Data", action: #selector(syncData))

        menuView.addSubview(playButton)
        menuView.addSubview(settingsButton)
        menuView.addSubview(leaderboardButton)
        menuView.addSubview(achievementsButton)
        menuView.addSubview(syncButton)

        layoutMenu()
    }

    private func setupButton(_ button: NSButton, title: String, action: Selector) {
        button.title = title
        button.font = NSFont.systemFont(ofSize: 20)
        button.bezelStyle = .rounded
        button.target = self
        button.action = action
    }

    private func layoutMenu() {
        let menuWidth: CGFloat = 300
        let menuHeight: CGFloat = 500
        let buttonHeight: CGFloat = 45
        let buttonSpacing: CGFloat = 15

        menuView.frame = CGRect(x: (bounds.width - menuWidth) / 2,
                               y: (bounds.height - menuHeight) / 2,
                               width: menuWidth, height: menuHeight)

        titleLabel.frame = CGRect(x: 20, y: menuHeight - 70, width: menuWidth - 40, height: 40)

        playButton.frame = CGRect(x: 20, y: menuHeight - 120, width: menuWidth - 40, height: buttonHeight)
        settingsButton.frame = CGRect(x: 20, y: menuHeight - 120 - buttonHeight - buttonSpacing, width: menuWidth - 40, height: buttonHeight)
        leaderboardButton.frame = CGRect(x: 20, y: menuHeight - 120 - (buttonHeight + buttonSpacing) * 2, width: menuWidth - 40, height: buttonHeight)
        achievementsButton.frame = CGRect(x: 20, y: menuHeight - 120 - (buttonHeight + buttonSpacing) * 3, width: menuWidth - 40, height: buttonHeight)
        syncButton.frame = CGRect(x: 20, y: menuHeight - 120 - (buttonHeight + buttonSpacing) * 4, width: menuWidth - 40, height: buttonHeight)
    }

    func handleMouse(_ event: NSEvent, in view: NSView) {
        // Handle menu interactions
        let location = convert(event.locationInWindow, from: nil)
        if menuView.frame.contains(location) {
            // Mouse event is within menu - handle menu interactions
        }
    }

    func fadeIn() {
        alphaValue = 0
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            self.animator().alphaValue = 1
        }
    }

    func fadeOut() {
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.3
            self.animator().alphaValue = 0
        } completionHandler: {
            self.isHidden = true
        }
    }

    @objc private func playGame() {
        NotificationCenter.default.post(name: NSNotification.Name("StartGame"), object: nil)
    }

    @objc private func showSettings() {
        NotificationCenter.default.post(name: NSNotification.Name("ShowSettings"), object: nil)
    }

    @objc private func showLeaderboard() {
        NotificationCenter.default.post(name: NSNotification.Name("ShowLeaderboard"), object: nil)
    }

    @objc private func showAchievements() {
        NotificationCenter.default.post(name: NSNotification.Name("ShowAchievements"), object: nil)
    }

    @objc private func syncData() {
        NotificationCenter.default.post(name: NSNotification.Name("SyncData"), object: nil)
    }
}
