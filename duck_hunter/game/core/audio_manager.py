"""
audio_manager.py

This module will manage loading, playing, and controlling all audio in the game.
It leverages the ResourceManager for caching.
"""
import pygame
from game.core.resource_manager import resources
from game.utils import constants as const
import os
import numpy as np
import numpy as np

# Force a more compatible audio driver before initialization to avoid hardware issues.
os.environ['SDL_AUDIODRIVER'] = 'directsound'

class AudioManager:
    """A class to manage all game audio."""
    def __init__(self):
        self.audio_enabled = True
        self.generated_sounds = {}
        try:
            pygame.mixer.init(frequency=44100, size=-16, channels=2, buffer=512)
        except pygame.error as e:
            print(f"!!! Audio Error: {e}")
            print("!!! Audio will be disabled.")
            self.audio_enabled = False
        
        # Generate procedural sound effects
        if self.audio_enabled:
            self.generate_sounds()
        
    def generate_sounds(self):
        """Generate procedural sound effects."""
        # Shotgun sound - explosive burst
        shotgun_sound = self.generate_shotgun_sound()
        self.generated_sounds['shotgun.wav'] = shotgun_sound
        
        # Empty click sound - short click
        empty_click_sound = self.generate_empty_click_sound()
        self.generated_sounds['empty_click.wav'] = empty_click_sound
        
        # Hit sound - satisfying pop
        hit_sound = self.generate_hit_sound()
        self.generated_sounds['hit.wav'] = hit_sound
        
        # Duck quack sound
        quack_sound = self.generate_quack_sound()
        self.generated_sounds['quack.wav'] = quack_sound
        
    def play_sound(self, sound_name, volume=1.0):
        """
        Plays a sound effect.
        
        :param sound_name: The filename of the sound in the audio directory.
        :param volume: The volume to play the sound at (0.0 to 1.0).
        """
        if not self.audio_enabled:
            return
            
        try:
            # Try to load from file first
            sound_path = os.path.join(const.AUDIO_PATH, sound_name)
            sound = resources.load_sound(sound_path)
            sound.set_volume(volume)
            sound.play()
        except (FileNotFoundError, pygame.error):
            # Fall back to generated sound
            if sound_name in self.generated_sounds:
                sound = self.generated_sounds[sound_name]
                sound.set_volume(volume)
                sound.play()
            else:
                print(f"Sound not found: {sound_name}")

    def generate_shotgun_sound(self):
        """Generate a shotgun sound effect."""
        sample_rate = 44100
        duration = 0.3
        frequency = 150
        
        t = np.linspace(0, duration, int(sample_rate * duration), False)
        
        # Create explosive burst with noise
        noise = np.random.normal(0, 0.3, len(t))
        envelope = np.exp(-t * 8)
        wave = (np.sin(frequency * 2 * np.pi * t) + noise) * envelope
        
        # Convert to 16-bit integers
        wave = (wave * 32767).astype(np.int16)
        
        # Create stereo sound
        stereo_wave = np.column_stack((wave, wave))
        
        return pygame.sndarray.make_sound(stereo_wave)

    def generate_empty_click_sound(self):
        """Generate an empty click sound effect."""
        sample_rate = 44100
        duration = 0.1
        frequency = 800
        
        t = np.linspace(0, duration, int(sample_rate * duration), False)
        
        # Simple click with quick decay
        envelope = np.exp(-t * 20)
        wave = np.sin(frequency * 2 * np.pi * t) * envelope
        
        # Convert to 16-bit integers
        wave = (wave * 10000).astype(np.int16)
        
        # Create stereo sound
        stereo_wave = np.column_stack((wave, wave))
        
        return pygame.sndarray.make_sound(stereo_wave)

    def generate_hit_sound(self):
        """Generate a hit sound effect."""
        sample_rate = 44100
        duration = 0.2
        
        t = np.linspace(0, duration, int(sample_rate * duration), False)
        
        # Satisfying pop sound
        envelope = np.exp(-t * 12)
        wave = np.sin(300 * 2 * np.pi * t) * envelope + np.sin(600 * 2 * np.pi * t) * envelope * 0.5
        
        # Convert to 16-bit integers
        wave = (wave * 20000).astype(np.int16)
        
        # Create stereo sound
        stereo_wave = np.column_stack((wave, wave))
        
        return pygame.sndarray.make_sound(stereo_wave)

    def generate_quack_sound(self):
        """Generate a duck quack sound effect."""
        sample_rate = 44100
        duration = 0.4
        
        t = np.linspace(0, duration, int(sample_rate * duration), False)
        
        # Duck quack pattern
        quack_pattern = np.sin(400 * 2 * np.pi * t) * np.exp(-t * 6) + \
                       np.sin(350 * 2 * np.pi * t) * np.exp(-(t-0.1) * 8) * (t > 0.1) + \
                       np.sin(450 * 2 * np.pi * t) * np.exp(-(t-0.2) * 10) * (t > 0.2)
        
        # Convert to 16-bit integers
        wave = (quack_pattern * 15000).astype(np.int16)
        
        # Create stereo sound
        stereo_wave = np.column_stack((wave, wave))
        
        return pygame.sndarray.make_sound(stereo_wave)

    def play_music(self, music_name, volume=1.0, loops=-1):
        """
        Plays background music.

        :param music_name: The filename of the music in the audio directory.
        :param volume: The volume to play the music at (0.0 to 1.0).
        :param loops: How many times the music should repeat (-1 for forever).
        """
        if not self.audio_enabled:
            return
            
        try:
            music_path = os.path.join(const.AUDIO_PATH, music_name)
            pygame.mixer.music.load(music_path)
            pygame.mixer.music.set_volume(volume)
            pygame.mixer.music.play(loops)
        except pygame.error as e:
            print(f"Couldn't play music {music_name}: {e}")
            
    def stop_music(self):
        """Stops the currently playing music."""
        if not self.audio_enabled:
            return
        pygame.mixer.music.stop()

# Create a single instance for global access
audio_manager = AudioManager() 