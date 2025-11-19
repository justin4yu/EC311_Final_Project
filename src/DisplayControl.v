`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: DisplayControl
// Description: Controls multiplexed 7-segment display refresh
//              Cycles through multiple digits to create persistence of vision
//////////////////////////////////////////////////////////////////////////////////

module DisplayControl #(
    parameter NUM_DIGITS = 4,          // Number of 7-segment displays
    parameter REFRESH_RATE = 100000    // Cycles per digit (1kHz @ 100MHz for 4 digits)
)(
    input wire clk,                    // System clock
    input wire reset,                  // Asynchronous reset
    input wire [31:0] display_value,   // 32-bit value to display (hex)
    output reg [NUM_DIGITS-1:0] digit_select,  // Digit selection (active low typically)
    output wire [3:0] digit_data       // Current digit data (4-bit BCD)
);

    reg [31:0] refresh_counter;
    reg [1:0] current_digit;  // Current digit being displayed (0-3)

    // Extract the current digit's data based on which digit is active
    assign digit_data = (current_digit == 2'd0) ? display_value[3:0] :
                        (current_digit == 2'd1) ? display_value[7:4] :
                        (current_digit == 2'd2) ? display_value[11:8] :
                                                   display_value[15:12];

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            refresh_counter <= 32'd0;
            current_digit <= 2'd0;
            digit_select <= 4'b1110;  // Active low, first digit on
        end
        else begin
            refresh_counter <= refresh_counter + 1;
            
            if (refresh_counter >= REFRESH_RATE) begin
                refresh_counter <= 32'd0;
                
                // Move to next digit
                current_digit <= current_digit + 1;
                
                // Update digit select (active low, one-hot)
                case (current_digit)
                    2'd0: digit_select <= 4'b1110;  // Digit 0 active
                    2'd1: digit_select <= 4'b1101;  // Digit 1 active
                    2'd2: digit_select <= 4'b1011;  // Digit 2 active
                    2'd3: digit_select <= 4'b0111;  // Digit 3 active
                endcase
            end
        end
    end

endmodule
