"""
particles.py

Manages particle effects for visuals like explosions, smoke, and sparkles.
"""
import pygame
import random

class Particle(pygame.sprite.Sprite):
    def __init__(self, pos, color, size, velocity, lifetime):
        super().__init__()
        self.image = pygame.Surface((size, size))
        pygame.draw.circle(self.image, color, (size // 2, size // 2), size // 2)
        self.rect = self.image.get_rect(center=pos)
        self.pos = pygame.math.Vector2(pos)
        self.velocity = pygame.math.Vector2(velocity)
        self.lifetime = lifetime
        self.age = 0

    def update(self, dt):
        self.pos += self.velocity * dt
        self.rect.center = self.pos
        self.age += dt
        if self.age >= self.lifetime:
            self.kill()

class ParticleSystem:
    def __init__(self):
        self.particles = pygame.sprite.Group()

    def emit_feathers(self, pos):
        """Emits a burst of 'feather' particles."""
        feather_color = (255, 255, 255) # White
        for _ in range(20): # Number of feathers
            vel = (random.uniform(-150, 150), random.uniform(-200, 0))
            size = random.randint(2, 5)
            lifetime = random.uniform(0.5, 1.5)
            particle = Particle(pos, feather_color, size, vel, lifetime)
            self.particles.add(particle)

    def update(self, dt):
        """Update all active particles."""
        self.particles.update(dt)

    def draw(self, surface):
        """Render all active particles."""
        self.particles.draw(surface) 