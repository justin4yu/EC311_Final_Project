`timescale 1ns / 1ps

module top_whackamole (
    input  wire        clock,        // 100MHz from FPGA clock
    input  wire        reset,        // Active-low reset button
    input  wire        startButton,  // Start button 
    input  wire [4:0]  moleButton,   // 5 mole buttons
    output wire [4:0]  moleLED,       // 5 LEDs for moles respectively
    output wire [7:0]  an,           // 
    output wire [6:0]  seg,          // 
    output wire        dp            // 
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
    wire       moleHit;
    
    // temporary hardcode game_over for testbench
    assign game_over = 1'b0;

    game_fsm whack_a_mole_fsm (
        .clkIn         (clock), // 100MHz clock from FPGA
        .incrementClk  (incrementClock), // from 1Hz clock divider
        .reset         (reset),
        .startGame     (game_start), // from start button debouncer
        .player_scored (moleHit), // bit masking output, 1 if player hit a mole
        .timer_expired (game_over),
        .game_active   (game_enable) // game status output 
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

       
    assign moleLED = molePositions;  // Directly map each mole positions to their respective mole LEDs

    // Check if the button pressed matches the current active mole position using bit masking
    assign moleHit = |(molePositions & moleButtonPulses);

    // ----------------------------------------------------------------
    // 5) Timer Counter (for game time – for display only right now)
    // ----------------------------------------------------------------
    wire        timer_done;
    wire [5:0]  current_time;

    timer_counter #(
        .TIMER_BITS (6),
        .MAX_TIME   (30)          // 30-second game, for example
    ) game_timer (
        .clk          (incrementClock), // 1Hz tick
        .reset        (reset),
        .enable       (game_enable),    // count only while game is active
        .load_timer   (~game_enable),   // reload when game is not active
        .timer_done   (game_over),
        .current_time (current_time)
    );
    // NOTE: We are NOT overriding game_over here to keep your behavior the same.
    // If you later want timer-driven game_over, you can connect timer_done to game_over.

    // ----------------------------------------------------------------
    // 6) BCD Converters for Score and Game Timer
    // ----------------------------------------------------------------
    wire [3:0] score_tens;
    wire [3:0] score_ones;
    wire [7:0] score_bcd;

    bcd_converter score_bcd_conv (
        .binary_in  ({2'b00, score}), // zero-extend 6-bit score to 8-bit
        .tens_digit (score_tens),
        .ones_digit (score_ones)
    );

    assign score_bcd = {score_tens, score_ones};

    wire [3:0] time_tens;
    wire [3:0] time_ones;
    wire [7:0] game_timer_bcd;

    bcd_converter time_bcd_conv (
        .binary_in  ({2'b00, current_time}), // zero-extend 6-bit time to 8-bit
        .tens_digit (time_tens),
        .ones_digit (time_ones)
    );

    assign game_timer_bcd = {time_tens, time_ones};

    // ----------------------------------------------------------------
    // 7) Display Controller (select what to show on the 7-seg)
    // ----------------------------------------------------------------
    wire [2:0] current_state;
    wire [3:0] countdown_timer;
    wire [31:0] display_data;

    // For now, since game_fsm does not expose its internal state,
    // we tie current_state to IDLE (3'd0). This keeps other modules untouched.
    assign current_state  = 3'd0;     // IDLE placeholder
    assign countdown_timer = 4'd0;    // no pre-game countdown yet

    display_controller disp_ctrl (
        .current_state   (current_state),
        .countdown_timer (countdown_timer),
        .game_timer_bcd  (game_timer_bcd),
        .score_bcd       (score_bcd),
        .display_data    (display_data)
    );


    // ----------------------------------------------------------------
    // 8) Seven-Segment Display Driver (Score Display)
    // ----------------------------------------------------------------

    // Pack 6-bit score into lowest digits, blank the rest.
    wire [31:0] score_display_data = {
    4'hF, 4'hF, 4'hF, 4'hF,   // digits 7..4 blank
    4'hF, 4'hF,               // digits 3..2 blank
    score[1:0],               // digit 1 = upper 2 bits of score
    score[3:0]                // digit 0 = lower 4 bits of score
    };

    // Instantiate seven-segment driver
    sev_seg_driver score_display (
        .clk     (displayClock),        // 1kHz display clock
        .reset   (reset),               // reset (active low)
        .data_in (score_display_data),  // 32-bit packed score
        .an      (an),                  // digit enable outputs
        .seg     (seg),                 // segment outputs
        .dp      (dp)                   // decimal point
    );


    // ----------------------------------------------------------------
    // 9) Score Counter
    // ----------------------------------------------------------------
    wire [5:0] score;
    score_counter score_count (
        .clkIn        (clock),
        .reset        (reset),
        .gameStart   (game_enable),
        .timer_expired(game_over),
        .player_scored(moleHit),
        .score        (score)
    );

    // ----------------------------------------------------------------
    // 10) UART Interface
    // ----------------------------------------------------------------
    wire [7:0] tx_data;
    reg        tx_start;
    wire       tx_busy;

    wire [7:0] rx_data;
    wire       rx_ready;

    // UART transmitter: FPGA -> PC
    uart_tx #(
        .CLKS_PER_BIT(10417)   // 100MHz / 9600 baud
    ) uart_tx_inst (
        .clock   (clock),
        .reset   (reset),
        .tx_start(tx_start),
        .tx_data (tx_data),
        .uart_tx (uart_tx_pin), // connect to top-level output pin
        .tx_busy (tx_busy)
    );

    // UART receiver: PC -> FPGA
    uart_rx #(
        .CLKS_PER_BIT(10417)   // must match TX & PC baud
    ) uart_rx_inst (
        .clock   (clock),
        .reset   (reset),
        .uart_rx (uart_rx_pin), // connect to top-level input pin
        .rx_data (rx_data),
        .rx_ready(rx_ready)
    );

    // ----------------------------------------------------------------
    // 11) UART Control Logic
    // ----------------------------------------------------------------
    assign moleLED = molePositions;
    wire moleHit = |(molePositions & moleButtonPulses); // bit masking output, 1 if player hit a mole

    // ----------------------------------------------------------------
    // 12) Send mole position to PC when it changes
    // ----------------------------------------------------------------
    reg [4:0] last_mole_pos;
    reg [7:0] tx_data_reg; // holds the data that is being sent via UART

    assign tx_data = tx_data_reg; 

    always @(posedge clock or negedge reset) begin
        if (!reset) begin
            last_mole_pos <= 5'b00000;
            tx_start      <= 1'b0;
            tx_data_reg   <= 8'd0;
        end else begin
            tx_start <= 1'b0;  // default, and reset the tx_busy after each packet sent

            // Send new mole position when it changes
            if (game_enable && (molePositions != last_mole_pos) && !tx_busy) begin
                last_mole_pos <= molePositions;
                tx_data_reg   <= {3'b000, molePositions}; // need to concatenate to feed UART 1 byte data
                tx_start      <= 1'b1; // signal to start TX
            end
        end
    end


    // Directly map each mole positions to their respective mole LEDs
    assign moleLED = molePositions; 
    // Check if the button pressed matches the current active mole position using bit masking
    wire moleHit = |(molePositions & moleButtonPulses); // added bitwise OR reduction in case we want to allow more than one mole appear at a time
    

endmodule