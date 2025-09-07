"""
ground_animal.py

This module defines ground animals (moose, deer, dinosaur) that move horizontally
across the bottom of the screen, providing different targets and scoring opportunities.
"""
import pygame
import random
import math
from game.utils import constants as const

class GroundAnimal(pygame.sprite.Sprite):
    def __init__(self, animal_type="deer", initial_pos=None):
        super().__init__()
        
        self.animal_type = animal_type
        self.type_data = self.get_animal_type_data(animal_type)
        
        # Create the animal sprite
        self.create_sprite()
        
        # Set initial position
        if initial_pos is None:
            # Spawn from left side at ground level
            initial_pos = (-50, const.SCREEN_HEIGHT - 100)
        
        self.rect = self.image.get_rect(center=initial_pos)
        self.pos = pygame.math.Vector2(self.rect.center)
        
        # Movement properties
        self.speed = random.uniform(self.type_data["speed_range"][0], self.type_data["speed_range"][1])
        self.direction = 1  # 1 for right, -1 for left
        
        # State
        self.state = "walking"  # "walking", "hit", "dying"
        self.hit_timer = 0
        
        # Store point value
        self.point_value = self.type_data["points"]

    def get_animal_type_data(self, animal_type):
        """Returns the data for a specific animal type."""
        animal_types = {
            "deer": {
                "points": 200,
                "speed_range": (80, 150),
                "size": (60, 40),
                "color": (139, 69, 19),  # Brown
                "spawn_weight": 30
            },
            "moose": {
                "points": 500,
                "speed_range": (60, 120),
                "size": (80, 60),
                "color": (101, 67, 33),  # Dark brown
                "spawn_weight": 20
            },
            "dinosaur": {
                "points": 1000,
                "speed_range": (100, 200),
                "size": (100, 80),
                "color": (34, 139, 34),  # Forest green
                "spawn_weight": 15
            },
            "rabbit": {
                "points": 150,
                "speed_range": (120, 180),
                "size": (40, 30),
                "color": (160, 82, 45),  # Light brown
                "spawn_weight": 40
            },
            "bear": {
                "points": 800,
                "speed_range": (70, 130),
                "size": (90, 70),
                "color": (101, 67, 33),  # Dark brown
                "spawn_weight": 10
            },
            "wolf": {
                "points": 600,
                "speed_range": (90, 160),
                "size": (70, 50),
                "color": (105, 105, 105),  # Gray
                "spawn_weight": 25
            }
        }
        return animal_types.get(animal_type, animal_types["deer"])

    def create_sprite(self):
        """Creates the animal sprite with walking animation frames."""
        size = self.type_data["size"]
        color = self.type_data["color"]
        
        # Create animation frames
        self.walking_frames = []
        self.current_frame = 0
        self.animation_timer = 0
        self.animation_speed = 0.3  # seconds per frame
        
        if self.animal_type == "deer":
            self.walking_frames = self.create_deer_animation(color)
        elif self.animal_type == "moose":
            self.walking_frames = self.create_moose_animation(color)
        elif self.animal_type == "dinosaur":
            self.walking_frames = self.create_dinosaur_animation(color)
        elif self.animal_type == "rabbit":
            self.walking_frames = self.create_rabbit_animation(color)
        elif self.animal_type == "bear":
            self.walking_frames = self.create_bear_animation(color)
        elif self.animal_type == "wolf":
            self.walking_frames = self.create_wolf_animation(color)
        
        self.image = self.walking_frames[0]

    def create_deer_animation(self, color):
        """Creates deer walking animation frames."""
        frames = []
        size = self.type_data["size"]
        
        for frame in range(4):  # 4 walking frames
            image = pygame.Surface(size, pygame.SRCALPHA)
            
            # Body (more realistic shape)
            pygame.draw.ellipse(image, color, (8, 18, 40, 25))
            # Head (more detailed)
            pygame.draw.ellipse(image, color, (42, 15, 20, 18))
            # Neck
            pygame.draw.ellipse(image, color, (35, 20, 12, 15))
            
            # Legs with walking animation
            leg_color = (max(0, color[0]-20), max(0, color[1]-20), max(0, color[2]-20))
            leg_offsets = [
                [0, 0, 0, 0],      # Frame 0: all legs down
                [2, -2, -2, 2],    # Frame 1: front legs up, back legs down
                [0, 0, 0, 0],      # Frame 2: all legs down
                [-2, 2, 2, -2]     # Frame 3: front legs down, back legs up
            ]
            
            offsets = leg_offsets[frame]
            pygame.draw.rect(image, leg_color, (12, 35 + offsets[0], 5, 12))
            pygame.draw.rect(image, leg_color, (22, 35 + offsets[1], 5, 12))
            pygame.draw.rect(image, leg_color, (32, 35 + offsets[2], 5, 12))
            pygame.draw.rect(image, leg_color, (42, 35 + offsets[3], 5, 12))
            
            # Hooves
            pygame.draw.rect(image, (50, 50, 50), (12, 45 + offsets[0], 5, 3))
            pygame.draw.rect(image, (50, 50, 50), (22, 45 + offsets[1], 5, 3))
            pygame.draw.rect(image, (50, 50, 50), (32, 45 + offsets[2], 5, 3))
            pygame.draw.rect(image, (50, 50, 50), (42, 45 + offsets[3], 5, 3))
            
            # Antlers (more detailed)
            antler_color = (139, 69, 19)
            pygame.draw.line(image, antler_color, (50, 12), (45, 5), 3)
            pygame.draw.line(image, antler_color, (50, 12), (55, 5), 3)
            pygame.draw.line(image, antler_color, (45, 5), (42, 2), 2)
            pygame.draw.line(image, antler_color, (55, 5), (58, 2), 2)
            
            # Eyes
            pygame.draw.circle(image, (0, 0, 0), (52, 20), 2)
            pygame.draw.circle(image, (0, 0, 0), (48, 20), 2)
            
            # Nose
            pygame.draw.circle(image, (0, 0, 0), (50, 26), 1)
            
            # Ears
            pygame.draw.ellipse(image, color, (45, 12, 6, 8))
            pygame.draw.ellipse(image, color, (51, 12, 6, 8))
            
            frames.append(image)
        
        return frames

    def create_moose_animation(self, color):
        """Creates moose walking animation frames."""
        frames = []
        size = self.type_data["size"]
        
        for frame in range(4):  # 4 walking frames
            image = pygame.Surface(size, pygame.SRCALPHA)
            
            # Body (larger, more realistic)
            pygame.draw.ellipse(image, color, (12, 22, 50, 35))
            # Head (larger, more detailed)
            pygame.draw.ellipse(image, color, (55, 18, 25, 22))
            # Neck (thick)
            pygame.draw.ellipse(image, color, (40, 25, 20, 20))
            
            # Legs with walking animation
            leg_color = (max(0, color[0]-25), max(0, color[1]-25), max(0, color[2]-25))
            leg_offsets = [
                [0, 0, 0, 0],      # Frame 0: all legs down
                [3, -3, -3, 3],    # Frame 1: front legs up, back legs down
                [0, 0, 0, 0],      # Frame 2: all legs down
                [-3, 3, 3, -3]     # Frame 3: front legs down, back legs up
            ]
            
            offsets = leg_offsets[frame]
            pygame.draw.rect(image, leg_color, (18, 45 + offsets[0], 8, 18))
            pygame.draw.rect(image, leg_color, (30, 45 + offsets[1], 8, 18))
            pygame.draw.rect(image, leg_color, (50, 45 + offsets[2], 8, 18))
            pygame.draw.rect(image, leg_color, (62, 45 + offsets[3], 8, 18))
            
            # Hooves (larger)
            pygame.draw.rect(image, (40, 40, 40), (18, 60 + offsets[0], 8, 4))
            pygame.draw.rect(image, (40, 40, 40), (30, 60 + offsets[1], 8, 4))
            pygame.draw.rect(image, (40, 40, 40), (50, 60 + offsets[2], 8, 4))
            pygame.draw.rect(image, (40, 40, 40), (62, 60 + offsets[3], 8, 4))
            
            # Antlers (larger, more impressive)
            antler_color = (139, 69, 19)
            pygame.draw.line(image, antler_color, (65, 12), (55, 2), 4)
            pygame.draw.line(image, antler_color, (65, 12), (75, 2), 4)
            pygame.draw.line(image, antler_color, (55, 2), (50, -3), 3)
            pygame.draw.line(image, antler_color, (75, 2), (80, -3), 3)
            pygame.draw.line(image, antler_color, (50, -3), (45, -8), 2)
            pygame.draw.line(image, antler_color, (80, -3), (85, -8), 2)
            
            # Eyes
            pygame.draw.circle(image, (0, 0, 0), (68, 25), 3)
            pygame.draw.circle(image, (0, 0, 0), (62, 25), 3)
            
            # Nose (larger)
            pygame.draw.ellipse(image, (0, 0, 0), (65, 32, 6, 4))
            
            # Ears (larger)
            pygame.draw.ellipse(image, color, (58, 15, 8, 10))
            pygame.draw.ellipse(image, color, (66, 15, 8, 10))
            
            # Dewlap (moose feature)
            pygame.draw.ellipse(image, color, (45, 35, 15, 12))
            
            frames.append(image)
        
        return frames

    def create_dinosaur_animation(self, color):
        """Creates dinosaur walking animation frames."""
        frames = []
        size = self.type_data["size"]
        
        for frame in range(4):  # 4 walking frames
            image = pygame.Surface(size, pygame.SRCALPHA)
            
            # Body (largest, more realistic)
            pygame.draw.ellipse(image, color, (15, 28, 60, 45))
            # Head (more detailed)
            pygame.draw.ellipse(image, color, (70, 25, 25, 20))
            # Tail (longer, more dynamic)
            pygame.draw.ellipse(image, color, (2, 32, 25, 18))
            pygame.draw.ellipse(image, color, (0, 35, 15, 12))
            
            # Legs with walking animation
            leg_color = (max(0, color[0]-30), max(0, color[1]-30), max(0, color[2]-30))
            leg_offsets = [
                [0, 0, 0, 0],      # Frame 0: all legs down
                [4, -4, -4, 4],    # Frame 1: front legs up, back legs down
                [0, 0, 0, 0],      # Frame 2: all legs down
                [-4, 4, 4, -4]     # Frame 3: front legs down, back legs up
            ]
            
            offsets = leg_offsets[frame]
            pygame.draw.rect(image, leg_color, (22, 60 + offsets[0], 10, 25))
            pygame.draw.rect(image, leg_color, (38, 60 + offsets[1], 10, 25))
            pygame.draw.rect(image, leg_color, (58, 60 + offsets[2], 10, 25))
            pygame.draw.rect(image, leg_color, (74, 60 + offsets[3], 10, 25))
            
            # Feet (claws)
            foot_color = (60, 60, 60)
            pygame.draw.rect(image, foot_color, (22, 82 + offsets[0], 10, 6))
            pygame.draw.rect(image, foot_color, (38, 82 + offsets[1], 10, 6))
            pygame.draw.rect(image, foot_color, (58, 82 + offsets[2], 10, 6))
            pygame.draw.rect(image, foot_color, (74, 82 + offsets[3], 10, 6))
            
            # Spikes on back (more detailed)
            spike_color = (0, 80, 0)
            for i in range(6):
                x = 20 + i * 12
                pygame.draw.polygon(image, spike_color, [(x, 25), (x-4, 12), (x+4, 12)])
                pygame.draw.polygon(image, (0, 60, 0), [(x, 25), (x-2, 16), (x+2, 16)])
            
            # Eyes (larger, more menacing)
            pygame.draw.circle(image, (255, 0, 0), (82, 30), 4)
            pygame.draw.circle(image, (0, 0, 0), (82, 30), 2)
            pygame.draw.circle(image, (255, 0, 0), (78, 30), 4)
            pygame.draw.circle(image, (0, 0, 0), (78, 30), 2)
            
            # Nostrils
            pygame.draw.circle(image, (0, 0, 0), (85, 35), 2)
            pygame.draw.circle(image, (0, 0, 0), (88, 35), 2)
            
            # Teeth (sharp)
            tooth_color = (255, 255, 255)
            pygame.draw.polygon(image, tooth_color, [(80, 40), (78, 45), (82, 45)])
            pygame.draw.polygon(image, tooth_color, [(85, 40), (83, 45), (87, 45)])
            
            # Arms (small)
            pygame.draw.ellipse(image, color, (45, 40, 8, 15))
            pygame.draw.ellipse(image, color, (55, 40, 8, 15))
            
            frames.append(image)
        
        return frames

    def create_rabbit_animation(self, color):
        """Creates rabbit hopping animation frames."""
        frames = []
        size = self.type_data["size"]
        
        for frame in range(3):  # 3 hopping frames
            image = pygame.Surface(size, pygame.SRCALPHA)
            
            # Body
            pygame.draw.ellipse(image, color, (8, 15, 25, 18))
            # Head
            pygame.draw.circle(image, color, (35, 18), 8)
            
            # Legs with hopping animation
            leg_color = (max(0, color[0]-15), max(0, color[1]-15), max(0, color[2]-15))
            hop_offsets = [0, -3, 0]  # Hop up and down
            
            pygame.draw.rect(image, leg_color, (12, 25 + hop_offsets[frame], 3, 8))
            pygame.draw.rect(image, leg_color, (18, 25 + hop_offsets[frame], 3, 8))
            pygame.draw.rect(image, leg_color, (24, 25 + hop_offsets[frame], 3, 8))
            
            # Ears
            pygame.draw.ellipse(image, color, (32, 8, 4, 12))
            pygame.draw.ellipse(image, color, (36, 8, 4, 12))
            
            # Eyes
            pygame.draw.circle(image, (0, 0, 0), (33, 16), 1)
            pygame.draw.circle(image, (0, 0, 0), (37, 16), 1)
            
            # Nose
            pygame.draw.circle(image, (0, 0, 0), (35, 20), 1)
            
            frames.append(image)
        
        return frames

    def create_bear_animation(self, color):
        """Creates bear walking animation frames."""
        frames = []
        size = self.type_data["size"]
        
        for frame in range(4):  # 4 walking frames
            image = pygame.Surface(size, pygame.SRCALPHA)
            
            # Body
            pygame.draw.ellipse(image, color, (15, 20, 50, 40))
            # Head
            pygame.draw.circle(image, color, (65, 25), 18)
            
            # Legs with walking animation
            leg_color = (max(0, color[0]-25), max(0, color[1]-25), max(0, color[2]-25))
            leg_offsets = [
                [0, 0, 0, 0],      # Frame 0: all legs down
                [3, -3, -3, 3],    # Frame 1: front legs up, back legs down
                [0, 0, 0, 0],      # Frame 2: all legs down
                [-3, 3, 3, -3]     # Frame 3: front legs down, back legs up
            ]
            
            offsets = leg_offsets[frame]
            pygame.draw.rect(image, leg_color, (20, 50 + offsets[0], 8, 15))
            pygame.draw.rect(image, leg_color, (35, 50 + offsets[1], 8, 15))
            pygame.draw.rect(image, leg_color, (50, 50 + offsets[2], 8, 15))
            pygame.draw.rect(image, leg_color, (65, 50 + offsets[3], 8, 15))
            
            # Paws
            pygame.draw.rect(image, (40, 40, 40), (20, 62 + offsets[0], 8, 4))
            pygame.draw.rect(image, (40, 40, 40), (35, 62 + offsets[1], 8, 4))
            pygame.draw.rect(image, (40, 40, 40), (50, 62 + offsets[2], 8, 4))
            pygame.draw.rect(image, (40, 40, 40), (65, 62 + offsets[3], 8, 4))
            
            # Ears
            pygame.draw.circle(image, color, (58, 12), 6)
            pygame.draw.circle(image, color, (72, 12), 6)
            
            # Eyes
            pygame.draw.circle(image, (0, 0, 0), (62, 22), 2)
            pygame.draw.circle(image, (0, 0, 0), (68, 22), 2)
            
            # Nose
            pygame.draw.circle(image, (0, 0, 0), (65, 28), 2)
            
            frames.append(image)
        
        return frames

    def create_wolf_animation(self, color):
        """Creates wolf walking animation frames."""
        frames = []
        size = self.type_data["size"]
        
        for frame in range(4):  # 4 walking frames
            image = pygame.Surface(size, pygame.SRCALPHA)
            
            # Body
            pygame.draw.ellipse(image, color, (10, 20, 45, 25))
            # Head
            pygame.draw.ellipse(image, color, (50, 18, 18, 16))
            
            # Legs with walking animation
            leg_color = (max(0, color[0]-20), max(0, color[1]-20), max(0, color[2]-20))
            leg_offsets = [
                [0, 0, 0, 0],      # Frame 0: all legs down
                [2, -2, -2, 2],    # Frame 1: front legs up, back legs down
                [0, 0, 0, 0],      # Frame 2: all legs down
                [-2, 2, 2, -2]     # Frame 3: front legs down, back legs up
            ]
            
            offsets = leg_offsets[frame]
            pygame.draw.rect(image, leg_color, (15, 35 + offsets[0], 4, 12))
            pygame.draw.rect(image, leg_color, (25, 35 + offsets[1], 4, 12))
            pygame.draw.rect(image, leg_color, (35, 35 + offsets[2], 4, 12))
            pygame.draw.rect(image, leg_color, (45, 35 + offsets[3], 4, 12))
            
            # Paws
            pygame.draw.rect(image, (30, 30, 30), (15, 45 + offsets[0], 4, 3))
            pygame.draw.rect(image, (30, 30, 30), (25, 45 + offsets[1], 4, 3))
            pygame.draw.rect(image, (30, 30, 30), (35, 45 + offsets[2], 4, 3))
            pygame.draw.rect(image, (30, 30, 30), (45, 45 + offsets[3], 4, 3))
            
            # Ears
            pygame.draw.ellipse(image, color, (52, 12, 5, 8))
            pygame.draw.ellipse(image, color, (58, 12, 5, 8))
            
            # Eyes
            pygame.draw.circle(image, (0, 0, 0), (55, 20), 2)
            pygame.draw.circle(image, (0, 0, 0), (61, 20), 2)
            
            # Nose
            pygame.draw.circle(image, (0, 0, 0), (58, 25), 1)
            
            # Tail
            pygame.draw.ellipse(image, color, (5, 25, 12, 8))
            
            frames.append(image)
        
        return frames

    def update(self, dt):
        """Updates the animal's position and state."""
        if self.state == "walking":
            # Move horizontally
            self.pos.x += self.speed * dt * self.direction
            self.rect.center = self.pos
            
            # Update walking animation
            self.animation_timer += dt
            if self.animation_timer >= self.animation_speed:
                self.animation_timer = 0
                self.current_frame = (self.current_frame + 1) % len(self.walking_frames)
                self.image = self.walking_frames[self.current_frame]
            
            # Despawn if off screen
            if self.rect.right < 0 or self.rect.left > const.SCREEN_WIDTH:
                self.kill()
                
        elif self.state == "hit":
            self.hit_timer += dt
            if self.hit_timer > 0.5:  # Show hit for 0.5 seconds
                self.state = "dying"
                self.hit_timer = 0
                
        elif self.state == "dying":
            # Fall down and fade out
            self.pos.y += 200 * dt  # Fall down
            self.rect.center = self.pos
            
            # Fade out
            alpha = max(0, 255 - int(self.hit_timer * 500))
            self.image.set_alpha(alpha)
            self.hit_timer += dt
            
            if alpha <= 0:
                self.kill()

    def shoot_hit(self):
        """Called when the animal is shot."""
        if self.state == "walking":
            self.state = "hit"
            self.hit_timer = 0
            # Change color to show hit
            self.image.fill((255, 0, 0, 100), special_flags=pygame.BLEND_MULT)

    def draw(self, surface):
        """Draws the animal onto the given surface."""
        surface.blit(self.image, self.rect)
