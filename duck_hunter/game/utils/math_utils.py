"""
math_utils.py

A collection of utility functions for mathematical operations,
such as vector calculations, interpolation, etc.
"""

def lerp(a, b, t):
    """Linearly interpolates between two points."""
    return a * (1.0 - t) + b * t

# TODO: Add more math utility functions as needed 