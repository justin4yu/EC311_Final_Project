`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: TopLevel_Example
// Description: Example top-level module integrating all components
//              Demonstrates a complete system with counter displayed on 7-seg
//              and LED patterns controlled by buttons
//////////////////////////////////////////////////////////////////////////////////

module TopLevel_Example (
    input wire clk,                    // 100MHz system clock
    input wire reset,                  // Reset button
    input wire btn_count_enable,       // Button to enable/disable counter
    input wire btn_led_mode_0,         // LED mode select bit 0
    input wire btn_led_mode_1,         // LED mode select bit 1
    output wire [15:0] leds,           // 16 LEDs
    output wire [3:0] digit_select,    // 4 digit select outputs (active low)
    output wire [6:0] segments         // 7-segment outputs
);

    // Internal signals
    wire clk_1Hz;                      // 1Hz clock for counter
    wire clk_100Hz;                    // 100Hz clock for LED updates
    wire btn_count_enable_clean;
    wire btn_led_mode_0_clean;
    wire btn_led_mode_1_clean;
    wire [1:0] led_mode;
    wire [15:0] count;
    wire [3:0] digit_data;

    // Combine LED mode bits
    assign led_mode = {btn_led_mode_1_clean, btn_led_mode_0_clean};

    // Clock dividers
    Clock_Divider #(.DIVIDER(50000000)) clk_div_1Hz (
        .clk(clk),
        .reset(reset),
        .clk_out(clk_1Hz)
    );

    Clock_Divider #(.DIVIDER(500000)) clk_div_100Hz (
        .clk(clk),
        .reset(reset),
        .clk_out(clk_100Hz)
    );

    // Button debouncers
    Debouncer #(.DEBOUNCE_TIME(1000000)) db_count (
        .clk(clk),
        .reset(reset),
        .button_in(btn_count_enable),
        .button_out(btn_count_enable_clean)
    );

    Debouncer #(.DEBOUNCE_TIME(1000000)) db_mode0 (
        .clk(clk),
        .reset(reset),
        .button_in(btn_led_mode_0),
        .button_out(btn_led_mode_0_clean)
    );

    Debouncer #(.DEBOUNCE_TIME(1000000)) db_mode1 (
        .clk(clk),
        .reset(reset),
        .button_in(btn_led_mode_1),
        .button_out(btn_led_mode_1_clean)
    );

    // 16-bit counter
    Counter_16Bit counter (
        .clk(clk_1Hz),
        .reset(reset),
        .enable(btn_count_enable_clean),
        .up_down(1'b1),              // Count up
        .load(1'b0),
        .load_value(16'h0000),
        .count(count),
        .carry_out(),
        .zero()
    );

    // LED pattern generator
    LEDGen #(.NUM_LEDS(16)) led_gen (
        .clk(clk_100Hz),
        .reset(reset),
        .enable(1'b1),
        .mode(led_mode),
        .leds(leds)
    );

    // Display controller
    DisplayControl #(
        .NUM_DIGITS(4),
        .REFRESH_RATE(25000)         // ~1kHz refresh per digit
    ) disp_ctrl (
        .clk(clk),
        .reset(reset),
        .display_value({16'h0000, count}),
        .digit_select(digit_select),
        .digit_data(digit_data)
    );

    // 7-segment encoder
    Encoder_7Seg #(.COMMON_ANODE(0)) seg_enc (
        .bcd(digit_data),
        .enable(1'b1),
        .segments(segments)
    );

endmodule
