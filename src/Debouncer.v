`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: Debouncer
// Description: Debounces mechanical button/switch inputs to eliminate noise
//              Uses a counter-based approach with configurable debounce time
//////////////////////////////////////////////////////////////////////////////////

module Debouncer #(
    parameter DEBOUNCE_TIME = 1000000  // Default: 10ms at 100MHz clock
)(
    input wire clk,              // System clock
    input wire reset,            // Asynchronous reset
    input wire button_in,        // Raw button input
    output reg button_out        // Debounced button output
);

    reg [31:0] counter;
    reg button_sync_0, button_sync_1;  // Synchronizer flip-flops

    // Synchronize input to avoid metastability
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            button_sync_0 <= 1'b0;
            button_sync_1 <= 1'b0;
        end
        else begin
            button_sync_0 <= button_in;
            button_sync_1 <= button_sync_0;
        end
    end

    // Debounce logic
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            counter <= 32'd0;
            button_out <= 1'b0;
        end
        else begin
            if (button_sync_1 == button_out) begin
                // Input matches output, reset counter
                counter <= 32'd0;
            end
            else begin
                // Input differs from output, increment counter
                counter <= counter + 1;
                if (counter >= DEBOUNCE_TIME) begin
                    // Stable for required time, update output
                    button_out <= button_sync_1;
                    counter <= 32'd0;
                end
            end
        end
    end

endmodule
