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
        .clkIn(clock),
        .reset(reset),
        .clkOut(incrementClock)
    );

    // 1kHz clock for segment display 
    wire displayClock;
    clock_divider #(
        .divisor(100_000) // divide by 100 thousand for 1kHz clock (reconfig default param)
    ) div_1kHz (
        .clkIn(clock),
        .reset(reset),
        .clkOut(displayClock)
    );

    // ----------------------------------------------------------------
    // 2) Debouncer setup + Initialize 5 mole buttons
    // ----------------------------------------------------------------
    wire startPulse; 
    debouncer start_debouncer (
        .clock(clock),
        .reset(reset),
        .buttonIn(startButton),
        .buttonOut(startPulse)
    );

    // Create a 5-bit wire to hold all 5 debounced mole button signals
    wire [4:0] moleButtonPulses;
    genvar moleIdx;
    generate // Equivalent to 5 debouncers for the 5 mole buttons
        for (moleIdx = 0; moleIdx < 5; moleIdx = moleIdx + 1) begin : moleButtonDebouncers
            debouncer mole_debouncer (
                .clock(clock),
                .reset(reset),
                .buttonIn(moleButton[moleIdx]),
                .buttonOut(moleButtonPulses[moleIdx])
            );
        end
    endgenerate

    // ----------------------------------------------------------------
    // 3) Temporary Game Start Enable 
    // ----------------------------------------------------------------
    reg game_enable;
    always 

    @(posedge startPulse or negedge reset) begin
        if (!reset) begin
            game_enable <= 1'b0;
        end else begin
            game_enable <= 1'b1; // For now, just enable game on start button press
        end
    end

endmodule