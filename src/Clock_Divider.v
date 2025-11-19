`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: Clock_Divider
// Description: Divides input clock frequency by a programmable factor
//              Useful for creating slower clock signals from a fast system clock
//////////////////////////////////////////////////////////////////////////////////

module Clock_Divider #(
    parameter DIVIDER = 100000000  // Default divider value (for 1Hz from 100MHz)
)(
    input wire clk,           // Input clock
    input wire reset,         // Asynchronous reset
    output reg clk_out        // Divided clock output
);

    reg [31:0] counter;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 32'd0;
            clk_out <= 1'b0;
        end
        else begin
            if (counter >= (DIVIDER - 1)) begin
                counter <= 32'd0;
                clk_out <= ~clk_out;  // Toggle output clock
            end
            else begin
                counter <= counter + 1;
            end
        end
    end

endmodule
