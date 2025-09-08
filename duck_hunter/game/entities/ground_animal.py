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
        # Scale base sizes based on display scaling
        scale_factor = const.UI_SCALE
        
        animal_types = {
            "deer": {
                "points": 200,
                "speed_range": (80, 150),
                "size": (int(60 * scale_factor), int(40 * scale_factor)),
                "color": (139, 69, 19),  # Brown
                "spawn_weight": 30
            },
            "moose": {
                "points": 500,
                "speed_range": (60, 120),
                "size": (int(80 * scale_factor), int(60 * scale_factor)),
                "color": (101, 67, 33),  # Dark brown
                "spawn_weight": 20
            },
            "dinosaur": {
                "points": 1000,
                "speed_range": (100, 200),
                "size": (int(100 * scale_factor), int(80 * scale_factor)),
                "color": (34, 139, 34),  # Forest green
                "spawn_weight": 15
            },
            "rabbit": {
                "points": 150,
                "speed_range": (120, 180),
                "size": (int(40 * scale_factor), int(30 * scale_factor)),
                "color": (160, 82, 45),  # Light brown
                "spawn_weight": 40
            },
            "bear": {
                "points": 800,
                "speed_range": (70, 130),
                "size": (int(90 * scale_factor), int(70 * scale_factor)),
                "color": (101, 67, 33),  # Dark brown
                "spawn_weight": 10
            },
            "wolf": {
                "points": 600,
                "speed_range": (90, 160),
                "size": (int(70 * scale_factor), int(50 * scale_factor)),
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
        
    def create_deer_animation(self, color):
        """Creates deer walking animation frames."""
        frames = []
        size = self.type_data["size"]
        scale_factor = const.UI_SCALE
        
        for frame in range(4):  # 4 walking frames
            image = pygame.Surface(size, pygame.SRCALPHA)
            
            # Body (more realistic shape)
            pygame.draw.ellipse(image, color, (int(8 * scale_factor), int(18 * scale_factor), int(40 * scale_factor), int(25 * scale_factor)))
            # Head (more detailed)
            pygame.draw.ellipse(image, color, (int(42 * scale_factor), int(15 * scale_factor), int(20 * scale_factor), int(18 * scale_factor)))
            # Neck
            pygame.draw.ellipse(image, color, (int(35 * scale_factor), int(20 * scale_factor), int(12 * scale_factor), int(15 * scale_factor)))
            
            # Legs with walking animation
            leg_color = (max(0, color[0]-20), max(0, color[1]-20), max(0, color[2]-20))
            leg_offsets = [
                [0, 0, 0, 0],      # Frame 0: all legs down
                [2, -2, -2, 2],    # Frame 1: front legs up, back legs down
                [0, 0, 0, 0],      # Frame 2: all legs down
                [-2, 2, 2, -2]     # Frame 3: front legs down, back legs up
            ]
            
            offsets = leg_offsets[frame]
            pygame.draw.rect(image, leg_color, (int(12 * scale_factor), int(35 * scale_factor + offsets[0] * scale_factor), int(5 * scale_factor), int(12 * scale_factor)))
            pygame.draw.rect(image, leg_color, (int(22 * scale_factor), int(35 * scale_factor + offsets[1] * scale_factor), int(5 * scale_factor), int(12 * scale_factor)))
            pygame.draw.rect(image, leg_color, (int(32 * scale_factor), int(35 * scale_factor + offsets[2] * scale_factor), int(5 * scale_factor), int(12 * scale_factor)))
            pygame.draw.rect(image, leg_color, (int(42 * scale_factor), int(35 * scale_factor + offsets[3] * scale_factor), int(5 * scale_factor), int(12 * scale_factor)))
            
            # Hooves
            pygame.draw.rect(image, (50, 50, 50), (int(12 * scale_factor), int(45 * scale_factor + offsets[0] * scale_factor), int(5 * scale_factor), int(3 * scale_factor)))
            pygame.draw.rect(image, (50, 50, 50), (int(22 * scale_factor), int(45 * scale_factor + offsets[1] * scale_factor), int(5 * scale_factor), int(3 * scale_factor)))
            pygame.draw.rect(image, (50, 50, 50), (int(32 * scale_factor), int(45 * scale_factor + offsets[2] * scale_factor), int(5 * scale_factor), int(3 * scale_factor)))
            pygame.draw.rect(image, (50, 50, 50), (int(42 * scale_factor), int(45 * scale_factor + offsets[3] * scale_factor), int(5 * scale_factor), int(3 * scale_factor)))
            
            # Antlers (more detailed)
            antler_color = (139, 69, 19)
            pygame.draw.line(image, antler_color, (int(50 * scale_factor), int(12 * scale_factor)), (int(45 * scale_factor), int(5 * scale_factor)), max(1, int(3 * scale_factor)))
            pygame.draw.line(image, antler_color, (int(50 * scale_factor), int(12 * scale_factor)), (int(55 * scale_factor), int(5 * scale_factor)), max(1, int(3 * scale_factor)))
            pygame.draw.line(image, antler_color, (int(45 * scale_factor), int(5 * scale_factor)), (int(42 * scale_factor), int(2 * scale_factor)), max(1, int(2 * scale_factor)))
            pygame.draw.line(image, antler_color, (int(55 * scale_factor), int(5 * scale_factor)), (int(58 * scale_factor), int(2 * scale_factor)), max(1, int(2 * scale_factor)))
            
            # Eyes
            pygame.draw.circle(image, (0, 0, 0), (int(52 * scale_factor), int(20 * scale_factor)), max(1, int(2 * scale_factor)))
            pygame.draw.circle(image, (0, 0, 0), (int(48 * scale_factor), int(20 * scale_factor)), max(1, int(2 * scale_factor)))
            
            # Nose
            pygame.draw.circle(image, (0, 0, 0), (int(50 * scale_factor), int(26 * scale_factor)), max(1, int(1 * scale_factor)))
            
            # Ears
            pygame.draw.ellipse(image, color, (int(45 * scale_factor), int(12 * scale_factor), int(6 * scale_factor), int(8 * scale_factor)))
            pygame.draw.ellipse(image, color, (int(51 * scale_factor), int(12 * scale_factor), int(6 * scale_factor), int(8 * scale_factor)))
            
            frames.append(image)
        
        return frames

    def create_moose_animation(self, color):
        """Creates moose walking animation frames."""
        frames = []
        size = self.type_data["size"]
        scale_factor = const.UI_SCALE
        
        for frame in range(4):  # 4 walking frames
            image = pygame.Surface(size, pygame.SRCALPHA)
            
            # Body (larger, more realistic)
            pygame.draw.ellipse(image, color, (int(12 * scale_factor), int(22 * scale_factor), int(50 * scale_factor), int(35 * scale_factor)))
            # Head (larger, more detailed)
            pygame.draw.ellipse(image, color, (int(55 * scale_factor), int(18 * scale_factor), int(25 * scale_factor), int(22 * scale_factor)))
            # Neck (thick)
            pygame.draw.ellipse(image, color, (int(40 * scale_factor), int(25 * scale_factor), int(20 * scale_factor), int(20 * scale_factor)))
            
            # Legs with walking animation
            leg_color = (max(0, color[0]-25), max(0, color[1]-25), max(0, color[2]-25))
            leg_offsets = [
                [0, 0, 0, 0],      # Frame 0: all legs down
                [3, -3, -3, 3],    # Frame 1: front legs up, back legs down
                [0, 0, 0, 0],      # Frame 2: all legs down
                [-3, 3, 3, -3]     # Frame 3: front legs down, back legs up
            ]
            
            offsets = leg_offsets[frame]
            pygame.draw.rect(image, leg_color, (int(18 * scale_factor), int((45 + offsets[0]) * scale_factor), int(8 * scale_factor), int(18 * scale_factor)))
            pygame.draw.rect(image, leg_color, (int(30 * scale_factor), int((45 + offsets[1]) * scale_factor), int(8 * scale_factor), int(18 * scale_factor)))
            pygame.draw.rect(image, leg_color, (int(50 * scale_factor), int((45 + offsets[2]) * scale_factor), int(8 * scale_factor), int(18 * scale_factor)))
            pygame.draw.rect(image, leg_color, (int(62 * scale_factor), int((45 + offsets[3]) * scale_factor), int(8 * scale_factor), int(18 * scale_factor)))
            
            # Hooves (larger)
            pygame.draw.rect(image, (40, 40, 40), (int(18 * scale_factor), int((60 + offsets[0]) * scale_factor), int(8 * scale_factor), int(4 * scale_factor)))
            pygame.draw.rect(image, (40, 40, 40), (int(30 * scale_factor), int((60 + offsets[1]) * scale_factor), int(8 * scale_factor), int(4 * scale_factor)))
            pygame.draw.rect(image, (40, 40, 40), (int(50 * scale_factor), int((60 + offsets[2]) * scale_factor), int(8 * scale_factor), int(4 * scale_factor)))
            pygame.draw.rect(image, (40, 40, 40), (int(62 * scale_factor), int((60 + offsets[3]) * scale_factor), int(8 * scale_factor), int(4 * scale_factor)))
            
            # Antlers (larger, more impressive)
            antler_color = (139, 69, 19)
            pygame.draw.line(image, antler_color, (int(65 * scale_factor), int(12 * scale_factor)), (int(55 * scale_factor), int(2 * scale_factor)), max(1, int(4 * scale_factor)))
            pygame.draw.line(image, antler_color, (int(65 * scale_factor), int(12 * scale_factor)), (int(75 * scale_factor), int(2 * scale_factor)), max(1, int(4 * scale_factor)))
            pygame.draw.line(image, antler_color, (int(55 * scale_factor), int(2 * scale_factor)), (int(50 * scale_factor), int(-3 * scale_factor)), max(1, int(3 * scale_factor)))
            pygame.draw.line(image, antler_color, (int(75 * scale_factor), int(2 * scale_factor)), (int(80 * scale_factor), int(-3 * scale_factor)), max(1, int(3 * scale_factor)))
            pygame.draw.line(image, antler_color, (int(50 * scale_factor), int(-3 * scale_factor)), (int(45 * scale_factor), int(-8 * scale_factor)), max(1, int(2 * scale_factor)))
            pygame.draw.line(image, antler_color, (int(80 * scale_factor), int(-3 * scale_factor)), (int(85 * scale_factor), int(-8 * scale_factor)), max(1, int(2 * scale_factor)))
            
            # Eyes
            pygame.draw.circle(image, (0, 0, 0), (int(68 * scale_factor), int(25 * scale_factor)), max(1, int(3 * scale_factor)))
            pygame.draw.circle(image, (0, 0, 0), (int(62 * scale_factor), int(25 * scale_factor)), max(1, int(3 * scale_factor)))
            
            # Nose (larger)
            pygame.draw.ellipse(image, (0, 0, 0), (int(65 * scale_factor), int(32 * scale_factor), int(6 * scale_factor), int(4 * scale_factor)))
            
            # Ears (larger)
            pygame.draw.ellipse(image, color, (int(58 * scale_factor), int(15 * scale_factor), int(8 * scale_factor), int(10 * scale_factor)))
            pygame.draw.ellipse(image, color, (int(66 * scale_factor), int(15 * scale_factor), int(8 * scale_factor), int(10 * scale_factor)))
            
            # Dewlap (moose feature)
            pygame.draw.ellipse(image, color, (int(45 * scale_factor), int(35 * scale_factor), int(15 * scale_factor), int(12 * scale_factor)))
            
            frames.append(image)
        
        return frames

    def create_dinosaur_animation(self, color):
        """Creates dinosaur walking animation frames."""
        frames = []
        size = self.type_data["size"]
        scale_factor = const.UI_SCALE
        
        for frame in range(4):  # 4 walking frames
            image = pygame.Surface(size, pygame.SRCALPHA)
            
            # Body (largest, more realistic)
            pygame.draw.ellipse(image, color, (int(15 * scale_factor), int(28 * scale_factor), int(60 * scale_factor), int(45 * scale_factor)))
            # Head (more detailed)
            pygame.draw.ellipse(image, color, (int(70 * scale_factor), int(25 * scale_factor), int(25 * scale_factor), int(20 * scale_factor)))
            # Tail (longer, more dynamic)
            pygame.draw.ellipse(image, color, (int(2 * scale_factor), int(32 * scale_factor), int(25 * scale_factor), int(18 * scale_factor)))
            pygame.draw.ellipse(image, color, (int(0 * scale_factor), int(35 * scale_factor), int(15 * scale_factor), int(12 * scale_factor)))
            
            # Legs with walking animation
            leg_color = (max(0, color[0]-30), max(0, color[1]-30), max(0, color[2]-30))
            leg_offsets = [
                [0, 0, 0, 0],      # Frame 0: all legs down
                [4, -4, -4, 4],    # Frame 1: front legs up, back legs down
                [0, 0, 0, 0],      # Frame 2: all legs down
                [-4, 4, 4, -4]     # Frame 3: front legs down, back legs up
            ]
            
            offsets = leg_offsets[frame]
            pygame.draw.rect(image, leg_color, (int(22 * scale_factor), int((60 + offsets[0]) * scale_factor), int(10 * scale_factor), int(25 * scale_factor)))
            pygame.draw.rect(image, leg_color, (int(38 * scale_factor), int((60 + offsets[1]) * scale_factor), int(10 * scale_factor), int(25 * scale_factor)))
            pygame.draw.rect(image, leg_color, (int(58 * scale_factor), int((60 + offsets[2]) * scale_factor), int(10 * scale_factor), int(25 * scale_factor)))
            pygame.draw.rect(image, leg_color, (int(74 * scale_factor), int((60 + offsets[3]) * scale_factor), int(10 * scale_factor), int(25 * scale_factor)))
            
            # Feet (claws)
            foot_color = (60, 60, 60)
            pygame.draw.rect(image, foot_color, (int(22 * scale_factor), int((82 + offsets[0]) * scale_factor), int(10 * scale_factor), int(6 * scale_factor)))
            pygame.draw.rect(image, foot_color, (int(38 * scale_factor), int((82 + offsets[1]) * scale_factor), int(10 * scale_factor), int(6 * scale_factor)))
            pygame.draw.rect(image, foot_color, (int(58 * scale_factor), int((82 + offsets[2]) * scale_factor), int(10 * scale_factor), int(6 * scale_factor)))
            pygame.draw.rect(image, foot_color, (int(74 * scale_factor), int((82 + offsets[3]) * scale_factor), int(10 * scale_factor), int(6 * scale_factor)))
            
            # Spikes on back (more detailed)
            spike_color = (0, 80, 0)
            for i in range(6):
                x = int((20 + i * 12) * scale_factor)
                y_base = int(25 * scale_factor)
                spike_height = int(13 * scale_factor)
                pygame.draw.polygon(image, spike_color, [(x, y_base), (x - int(4 * scale_factor), y_base - spike_height), (x + int(4 * scale_factor), y_base - spike_height)])
                pygame.draw.polygon(image, (0, 60, 0), [(x, y_base), (x - int(2 * scale_factor), y_base - int(9 * scale_factor)), (x + int(2 * scale_factor), y_base - int(9 * scale_factor))])
            
            # Eyes (larger, more menacing)
            pygame.draw.circle(image, (255, 0, 0), (int(82 * scale_factor), int(30 * scale_factor)), max(1, int(4 * scale_factor)))
            pygame.draw.circle(image, (0, 0, 0), (int(82 * scale_factor), int(30 * scale_factor)), max(1, int(2 * scale_factor)))
            pygame.draw.circle(image, (255, 0, 0), (int(78 * scale_factor), int(30 * scale_factor)), max(1, int(4 * scale_factor)))
            pygame.draw.circle(image, (0, 0, 0), (int(78 * scale_factor), int(30 * scale_factor)), max(1, int(2 * scale_factor)))
            
            # Nostrils
            pygame.draw.circle(image, (0, 0, 0), (int(85 * scale_factor), int(35 * scale_factor)), max(1, int(2 * scale_factor)))
            pygame.draw.circle(image, (0, 0, 0), (int(88 * scale_factor), int(35 * scale_factor)), max(1, int(2 * scale_factor)))
            
            # Teeth (sharp)
            tooth_color = (255, 255, 255)
            tooth_x1 = int(80 * scale_factor)
            tooth_y1 = int(40 * scale_factor)
            pygame.draw.polygon(image, tooth_color, [(tooth_x1, tooth_y1), (tooth_x1 - int(2 * scale_factor), tooth_y1 + int(5 * scale_factor)), (tooth_x1 + int(2 * scale_factor), tooth_y1 + int(5 * scale_factor))])
            tooth_x2 = int(85 * scale_factor)
            pygame.draw.polygon(image, tooth_color, [(tooth_x2, tooth_y1), (tooth_x2 - int(2 * scale_factor), tooth_y1 + int(5 * scale_factor)), (tooth_x2 + int(2 * scale_factor), tooth_y1 + int(5 * scale_factor))])
            
            # Arms (small)
            pygame.draw.ellipse(image, color, (int(45 * scale_factor), int(40 * scale_factor), int(8 * scale_factor), int(15 * scale_factor)))
            pygame.draw.ellipse(image, color, (int(55 * scale_factor), int(40 * scale_factor), int(8 * scale_factor), int(15 * scale_factor)))
            
            frames.append(image)
        
        return frames

    def create_rabbit_animation(self, color):
        """Creates rabbit hopping animation frames."""
        frames = []
        size = self.type_data["size"]
        scale_factor = const.UI_SCALE
        
        for frame in range(3):  # 3 hopping frames
            image = pygame.Surface(size, pygame.SRCALPHA)
            
            # Body
            pygame.draw.ellipse(image, color, (int(8 * scale_factor), int(15 * scale_factor), int(25 * scale_factor), int(18 * scale_factor)))
            # Head
            pygame.draw.circle(image, color, (int(35 * scale_factor), int(18 * scale_factor)), max(1, int(8 * scale_factor)))
            
            # Legs with hopping animation
            leg_color = (max(0, color[0]-15), max(0, color[1]-15), max(0, color[2]-15))
            hop_offsets = [0, -3, 0]  # Hop up and down
            
            pygame.draw.rect(image, leg_color, (int(12 * scale_factor), int((25 + hop_offsets[frame]) * scale_factor), max(1, int(3 * scale_factor)), max(1, int(8 * scale_factor))))
            pygame.draw.rect(image, leg_color, (int(18 * scale_factor), int((25 + hop_offsets[frame]) * scale_factor), max(1, int(3 * scale_factor)), max(1, int(8 * scale_factor))))
            pygame.draw.rect(image, leg_color, (int(24 * scale_factor), int((25 + hop_offsets[frame]) * scale_factor), max(1, int(3 * scale_factor)), max(1, int(8 * scale_factor))))
            
            # Ears
            pygame.draw.ellipse(image, color, (int(32 * scale_factor), int(8 * scale_factor), max(1, int(4 * scale_factor)), max(1, int(12 * scale_factor))))
            pygame.draw.ellipse(image, color, (int(36 * scale_factor), int(8 * scale_factor), max(1, int(4 * scale_factor)), max(1, int(12 * scale_factor))))
            
            # Eyes
            pygame.draw.circle(image, (0, 0, 0), (int(33 * scale_factor), int(16 * scale_factor)), max(1, int(1 * scale_factor)))
            pygame.draw.circle(image, (0, 0, 0), (int(37 * scale_factor), int(16 * scale_factor)), max(1, int(1 * scale_factor)))
            
            # Nose
            pygame.draw.circle(image, (0, 0, 0), (int(35 * scale_factor), int(20 * scale_factor)), max(1, int(1 * scale_factor)))
            
            frames.append(image)
        
        return frames

    def create_bear_animation(self, color):
        """Creates bear walking animation frames."""
        frames = []
        size = self.type_data["size"]
        scale_factor = const.UI_SCALE
        
        for frame in range(4):  # 4 walking frames
            image = pygame.Surface(size, pygame.SRCALPHA)
            
            # Body
            pygame.draw.ellipse(image, color, (int(15 * scale_factor), int(20 * scale_factor), int(50 * scale_factor), int(40 * scale_factor)))
            # Head
            pygame.draw.circle(image, color, (int(65 * scale_factor), int(25 * scale_factor)), max(1, int(18 * scale_factor)))
            
            # Legs with walking animation
            leg_color = (max(0, color[0]-25), max(0, color[1]-25), max(0, color[2]-25))
            leg_offsets = [
                [0, 0, 0, 0],      # Frame 0: all legs down
                [3, -3, -3, 3],    # Frame 1: front legs up, back legs down
                [0, 0, 0, 0],      # Frame 2: all legs down
                [-3, 3, 3, -3]     # Frame 3: front legs down, back legs up
            ]
            
            offsets = leg_offsets[frame]
            pygame.draw.rect(image, leg_color, (int(20 * scale_factor), int((50 + offsets[0]) * scale_factor), max(1, int(8 * scale_factor)), max(1, int(15 * scale_factor))))
            pygame.draw.rect(image, leg_color, (int(35 * scale_factor), int((50 + offsets[1]) * scale_factor), max(1, int(8 * scale_factor)), max(1, int(15 * scale_factor))))
            pygame.draw.rect(image, leg_color, (int(50 * scale_factor), int((50 + offsets[2]) * scale_factor), max(1, int(8 * scale_factor)), max(1, int(15 * scale_factor))))
            pygame.draw.rect(image, leg_color, (int(65 * scale_factor), int((50 + offsets[3]) * scale_factor), max(1, int(8 * scale_factor)), max(1, int(15 * scale_factor))))
            
            # Paws
            pygame.draw.rect(image, (40, 40, 40), (int(20 * scale_factor), int((62 + offsets[0]) * scale_factor), max(1, int(8 * scale_factor)), max(1, int(4 * scale_factor))))
            pygame.draw.rect(image, (40, 40, 40), (int(35 * scale_factor), int((62 + offsets[1]) * scale_factor), max(1, int(8 * scale_factor)), max(1, int(4 * scale_factor))))
            pygame.draw.rect(image, (40, 40, 40), (int(50 * scale_factor), int((62 + offsets[2]) * scale_factor), max(1, int(8 * scale_factor)), max(1, int(4 * scale_factor))))
            pygame.draw.rect(image, (40, 40, 40), (int(65 * scale_factor), int((62 + offsets[3]) * scale_factor), max(1, int(8 * scale_factor)), max(1, int(4 * scale_factor))))
            
            # Ears
            pygame.draw.circle(image, color, (int(58 * scale_factor), int(12 * scale_factor)), max(1, int(6 * scale_factor)))
            pygame.draw.circle(image, color, (int(72 * scale_factor), int(12 * scale_factor)), max(1, int(6 * scale_factor)))
            
            # Eyes
            pygame.draw.circle(image, (0, 0, 0), (int(62 * scale_factor), int(22 * scale_factor)), max(1, int(2 * scale_factor)))
            pygame.draw.circle(image, (0, 0, 0), (int(68 * scale_factor), int(22 * scale_factor)), max(1, int(2 * scale_factor)))
            
            # Nose
            pygame.draw.circle(image, (0, 0, 0), (int(65 * scale_factor), int(28 * scale_factor)), max(1, int(2 * scale_factor)))
            
            frames.append(image)
        
        return frames

    def create_wolf_animation(self, color):
        """Creates wolf walking animation frames."""
        frames = []
        size = self.type_data["size"]
        scale_factor = const.UI_SCALE
        
        for frame in range(4):  # 4 walking frames
            image = pygame.Surface(size, pygame.SRCALPHA)
            
            # Body
            pygame.draw.ellipse(image, color, (int(10 * scale_factor), int(20 * scale_factor), int(45 * scale_factor), int(25 * scale_factor)))
            # Head
            pygame.draw.ellipse(image, color, (int(50 * scale_factor), int(18 * scale_factor), int(18 * scale_factor), int(16 * scale_factor)))
            
            # Legs with walking animation
            leg_color = (max(0, color[0]-20), max(0, color[1]-20), max(0, color[2]-20))
            leg_offsets = [
                [0, 0, 0, 0],      # Frame 0: all legs down
                [2, -2, -2, 2],    # Frame 1: front legs up, back legs down
                [0, 0, 0, 0],      # Frame 2: all legs down
                [-2, 2, 2, -2]     # Frame 3: front legs down, back legs up
            ]
            
            offsets = leg_offsets[frame]
            pygame.draw.rect(image, leg_color, (int(15 * scale_factor), int((35 + offsets[0]) * scale_factor), max(1, int(4 * scale_factor)), max(1, int(12 * scale_factor))))
            pygame.draw.rect(image, leg_color, (int(25 * scale_factor), int((35 + offsets[1]) * scale_factor), max(1, int(4 * scale_factor)), max(1, int(12 * scale_factor))))
            pygame.draw.rect(image, leg_color, (int(35 * scale_factor), int((35 + offsets[2]) * scale_factor), max(1, int(4 * scale_factor)), max(1, int(12 * scale_factor))))
            pygame.draw.rect(image, leg_color, (int(45 * scale_factor), int((35 + offsets[3]) * scale_factor), max(1, int(4 * scale_factor)), max(1, int(12 * scale_factor))))
            
            # Paws
            pygame.draw.rect(image, (30, 30, 30), (int(15 * scale_factor), int((45 + offsets[0]) * scale_factor), max(1, int(4 * scale_factor)), max(1, int(3 * scale_factor))))
            pygame.draw.rect(image, (30, 30, 30), (int(25 * scale_factor), int((45 + offsets[1]) * scale_factor), max(1, int(4 * scale_factor)), max(1, int(3 * scale_factor))))
            pygame.draw.rect(image, (30, 30, 30), (int(35 * scale_factor), int((45 + offsets[2]) * scale_factor), max(1, int(4 * scale_factor)), max(1, int(3 * scale_factor))))
            pygame.draw.rect(image, (30, 30, 30), (int(45 * scale_factor), int((45 + offsets[3]) * scale_factor), max(1, int(4 * scale_factor)), max(1, int(3 * scale_factor))))
            
            # Ears
            pygame.draw.ellipse(image, color, (int(52 * scale_factor), int(12 * scale_factor), max(1, int(5 * scale_factor)), max(1, int(8 * scale_factor))))
            pygame.draw.ellipse(image, color, (int(58 * scale_factor), int(12 * scale_factor), max(1, int(5 * scale_factor)), max(1, int(8 * scale_factor))))
            
            # Eyes
            pygame.draw.circle(image, (0, 0, 0), (int(55 * scale_factor), int(20 * scale_factor)), max(1, int(2 * scale_factor)))
            pygame.draw.circle(image, (0, 0, 0), (int(61 * scale_factor), int(20 * scale_factor)), max(1, int(2 * scale_factor)))
            
            # Nose
            pygame.draw.circle(image, (0, 0, 0), (int(58 * scale_factor), int(25 * scale_factor)), max(1, int(1 * scale_factor)))
            
            # Tail
            pygame.draw.ellipse(image, color, (int(5 * scale_factor), int(25 * scale_factor), max(1, int(12 * scale_factor)), max(1, int(8 * scale_factor))))
            
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
