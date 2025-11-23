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
        .clk_in(clock),
        .reset(reset),
        .clk_out(incrementClock)
    );

    // 1kHz clock for segment display 
    wire displayClock;
    clock_divider #(
        .divisor(100_000) // divide by 100 thousand for 1kHz clock (reconfig default param)
    ) div_1kHz (
        .clk_in(clock),
        .reset(reset),
        .clk_out(displayClock)
    );

endmodule