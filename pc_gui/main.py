# Cited Source for Pygame Whack-A-Mole Implementation:
# https://medium.com/@uva/building-a-whack-a-mole-game-with-python-and-pygame-264c9f4cd512

import pygame
import random
import time
import serial

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
    make_button_rect,   
    draw_button,        
)
# serial connection
SERIAL_PORT = "COM5" 
BAUD_RATE   = 9600
ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=0.01)

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
    mole_col = 0 # default column
    mole_position = (0, mole_col)
    mole_visible = True

    while running:
        screen.fill(BACKGROUND_COLOR)
        draw_grid()
        current_time   = time.time()
        elapsed_time   = current_time - start_time
        remaining_time = GAME_TIME - elapsed_time

        # End game when time runs out
        if remaining_time <= 0:
            running = False
        ''' End revision '''

        # ----------------------------------------------------------------
        # Need to revise so that the mole generation comes from the recieve UART bytes from FPGA
        # ----------------------------------------------------------------
        '''Need to revise so that the mole generation comes from the recieve UART bytes from FPGA'''
        # Read from serial port for mole position
        try:
            while ser.in_waiting > 0:
                byte = ser.read(1)
                ascii_value = byte.decode('utf-8', errors='ignore')

                if ascii_value in ['0', '1', '2', '3', '4']:
                    mole_col = int(ascii_value)
                    mole_position = (0, mole_col)
                    mole_visible = True
                elif ascii_value == 'R':   # FPGA reset signal
                    print("Got R from FPGA: restarting game on PC")
                    running = False
                    mole_visible = False
                    break
        except Exception as e:
            print(f"Error reading from serial: {e}")
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

                    if clicked_cell == mole_position:
                        score += 1
                        print(f"Hit mole #{clicked_cell[1]}")
                        mole_visible = False  # hide mole until next UART update

                        # ONLY send 'H' to FPGA on a real hit
                        try:
                            ser.write(b"H")
                            print("Sent H to FPGA")
                        except Exception as e:
                            print(f"Error writing to serial: {e}")
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

    # Draw Play Again button 
    play_again_rect = make_button_rect(screen.get_height() // 2 + 80)
    draw_button(play_again_rect, "Play Again")

    pygame.display.flip()
    play_again_clicked = False
    reset_from_fpga    = False
    waiting            = True
    while waiting:
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                waiting = False
                play_again_clicked = False

            elif event.type == pygame.MOUSEBUTTONDOWN:
                if play_again_rect.collidepoint(event.pos):
                    play_again_clicked = True
                    waiting = False
                    try:
                        ser.write(b"S")   # 'S' = Start
                        print("Sent S to FPGA (Play Again clicked)")
                    except Exception as e:
                        print(f"Error writing start to serial: {e}")

        try:
            while ser.in_waiting > 0:
                byte = ser.read(1)
                ascii_value = byte.decode('utf-8', errors='ignore') 

                if ascii_value == 'R':   # FPGA reset signal
                    print("Got R from FPGA: restarting game on PC")
                    reset_from_fpga = True
                    waiting = False
                    break
        except Exception as e:
            print(f"Error reading from serial during game over: {e}")

        pygame.time.delay(10)

    return play_again_clicked or reset_from_fpga

if __name__ == "__main__":
    keep_playing = True
    while keep_playing:
        keep_playing = main()   # main() restarts if Play Again or FPGA reset

    pygame.quit()


