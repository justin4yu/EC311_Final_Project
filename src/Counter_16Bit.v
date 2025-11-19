`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: Counter_16Bit
// Description: 16-bit up/down counter with enable and load functionality
//              Useful for counting events, timekeeping, or display updates
//////////////////////////////////////////////////////////////////////////////////

module Counter_16Bit (
    input wire clk,              // System clock
    input wire reset,            // Asynchronous reset
    input wire enable,           // Counter enable
    input wire up_down,          // 1 = count up, 0 = count down
    input wire load,             // Load enable
    input wire [15:0] load_value, // Value to load
    output reg [15:0] count,     // Current count value
    output wire carry_out,       // Carry out (overflow/underflow)
    output wire zero             // Zero flag
);

    // Carry out occurs at max value (up) or zero (down)
    assign carry_out = (up_down && (count == 16'hFFFF)) || 
                       (!up_down && (count == 16'h0000));
    
    // Zero flag
    assign zero = (count == 16'h0000);

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            count <= 16'h0000;
        end
        else if (load) begin
            count <= load_value;
        end
        else if (enable) begin
            if (up_down) begin
                count <= count + 1;  // Count up
            end
            else begin
                count <= count - 1;  // Count down
            end
        end
    end

endmodule
