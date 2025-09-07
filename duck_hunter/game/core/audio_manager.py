"""
audio_manager.py

This module will manage loading, playing, and controlling all audio in the game.
It leverages the ResourceManager for caching.
"""
import pygame
from game.core.resource_manager import resources
from game.utils import constants as const
import os

# Force a more compatible audio driver before initialization to avoid hardware issues.
os.environ['SDL_AUDIODRIVER'] = 'directsound'

class AudioManager:
    """A class to manage all game audio."""
    def __init__(self):
        self.audio_enabled = True
        try:
            pygame.mixer.init()
        except pygame.error as e:
            print(f"!!! Audio Error: {e}")
            print("!!! Audio will be disabled.")
            self.audio_enabled = False
        # Allocate channels for specific sound types if needed
        # pygame.mixer.set_num_channels(16)
        
    def play_sound(self, sound_name, volume=1.0):
        """
        Plays a sound effect.
        
        :param sound_name: The filename of the sound in the audio directory.
        :param volume: The volume to play the sound at (0.0 to 1.0).
        """
        if not self.audio_enabled:
            return
            
        try:
            sound_path = os.path.join(const.AUDIO_PATH, sound_name)
            sound = resources.load_sound(sound_path)
            sound.set_volume(volume)
            sound.play()
        except FileNotFoundError:
            print(f"Audio file not found: {sound_path}. Skipping sound.")
        except pygame.error as e:
            print(f"Couldn't play sound {sound_name}: {e}")

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