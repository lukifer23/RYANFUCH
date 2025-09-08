// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "DuckHunteriOS",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "DuckHunteriOS",
            targets: ["DuckHunteriOS"]
        )
    ],
    dependencies: [
        // Add any external dependencies here
    ],
    targets: [
        .executableTarget(
            name: "DuckHunteriOS",
            dependencies: [],
            path: "DuckHunteriOS",
            sources: [
                "App/AppDelegate.swift",
                "App/GameViewController.swift",
                "Game/Core/GameEngine.swift",
                "Game/Core/GameScene.swift",
                "Game/Core/ResourceManager.swift",
                "Game/Core/AudioManager.swift",
                "Game/Core/InputManager.swift",
                "Game/Entities/Duck.swift",
                "Game/Entities/Player.swift",
                "Game/Entities/CrosshairNode.swift",
                "Game/Systems/BackgroundNode.swift",
                "Game/Systems/DuckSpawner.swift",
                "Game/Systems/ParticleSystem.swift",
                "Game/Systems/UISystem.swift",
                "Game/Systems/MenuSystem.swift",
                "Game/Systems/GameCenterManager.swift",
                "Game/Systems/iCloudManager.swift",
                "Game/Utils/Constants.swift"
            ],
            resources: [
                .copy("Resources/animations.json"),
                .copy("Resources/keybinds.json"),
                .copy("Resources/settings.json")
            ]
        )
    ]
)
