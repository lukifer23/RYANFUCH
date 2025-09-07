"""
constants.py

This file contains all the core constants for the Duck Hunter game.
Centralizing these values makes them easy to find, modify, and manage.
Using constants avoids magic numbers and ensures consistency across the codebase.
"""

# Screen dimensions
SCREEN_WIDTH = 1920
SCREEN_HEIGHT = 1080
FPS = 60

# Colors (RGB)
BLACK = (0, 0, 0)
WHITE = (255, 255, 255)

# Game states
MAIN_MENU = "main_menu"
GAMEPLAY = "gameplay"
GAME_OVER = "game_over"

# File paths
ASSETS_PATH = "assets"
SPRITES_PATH = f"{ASSETS_PATH}/sprites"
AUDIO_PATH = f"{ASSETS_PATH}/audio"
FONTS_PATH = f"{ASSETS_PATH}/fonts"
DATA_PATH = f"{ASSETS_PATH}/data"
SAVES_PATH = "saves"
CONFIG_PATH = "config"
SETTINGS_FILE = f"{CONFIG_PATH}/settings.json"
KEYBINDS_FILE = f"{CONFIG_PATH}/keybinds.json" 