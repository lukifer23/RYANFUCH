//
//  AudioManager.swift
//  DuckHunteriOS
//
//  Created by John Carmack
//  Copyright © 2024 Duck Hunter. All rights reserved.
//

import AVFoundation

class AudioManager {

    // MARK: - Singleton
    static let shared = AudioManager()

    private init() {
        setupAudioEngine()
    }

    // MARK: - Properties
    private var audioEngine: AVAudioEngine!
    private var mixer: AVAudioMixerNode!
    private var players: [String: AVAudioPlayerNode] = [:]
    private var buffers: [String: AVAudioPCMBuffer] = [:]

    private var isAudioEnabled = true
    private var masterVolume: Float = Constants.masterVolume
    private var sfxVolume: Float = Constants.sfxVolume
    private var musicVolume: Float = Constants.musicVolume

    // MARK: - Audio Engine Setup
    private func setupAudioEngine() {
        audioEngine = AVAudioEngine()
        mixer = audioEngine.mainMixerNode

        do {
            try audioEngine.start()
            print("🎵 Audio engine started successfully")
        } catch {
            print("❌ Failed to start audio engine: \(error)")
            isAudioEnabled = false
        }
    }

    // MARK: - Sound Playback
    func playSound(_ soundType: SoundType, volume: Float? = nil) {
        guard isAudioEnabled else { return }

        let soundName = soundType.fileName
        let soundVolume = volume ?? soundType.defaultVolume

        // For simple sounds, use ResourceManager for now
        // In a full implementation, we'd use AVAudioEngine for better performance
        ResourceManager.shared.playSound(soundName, volume: soundVolume * masterVolume * sfxVolume)
    }

    func playMusic(_ musicName: String, loop: Bool = true, volume: Float? = nil) {
        guard isAudioEnabled else { return }

        let volume = volume ?? musicVolume

        if let player = ResourceManager.shared.getSound(named: musicName) {
            player.volume = volume * masterVolume
            player.numberOfLoops = loop ? -1 : 0
            player.play()
        }
    }

    func stopMusic() {
        // Stop all music players (for now, just stop any currently playing)
        // In a full implementation, we'd track music players separately
    }

    // MARK: - Volume Control
    func setMasterVolume(_ volume: Float) {
        masterVolume = max(0, min(1, volume))
    }

    func setSFXVolume(_ volume: Float) {
        sfxVolume = max(0, min(1, volume))
    }

    func setMusicVolume(_ volume: Float) {
        musicVolume = max(0, min(1, volume))
    }

    func getMasterVolume() -> Float { masterVolume }
    func getSFXVolume() -> Float { sfxVolume }
    func getMusicVolume() -> Float { musicVolume }

    // MARK: - Audio State
    func isEnabled() -> Bool { isAudioEnabled }

    func setEnabled(_ enabled: Bool) {
        isAudioEnabled = enabled
        if enabled {
            do {
                try audioEngine.start()
            } catch {
                print("❌ Failed to restart audio engine: \(error)")
                isAudioEnabled = false
            }
        } else {
            audioEngine.stop()
        }
    }

    // MARK: - 3D Audio (Future Enhancement)
    func setListenerPosition(_ position: CGPoint) {
        // Future: Implement 3D positional audio for duck calls
    }

    func setSoundPosition(_ soundName: String, position: CGPoint) {
        // Future: Implement positional audio
    }

    // MARK: - Cleanup
    func cleanup() {
        audioEngine.stop()
        players.removeAll()
        buffers.removeAll()
    }

    deinit {
        cleanup()
    }
}

// MARK: - Sound Types
enum SoundType {
    case shotgun
    case hit
    case miss
    case emptyClick
    case duckCall
    case reload
    case menuSelect
    case menuConfirm

    var fileName: String {
        switch self {
        case .shotgun: return "shotgun.wav"
        case .hit: return "hit.wav"
        case .miss: return "miss.wav"
        case .emptyClick: return "empty_click.wav"
        case .duckCall: return "duck_call.wav"
        case .reload: return "reload.wav"
        case .menuSelect: return "menu_select.wav"
        case .menuConfirm: return "menu_confirm.wav"
        }
    }

    var defaultVolume: Float {
        switch self {
        case .shotgun: return 0.8
        case .hit: return 0.7
        case .miss: return 0.5
        case .emptyClick: return 0.6
        case .duckCall: return 0.4
        case .reload: return 0.6
        case .menuSelect: return 0.5
        case .menuConfirm: return 0.7
        }
    }
}
