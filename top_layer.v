`timescale 1ns / 1ps

module top_whackamole (
    input  wire        clock,        // 100MHz from FPGA clock
    input  wire        reset,        // Active-low reset button
    input  wire        startButton,  // Start button 
    input  wire [4:0]  moleButton,   // 5 mole buttons
    output wire [4:0]  moleLED       // 5 LEDs for moles respectively
);

    // ----------------------------------------------------------------
    // 1) Setup all Clock Dividers (1Hz, 1kHz)
    // ----------------------------------------------------------------
    // 1Hz clock for mole appearance timing
    wire incrementClock;
    clock_divider #(
        .divisor(100_000_000) // divide by 100 million for 1Hz clock (reconfig default param)
    ) div_1Hz (
        .clkIn  (clock),
        .reset  (reset),
        
        .clkOut (incrementClock)
    );

    // 1kHz clock for segment display 
    wire displayClock;
    clock_divider #(
        .divisor(100_000) // divide by 100 thousand for 1kHz clock (reconfig default param)
    ) div_1kHz (
        .clkIn  (clock),
        .reset  (reset),

        .clkOut (displayClock)
    );

    // ----------------------------------------------------------------
    // 2) Debouncer setup + Initialize 5 mole buttons
    // ----------------------------------------------------------------
    wire game_start; 
    debouncer start_debouncer (
        .clock     (clock),
        .reset     (reset),
        .buttonIn  (startButton),

        .buttonOut (game_start)
    );

    // Create a 5-bit wire to hold all 5 debounced mole button signals
    wire [4:0] moleButtonPulses;
    genvar moleIdx;
    generate // Equivalent to 5 debouncers for the 5 mole buttons
        for (moleIdx = 0; moleIdx < 5; moleIdx = moleIdx + 1) begin : moleButtonDebouncers
            debouncer mole_debouncer (
                .clock     (clock),
                .reset     (reset),
                .buttonIn  (moleButton[moleIdx]),

                .buttonOut (moleButtonPulses[moleIdx])
            );
        end
    endgenerate

    // ----------------------------------------------------------------
    // 3) Game_FSM Setup
    // ----------------------------------------------------------------
    wire [5:0] score;
    wire       game_enable;
    wire       game_over;

    game_fsm whack_a_mole_fsm (
        .clkIn          (clock), // 100MHz clock from FPGA
        .incrementClock (incrementClock), // from 1Hz clock divider
        .reset          (reset),
        .startGame      (game_start), // from start button debouncer
        .player_scored  (moleHit), // bit masking output, 1 if player hit a mole
        .timer_expired  (game_over),

        .game_active    (game_enable), // game status output 
        .score          (score)
    );

    // ----------------------------------------------------------------
    // 4) Mole Generator & Button Press Detection
    // ----------------------------------------------------------------
    wire [4:0] molePositions;
    mole_generator mole_gen (
        .clock         (clock),
        .reset         (reset),
        .enable        (game_enable), // from Game_FSM
        .pulse         (incrementClock), // 1Hz pulse for mole appearance timing from 1Hz clock divider

        .mole_position (molePositions)
    );

    // Directly map each mole positions to their respective mole LEDs
    assign moleLED = molePositions; 
    // Check if the button pressed matches the current active mole position using bit masking
    wire moleHit = |(molePositions & moleButtonPulses); // added bitwise OR reduction in case we want to allow more than one mole appear at a time

endmodule