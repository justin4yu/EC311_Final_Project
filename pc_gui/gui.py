# Cited Source for Pygame Whack-A-Mole Implementation:
# https://medium.com/@uva/building-a-whack-a-mole-game-with-python-and-pygame-264c9f4cd512

import pygame
import random
import time

pygame.init() 

# ----------------------------------------------------------------
# Constants & Configurations
# ----------------------------------------------------------------
SCREEN_WIDTH = 800
SCREEN_HEIGHT = 700  # Increased height to accommodate the score display
BUTTON_WIDTH  = 220
BUTTON_HEIGHT = 70

# 5 Mole grid (1x5)
GRID_ROWS = 1       
GRID_COLS = 5        

# Tile dimensions
CELL_SIZE = 150      
MOLE_SIZE = 100
GRID_SPACING = 10    

BACKGROUND_COLOR = (0, 255, 0)
HOLE_COLOR = (139, 69, 19)

# **********Need Modification for FPGA Integration**********
FPS = 30
MOLE_TIME = 1        # seconds a mole stays up
GAME_TIME = 10       # total game time in seconds

# ----------------------------------------------------------------
# Set up the display
# ----------------------------------------------------------------
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Whack-a-Mole")

# ----------------------------------------------------------------
# Load images
# ----------------------------------------------------------------
MOLE_IMAGE_PATH = "WhackAMole_mole.png"
HAMMER_IMAGE_PATH = "WhackAMole_hammer.png"

mole_image = pygame.image.load(MOLE_IMAGE_PATH).convert_alpha()
mole_image = pygame.transform.scale(mole_image, (MOLE_SIZE, MOLE_SIZE))

hammer_image = pygame.image.load(HAMMER_IMAGE_PATH).convert_alpha()
hammer_image = pygame.transform.scale(hammer_image, (50, 50))

# ----------------------------------------------------------------
# Font
# ----------------------------------------------------------------
font = pygame.font.SysFont("arial", 36)

# ----------------------------------------------------------------
# Drawing Functions
# ----------------------------------------------------------------
def draw_grid():
    for row in range(GRID_ROWS):
        for col in range(GRID_COLS):
            x = 5 + col * (CELL_SIZE + GRID_SPACING) # terrible hardcoding with dimensions but works for now
            y = 250 + row * (CELL_SIZE + GRID_SPACING) # terrible hardcoding with dimensions but works for now
            pygame.draw.rect(screen, HOLE_COLOR, (x, y, CELL_SIZE, CELL_SIZE))

def draw_mole(mole_position):
    """Draw the mole image centered in the active cell."""
    row, col = mole_position
    x = 5 +col * (CELL_SIZE + GRID_SPACING) + (CELL_SIZE - MOLE_SIZE) // 2 # terrible hardcoding with dimensions but works for now
    y = 250 + row * (CELL_SIZE + GRID_SPACING) + (CELL_SIZE - MOLE_SIZE) // 2 # terrible hardcoding with dimensions but works for now
    screen.blit(mole_image, (x, y))

def get_cell_from_mouse_pos(pos):
    x, y = pos
    col = (x - 5) // (CELL_SIZE + GRID_SPACING) # terrible hardcoding with dimensions but works for now
    row = (y - 250) // (CELL_SIZE + GRID_SPACING) # terrible hardcoding with dimensions but works for now
    return int(row), int(col)

def make_button_rect(center_y):
    return pygame.Rect(
        SCREEN_WIDTH // 2 - BUTTON_WIDTH // 2,
        center_y - BUTTON_HEIGHT // 2,
        BUTTON_WIDTH,
        BUTTON_HEIGHT,
    )

def draw_button(rect, text_str):
    pygame.draw.rect(screen, (200, 200, 200), rect)   # button fill
    pygame.draw.rect(screen, (0, 0, 0), rect, 3)      # border
    text_surface = font.render(text_str, True, (0, 0, 0))
    text_rect = text_surface.get_rect(center=rect.center)
    screen.blit(text_surface, text_rect)

