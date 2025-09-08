package com.duckhunter.android.game.core

import android.content.Context
import android.content.res.AssetFileDescriptor
import android.media.AudioAttributes
import android.media.AudioManager
import android.media.SoundPool
import android.util.Log

class AudioManager(private val context: Context) {

    private val TAG = "AudioManager"

    private var soundPool: SoundPool? = null
    private val soundIds = mutableMapOf<String, Int>()
    private var loadedSounds = 0
    private var totalSounds = 0

    // Volume settings
    var masterVolume = 1.0f
    var sfxVolume = 0.8f
    var musicVolume = 0.6f

    init {
        initializeAudio()
        loadSounds()
    }

    private fun initializeAudio() {
        try {
            val audioAttributes = AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_GAME)
                .setContentType(AudioAttributes.CONTENT_TYPE_SONIFICATION)
                .build()

            soundPool = SoundPool.Builder()
                .setMaxStreams(10)
                .setAudioAttributes(audioAttributes)
                .build()

            soundPool?.setOnLoadCompleteListener { _, sampleId, status ->
                loadedSounds++
                if (status == 0) {
                    Log.d(TAG, "Sound loaded successfully: $sampleId ($loadedSounds/$totalSounds)")
                } else {
                    Log.e(TAG, "Failed to load sound: $sampleId")
                }
            }

            Log.i(TAG, "Audio system initialized")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to initialize audio system", e)
        }
    }

    private fun loadSounds() {
        val soundFiles = arrayOf(
            "shotgun" to "sounds/shotgun.wav",
            "hit" to "sounds/hit.wav",
            "miss" to "sounds/miss.wav",
            "reload" to "sounds/reload.wav",
            "duck_call" to "sounds/duck_call.wav",
            "empty_click" to "sounds/empty_click.wav",
            "menu_select" to "sounds/menu_select.wav",
            "menu_confirm" to "sounds/menu_confirm.wav"
        )

        totalSounds = soundFiles.size

        soundFiles.forEach { (name, path) ->
            try {
                val afd: AssetFileDescriptor = context.assets.openFd(path)
                val soundId = soundPool?.load(afd, 1) ?: 0
                if (soundId != 0) {
                    soundIds[name] = soundId
                    Log.d(TAG, "Loading sound: $name from $path (ID: $soundId)")
                } else {
                    Log.e(TAG, "Failed to load sound: $name")
                }
                afd.close()
            } catch (e: Exception) {
                Log.e(TAG, "Error loading sound $name from $path", e)
            }
        }
    }

    fun playSound(soundName: String, volume: Float = 1.0f) {
        try {
            val soundId = soundIds[soundName]
            if (soundId != null && soundPool != null) {
                val finalVolume = (volume * sfxVolume * masterVolume).coerceIn(0f, 1f)
                val streamId = soundPool?.play(soundId, finalVolume, finalVolume, 1, 0, 1.0f)

                if (streamId == 0) {
                    Log.w(TAG, "Failed to play sound: $soundName")
                } else {
                    Log.v(TAG, "Playing sound: $soundName (volume: $finalVolume)")
                }
            } else {
                Log.w(TAG, "Sound not found or sound pool not initialized: $soundName")
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error playing sound: $soundName", e)
        }
    }

    fun playShotSound() {
        playSound("shotgun", 0.7f)
    }

    fun playHitSound() {
        playSound("hit", 0.8f)
    }

    fun playMissSound() {
        playSound("miss", 0.6f)
    }

    fun playReloadSound() {
        playSound("reload", 0.5f)
    }

    fun playDuckCallSound() {
        playSound("duck_call", 0.4f)
    }

    fun playEmptyClickSound() {
        playSound("empty_click", 0.3f)
    }

    fun playMenuSelectSound() {
        playSound("menu_select", 0.4f)
    }

    fun playMenuConfirmSound() {
        playSound("menu_confirm", 0.5f)
    }

    fun setMasterVolumeLevel(volume: Float) {
        masterVolume = volume.coerceIn(0f, 1f)
        Log.d(TAG, "Master volume set to: $masterVolume")
    }

    fun setSFXVolumeLevel(volume: Float) {
        sfxVolume = volume.coerceIn(0f, 1f)
        Log.d(TAG, "SFX volume set to: $sfxVolume")
    }

    fun setMusicVolumeLevel(volume: Float) {
        musicVolume = volume.coerceIn(0f, 1f)
        Log.d(TAG, "Music volume set to: $musicVolume")
    }

    fun isLoaded(): Boolean {
        return loadedSounds >= totalSounds * 0.8f // 80% loaded is acceptable
    }

    fun dispose() {
        try {
            soundPool?.release()
            soundPool = null
            soundIds.clear()
            Log.i(TAG, "AudioManager disposed")
        } catch (e: Exception) {
            Log.e(TAG, "Error disposing AudioManager", e)
        }
    }

    fun getLoadedSoundsCount(): Int = loadedSounds
    fun getTotalSoundsCount(): Int = totalSounds
}
