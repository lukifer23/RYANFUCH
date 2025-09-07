"""
ui.py

Handles the rendering and logic for all User Interface elements,
such as menus, HUD, and score displays.
"""
import pygame
from game.utils import constants as const
from game.core.resource_manager import resources
import os

class UISystem:
    def __init__(self):
        self.font = None
        self.small_font = None
        try:
            # In a real scenario, you'd have a .ttf file in your assets/fonts folder
            font_path = os.path.join(const.FONTS_PATH, "default_font.ttf")
            self.font = resources.load_font(font_path, 36)
            self.small_font = resources.load_font(font_path, 24)
        except Exception:
            # Fallback to Pygame's default font if the custom one fails
            print("Default font not found. Falling back to pygame default.")
            self.font = pygame.font.Font(None, 48)
            self.small_font = pygame.font.Font(None, 32)
        
        # FPS tracking
        self.fps_history = []
        self.fps_display = 60

    def draw_score(self, surface, score):
        """Renders the current score to the screen."""
        score_text = f"Score: {score}"
        text_surface = self.font.render(score_text, True, const.WHITE)
        text_rect = text_surface.get_rect(topleft=(20, 20))
        surface.blit(text_surface, text_rect)

    def draw_lives(self, surface, lives):
        """Renders the current lives to the screen."""
        if lives == float('inf'):
            lives_text = "Lives: ∞"
        else:
            lives_text = f"Lives: {lives}"
        text_surface = self.font.render(lives_text, True, const.WHITE)
        text_rect = text_surface.get_rect(topright=(const.SCREEN_WIDTH - 20, 20))
        surface.blit(text_surface, text_rect)

    def draw_ammo(self, surface, weapon_data):
        """Renders the current ammo status to the screen."""
        if weapon_data.current_ammo == float('inf') or weapon_data.ammo_capacity == float('inf'):
            ammo_text = "Ammo: ∞"
        else:
            ammo_text = f"Ammo: {weapon_data.current_ammo}/{weapon_data.ammo_capacity}"
        
        if weapon_data.is_reloading and weapon_data.current_ammo != float('inf'):
            ammo_text = "Reloading..."
        
        text_surface = self.font.render(ammo_text, True, const.WHITE)
        text_rect = text_surface.get_rect(bottomleft=(20, const.SCREEN_HEIGHT - 20))
        surface.blit(text_surface, text_rect)

    def draw_game_mode(self, surface, game_mode):
        """Renders the current game mode to the screen."""
        mode_text = f"Mode: {game_mode.upper()}"
        text_surface = self.font.render(mode_text, True, const.WHITE)
        text_rect = text_surface.get_rect(bottomright=(const.SCREEN_WIDTH - 20, const.SCREEN_HEIGHT - 20))
        surface.blit(text_surface, text_rect)

    def draw_timer(self, surface, elapsed_time, time_limit):
        """Renders the timer for God Mode."""
        if time_limit > 0:
            remaining_time = max(0, time_limit - elapsed_time)
            minutes = int(remaining_time // 60)
            seconds = int(remaining_time % 60)
            timer_text = f"Time: {minutes:02d}:{seconds:02d}"
            
            # Color changes as time runs out
            if remaining_time < 30:
                color = (255, 100, 100)  # Red when time is low
            elif remaining_time < 60:
                color = (255, 255, 100)  # Yellow when time is medium
            else:
                color = const.WHITE
            
            text_surface = self.small_font.render(timer_text, True, color)
            text_rect = text_surface.get_rect(bottomright=(const.SCREEN_WIDTH - 20, const.SCREEN_HEIGHT - 60))
            
            # Add background for better readability
            bg_rect = text_rect.inflate(8, 4)
            bg_surface = pygame.Surface(bg_rect.size, pygame.SRCALPHA)
            bg_surface.fill((0, 0, 0, 100))
            
            surface.blit(bg_surface, bg_rect)
            surface.blit(text_surface, text_rect)

    def update_fps(self, dt):
        """Updates the FPS counter with smooth averaging."""
        if dt > 0:
            current_fps = 1.0 / dt
            self.fps_history.append(current_fps)
            
            # Keep only last 30 frames for smooth averaging
            if len(self.fps_history) > 30:
                self.fps_history.pop(0)
            
            # Calculate average FPS
            self.fps_display = sum(self.fps_history) / len(self.fps_history)

    def draw_fps(self, surface):
        """Renders the FPS counter in a tasteful way."""
        fps_text = f"FPS: {int(self.fps_display)}"
        text_surface = self.small_font.render(fps_text, True, const.WHITE)
        
        # Position in top-left corner, below the score
        text_rect = text_surface.get_rect(topleft=(20, 60))
        
        # Add a subtle background for better readability
        bg_rect = text_rect.inflate(8, 4)
        bg_surface = pygame.Surface(bg_rect.size, pygame.SRCALPHA)
        bg_surface.fill((0, 0, 0, 100))
        
        surface.blit(bg_surface, bg_rect)
        surface.blit(text_surface, text_rect)

    def update(self, dt, game_state):
        """Updates UI elements based on game state."""
        self.update_fps(dt)

    def draw(self, surface, player_data, elapsed_time=0, time_limit=0):
        """Renders all UI elements."""
        self.draw_score(surface, player_data.score)
        self.draw_fps(surface)
        self.draw_lives(surface, player_data.lives)
        self.draw_ammo(surface, player_data.weapon)
        self.draw_game_mode(surface, player_data.game_mode)
        self.draw_timer(surface, elapsed_time, time_limit) 