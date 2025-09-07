"""
background.py

This module defines the ParallaxBackground class for creating a multi-layered,
scrolling background with a sense of depth.
"""
import pygame
from game.utils import constants as const
import random

class ParallaxBackground:
    def __init__(self):
        # In a real scenario, you would load multiple image layers.
        # e.g., self.sky = resources.load_image("sky.png").convert()
        
        # Creating dummy surfaces for testing purposes.
        # Layer 0: Sky (with clouds)
        self.sky_layer = pygame.Surface((const.SCREEN_WIDTH, const.SCREEN_HEIGHT))
        self.sky_layer.fill((135, 206, 235)) # Sky blue
        self.clouds = self.create_clouds(20, const.SCREEN_WIDTH * 2) # 20 clouds over double screen width
        
        # Layer 1: Distant hills/trees
        self.distant_hills_layer = self.create_dummy_layer(const.SCREEN_WIDTH * 2, const.SCREEN_HEIGHT, (34, 139, 34), 100, 20)
        
        # Layer 2: Near ground/trees
        self.near_ground_layer = self.create_dummy_layer(const.SCREEN_WIDTH * 2, const.SCREEN_HEIGHT, (0, 100, 0), 200, 40, True)

        self.layers = [
            # (layer_surface, scroll_speed)
            (self.sky_layer, 0.1), # Slow scroll for clouds
            (self.distant_hills_layer, 0.25),
            (self.near_ground_layer, 0.5)
        ]
        
        self.scroll = 0

    def create_clouds(self, num_clouds, coverage_width):
        """Creates a list of cloud rects for rendering."""
        clouds = []
        for _ in range(num_clouds):
            x = random.randint(0, coverage_width)
            y = random.randint(50, 200)
            width = random.randint(100, 300)
            height = random.randint(50, 100)
            clouds.append(pygame.Rect(x, y, width, height))
        return clouds

    def create_dummy_layer(self, width, height, color, ground_height, num_trees, is_foreground=False):
        """Creates a simple surface with a colored rectangle and tree silhouettes."""
        layer = pygame.Surface((width, height), pygame.SRCALPHA)
        pygame.draw.rect(layer, color, (0, height - ground_height, width, ground_height))
        
        # Add tree silhouettes
        for _ in range(num_trees):
            tree_x = random.randint(0, width)
            tree_height = random.randint(80, 150) if is_foreground else random.randint(50, 100)
            tree_y = height - ground_height - tree_height
            tree_color = (20, 80, 20)
            pygame.draw.rect(layer, tree_color, (tree_x, tree_y, 20, tree_height)) # Trunk
            pygame.draw.circle(layer, tree_color, (tree_x + 10, tree_y), 30) # Foliage
        return layer

    def update(self, dt):
        """Updates the scroll position."""
        # This will be tied to player movement or a constant scroll later.
        # For now, a slow constant scroll for testing.
        self.scroll += 50 * dt

    def draw(self, surface):
        """Draws all layers to the screen, offset by their scroll speed."""
        surface.fill((135, 206, 235)) # Fill with sky blue first
        
        # Draw clouds separately as they are on the base sky layer
        cloud_speed = self.layers[0][1]
        for cloud in self.clouds:
            x_pos = cloud.x - ((self.scroll * cloud_speed) % (const.SCREEN_WIDTH * 2))
            # If cloud scrolls off left, wrap it around to the right
            if x_pos < -cloud.width:
                x_pos += const.SCREEN_WIDTH * 2
            surface.blit(self.create_cloud_surface(cloud.size), (x_pos, cloud.y))

        for i in range(1, len(self.layers)):
            layer, speed = self.layers[i]
            x_pos = -((self.scroll * speed) % layer.get_width())
            surface.blit(layer, (x_pos, 0))
            surface.blit(layer, (x_pos + layer.get_width(), 0))

    def create_cloud_surface(self, size):
        """Creates a simple cloud shape on a surface."""
        # This is inefficient to call every frame, but fine for a demo.
        # A better way would be to pre-render these.
        surf = pygame.Surface(size, pygame.SRCALPHA)
        pygame.draw.ellipse(surf, (255, 255, 255), (0, 0, size[0], size[1]))
        return surf 