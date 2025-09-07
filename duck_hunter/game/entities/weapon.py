"""
weapon.py

Defines the player's weapon systems.
"""
import pygame

class Weapon:
    def __init__(self):
        self.ammo_capacity = 8
        self.current_ammo = self.ammo_capacity
        self.reload_time = 2.0 # seconds
        self.is_reloading = False
        self.reload_timer = 0
        
    def shoot(self):
        """
        Attempts to fire the weapon. Returns True if successful, False otherwise.
        """
        if self.current_ammo > 0 and not self.is_reloading:
            self.current_ammo -= 1
            print(f"Bang! Ammo: {self.current_ammo}/{self.ammo_capacity}")
            return True
        elif self.current_ammo <= 0 and not self.is_reloading:
            print("Click! Out of ammo.")
            # We could play an empty clip sound here
            self.start_reload()
        return False

    def start_reload(self):
        """Initiates the reloading process."""
        if not self.is_reloading:
            self.is_reloading = True
            self.reload_timer = 0
            print("Reloading...")

    def update(self, dt):
        """Updates the reloading timer."""
        if self.is_reloading:
            self.reload_timer += dt
            if self.reload_timer >= self.reload_time:
                self.is_reloading = False
                self.current_ammo = self.ammo_capacity
                print("Reload complete!")

    def get_ammo_status(self):
        """Returns the current ammo and capacity as a tuple."""
        return (self.current_ammo, self.ammo_capacity) 