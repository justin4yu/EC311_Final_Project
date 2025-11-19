`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for LEDGen module
//////////////////////////////////////////////////////////////////////////////////

module tb_LEDGen;

    // Testbench signals
    reg clk;
    reg reset;
    reg enable;
    reg [1:0] mode;
    wire [15:0] leds;

    // Instantiate the LEDGen
    LEDGen #(.NUM_LEDS(16)) uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .mode(mode),
        .leds(leds)
    );

    // Clock generation (10ns period = 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        $display("Starting LEDGen testbench");
        
        // Initialize
        reset = 1;
        enable = 0;
        mode = 2'b00;
        #20;
        reset = 0;
        #10;
        
        // Test Mode 0: Running light
        $display("Testing Mode 0: Running light");
        enable = 1;
        mode = 2'b00;
        #10000000;  // Run for a while to see pattern
        $display("Mode 0 LED state: %b", leds);
        
        // Test Mode 1: Binary counter
        $display("Testing Mode 1: Binary counter");
        mode = 2'b01;
        #10000000;
        $display("Mode 1 LED state: %b", leds);
        
        // Test Mode 2: Alternating pattern
        $display("Testing Mode 2: Alternating pattern");
        mode = 2'b10;
        #10000000;
        $display("Mode 2 LED state: %b", leds);
        
        // Test Mode 3: Knight Rider effect
        $display("Testing Mode 3: Knight Rider effect");
        mode = 2'b11;
        #10000000;
        $display("Mode 3 LED state: %b", leds);
        
        // Test disable
        $display("Testing disable");
        enable = 0;
        #1000;
        $display("Disabled LED state: %b", leds);
        
        $display("LEDGen testbench completed");
        $finish;
    end

endmodule
