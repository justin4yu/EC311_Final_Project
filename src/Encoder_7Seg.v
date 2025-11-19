`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: Encoder_7Seg
// Description: Converts 4-bit BCD/hex values to 7-segment display encoding
//              Supports common cathode or common anode displays
//////////////////////////////////////////////////////////////////////////////////

module Encoder_7Seg #(
    parameter COMMON_ANODE = 0  // 0 for common cathode, 1 for common anode
)(
    input wire [3:0] bcd,        // 4-bit BCD/hex input (0-F)
    input wire enable,           // Display enable (blank when low)
    output reg [6:0] segments    // 7-segment output: {g,f,e,d,c,b,a}
);

    reg [6:0] seg_data;

    // 7-segment encoding for hex digits 0-F
    // Segment order: gfedcba
    always @(*) begin
        case (bcd)
            4'h0: seg_data = 7'b0111111;  // 0
            4'h1: seg_data = 7'b0000110;  // 1
            4'h2: seg_data = 7'b1011011;  // 2
            4'h3: seg_data = 7'b1001111;  // 3
            4'h4: seg_data = 7'b1100110;  // 4
            4'h5: seg_data = 7'b1101101;  // 5
            4'h6: seg_data = 7'b1111101;  // 6
            4'h7: seg_data = 7'b0000111;  // 7
            4'h8: seg_data = 7'b1111111;  // 8
            4'h9: seg_data = 7'b1101111;  // 9
            4'hA: seg_data = 7'b1110111;  // A
            4'hB: seg_data = 7'b1111100;  // b
            4'hC: seg_data = 7'b0111001;  // C
            4'hD: seg_data = 7'b1011110;  // d
            4'hE: seg_data = 7'b1111001;  // E
            4'hF: seg_data = 7'b1110001;  // F
            default: seg_data = 7'b0000000;
        endcase
    end

    // Apply enable and common anode/cathode polarity
    always @(*) begin
        if (!enable) begin
            segments = COMMON_ANODE ? 7'b1111111 : 7'b0000000;  // Blank display
        end
        else begin
            segments = COMMON_ANODE ? ~seg_data : seg_data;
        end
    end

endmodule
