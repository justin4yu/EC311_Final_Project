`timescale 1ns / 1ps
// Module to convert an 8-bit binary number into two 4-bit Binary-Coded Decimal (BCD) digits.
module bcd_converter (
    input wire [7:0] binary_in,      // 8-bit binary value (e.g., Score, up to 255)
    output wire [3:0] tens_digit,    // BCD value for the tens place
    output wire [3:0] ones_digit     // BCD value for the ones place
);

    // This is a combinational assignment. Since we are using division and modulo,
    // Verilog performs the necessary arithmetic operation.

    // Calculate the Tens digit: Integer division by 10 isolates the tens value.
    assign tens_digit = binary_in / 8'd10;

    // Calculate the Ones digit: Modulo 10 isolates the remainder (the ones value).
    assign ones_digit = binary_in % 8'd10;

endmodule