"""
animation.py

This module contains the Animation class for managing sprite sheet animations.
"""
import pygame

class Animation:
    def __init__(self, frames, frame_durations, loop=True):
        """
        Initializes an animation sequence.

        :param frames: A list of pygame.Surface objects representing animation frames.
        :param frame_durations: A list or tuple of durations (in seconds) for each frame.
                                If a single value, it's used for all frames.
        :param loop: Boolean indicating if the animation should loop.
        """
        self.frames = frames
        if isinstance(frame_durations, (list, tuple)):
            self.frame_durations = frame_durations
        else:
            self.frame_durations = [frame_durations] * len(self.frames)
        
        self.loop = loop
        self.frame_count = len(self.frames)
        self.current_frame_index = 0
        self.current_frame_duration = 0
        self.is_done = False

    def update(self, dt):
        """
        Updates the animation state based on the delta time.
        """
        if self.is_done:
            return

        self.current_frame_duration += dt
        if self.current_frame_duration >= self.frame_durations[self.current_frame_index]:
            self.current_frame_duration -= self.frame_durations[self.current_frame_index]
            self.current_frame_index += 1
            if self.current_frame_index >= self.frame_count:
                if self.loop:
                    self.current_frame_index = 0
                else:
                    self.is_done = True
                    self.current_frame_index = self.frame_count - 1

    def get_current_frame(self):
        """
        Returns the current frame of the animation.
        """
        return self.frames[self.current_frame_index]

    def reset(self):
        """
        Resets the animation to its first frame.
        """
        self.current_frame_index = 0
        self.current_frame_duration = 0
        self.is_done = False 