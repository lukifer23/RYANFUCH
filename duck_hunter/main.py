"""
main.py

The main entry point for the Duck Hunter game.
This file is responsible for initializing Pygame, creating the game window,
and running the main game loop.
"""

import pygame
import sys
import os
import random

# To run this from the root directory, we need to add the project root to the python path.
# This is a temporary solution for development. A better solution would be to package the game properly.
sys.path.insert(0, os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from game.utils import constants as const
from game.core.resource_manager import resources
from game.entities.duck import Duck
from game.entities.ground_animal import GroundAnimal
from game.systems.background import ParallaxBackground
from game.systems.particles import ParticleSystem
from game.core.audio_manager import audio_manager
from game.entities.player import Player
from game.systems.ui import UISystem
from game.systems.menu_system import MenuSystem

class Crosshair(pygame.sprite.Sprite):
    def __init__(self):
        super().__init__()
        # Scale crosshair size based on display scaling
        crosshair_size = int(60 * const.UI_SCALE)
        self.image = pygame.Surface((crosshair_size, crosshair_size), pygame.SRCALPHA)
        
        center = crosshair_size // 2
        
        # Draw a more visible crosshair with larger hit area
        # Outer circle (thick) - shows hit radius
        outer_radius = int(25 * const.UI_SCALE)
        pygame.draw.circle(self.image, (255, 255, 255), (center, center), outer_radius, max(1, int(2 * const.UI_SCALE)))
        
        # Inner circle (thin)
        inner_radius = int(15 * const.UI_SCALE)
        pygame.draw.circle(self.image, (255, 255, 255), (center, center), inner_radius, max(1, int(1 * const.UI_SCALE)))
        
        # Cross lines (longer for better visibility)
        line_width = max(1, int(2 * const.UI_SCALE))
        pygame.draw.line(self.image, (255, 255, 255), (center, 0), (center, int(12 * const.UI_SCALE)), line_width)
        pygame.draw.line(self.image, (255, 255, 255), (center, crosshair_size - int(12 * const.UI_SCALE)), (center, crosshair_size), line_width)
        pygame.draw.line(self.image, (255, 255, 255), (0, center), (int(12 * const.UI_SCALE), center), line_width)
        pygame.draw.line(self.image, (255, 255, 255), (crosshair_size - int(12 * const.UI_SCALE), center), (crosshair_size, center), line_width)
        
        # Center dot
        pygame.draw.circle(self.image, (255, 255, 255), (center, center), max(1, int(3 * const.UI_SCALE)))
        
        # Hit radius indicator (semi-transparent)
        hit_indicator_size = int(50 * const.UI_SCALE)
        hit_indicator = pygame.Surface((hit_indicator_size, hit_indicator_size), pygame.SRCALPHA)
        hit_indicator_center = hit_indicator_size // 2
        hit_indicator_radius = int(20 * const.UI_SCALE)
        pygame.draw.circle(hit_indicator, (255, 255, 255, 50), (hit_indicator_center, hit_indicator_center), hit_indicator_radius, max(1, int(1 * const.UI_SCALE)))
        
        self.rect = self.image.get_rect()
        self.hit_radius = int(25 * const.UI_SCALE)  # Larger hit detection radius for easier targeting
        self.hit_indicator = hit_indicator

    def update(self, *args):
        self.rect.center = pygame.mouse.get_pos()
        
    def draw(self, screen, flash_timer=0, show_hit_radius=False):
        """Draw the crosshair with optional flash effect and hit radius indicator."""
        if flash_timer > 0:
            # Flash effect - draw a bright version
            flash_image = self.image.copy()
            # Make it brighter/red for hit feedback
            flash_image.fill((255, 100, 100, 255), special_flags=pygame.BLEND_MULT)
            screen.blit(flash_image, self.rect)
        else:
            screen.blit(self.image, self.rect)
            
        # Show hit radius indicator when aiming at a target
        if show_hit_radius:
            hit_rect = self.hit_indicator.get_rect(center=self.rect.center)
            screen.blit(self.hit_indicator, hit_rect)

class DuckSpawnManager:
    def __init__(self, sprite_group, player):
        self.sprite_group = sprite_group
        self.player = player
        self.spawn_timer = 0
        self.base_spawn_interval = 2.0  # seconds

    def update(self, dt, score=0):
        # Decrease spawn interval and increase speed based on score
        spawn_interval = max(0.5, self.base_spawn_interval - (score / 5000))
        
        self.spawn_timer += dt
        if self.spawn_timer >= spawn_interval:
            self.spawn_timer = 0
            self.spawn_duck(score)

    def spawn_duck(self, score=0):
        # Spawn from the left side at a random height
        y_pos = random.randint(50, const.SCREEN_HEIGHT - 200)
        
        # Choose duck type based on weighted probability
        duck_type = self.choose_duck_type()
        new_duck = Duck(initial_pos=(-50, y_pos), duck_type=duck_type)
        
        # Increase duck speed based on score
        speed_bonus = (score / 100)
        new_duck.speed += speed_bonus

        self.sprite_group.add(new_duck)
        
    def choose_duck_type(self):
        """Chooses a duck type based on weighted probability."""
        # Duck type weights (higher score = more rare ducks)
        duck_types = ["common", "rare", "golden", "boss"]
        weights = [60, 25, 10, 5]  # Base weights
        
        # Adjust weights based on score (more rare ducks at higher scores)
        score_bonus = min(20, self.player.score / 1000)  # Cap at 20% bonus
        weights[1] = min(35, weights[1] + score_bonus)  # Rare ducks
        weights[2] = min(20, weights[2] + score_bonus * 0.5)  # Golden ducks
        weights[3] = min(10, weights[3] + score_bonus * 0.3)  # Boss ducks
        
        # Normalize weights
        total_weight = sum(weights)
        weights = [w / total_weight for w in weights]
        
        return random.choices(duck_types, weights=weights)[0]

class GroundAnimalSpawnManager:
    def __init__(self, sprite_group, player):
        self.sprite_group = sprite_group
        self.player = player
        self.spawn_timer = 0
        self.base_spawn_interval = 2.5  # seconds (more frequent than before)

    def update(self, dt, score=0):
        # Decrease spawn interval based on score (more aggressive)
        spawn_interval = max(0.8, self.base_spawn_interval - (score / 5000))
        
        self.spawn_timer += dt
        if self.spawn_timer >= spawn_interval:
            self.spawn_timer = 0
            self.spawn_ground_animal(score)

    def spawn_ground_animal(self, score=0):
        # Choose animal type based on weighted probability
        animal_type = self.choose_animal_type(score)
        new_animal = GroundAnimal(animal_type=animal_type)
        
        # Increase speed based on score
        speed_bonus = (score / 200)
        new_animal.speed += speed_bonus

        self.sprite_group.add(new_animal)
        
    def choose_animal_type(self, score):
        """Chooses an animal type based on weighted probability."""
        animal_types = ["rabbit", "deer", "wolf", "moose", "bear", "dinosaur"]
        weights = [40, 30, 25, 20, 10, 15]  # Base weights
        
        # Adjust weights based on score (more rare animals at higher scores)
        score_bonus = min(25, score / 3000)  # Cap at 25% bonus
        weights[3] = min(35, weights[3] + score_bonus)  # Moose
        weights[4] = min(20, weights[4] + score_bonus * 0.8)  # Bear
        weights[5] = min(25, weights[5] + score_bonus * 0.6)  # Dinosaur
        
        # Normalize weights
        total_weight = sum(weights)
        weights = [w / total_weight for w in weights]
        
        return random.choices(animal_types, weights=weights)[0]

class Game:
    """
    The main Game class that orchestrates the entire game.
    """
    def __init__(self):
        """
        Initializes the game, sets up the window, and prepares game resources.
        """
        pygame.init()
        self.screen = pygame.display.set_mode((const.SCREEN_WIDTH, const.SCREEN_HEIGHT))
        pygame.display.set_caption("Duck Hunter")
        self.clock = pygame.time.Clock()
        self.is_running = True
        self.dt = 0

        # Initialize managers
        self.resource_manager = resources
        
        # Create sprite groups
        self.all_sprites = pygame.sprite.Group()
        self.crosshair_group = pygame.sprite.GroupSingle()
        
        # Create initial game objects
        self.crosshair = Crosshair()
        self.crosshair_group.add(self.crosshair)

        # Create player first (default to normal mode)
        self.player = Player("normal")
        self.selected_mode = "normal"  # Default mode

        # Create managers
        self.duck_spawn_manager = DuckSpawnManager(self.all_sprites, self.player)
        self.ground_animal_spawn_manager = GroundAnimalSpawnManager(self.all_sprites, self.player)
        self.background = ParallaxBackground()
        self.particle_system = ParticleSystem()
        self.audio_manager = audio_manager
        self.ui_system = UISystem()
        self.menu_system = MenuSystem(self.screen)

        # Game State
        self.paused = False
        self.crosshair_flash_timer = 0
        self.game_start_time = 0
        self.god_mode_time_limit = 300  # 5 minutes for God Mode
        
        # Show cursor initially (we're in menu mode)
        pygame.mouse.set_visible(True)

    def run(self):
        """
        The main game loop.
        Handles events, updates game state, and renders the screen.
        """
        while self.is_running:
            self.handle_events()
            
            # Check if a new game mode was selected
            if hasattr(self.menu_system, 'selected_mode') and self.menu_system.selected_mode:
                self.start_new_game(self.menu_system.selected_mode)
                self.menu_system.selected_mode = None  # Clear the selection
            
            if self.menu_system.is_playing() and not self.paused:
                self.update()
            
            self.render()

            # Cap the frame rate and get delta time.
            # dt is time in seconds since the last frame.
            self.dt = self.clock.tick(const.FPS) / 1000.0

        self.quit_game()

    def handle_events(self):
        """
        Processes all events from the Pygame event queue.
        """
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                self.is_running = False
            elif event.type == pygame.KEYDOWN:
                if event.key == pygame.K_p or event.key == pygame.K_SPACE:
                    if self.menu_system.is_playing():
                        self.paused = not self.paused
                        print(f"Game {'PAUSED' if self.paused else 'UNPAUSED'}")
                elif event.key == pygame.K_r:
                    if self.menu_system.is_playing() and not self.paused:
                        self.player.weapon.start_reload()
                elif event.key == pygame.K_ESCAPE:
                    if self.menu_system.is_playing():
                        if self.paused:
                            # If already paused, ESC quits the game
                            self.menu_system.set_game_over(self.player.score)
                            self.reset_game()
                            print("Game quit via ESC key")
                        else:
                            # If not paused, ESC pauses the game
                            self.paused = not self.paused
                            print(f"Game {'PAUSED' if self.paused else 'UNPAUSED'}")
            
            # Handle menu events
            if not self.menu_system.is_playing():
                pygame.mouse.set_visible(True)  # Show cursor in menus
                self.menu_system.handle_event(event)
            elif not self.paused:
                pygame.mouse.set_visible(False)  # Hide cursor during gameplay
                # Handle game events
                if event.type == pygame.MOUSEBUTTONDOWN:
                    if event.button == 1: # Left mouse button
                        self.shoot()
                elif event.type == pygame.USEREVENT:
                    if 'duck' in event.dict:
                        self.player.lose_life()
                        if self.player.lives <= 0:
                            self.menu_system.set_game_over(self.player.score)
                            self.reset_game()

    def shoot(self):
        """
        Handles the shooting logic. Checks for collisions between the crosshair
        and any targets (ducks or ground animals).
        """
        if self.player.weapon.shoot():
            self.audio_manager.play_sound("shotgun.wav")
            
            # Get mouse position for hit detection
            mouse_pos = pygame.mouse.get_pos()
            
            # Check for hits using distance-based detection (more forgiving)
            hit_targets = []
            for sprite in self.all_sprites:
                # Check ducks
                if hasattr(sprite, 'state') and sprite.state == "flying":
                    # Calculate distance from mouse to duck center
                    sprite_center = sprite.rect.center
                    distance = ((mouse_pos[0] - sprite_center[0])**2 + (mouse_pos[1] - sprite_center[1])**2)**0.5
                    
                    # Hit if within hit radius
                    if distance <= self.crosshair.hit_radius:
                        hit_targets.append(sprite)
                
                # Check ground animals
                elif hasattr(sprite, 'animal_type') and sprite.state == "walking":
                    # Calculate distance from mouse to animal center
                    sprite_center = sprite.rect.center
                    distance = ((mouse_pos[0] - sprite_center[0])**2 + (mouse_pos[1] - sprite_center[1])**2)**0.5
                    
                    # Hit if within hit radius
                    if distance <= self.crosshair.hit_radius:
                        hit_targets.append(sprite)
            
            # Process hits
            if hit_targets:
                # Hit the closest target if multiple are in range
                closest_target = min(hit_targets, key=lambda t: 
                    ((mouse_pos[0] - t.rect.center[0])**2 + (mouse_pos[1] - t.rect.center[1])**2)**0.5)
                
                # Handle different target types
                if hasattr(closest_target, 'duck_type'):  # It's a duck
                    closest_target.shoot_down()
                    self.particle_system.emit_feathers(closest_target.rect.center)
                    self.audio_manager.play_sound("hit.wav")
                    print(f"Hit! {closest_target.duck_type.title()} duck: +{closest_target.point_value} points")
                elif hasattr(closest_target, 'animal_type'):  # It's a ground animal
                    closest_target.shoot_hit()
                    self.audio_manager.play_sound("hit.wav")
                    print(f"Hit! {closest_target.animal_type.title()}: +{closest_target.point_value} points")
                
                self.player.add_score(closest_target.point_value)
                
                # Visual feedback - flash the crosshair
                self.crosshair_flash_timer = 0.1
            else:
                print("Miss!")
        else:
            # Optionally play an empty click sound here
            self.audio_manager.play_sound("empty_click.wav")
            print("Click! Out of ammo.")

    def update(self):
        """
        Updates the state of all game objects.
        The delta time (self.dt) is used to ensure frame-rate independent physics.
        """
        if self.menu_system.is_playing():
            self.background.update(self.dt)
            self.all_sprites.update(self.dt)
            self.crosshair_group.update()
            self.duck_spawn_manager.update(self.dt, self.player.score)
            self.ground_animal_spawn_manager.update(self.dt, self.player.score)
            self.particle_system.update(self.dt)
            self.player.update(self.dt)
            self.ui_system.update(self.dt, "playing")
            
            # Update crosshair flash timer
            if self.crosshair_flash_timer > 0:
                self.crosshair_flash_timer -= self.dt
            
            # Check for God Mode time limit
            if self.player.game_mode == "god":
                current_time = pygame.time.get_ticks() / 1000.0
                elapsed_time = current_time - self.game_start_time
                if elapsed_time >= self.god_mode_time_limit:
                    self.menu_system.set_game_over(self.player.score)
                    self.reset_game()
                    print(f"God Mode time limit reached! Final score: {self.player.score}")
        else:
            self.menu_system.update(self.dt)

    def render(self):
        """
        Draws all game objects to the screen.
        """
        if self.menu_system.is_playing():
            self.screen.fill(const.BLACK)
            self.background.draw(self.screen)
            self.all_sprites.draw(self.screen)
            self.particle_system.draw(self.screen)
            
            # Draw crosshair with flash effect
            self.crosshair.draw(self.screen, self.crosshair_flash_timer)
            
            # Calculate elapsed time for timer display
            current_time = pygame.time.get_ticks() / 1000.0
            elapsed_time = current_time - self.game_start_time
            time_limit = self.god_mode_time_limit if self.player.game_mode == "god" else 0
            
            self.ui_system.draw(self.screen, self.player, elapsed_time, time_limit)
            
            if self.paused:
                self.draw_paused()
        else:
            # Draw menu
            self.menu_system.draw(self.player.score)

        pygame.display.flip()  # Update the full display

    def start_new_game(self, mode="normal"):
        """Starts a new game with the specified mode."""
        # Clear all sprites
        self.all_sprites.empty()
        
        # Create new player with selected mode
        self.player = Player(mode)
        self.selected_mode = mode
        
        # Reset managers
        self.duck_spawn_manager = DuckSpawnManager(self.all_sprites, self.player)
        self.ground_animal_spawn_manager = GroundAnimalSpawnManager(self.all_sprites, self.player)
        self.particle_system = ParticleSystem()
        
        # Start game timer
        self.game_start_time = pygame.time.get_ticks() / 1000.0
        
        print(f"Starting new game in {mode.upper()} mode!")

    def reset_game(self):
        """Resets the game state for a new game."""
        # Clear all sprites
        self.all_sprites.empty()
        
        # Reset player (keep current game mode)
        current_mode = self.player.game_mode
        self.player = Player(current_mode)
        
        # Reset managers
        self.duck_spawn_manager = DuckSpawnManager(self.all_sprites, self.player)
        self.ground_animal_spawn_manager = GroundAnimalSpawnManager(self.all_sprites, self.player)
        self.particle_system = ParticleSystem()

    def draw_paused(self):
        """Draws the paused screen."""
        font = self.ui_system.font
        title_font = pygame.font.Font(None, 72)
        
        # Main paused text
        paused_text = title_font.render("PAUSED", True, const.WHITE)
        paused_rect = paused_text.get_rect(center=(const.SCREEN_WIDTH / 2, const.SCREEN_HEIGHT / 2 - 50))
        
        # Instructions
        instructions = [
            "Press P, SPACE, or ESC to resume",
            "Press R to reload",
            "Click to shoot",
            "Press ESC again to quit game"
        ]
        
        # Create semi-transparent overlay
        overlay = pygame.Surface((const.SCREEN_WIDTH, const.SCREEN_HEIGHT), pygame.SRCALPHA)
        overlay.fill((0, 0, 0, 128))
        self.screen.blit(overlay, (0, 0))
        
        # Draw paused text with background
        bg_rect = paused_rect.inflate(40, 20)
        bg_surf = pygame.Surface(bg_rect.size, pygame.SRCALPHA)
        bg_surf.fill((0, 0, 0, 200))
        self.screen.blit(bg_surf, bg_rect)
        self.screen.blit(paused_text, paused_rect)
        
        # Draw instructions
        for i, instruction in enumerate(instructions):
            text_surface = font.render(instruction, True, const.WHITE)
            text_rect = text_surface.get_rect(center=(const.SCREEN_WIDTH / 2, const.SCREEN_HEIGHT / 2 + 20 + i * 30))
            self.screen.blit(text_surface, text_rect)

    def quit_game(self):
        """
        Cleans up and exits the game.
        """
        pygame.quit()
        sys.exit()

if __name__ == '__main__':
    # Change working directory to the project root to ensure assets are found
    # This ensures that relative paths for assets work correctly.
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    os.chdir('..')
    game = Game()
    game.run() 