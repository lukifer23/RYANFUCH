//
//  ResourceManager.swift
//  DuckHunteriOS
//
//  Created by John Carmack
//  Copyright © 2024 Duck Hunter. All rights reserved.
//

import UIKit
import AVFoundation

class ResourceManager {

    // MARK: - Singleton
    static let shared = ResourceManager()

    private init() {
        setupAudioSession()
    }

    // MARK: - Properties
    private var textureCache: [String: SKTexture] = [:]
    private var soundCache: [String: AVAudioPlayer] = [:]
    private var imageCache: [String: UIImage] = [:]
    private var fontCache: [String: UIFont] = [:]

    // MARK: - Audio Session Setup
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Failed to setup audio session: \(error)")
        }
    }

    // MARK: - Texture Management
    func getTexture(named name: String) -> SKTexture? {
        if let cachedTexture = textureCache[name] {
            return cachedTexture
        }

        // Try to load from bundle
        if let image = UIImage(named: name) {
            let texture = SKTexture(image: image)
            textureCache[name] = texture
            return texture
        }

        // If not found, create procedural texture
        if let proceduralTexture = createProceduralTexture(named: name) {
            textureCache[name] = proceduralTexture
            return proceduralTexture
        }

        print("⚠️ Texture not found: \(name)")
        return nil
    }

    private func createProceduralTexture(named name: String) -> SKTexture? {
        // For now, return nil - we'll implement procedural textures in the entities
        return nil
    }

    // MARK: - Sound Management
    func getSound(named name: String) -> AVAudioPlayer? {
        if let cachedSound = soundCache[name] {
            return cachedSound
        }

        // Try to load from bundle
        if let soundURL = Bundle.main.url(forResource: name, withExtension: nil) {
            do {
                let player = try AVAudioPlayer(contentsOf: soundURL)
                player.prepareToPlay()
                soundCache[name] = player
                return player
            } catch {
                print("❌ Failed to load sound \(name): \(error)")
            }
        }

        print("⚠️ Sound not found: \(name)")
        return nil
    }

    func playSound(_ soundName: String, volume: Float = 1.0) {
        guard let player = getSound(named: soundName) else { return }

        player.volume = volume
        player.currentTime = 0
        player.play()
    }

    // MARK: - Font Management
    func getFont(named name: String, size: CGFloat) -> UIFont {
        let key = "\(name)-\(size)"

        if let cachedFont = fontCache[key] {
            return cachedFont
        }

        let font: UIFont
        if let customFont = UIFont(name: name, size: size) {
            font = customFont
        } else {
            // Fallback to system font
            font = UIFont.systemFont(ofSize: size, weight: .bold)
        }

        fontCache[key] = font
        return font
    }

    // MARK: - Image Management
    func getImage(named name: String) -> UIImage? {
        if let cachedImage = imageCache[name] {
            return cachedImage
        }

        if let image = UIImage(named: name) {
            imageCache[name] = image
            return image
        }

        print("⚠️ Image not found: \(name)")
        return nil
    }

    // MARK: - Cache Management
    func clearCache() {
        textureCache.removeAll()
        soundCache.removeAll()
        imageCache.removeAll()
        fontCache.removeAll()
        print("🧹 Resource cache cleared")
    }

    func preloadEssentialAssets() {
        // Preload commonly used textures and sounds
        let essentialTextures = [
            "duck_fly_1",
            "duck_fly_2",
            "duck_fall",
            "crosshair",
            "background"
        ]

        let essentialSounds = [
            "shotgun.wav",
            "hit.wav",
            "miss.wav",
            "empty_click.wav"
        ]

        for textureName in essentialTextures {
            _ = getTexture(named: textureName)
        }

        for soundName in essentialSounds {
            _ = getSound(named: soundName)
        }

        print("✅ Essential assets preloaded")
    }

    // MARK: - Memory Management
    deinit {
        clearCache()
    }
}
