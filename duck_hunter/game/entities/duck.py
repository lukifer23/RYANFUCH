"""
duck.py

This module defines the Duck entity, including its behavior, animation,
and interactions within the game.
"""
import pygame
import os
from game.core.resource_manager import resources
from game.utils.helpers import load_sprite_sheet
from game.core.animation import Animation
from game.utils import constants as const
import math
import random
import json

class Duck(pygame.sprite.Sprite):
    def __init__(self, initial_pos, duck_type="common"):
        super().__init__()
        
        # Duck type properties
        self.duck_type = duck_type
        self.type_data = self.get_duck_type_data(duck_type)
        
        # --- Data-Driven Asset Loading ---
        self.load_assets()
        
        # Set initial animation
        self.set_animation("fly")
        
        self.rect = self.image.get_rect(center=initial_pos)
        self.pos = pygame.math.Vector2(self.rect.center)
        
        # State machine
        self.state = "flying" # "flying", "falling"
        
        # AI properties (based on duck type)
        self.speed = random.uniform(self.type_data["speed_range"][0], self.type_data["speed_range"][1])
        self.amplitude = random.uniform(self.type_data["amplitude_range"][0], self.type_data["amplitude_range"][1])
        self.frequency = random.uniform(self.type_data["frequency_range"][0], self.type_data["frequency_range"][1])
        self.initial_y = initial_pos[1]
        
        # Physics properties
        self.fall_speed = 0
        
        # Store point value
        self.point_value = self.type_data["points"]

    def get_duck_type_data(self, duck_type):
        """Returns the data for a specific duck type."""
        duck_types = {
            "common": {
                "points": 100,
                "speed_range": (150, 250),
                "amplitude_range": (20, 60),
                "frequency_range": (0.01, 0.02),
                "spawn_weight": 60,  # 60% chance
                "color_scheme": 0  # Brown duck
            },
            "rare": {
                "points": 500,
                "speed_range": (200, 350),
                "amplitude_range": (30, 80),
                "frequency_range": (0.015, 0.025),
                "spawn_weight": 25,  # 25% chance
                "color_scheme": 1  # Gray duck
            },
            "golden": {
                "points": 1000,
                "speed_range": (300, 450),
                "amplitude_range": (40, 100),
                "frequency_range": (0.02, 0.03),
                "spawn_weight": 10,  # 10% chance
                "color_scheme": 2  # Golden duck
            },
            "boss": {
                "points": 2000,
                "speed_range": (100, 200),
                "amplitude_range": (10, 30),
                "frequency_range": (0.005, 0.01),
                "spawn_weight": 5,  # 5% chance
                "color_scheme": 3  # Green duck
            }
        }
        return duck_types.get(duck_type, duck_types["common"])

    def load_assets(self):
        """Loads duck assets and animations based on animations.json."""
        try:
            with open(os.path.join(const.CONFIG_PATH, "animations.json")) as f:
                anim_data = json.load(f)["duck"]
            
            sprite_sheet_path = os.path.join(const.SPRITES_PATH, anim_data["sprite_sheet"])
            sprite_sheet = resources.load_image(sprite_sheet_path)
            frame_size = anim_data["frame_size"]
            
            self.animations = {}
            for name, data in anim_data["animations"].items():
                all_frames = load_sprite_sheet(sprite_sheet, frame_size[0], frame_size[1], sum(len(d["frames"]) for d in anim_data["animations"].values()))
                anim_frames = [all_frames[i] for i in data["frames"]]
                self.animations[name] = Animation(anim_frames, data["duration"], data["loop"])
            print("Loaded duck assets from animations.json")
            
        except (pygame.error, FileNotFoundError, KeyError):
            print("Could not load assets from config. Using procedural placeholder.")
            self.animations = {
                "fly": Animation(self.create_procedural_duck_fly(), 0.2, True),
                "fall": Animation(self.create_procedural_duck_fall(), 1.0, False)
            }

    def set_animation(self, name):
        """Sets the current animation and updates the image."""
        self.current_animation_name = name
        self.animation = self.animations[name]
        self.animation.reset()
        self.image = self.animation.get_current_frame()

    def create_procedural_duck_fly(self):
        """Creates detailed duck sprites with flapping animation."""
        # Choose colors based on duck type
        duck_types = [
            {"body": (139, 69, 19), "head": (160, 82, 45), "wing": (222, 184, 135), "beak": (255, 165, 0), "eye": (0, 0, 0)},  # Brown duck
            {"body": (105, 105, 105), "head": (128, 128, 128), "wing": (192, 192, 192), "beak": (255, 140, 0), "eye": (0, 0, 0)},  # Gray duck
            {"body": (255, 215, 0), "head": (255, 223, 0), "wing": (255, 239, 0), "beak": (255, 69, 0), "eye": (0, 0, 0)},  # Golden duck
            {"body": (0, 100, 0), "head": (0, 128, 0), "wing": (144, 238, 144), "beak": (255, 20, 147), "eye": (0, 0, 0)}   # Green duck
        ]
        
        colors = duck_types[self.type_data["color_scheme"]]
        
        # Frame 1: Wings up
        frame1 = pygame.Surface((48, 32), pygame.SRCALPHA)
        # Body (main ellipse)
        pygame.draw.ellipse(frame1, colors["body"], (4, 12, 32, 16))
        # Head
        pygame.draw.circle(frame1, colors["head"], (36, 12), 8)
        # Wing (up position)
        pygame.draw.ellipse(frame1, colors["wing"], (12, 8, 16, 12))
        # Beak
        pygame.draw.polygon(frame1, colors["beak"], [(44, 12), (48, 10), (48, 14)])
        # Eye
        pygame.draw.circle(frame1, colors["eye"], (38, 9), 2)
        # Wing detail
        wing_detail_color = (max(0, colors["wing"][0]-20), max(0, colors["wing"][1]-20), max(0, colors["wing"][2]-20))
        pygame.draw.ellipse(frame1, wing_detail_color, (14, 10, 12, 8))
        
        # Frame 2: Wings down
        frame2 = pygame.Surface((48, 32), pygame.SRCALPHA)
        # Body (main ellipse)
        pygame.draw.ellipse(frame2, colors["body"], (4, 12, 32, 16))
        # Head
        pygame.draw.circle(frame2, colors["head"], (36, 12), 8)
        # Wing (down position)
        pygame.draw.ellipse(frame2, colors["wing"], (12, 16, 16, 12))
        # Beak
        pygame.draw.polygon(frame2, colors["beak"], [(44, 12), (48, 10), (48, 14)])
        # Eye
        pygame.draw.circle(frame2, colors["eye"], (38, 9), 2)
        # Wing detail
        wing_detail_color = (max(0, colors["wing"][0]-20), max(0, colors["wing"][1]-20), max(0, colors["wing"][2]-20))
        pygame.draw.ellipse(frame2, wing_detail_color, (14, 18, 12, 8))

        return [frame1, frame2]

    def create_procedural_duck_fall(self):
        """Creates a falling duck with X eyes."""
        frame = pygame.Surface((48, 32), pygame.SRCALPHA)
        # Use the same colors as the flying duck
        duck_types = [
            {"body": (139, 69, 19), "head": (160, 82, 45), "wing": (222, 184, 135), "beak": (255, 165, 0), "eye": (0, 0, 0)},  # Brown duck
            {"body": (105, 105, 105), "head": (128, 128, 128), "wing": (192, 192, 192), "beak": (255, 140, 0), "eye": (0, 0, 0)},  # Gray duck
            {"body": (255, 215, 0), "head": (255, 223, 0), "wing": (255, 239, 0), "beak": (255, 69, 0), "eye": (0, 0, 0)},  # Golden duck
            {"body": (0, 100, 0), "head": (0, 128, 0), "wing": (144, 238, 144), "beak": (255, 20, 147), "eye": (0, 0, 0)}   # Green duck
        ]
        
        colors = duck_types[self.type_data["color_scheme"]]
        
        # Body (main ellipse)
        pygame.draw.ellipse(frame, colors["body"], (4, 12, 32, 16))
        # Head
        pygame.draw.circle(frame, colors["head"], (36, 12), 8)
        # Wings (spread out for falling)
        pygame.draw.ellipse(frame, colors["wing"], (8, 10, 20, 8))
        pygame.draw.ellipse(frame, colors["wing"], (8, 16, 20, 8))
        # Beak
        pygame.draw.polygon(frame, colors["beak"], [(44, 12), (48, 10), (48, 14)])
        # X eyes (dead)
        pygame.draw.line(frame, (255, 0, 0), (34, 8), (38, 12), 2)
        pygame.draw.line(frame, (255, 0, 0), (38, 8), (34, 12), 2)
        
        return [frame]

    def update(self, dt):
        """Updates the duck's animation and position based on its state."""
        if self.state == "flying":
            self.fly(dt)
        elif self.state == "falling":
            self.fall(dt)

        self.animation.update(dt)
        self.image = self.animation.get_current_frame()

    def fly(self, dt):
        """Handles the 'flying' state logic."""
        # Horizontal movement
        self.pos.x += self.speed * dt
        # Vertical sine wave movement
        self.pos.y = self.initial_y + self.amplitude * math.sin(self.frequency * self.pos.x)
        self.rect.center = self.pos

        # Despawn if it flies off-screen and post an event
        if self.rect.left > const.SCREEN_WIDTH:
            pygame.event.post(pygame.event.Event(pygame.USEREVENT, {'duck': self}))
            self.kill()
    
    def fall(self, dt):
        """Handles the 'falling' state logic."""
        # Apply gravity
        gravity = 980  # Pixels per second squared
        self.fall_speed += gravity * dt
        self.pos.y += self.fall_speed * dt
        
        # Simple rotation effect
        angle = min(90, self.fall_speed * 0.1)
        self.image = pygame.transform.rotate(self.animation.get_current_frame(), angle)
        
        self.rect = self.image.get_rect(center=self.pos)
        
        # Despawn when it falls off-screen
        if self.rect.top > const.SCREEN_HEIGHT:
            self.kill()

    def shoot_down(self):
        """Initiates the 'falling' state."""
        if self.state == "flying":
            self.state = "falling"
            self.set_animation("fall")
            
    def draw(self, surface):
        """
        Draws the duck onto the given surface.
        """
        surface.blit(self.image, self.rect) 