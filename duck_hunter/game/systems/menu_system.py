"""
menu_system.py

Handles all menu states, transitions, and user interface elements.
"""
import pygame
from game.utils import constants as const
from game.systems.background import ParallaxBackground

class Button:
    def __init__(self, x, y, width, height, text, font, callback=None):
        self.rect = pygame.Rect(x, y, width, height)
        self.text = text
        self.font = font
        self.callback = callback
        self.hovered = False
        self.normal_color = (100, 100, 100)
        self.hover_color = (150, 150, 150)
        self.text_color = const.WHITE

    def handle_event(self, event):
        if event.type == pygame.MOUSEBUTTONDOWN:
            if event.button == 1 and self.rect.collidepoint(event.pos):
                if self.callback:
                    self.callback()
                return True
        return False

    def update(self, mouse_pos):
        self.hovered = self.rect.collidepoint(mouse_pos)

    def draw(self, surface):
        color = self.hover_color if self.hovered else self.normal_color
        pygame.draw.rect(surface, color, self.rect)
        pygame.draw.rect(surface, const.WHITE, self.rect, 2)
        
        text_surface = self.font.render(self.text, True, self.text_color)
        text_rect = text_surface.get_rect(center=self.rect.center)
        surface.blit(text_surface, text_rect)

class MenuSystem:
    def __init__(self, screen):
        self.screen = screen
        self.current_state = "main_menu"
        self.background = ParallaxBackground()
        
        # Load font
        try:
            self.font = pygame.font.Font(None, 48)
            self.title_font = pygame.font.Font(None, 72)
        except:
            self.font = pygame.font.Font(None, 48)
            self.title_font = pygame.font.Font(None, 72)
        
        # Initialize buttons for different states
        self.setup_main_menu()
        self.setup_game_over_menu()
        self.setup_settings_menu()
        self.setup_high_scores_menu()
        self.setup_mode_selection_menu()
        
    def setup_main_menu(self):
        """Creates buttons for the main menu."""
        center_x = const.SCREEN_WIDTH // 2
        button_width = 200
        button_height = 50
        button_spacing = 70
        
        self.main_menu_buttons = [
            Button(center_x - button_width//2, 300, button_width, button_height, 
                   "Start Game", self.font, self.start_game),
            Button(center_x - button_width//2, 300 + button_spacing, button_width, button_height, 
                   "Select Mode", self.font, self.show_mode_selection),
            Button(center_x - button_width//2, 300 + button_spacing*2, button_width, button_height, 
                   "High Scores", self.font, self.show_high_scores),
            Button(center_x - button_width//2, 300 + button_spacing*3, button_width, button_height, 
                   "Settings", self.font, self.show_settings),
            Button(center_x - button_width//2, 300 + button_spacing*4, button_width, button_height, 
                   "Quit", self.font, self.quit_game)
        ]
    
    def setup_game_over_menu(self):
        """Creates buttons for the game over screen."""
        center_x = const.SCREEN_WIDTH // 2
        button_width = 200
        button_height = 50
        button_spacing = 70
        
        self.game_over_buttons = [
            Button(center_x - button_width//2, 400, button_width, button_height, 
                   "Play Again", self.font, self.start_game),
            Button(center_x - button_width//2, 400 + button_spacing, button_width, button_height, 
                   "Main Menu", self.font, self.return_to_main_menu),
            Button(center_x - button_width//2, 400 + button_spacing*2, button_width, button_height, 
                   "Quit", self.font, self.quit_game)
        ]

    def setup_settings_menu(self):
        """Creates buttons for the settings menu."""
        center_x = const.SCREEN_WIDTH // 2
        button_width = 200
        button_height = 50
        button_spacing = 70
        
        self.settings_buttons = [
            Button(center_x - button_width//2, 300, button_width, button_height, 
                   "Master Volume: 100%", self.font, self.toggle_volume),
            Button(center_x - button_width//2, 300 + button_spacing, button_width, button_height, 
                   "Graphics: High", self.font, self.toggle_graphics),
            Button(center_x - button_width//2, 300 + button_spacing*2, button_width, button_height, 
                   "Controls: Default", self.font, self.toggle_controls),
            Button(center_x - button_width//2, 300 + button_spacing*3, button_width, button_height, 
                   "Back", self.font, self.return_to_main_menu)
        ]
        
        # Settings state
        self.volume_level = 100
        self.graphics_quality = "High"
        self.controls_preset = "Default"

    def setup_high_scores_menu(self):
        """Creates buttons for the high scores menu."""
        center_x = const.SCREEN_WIDTH // 2
        button_width = 200
        button_height = 50
        
        self.high_scores_buttons = [
            Button(center_x - button_width//2, 500, button_width, button_height, 
                   "Back", self.font, self.return_to_main_menu)
        ]

    def setup_mode_selection_menu(self):
        """Creates buttons for the mode selection menu."""
        center_x = const.SCREEN_WIDTH // 2
        button_width = 250
        button_height = 50
        button_spacing = 70
        
        self.mode_selection_buttons = [
            Button(center_x - button_width//2, 250, button_width, button_height, 
                   "Easy Mode", self.font, lambda: self.select_mode("easy")),
            Button(center_x - button_width//2, 250 + button_spacing, button_width, button_height, 
                   "Normal Mode", self.font, lambda: self.select_mode("normal")),
            Button(center_x - button_width//2, 250 + button_spacing*2, button_width, button_height, 
                   "Hard Mode", self.font, lambda: self.select_mode("hard")),
            Button(center_x - button_width//2, 250 + button_spacing*3, button_width, button_height, 
                   "God Mode", self.font, lambda: self.select_mode("god")),
            Button(center_x - button_width//2, 250 + button_spacing*4, button_width, button_height, 
                   "Back", self.font, self.return_to_main_menu)
        ]

    def handle_event(self, event):
        """Handles events for the current menu state."""
        if self.current_state == "main_menu":
            for button in self.main_menu_buttons:
                if button.handle_event(event):
                    return True
        elif self.current_state == "game_over":
            for button in self.game_over_buttons:
                if button.handle_event(event):
                    return True
        elif self.current_state == "settings":
            for button in self.settings_buttons:
                if button.handle_event(event):
                    return True
        elif self.current_state == "high_scores":
            for button in self.high_scores_buttons:
                if button.handle_event(event):
                    return True
        elif self.current_state == "mode_selection":
            for button in self.mode_selection_buttons:
                if button.handle_event(event):
                    return True
        return False

    def update(self, dt):
        """Updates the current menu state."""
        self.background.update(dt)
        
        mouse_pos = pygame.mouse.get_pos()
        
        if self.current_state == "main_menu":
            for button in self.main_menu_buttons:
                button.update(mouse_pos)
        elif self.current_state == "game_over":
            for button in self.game_over_buttons:
                button.update(mouse_pos)
        elif self.current_state == "settings":
            for button in self.settings_buttons:
                button.update(mouse_pos)
        elif self.current_state == "high_scores":
            for button in self.high_scores_buttons:
                button.update(mouse_pos)
        elif self.current_state == "mode_selection":
            for button in self.mode_selection_buttons:
                button.update(mouse_pos)

    def draw(self, final_score=0):
        """Draws the current menu state."""
        # Draw background
        self.background.draw(self.screen)
        
        if self.current_state == "main_menu":
            self.draw_main_menu()
        elif self.current_state == "game_over":
            self.draw_game_over_menu(final_score)
        elif self.current_state == "settings":
            self.draw_settings_menu()
        elif self.current_state == "high_scores":
            self.draw_high_scores_menu()
        elif self.current_state == "mode_selection":
            self.draw_mode_selection_menu()

    def draw_main_menu(self):
        """Draws the main menu."""
        # Title
        title_text = self.title_font.render("DUCK HUNTER", True, const.WHITE)
        title_rect = title_text.get_rect(center=(const.SCREEN_WIDTH//2, 150))
        
        # Semi-transparent background for title
        bg_rect = title_rect.inflate(40, 20)
        bg_surface = pygame.Surface(bg_rect.size, pygame.SRCALPHA)
        bg_surface.fill((0, 0, 0, 150))
        
        self.screen.blit(bg_surface, bg_rect)
        self.screen.blit(title_text, title_rect)
        
        # Draw buttons
        for button in self.main_menu_buttons:
            button.draw(self.screen)

    def draw_game_over_menu(self, final_score):
        """Draws the game over screen."""
        # Game Over text
        game_over_text = self.title_font.render("GAME OVER", True, const.WHITE)
        game_over_rect = game_over_text.get_rect(center=(const.SCREEN_WIDTH//2, 200))
        
        # Final score
        score_text = self.font.render(f"Final Score: {final_score}", True, const.WHITE)
        score_rect = score_text.get_rect(center=(const.SCREEN_WIDTH//2, 280))
        
        # Semi-transparent backgrounds
        for text, rect in [(game_over_text, game_over_rect), (score_text, score_rect)]:
            bg_rect = rect.inflate(40, 20)
            bg_surface = pygame.Surface(bg_rect.size, pygame.SRCALPHA)
            bg_surface.fill((0, 0, 0, 150))
            self.screen.blit(bg_surface, bg_rect)
            self.screen.blit(text, rect)
        
        # Draw buttons
        for button in self.game_over_buttons:
            button.draw(self.screen)

    def draw_settings_menu(self):
        """Draws the settings menu."""
        # Title
        title_text = self.title_font.render("SETTINGS", True, const.WHITE)
        title_rect = title_text.get_rect(center=(const.SCREEN_WIDTH//2, 150))
        
        # Semi-transparent background for title
        bg_rect = title_rect.inflate(40, 20)
        bg_surface = pygame.Surface(bg_rect.size, pygame.SRCALPHA)
        bg_surface.fill((0, 0, 0, 150))
        
        self.screen.blit(bg_surface, bg_rect)
        self.screen.blit(title_text, title_rect)
        
        # Draw buttons
        for button in self.settings_buttons:
            button.draw(self.screen)

    def draw_high_scores_menu(self):
        """Draws the high scores menu."""
        # Title
        title_text = self.title_font.render("HIGH SCORES", True, const.WHITE)
        title_rect = title_text.get_rect(center=(const.SCREEN_WIDTH//2, 150))
        
        # Semi-transparent background for title
        bg_rect = title_rect.inflate(40, 20)
        bg_surface = pygame.Surface(bg_rect.size, pygame.SRCALPHA)
        bg_surface.fill((0, 0, 0, 150))
        
        self.screen.blit(bg_surface, bg_rect)
        self.screen.blit(title_text, title_rect)
        
        # No scores message
        no_scores_text = self.font.render("No scores yet!", True, const.WHITE)
        no_scores_rect = no_scores_text.get_rect(center=(const.SCREEN_WIDTH//2, 300))
        
        bg_rect2 = no_scores_rect.inflate(40, 20)
        bg_surface2 = pygame.Surface(bg_rect2.size, pygame.SRCALPHA)
        bg_surface2.fill((0, 0, 0, 150))
        
        self.screen.blit(bg_surface2, bg_rect2)
        self.screen.blit(no_scores_text, no_scores_rect)
        
        # Draw buttons
        for button in self.high_scores_buttons:
            button.draw(self.screen)

    def draw_mode_selection_menu(self):
        """Draws the mode selection menu."""
        # Title
        title_text = self.title_font.render("SELECT GAME MODE", True, const.WHITE)
        title_rect = title_text.get_rect(center=(const.SCREEN_WIDTH//2, 150))
        
        # Semi-transparent background for title
        bg_rect = title_rect.inflate(40, 20)
        bg_surface = pygame.Surface(bg_rect.size, pygame.SRCALPHA)
        bg_surface.fill((0, 0, 0, 150))
        
        self.screen.blit(bg_surface, bg_rect)
        self.screen.blit(title_text, title_rect)
        
        # Draw buttons
        for button in self.mode_selection_buttons:
            button.draw(self.screen)
        
        # Draw mode descriptions
        descriptions = [
            "10 lives, 15 ammo - Perfect for beginners",
            "3 lives, 8 ammo - Balanced challenge", 
            "1 life, 5 ammo - Hardcore difficulty",
            "Unlimited lives & ammo - Pure fun mode"
        ]
        
        for i, desc in enumerate(descriptions):
            desc_text = self.font.render(desc, True, const.WHITE)
            desc_rect = desc_text.get_rect(center=(const.SCREEN_WIDTH//2, 300 + i * 70 + 25))
            self.screen.blit(desc_text, desc_rect)

    # Button callbacks
    def start_game(self):
        self.current_state = "playing"
        
    def show_high_scores(self):
        self.current_state = "high_scores"
        
    def show_settings(self):
        self.current_state = "settings"
        
    def show_mode_selection(self):
        self.current_state = "mode_selection"
        
    def select_mode(self, mode):
        """Sets the game mode and starts the game."""
        self.selected_mode = mode
        self.current_state = "playing"
        
    def return_to_main_menu(self):
        self.current_state = "main_menu"
        
    def toggle_volume(self):
        """Cycles through volume levels."""
        volume_levels = [0, 25, 50, 75, 100]
        current_index = volume_levels.index(self.volume_level)
        self.volume_level = volume_levels[(current_index + 1) % len(volume_levels)]
        
        # Update button text
        for button in self.settings_buttons:
            if "Master Volume" in button.text:
                button.text = f"Master Volume: {self.volume_level}%"
                break
                
    def toggle_graphics(self):
        """Cycles through graphics quality levels."""
        graphics_levels = ["Low", "Medium", "High", "Ultra"]
        current_index = graphics_levels.index(self.graphics_quality)
        self.graphics_quality = graphics_levels[(current_index + 1) % len(graphics_levels)]
        
        # Update button text
        for button in self.settings_buttons:
            if "Graphics:" in button.text:
                button.text = f"Graphics: {self.graphics_quality}"
                break
                
    def toggle_controls(self):
        """Cycles through control presets."""
        control_presets = ["Default", "WASD", "Arrow Keys", "Custom"]
        current_index = control_presets.index(self.controls_preset)
        self.controls_preset = control_presets[(current_index + 1) % len(control_presets)]
        
        # Update button text
        for button in self.settings_buttons:
            if "Controls:" in button.text:
                button.text = f"Controls: {self.controls_preset}"
                break
        
    def quit_game(self):
        pygame.quit()
        exit()

    def set_game_over(self, final_score):
        self.current_state = "game_over"
        self.final_score = final_score

    def is_playing(self):
        return self.current_state == "playing"
