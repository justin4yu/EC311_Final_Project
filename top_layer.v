`timescale 1ns / 1ps

module top_whackamole (
    input  wire        clock,        // 100MHz from FPGA clock
    input  wire        reset,        // Active-low reset button
    input  wire        startButton,  // Start button 
    input  wire [4:0]  moleButton,   // 5 mole buttons
    input  wire        uart_rx_pin,  // UART receive line 
    output wire        uart_tx_pin,      // UART transmit line
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

        .mole_position (molePositions) // [4:0] output
    );

    // ----------------------------------------------------------------
    // 5) Score Counter
    // ----------------------------------------------------------------
    score_counter score_count (
        .clkIn        (clock),
        .reset        (reset),
        .game_Start   (game_enable),
        .timer_expired(game_over),
        .player_scored(moleHit),
        
        .score        (score)
    );

    // ----------------------------------------------------------------
    // 6) UART TX / RX
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
    // 7) UART Control Logic
    // ----------------------------------------------------------------
    assign moleLED = molePositions;
    wire moleHit = |(molePositions & moleButtonPulses); // bit masking output, 1 if player hit a mole

    // ----------------------------------------------------------------
    // 8) Send mole position to PC when it changes
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