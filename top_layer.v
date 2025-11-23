`timescale 1ns / 1ps

module top_whackamole (
    input  wire        clock,        // 100MHz from FPGA clock
    input  wire        reset,        // Active-low reset button
    input  wire        startButton,  // Start button 
    input  wire [4:0]  moleButton,   // 5 mole buttons
    output wire [4:0]  moleLED       // 5 LEDs for moles respectively
);

    // 1) Setup all Clock Dividers (1Hz, 1kHz)
    wire incrementClock;
    clock_divider #(
        .DIVIDE_BY(100_000_000) // divide by 100 million for 1Hz clock (reconfig default param)
    ) clk_div_inst (
        .clk_in(clock),
        .reset(reset),
        .clk_out(incrementClock)
    );

endmodule