//
//  GameCenterManager.swift
//  DuckHunteriOS_Full
//
//  Game Center integration for leaderboards and achievements
//

import GameKit
import AppKit

class GameCenterManager: NSObject {

    // MARK: - Properties
    static let shared = GameCenterManager()

    private var isGameCenterEnabled = false
    private var localPlayer: GKLocalPlayer!

    // Leaderboard IDs
    private let highScoreLeaderboardID = "com.duckhunter.highscore"
    private let totalDucksLeaderboardID = "com.duckhunter.totalducks"
    private let accuracyLeaderboardID = "com.duckhunter.accuracy"

    // Achievement IDs
    private let firstDuckAchievementID = "com.duckhunter.firstduck"
    private let hundredDucksAchievementID = "com.duckhunter.hundredducks"
    private let perfectRoundAchievementID = "com.duckhunter.perfectround"
    private let sharpshooterAchievementID = "com.duckhunter.sharpshooter"

    // MARK: - Initialization
    private override init() {
        super.init()
        authenticatePlayer()
    }

    // MARK: - Authentication
    private func authenticatePlayer() {
        localPlayer = GKLocalPlayer.local

        localPlayer.authenticateHandler = { [weak self] viewController, error in
            guard let self = self else { return }

            if let viewController = viewController {
                // Present the authentication view controller
                DispatchQueue.main.async {
                    if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
                        rootVC.present(viewController, animated: true, completion: nil)
                    }
                }
                return
            }

            if let error = error {
                print("❌ Game Center authentication failed: \(error.localizedDescription)")
                self.isGameCenterEnabled = false
                return
            }

            if self.localPlayer.isAuthenticated {
                print("✅ Game Center authenticated: \(self.localPlayer.displayName ?? "Unknown Player")")
                self.isGameCenterEnabled = true
                self.loadAchievements()
            } else {
                print("❌ Game Center authentication failed")
                self.isGameCenterEnabled = false
            }
        }
    }

    // MARK: - Leaderboards
    func submitScore(_ score: Int, forLeaderboard leaderboardID: String) {
        guard isGameCenterEnabled else {
            print("⚠️ Game Center not enabled, score not submitted")
            return
        }

        let scoreReporter = GKScore(leaderboardIdentifier: leaderboardID)
        scoreReporter.value = Int64(score)

        GKScore.report([scoreReporter]) { error in
            if let error = error {
                print("❌ Failed to submit score: \(error.localizedDescription)")
            } else {
                print("✅ Score submitted to \(leaderboardID): \(score)")
            }
        }
    }

    func submitHighScore(_ score: Int) {
        submitScore(score, forLeaderboard: highScoreLeaderboardID)
    }

    func submitTotalDucks(_ count: Int) {
        submitScore(count, forLeaderboard: totalDucksLeaderboardID)
    }

    func submitAccuracy(_ percentage: Double) {
        let accuracyScore = Int(percentage * 100) // Convert to integer for leaderboard
        submitScore(accuracyScore, forLeaderboard: accuracyLeaderboardID)
    }

    func showLeaderboard(_ leaderboardID: String, from viewController: NSViewController) {
        guard isGameCenterEnabled else {
            print("⚠️ Game Center not enabled")
            return
        }

        let gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = .leaderboards
        gcViewController.leaderboardIdentifier = leaderboardID

        DispatchQueue.main.async {
            viewController.present(gcViewController, animated: true, completion: nil)
        }
    }

    func showLeaderboards(from viewController: NSViewController) {
        guard isGameCenterEnabled else {
            print("⚠️ Game Center not enabled")
            return
        }

        let gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = .leaderboards

        DispatchQueue.main.async {
            viewController.present(gcViewController, animated: true, completion: nil)
        }
    }

    // MARK: - Achievements
    func unlockAchievement(_ achievementID: String, progress: Double = 100.0) {
        guard isGameCenterEnabled else {
            print("⚠️ Game Center not enabled, achievement not unlocked")
            return
        }

        let achievement = GKAchievement(identifier: achievementID)
        achievement.percentComplete = progress
        achievement.showsCompletionBanner = true

        GKAchievement.report([achievement]) { error in
            if let error = error {
                print("❌ Failed to unlock achievement: \(error.localizedDescription)")
            } else {
                print("🏆 Achievement unlocked: \(achievementID)")
            }
        }
    }

    func unlockFirstDuck() {
        unlockAchievement(firstDuckAchievementID)
    }

    func unlockHundredDucks() {
        unlockAchievement(hundredDucksAchievementID)
    }

    func unlockPerfectRound() {
        unlockAchievement(perfectRoundAchievementID)
    }

    func unlockSharpshooter() {
        unlockAchievement(sharpshooterAchievementID)
    }

    func showAchievements(from viewController: NSViewController) {
        guard isGameCenterEnabled else {
            print("⚠️ Game Center not enabled")
            return
        }

        let gcViewController = GKGameCenterViewController()
        gcViewController.gameCenterDelegate = self
        gcViewController.viewState = .achievements

        DispatchQueue.main.async {
            viewController.present(gcViewController, animated: true, completion: nil)
        }
    }

    private func loadAchievements() {
        GKAchievement.loadAchievements { [weak self] achievements, error in
            if let error = error {
                print("❌ Failed to load achievements: \(error.localizedDescription)")
                return
            }

            if let achievements = achievements {
                print("✅ Loaded \(achievements.count) achievements")
                // Process loaded achievements if needed
            }
        }
    }

    // MARK: - Game Center State
    func isAuthenticated() -> Bool {
        return isGameCenterEnabled && localPlayer.isAuthenticated
    }

    func getPlayerName() -> String {
        return localPlayer.displayName ?? "Anonymous Player"
    }
}

// MARK: - GKGameCenterControllerDelegate
extension GameCenterManager: GKGameCenterControllerDelegate {
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
