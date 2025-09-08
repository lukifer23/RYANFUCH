//
//  AppDelegate.swift
//  DuckHunteriOS
//
//  macOS App Delegate for Duck Hunter
//

import AppKit
import AVFoundation

@main
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        print("🎮 Duck Hunter macOS - App Launched")

        // Initialize audio session for game sounds
        setupAudioSession()

        // Initialize Game Center (simulated for macOS)
        setupGameCenter()

        // Initialize iCloud (simulated for macOS)
        setupiCloud()

        // Create main window
        createMainWindow()
    }

    func applicationWillTerminate(_ notification: Notification) {
        print("👋 Duck Hunter - App Terminating")
    }

    private func createMainWindow() {
        let screenRect = NSScreen.main?.frame ?? NSRect(x: 0, y: 0, width: 800, height: 600)
        window = NSWindow(contentRect: screenRect,
                         styleMask: [.titled, .closable, .miniaturizable, .resizable],
                         backing: .buffered,
                         defer: false)

        window?.title = "🎯 Duck Hunter"
        window?.center()

        // Create game view controller
        let gameViewController = GameViewController()
        window?.contentViewController = gameViewController
        window?.makeKeyAndOrderFront(nil)

        print("✅ Main window created and displayed")
    }

    private func setupAudioSession() {
        // Note: AVAudioSession is not available on macOS
        // Audio setup would be handled differently on macOS
        print("🔊 Audio setup (simplified for macOS)")
    }

    private func setupGameCenter() {
        // Note: Game Center is primarily for iOS. On macOS, this would be simulated
        print("🏆 Game Center setup (simulated for macOS)")
    }

    private func setupiCloud() {
        // Note: iCloud integration would work similarly on macOS
        print("☁️ iCloud setup (simulated for macOS)")
    }
}
