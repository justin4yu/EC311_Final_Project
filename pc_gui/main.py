# Cited Source for Pygame Whack-A-Mole Implementation:
# https://medium.com/@uva/building-a-whack-a-mole-game-with-python-and-pygame-264c9f4cd512

import pygame
import random
import time

# Import all the stuff defined in gui.py
from gui import (
    screen,
    font,
    hammer_image,
    GRID_COLS,
    BACKGROUND_COLOR,
    GAME_TIME,
    MOLE_TIME,
    FPS,
    draw_grid,
    draw_mole,
    get_cell_from_mouse_pos,
    SCREEN_WIDTH,
    SCREEN_HEIGHT,
)

def main():
    # ----------------------------------------------------------------
    # This has been hardencoded for game start, need to integrate this for FPGA game start signal
    # ----------------------------------------------------------------
    clock = pygame.time.Clock()  # Manages frame rate

    running = True
    score = 0

    start_time = time.time()
    last_mole_time = start_time

    # ----------------------------------------------------------------
    # initial mole position (row is always 0 in a 1x5 grid)
    # ----------------------------------------------------------------
    '''Need to revise so that the mole generation comes from the recieve UART bytes from FPGA'''
    # initial mole position (row is always 0 in a 1x5 grid)
    mole_position = (0, random.randint(0, GRID_COLS - 1))
    mole_visible = True

    while running:
        screen.fill(BACKGROUND_COLOR)
        draw_grid()
        current_time = time.time    ()
        elapsed_time = current_time - start_time
        remaining_time = GAME_TIME - elapsed_time

        # End game when time runs out
        if remaining_time <= 0:
            running = False
        ''' End revision '''

        # ----------------------------------------------------------------
        # Need to revise so that the mole generation comes from the recieve UART bytes from FPGA
        # ----------------------------------------------------------------
        '''Need to revise so that the mole generation comes from the recieve UART bytes from FPGA'''
        if current_time - last_mole_time > MOLE_TIME:
            mole_position = (0, random.randint(0, GRID_COLS - 1))
            last_mole_time = current_time
            mole_visible = True
        ''' End revision '''

        # ----------------------------------------------------------------
        # Event Handling
        # ----------------------------------------------------------------
        ''' Need to revise so that the mouse click detection can come from the FPGA input '''
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False

            elif event.type == pygame.MOUSEBUTTONDOWN:
                if mole_visible:
                    mouse_pos = pygame.mouse.get_pos()
                    clicked_cell = get_cell_from_mouse_pos(mouse_pos)

                    # clicked_cell is (row, col) – we compare to mole_position
                    if clicked_cell == mole_position:
                        score += 1
                        print(f"Hit mole #{clicked_cell[1]}")
                        mole_visible = False  # hide mole until next timer
        ''' End revision '''

        if mole_visible:
            draw_mole(mole_position)

        #----------------------------------------------------------------
        # Game Info Display
        # ----------------------------------------------------------------
        '''DOES NOT NEED REVISION'''
        # Draw time (bottom-left)
        time_text = font.render(f"Time: {int(max(0, remaining_time))}s", True, (0, 0, 0))
        screen.blit(time_text, (10,  SCREEN_HEIGHT - 100))

        # Draw score (bottom-left)
        score_text = font.render(f"Score: {score}", True, (0, 0, 0))
        screen.blit(score_text, (10, SCREEN_HEIGHT - 50))

        # Draw hammer cursor at mouse position
        mouse_pos = pygame.mouse.get_pos()
        hammer_rect = hammer_image.get_rect(center=mouse_pos)
        screen.blit(hammer_image, hammer_rect.topleft)

        pygame.display.flip()
        clock.tick(FPS)

    # ----------------------------------------------------------------
    # Game Over Menu
    # ----------------------------------------------------------------
    ''' Need to revise so that the game over display can be sent to FPGA display output and also add a Play Again Button '''
    game_over_text = font.render("Game Over!", True, (0, 0, 0))
    final_score_text = font.render(f"Final Score: {score}", True, (0, 0, 0))

    screen.fill(BACKGROUND_COLOR)
    screen.blit(
        game_over_text,
        (screen.get_width() // 2 - game_over_text.get_width() // 2,
         screen.get_height() // 2 - 60),
    )
    screen.blit(
        final_score_text,
        (screen.get_width() // 2 - final_score_text.get_width() // 2,
         screen.get_height() // 2),
    )
    ''' End revision '''


    pygame.display.flip()
    pygame.time.wait(20000)

    pygame.quit()


if __name__ == "__main__":
    main()
