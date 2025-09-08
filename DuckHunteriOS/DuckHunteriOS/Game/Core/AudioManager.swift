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
    private var generatedBuffers: [String: AVAudioPCMBuffer] = [:]

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
            generateProceduralSounds()
        } catch {
            print("❌ Failed to start audio engine: \(error)")
            isAudioEnabled = false
        }
    }

    // MARK: - Procedural Sound Generation
    private func generateProceduralSounds() {
        generatedBuffers["shotgun.wav"] = generateShotgunSound()
        generatedBuffers["empty_click.wav"] = generateEmptyClickSound()
        generatedBuffers["hit.wav"] = generateHitSound()
        generatedBuffers["duck_call.wav"] = generateDuckCallSound()
        generatedBuffers["miss.wav"] = generateMissSound()
        generatedBuffers["reload.wav"] = generateReloadSound()
        generatedBuffers["menu_select.wav"] = generateMenuSelectSound()
        generatedBuffers["menu_confirm.wav"] = generateMenuConfirmSound()
        
        print("✅ Procedural sounds generated")
    }

    // MARK: - Sound Playback
    func playSoundByName(_ soundName: String, volume: Float = 1.0) {
        guard isAudioEnabled else { return }
        
        if let buffer = generatedBuffers[soundName] {
            playGeneratedSound(buffer, volume: volume * masterVolume * sfxVolume)
        }
    }

    private func playGeneratedSound(_ buffer: AVAudioPCMBuffer, volume: Float) {
        let player = AVAudioPlayerNode()
        audioEngine.attach(player)
        audioEngine.connect(player, to: mixer, format: buffer.format)
        
        player.volume = volume
        
        player.scheduleBuffer(buffer, at: nil, options: .interrupts, completionHandler: nil)
        
        do {
            try audioEngine.start()
            player.play()
            
            // Clean up after playing
            DispatchQueue.main.asyncAfter(deadline: .now() + buffer.duration) {
                self.audioEngine.detach(player)
            }
        } catch {
            print("❌ Failed to play generated sound: \(error)")
        }
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
        generatedBuffers.removeAll()
    }

    deinit {
        cleanup()
    }

    // MARK: - Procedural Sound Generation Functions
    private func generateShotgunSound() -> AVAudioPCMBuffer? {
        let sampleRate: Double = 44100
        let duration: Double = 0.3
        let frequency: Double = 150
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else { return nil }
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        
        guard let channelData = buffer.floatChannelData else { return nil }
        
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            
            // Create explosive burst with noise
            let noise = Float.random(in: -0.3...0.3)
            let envelope = exp(-t * 8)
            let wave = (sin(frequency * 2 * .pi * t) + noise) * envelope
            
            // Apply to both channels
            channelData[0][frame] = wave
            channelData[1][frame] = wave
        }
        
        return buffer
    }

    private func generateEmptyClickSound() -> AVAudioPCMBuffer? {
        let sampleRate: Double = 44100
        let duration: Double = 0.1
        let frequency: Double = 800
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else { return nil }
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        
        guard let channelData = buffer.floatChannelData else { return nil }
        
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            
            // Simple click with quick decay
            let envelope = exp(-t * 20)
            let wave = sin(frequency * 2 * .pi * t) * envelope
            
            channelData[0][frame] = wave * 0.3
            channelData[1][frame] = wave * 0.3
        }
        
        return buffer
    }

    private func generateHitSound() -> AVAudioPCMBuffer? {
        let sampleRate: Double = 44100
        let duration: Double = 0.2
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else { return nil }
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        
        guard let channelData = buffer.floatChannelData else { return nil }
        
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            
            // Satisfying pop sound
            let envelope = exp(-t * 12)
            let wave1 = sin(300 * 2 * .pi * t) * envelope
            let wave2 = sin(600 * 2 * .pi * t) * envelope * 0.5
            let wave = wave1 + wave2
            
            channelData[0][frame] = wave * 0.6
            channelData[1][frame] = wave * 0.6
        }
        
        return buffer
    }

    private func generateDuckCallSound() -> AVAudioPCMBuffer? {
        let sampleRate: Double = 44100
        let duration: Double = 0.4
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else { return nil }
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        
        guard let channelData = buffer.floatChannelData else { return nil }
        
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            
            // Duck quack pattern with multiple frequencies
            var wave: Float = 0
            
            if t < 0.1 {
                wave = sin(400 * 2 * .pi * t) * exp(-t * 6)
            } else if t < 0.2 {
                wave = sin(350 * 2 * .pi * t) * exp(-(t - 0.1) * 8)
            } else {
                wave = sin(450 * 2 * .pi * t) * exp(-(t - 0.2) * 10)
            }
            
            channelData[0][frame] = wave * 0.4
            channelData[1][frame] = wave * 0.4
        }
        
        return buffer
    }

    private func generateMissSound() -> AVAudioPCMBuffer? {
        let sampleRate: Double = 44100
        let duration: Double = 0.15
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else { return nil }
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        
        guard let channelData = buffer.floatChannelData else { return nil }
        
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            
            // Short whoosh sound
            let envelope = exp(-t * 15)
            let wave = sin(200 * 2 * .pi * t) * envelope
            
            channelData[0][frame] = wave * 0.5
            channelData[1][frame] = wave * 0.5
        }
        
        return buffer
    }

    private func generateReloadSound() -> AVAudioPCMBuffer? {
        let sampleRate: Double = 44100
        let duration: Double = 0.25
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else { return nil }
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        
        guard let channelData = buffer.floatChannelData else { return nil }
        
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            
            // Mechanical click sound
            let envelope = exp(-t * 10)
            let wave = sin(1000 * 2 * .pi * t) * envelope
            
            channelData[0][frame] = wave * 0.4
            channelData[1][frame] = wave * 0.4
        }
        
        return buffer
    }

    private func generateMenuSelectSound() -> AVAudioPCMBuffer? {
        let sampleRate: Double = 44100
        let duration: Double = 0.08
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else { return nil }
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        
        guard let channelData = buffer.floatChannelData else { return nil }
        
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            
            // Quick beep
            let envelope = exp(-t * 25)
            let wave = sin(600 * 2 * .pi * t) * envelope
            
            channelData[0][frame] = wave * 0.3
            channelData[1][frame] = wave * 0.3
        }
        
        return buffer
    }

    private func generateMenuConfirmSound() -> AVAudioPCMBuffer? {
        let sampleRate: Double = 44100
        let duration: Double = 0.12
        let frameCount = AVAudioFrameCount(sampleRate * duration)
        
        guard let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2) else { return nil }
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else { return nil }
        buffer.frameLength = frameCount
        
        guard let channelData = buffer.floatChannelData else { return nil }
        
        for frame in 0..<Int(frameCount) {
            let t = Double(frame) / sampleRate
            
            // Confirming chime
            let envelope = exp(-t * 18)
            let wave1 = sin(800 * 2 * .pi * t) * envelope
            let wave2 = sin(1000 * 2 * .pi * t) * envelope * 0.7
            let wave = wave1 + wave2
            
            channelData[0][frame] = wave * 0.4
            channelData[1][frame] = wave * 0.4
        }
        
        return buffer
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
