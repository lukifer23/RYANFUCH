"""
resource_manager.py

A centralized manager for loading, caching, and accessing all game assets like
sprites, sounds, and fonts to ensure efficiency.
"""
import pygame
import os

class ResourceManager:
    """A singleton class to manage game resources."""
    _instance = None

    def __new__(cls):
        if cls._instance is None:
            cls._instance = super(ResourceManager, cls).__new__(cls)
            cls._instance._initialized = False
        return cls._instance

    def __init__(self):
        if self._initialized:
            return
        self._initialized = True
        self.image_cache = {}
        self.sound_cache = {}
        self.font_cache = {}

    def load_image(self, file_name, use_alpha=True):
        """
        Loads an image, caches it, and returns the pygame.Surface.
        Checks the cache first to avoid reloading.
        """
        if file_name in self.image_cache:
            return self.image_cache[file_name]

        try:
            image = pygame.image.load(file_name).convert()
            if use_alpha:
                image = image.convert_alpha()
            self.image_cache[file_name] = image
            return image
        except pygame.error as e:
            print(f"Error loading image: {file_name}")
            raise SystemExit(e)

    def load_sound(self, file_name):
        """
        Loads a sound, caches it, and returns the pygame.mixer.Sound.
        Checks the cache first to avoid reloading.
        """
        if file_name in self.sound_cache:
            return self.sound_cache[file_name]

        try:
            sound = pygame.mixer.Sound(file_name)
            self.sound_cache[file_name] = sound
            return sound
        except pygame.error as e:
            print(f"Error loading sound: {file_name}")
            raise SystemExit(e)

    def load_font(self, file_name, size):
        """
        Loads a font, caches it, and returns the pygame.font.Font.
        The cache key includes the size to allow multiple sizes of the same font.
        """
        key = (file_name, size)
        if key in self.font_cache:
            return self.font_cache[key]

        try:
            font = pygame.font.Font(file_name, size)
            self.font_cache[key] = font
            return font
        except pygame.error as e:
            print(f"Error loading font: {file_name}")
            raise SystemExit(e)

# Create a single instance of the resource manager for global access
resources = ResourceManager() 