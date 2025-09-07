"""
player.py

Defines the player state, including score, lives, and current weapon.
"""
from game.entities.weapon import Weapon

class Player:
    def __init__(self, game_mode="normal"):
        self.score = 0
        self.game_mode = game_mode
        self.weapon = Weapon()
        
        # Set initial values based on game mode
        self.set_game_mode(game_mode)

    def set_game_mode(self, mode):
        """Sets the game mode and adjusts player stats accordingly."""
        self.game_mode = mode
        
        if mode == "god":
            self.lives = float('inf')  # Infinite lives
            self.weapon.ammo_capacity = float('inf')  # Infinite ammo
            self.weapon.current_ammo = float('inf')
        elif mode == "easy":
            self.lives = 10
            self.weapon.ammo_capacity = 15
            self.weapon.current_ammo = 15
        elif mode == "hard":
            self.lives = 1
            self.weapon.ammo_capacity = 5
            self.weapon.current_ammo = 5
        else:  # normal
            self.lives = 3
            self.weapon.ammo_capacity = 8
            self.weapon.current_ammo = 8

    def add_score(self, points):
        """Adds points to the player's score."""
        self.score += points

    def lose_life(self):
        """Decrements the player's life count."""
        if self.game_mode != "god":
            self.lives -= 1

    def has_lives(self):
        """Returns True if the player has lives remaining."""
        if self.game_mode == "god":
            return True
        return self.lives > 0

    def update(self, dt):
        """Updates player-related logic, e.g., weapon cooldowns."""
        self.weapon.update(dt) 