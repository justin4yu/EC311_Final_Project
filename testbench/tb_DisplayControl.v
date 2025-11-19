`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for DisplayControl module
//////////////////////////////////////////////////////////////////////////////////

module tb_DisplayControl;

    // Testbench signals
    reg clk;
    reg reset;
    reg [31:0] display_value;
    wire [3:0] digit_select;
    wire [3:0] digit_data;

    // Instantiate the DisplayControl with small refresh rate for testing
    DisplayControl #(
        .NUM_DIGITS(4),
        .REFRESH_RATE(100)
    ) uut (
        .clk(clk),
        .reset(reset),
        .display_value(display_value),
        .digit_select(digit_select),
        .digit_data(digit_data)
    );

    // Clock generation (10ns period = 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        $display("Starting DisplayControl testbench");
        
        // Initialize
        reset = 1;
        display_value = 32'h12345678;
        #20;
        reset = 0;
        
        // Let it cycle through all digits multiple times
        $display("Testing digit multiplexing with value: %h", display_value);
        #5000;
        
        // Change display value
        display_value = 32'hABCDEF00;
        $display("Changed display value to: %h", display_value);
        #5000;
        
        // Test reset during operation
        $display("Testing reset");
        reset = 1;
        #20;
        reset = 0;
        #2000;
        
        $display("DisplayControl testbench completed");
        $finish;
    end

    // Monitor digit transitions
    always @(digit_select) begin
        $display("Time: %0t - Digit select: %b, Digit data: %h", 
                 $time, digit_select, digit_data);
    end

endmodule
