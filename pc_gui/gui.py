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
MOLE_SIZE = 250
GRID_SPACING = 10    

HOLE_COLOR = (139, 69, 19)

# **********Need Modification for FPGA Integration**********
FPS = 30
MOLE_TIME = 1        # seconds a mole stays up
GAME_TIME = 30       # total game time in seconds

# ----------------------------------------------------------------
# Set up the display
# ----------------------------------------------------------------
screen = pygame.display.set_mode((SCREEN_WIDTH, SCREEN_HEIGHT))
pygame.display.set_caption("Whack-a-Mole")

# ----------------------------------------------------------------
# Load images
# ----------------------------------------------------------------
MOLE_IMAGE_PATH = "pc_gui\\transparent_mole.png"
HAMMER_IMAGE_PATH = "pc_gui\\transparent_hammer.png"
BACKGROUND_IMAGE_PATH = "pc_gui\\WhackAMole_background.jpg"  

mole_image = pygame.image.load(MOLE_IMAGE_PATH).convert_alpha()
mole_image = pygame.transform.scale(mole_image, (MOLE_SIZE, MOLE_SIZE))
mole_image = pygame.transform.smoothscale(mole_image, (int(MOLE_SIZE * 1.4), MOLE_SIZE))  # Slightly larger for better fit

hammer_image = pygame.image.load(HAMMER_IMAGE_PATH).convert_alpha()
hammer_image = pygame.transform.scale(hammer_image, (125, 125))

background_image = pygame.image.load(BACKGROUND_IMAGE_PATH).convert()
background_image = pygame.transform.scale(background_image, (SCREEN_WIDTH, SCREEN_HEIGHT))

MOLE_SCALE   = 1.5   # 1.0 = original size, 2.0 = double
HAMMER_SCALE = 1.5

# ----------------------------------------------------------------
# Font
# ----------------------------------------------------------------
font = pygame.font.SysFont("comicsansms", 36)

# ----------------------------------------------------------------
# Drawing Functions
# ----------------------------------------------------------------
def draw_grid():
    for row in range(GRID_ROWS):
        for col in range(GRID_COLS):
            x = 5 + col * (CELL_SIZE + GRID_SPACING) # terrible hardcoding with dimensions but works for now
            y = 250 + row * (CELL_SIZE + GRID_SPACING) # terrible hardcoding with dimensions but works for now
            # Create a surface with per-pixel alpha enabled
            hole_surface = pygame.Surface((CELL_SIZE, CELL_SIZE), pygame.SRCALPHA)

            # Fill with brown *with transparency*
            # (R, G, B, A) → A = alpha transparency 0–255
            hole_surface.fill((139, 69, 19, 180))   # 140 ≈ ~55% opacity

            # Draw the transparent rectangle onto the screen
            screen.blit(hole_surface, (x, y))

def draw_mole(mole_position):
    row, col = mole_position

    # Top-left of the cell
    cell_x = 5 + col * (CELL_SIZE + GRID_SPACING)
    cell_y = 250 + row * (CELL_SIZE + GRID_SPACING)

    # Use the actual size of the mole image
    w = mole_image.get_width()
    h = mole_image.get_height()

    # Center the mole inside the cell
    x = cell_x + (CELL_SIZE - w) // 2 + 11.5
    y = cell_y + (CELL_SIZE - h) // 2 - 20

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