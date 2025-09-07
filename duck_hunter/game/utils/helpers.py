"""
helpers.py

A collection of general-purpose helper functions that don't fit
into other specific utility modules.
"""

import pygame

def clamp(value, min_val, max_val):
    """Clamps a value between a minimum and maximum."""
    return max(min_val, min(value, max_val))

def load_sprite_sheet(sheet, frame_width, frame_height, num_frames):
    """
    Extracts frames from a sprite sheet.
    
    :param sheet: The sprite sheet surface.
    :param frame_width: The width of a single frame.
    :param frame_height: The height of a single frame.
    :param num_frames: The total number of frames to extract.
    :return: A list of surfaces, each being a single frame.
    """
    frames = []
    sheet_width, sheet_height = sheet.get_size()
    
    for i in range(num_frames):
        frame_x = (i % (sheet_width // frame_width)) * frame_width
        frame_y = (i // (sheet_width // frame_width)) * frame_height
        
        # Ensure we don't try to grab a frame that's out of bounds
        if frame_y + frame_height > sheet_height:
            break
            
        rect = pygame.Rect(frame_x, frame_y, frame_width, frame_height)
        frame = pygame.Surface(rect.size, pygame.SRCALPHA)
        frame.blit(sheet, (0, 0), rect)
        frames.append(frame)
        
    return frames

# TODO: Add more helper functions as needed 