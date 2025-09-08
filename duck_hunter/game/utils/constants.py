"""
constants.py

This file contains all the core constants for the Duck Hunter game.
Centralizing these values makes them easy to find, modify, and manage.
Using constants avoids magic numbers and ensures consistency across the codebase.
"""

import pygame

# Base design resolution (what the game was designed for)
DESIGN_WIDTH = 1920
DESIGN_HEIGHT = 1080

# Get actual screen size and calculate scaling
def get_display_info():
    """Get the actual display resolution and calculate scaling factors."""
    pygame.init()
    display_info = pygame.display.Info()
    
    # Get the actual screen resolution
    actual_width = display_info.current_w
    actual_height = display_info.current_h
    
    # Calculate scaling factors
    scale_x = actual_width / DESIGN_WIDTH
    scale_y = actual_height / DESIGN_HEIGHT
    
    # Use the smaller scale to maintain aspect ratio
    scale = min(scale_x, scale_y)
    
    # Calculate scaled resolution (maintaining aspect ratio)
    scaled_width = int(DESIGN_WIDTH * scale)
    scaled_height = int(DESIGN_HEIGHT * scale)
    
    return {
        'actual_width': actual_width,
        'actual_height': actual_height,
        'scaled_width': scaled_width,
        'scaled_height': scaled_height,
        'scale_x': scale_x,
        'scale_y': scale_y,
        'scale': scale
    }

# Initialize display info
DISPLAY_INFO = get_display_info()

# Screen dimensions (scaled to fit the actual display)
SCREEN_WIDTH = DISPLAY_INFO['scaled_width']
SCREEN_HEIGHT = DISPLAY_INFO['scaled_height']

# Scaling factors for UI elements
UI_SCALE = DISPLAY_INFO['scale']

# FPS
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