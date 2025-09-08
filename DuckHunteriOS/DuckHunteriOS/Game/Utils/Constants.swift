//
//  Constants.swift
//  DuckHunteriOS
//
//  Created by John Carmack
//  Copyright © 2024 Duck Hunter. All rights reserved.
//

#if os(iOS)
import UIKit
#else
import AppKit
import CoreGraphics
#endif

struct Constants {

    // MARK: - Screen Dimensions (Dynamic Scaling)
    static var screenWidth: CGFloat {
        #if os(iOS)
        return UIScreen.main.bounds.width
        #else
        return NSScreen.main?.frame.width ?? 1920
        #endif
    }

    static var screenHeight: CGFloat {
        #if os(iOS)
        return UIScreen.main.bounds.height
        #else
        return NSScreen.main?.frame.height ?? 1080
        #endif
    }
    
    // Scaling factors based on reference resolution (1920x1080)
    static let referenceWidth: CGFloat = 1920
    static let referenceHeight: CGFloat = 1080
    
    static var scaleX: CGFloat {
        return screenWidth / referenceWidth
    }
    
    static var scaleY: CGFloat {
        return screenHeight / referenceHeight
    }
    
    static var scaleFactor: CGFloat {
        return min(scaleX, scaleY)
    }

    // MARK: - Game Physics
    static let gravity: CGFloat = 980.0  // pixels per second squared
    static let duckFallSpeed: CGFloat = 200.0
    static let groundY: CGFloat = 120.0

    // MARK: - Crosshair Settings
    static var crosshairHitRadius: CGFloat {
        return 25.0 * scaleFactor
    }
    
    static var crosshairSize: CGSize {
        let baseSize: CGFloat = 60.0
        return CGSize(width: baseSize * scaleFactor, height: baseSize * scaleFactor)
    }

    // MARK: - Game Timing
    static let godModeTimeLimit: TimeInterval = 300.0  // 5 minutes
    static let duckSpawnInterval: TimeInterval = 2.0
    static let groundAnimalSpawnInterval: TimeInterval = 2.5

    // MARK: - Duck Types
    enum DuckType {
        case common, rare, golden, boss

        var pointValue: Int {
            switch self {
            case .common: return 100
            case .rare: return 500
            case .golden: return 1000
            case .boss: return 2000
            }
        }

        var speedRange: ClosedRange<CGFloat> {
            switch self {
            case .common: return 150...250
            case .rare: return 200...350
            case .golden: return 300...450
            case .boss: return 100...200
            }
        }

        var amplitudeRange: ClosedRange<CGFloat> {
            switch self {
            case .common: return 20...60
            case .rare: return 30...80
            case .golden: return 40...100
            case .boss: return 10...30
            }
        }

        var frequencyRange: ClosedRange<CGFloat> {
            switch self {
            case .common: return 0.01...0.02
            case .rare: return 0.015...0.025
            case .golden: return 0.02...0.03
            case .boss: return 0.005...0.01
            }
        }

        var spawnWeight: Int {
            switch self {
            case .common: return 60
            case .rare: return 25
            case .golden: return 10
            case .boss: return 5
            }
        }

        var colorSchemeIndex: Int {
            switch self {
            case .common: return 0  // Brown duck
            case .rare: return 1    // Gray duck
            case .golden: return 2  // Golden duck
            case .boss: return 3    // Green duck
            }
        }
    }

    // MARK: - Ground Animal Types
    enum GroundAnimalType {
        case rabbit, deer, wolf, moose, bear, dinosaur

        var pointValue: Int {
            switch self {
            case .rabbit: return 150
            case .deer: return 200
            case .wolf: return 600
            case .moose: return 800
            case .bear: return 1000
            case .dinosaur: return 1500
            }
        }

        var speedRange: ClosedRange<CGFloat> {
            switch self {
            case .rabbit: return 80...120
            case .deer: return 100...150
            case .wolf: return 120...180
            case .moose: return 60...100
            case .bear: return 40...80
            case .dinosaur: return 30...60
            }
        }

        var spawnWeight: Int {
            switch self {
            case .rabbit: return 40
            case .deer: return 30
            case .wolf: return 25
            case .moose: return 20
            case .bear: return 10
            case .dinosaur: return 15
            }
        }

        var colorSchemeIndex: Int {
            switch self {
            case .rabbit: return 0    // Brown
            case .deer: return 1      // Tan
            case .wolf: return 2      // Gray
            case .moose: return 3     // Dark brown
            case .bear: return 4      // Black
            case .dinosaur: return 5  // Green
            }
        }
    }

    // MARK: - Game Modes
    enum GameMode {
        case easy, normal, hard, god

        var maxLives: Int {
            switch self {
            case .easy: return 10
            case .normal: return 3
            case .hard: return 1
            case .god: return Int.max
            }
        }

        var maxAmmo: Int {
            switch self {
            case .easy: return 15
            case .normal: return 8
            case .hard: return 5
            case .god: return Int.max
            }
        }

        var displayName: String {
            switch self {
            case .easy: return "Easy Mode"
            case .normal: return "Normal Mode"
            case .hard: return "Hard Mode"
            case .god: return "God Mode"
            }
        }
    }

    // MARK: - Colors
    static let backgroundColor: CGColor = {
        #if os(iOS)
        return UIColor.black.cgColor
        #else
        return NSColor.black.cgColor
        #endif
    }()
    
    static let uiTextColor: CGColor = {
        #if os(iOS)
        return UIColor.white.cgColor
        #else
        return NSColor.white.cgColor
        #endif
    }()

    // MARK: - UI Layout
    static var hudTopMargin: CGFloat {
        return 20.0 * scaleFactor
    }
    
    static var hudSideMargin: CGFloat {
        return 30.0 * scaleFactor
    }
    
    static var uiFontSize: CGFloat {
        return 24.0 * scaleFactor
    }
    static let uiFontName = "Courier-Bold"

    // MARK: - Animation
    static let duckFlapDuration: TimeInterval = 0.2
    static let duckFallDuration: TimeInterval = 1.0
    static let hitFeedbackDuration: TimeInterval = 0.1
    static let screenShakeDuration: TimeInterval = 0.2
    
    static var screenShakeIntensity: CGFloat {
        return 5.0 * scaleFactor
    }

    // MARK: - Audio
    static let masterVolume: Float = 1.0
    static let sfxVolume: Float = 0.8
    static let musicVolume: Float = 0.6

    // MARK: - Performance
    static let maxConcurrentParticles: Int = 50
    static let maxConcurrentDucks: Int = 10
    static let maxConcurrentGroundAnimals: Int = 6

    // MARK: - File Paths
    static let resourcesPath = "Resources"
    static let spritesPath = "\(resourcesPath)/Sprites"
    static let soundsPath = "\(resourcesPath)/Sounds"
    static let fontsPath = "\(resourcesPath)/Fonts"
    static let dataPath = "\(resourcesPath)/Data"
}

// MARK: - Extensions
extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        let dx = self.x - point.x
        let dy = self.y - point.y
        return sqrt(dx * dx + dy * dy)
    }
}

#if os(iOS)
extension UIColor {
    // Duck color schemes (matching Python version)
    static let duckColorSchemes: [[UIColor]] = [
        // Brown duck: body, head, wing, beak, eye
        [UIColor(red: 0.55, green: 0.27, blue: 0.07, alpha: 1.0),  // body
         UIColor(red: 0.63, green: 0.41, blue: 0.22, alpha: 1.0),  // head
         UIColor(red: 0.87, green: 0.72, blue: 0.53, alpha: 1.0),  // wing
         UIColor(red: 1.0, green: 0.65, blue: 0.0, alpha: 1.0),    // beak
         UIColor.black],                                           // eye

        // Gray duck: body, head, wing, beak, eye
        [UIColor(red: 0.41, green: 0.41, blue: 0.41, alpha: 1.0),
         UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0),
         UIColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0),
         UIColor(red: 1.0, green: 0.7, blue: 0.0, alpha: 1.0),
         UIColor.black],

        // Golden duck: body, head, wing, beak, eye
        [UIColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0),
         UIColor(red: 1.0, green: 0.87, blue: 0.0, alpha: 1.0),
         UIColor(red: 1.0, green: 0.96, blue: 0.0, alpha: 1.0),
         UIColor(red: 1.0, green: 0.27, blue: 0.0, alpha: 1.0),
         UIColor.black],

        // Green duck: body, head, wing, beak, eye
        [UIColor(red: 0.0, green: 0.39, blue: 0.0, alpha: 1.0),
         UIColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0),
         UIColor(red: 0.56, green: 0.93, blue: 0.56, alpha: 1.0),
         UIColor(red: 1.0, green: 0.08, blue: 0.58, alpha: 1.0),
         UIColor.black]
    ]
}
#else
extension NSColor {
    // Duck color schemes (matching Python version)
    static let duckColorSchemes: [[NSColor]] = [
        // Brown duck: body, head, wing, beak, eye
        [NSColor(red: 0.55, green: 0.27, blue: 0.07, alpha: 1.0),  // body
         NSColor(red: 0.63, green: 0.41, blue: 0.22, alpha: 1.0),  // head
         NSColor(red: 0.87, green: 0.72, blue: 0.53, alpha: 1.0),  // wing
         NSColor(red: 1.0, green: 0.65, blue: 0.0, alpha: 1.0),    // beak
         NSColor.black],                                           // eye

        // Gray duck: body, head, wing, beak, eye
        [NSColor(red: 0.41, green: 0.41, blue: 0.41, alpha: 1.0),
         NSColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 1.0),
         NSColor(red: 0.75, green: 0.75, blue: 0.75, alpha: 1.0),
         NSColor(red: 1.0, green: 0.7, blue: 0.0, alpha: 1.0),
         NSColor.black],

        // Golden duck: body, head, wing, beak, eye
        [NSColor(red: 1.0, green: 0.84, blue: 0.0, alpha: 1.0),
         NSColor(red: 1.0, green: 0.87, blue: 0.0, alpha: 1.0),
         NSColor(red: 1.0, green: 0.96, blue: 0.0, alpha: 1.0),
         NSColor(red: 1.0, green: 0.27, blue: 0.0, alpha: 1.0),
         NSColor.black],

        // Green duck: body, head, wing, beak, eye
        [NSColor(red: 0.0, green: 0.39, blue: 0.0, alpha: 1.0),
         NSColor(red: 0.0, green: 0.5, blue: 0.0, alpha: 1.0),
         NSColor(red: 0.56, green: 0.93, blue: 0.56, alpha: 1.0),
         NSColor(red: 1.0, green: 0.08, blue: 0.58, alpha: 1.0),
         NSColor.black]
    ]
}
#endif
