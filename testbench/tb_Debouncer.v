`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for Debouncer module
//////////////////////////////////////////////////////////////////////////////////

module tb_Debouncer;

    // Testbench signals
    reg clk;
    reg reset;
    reg button_in;
    wire button_out;

    // Instantiate the Debouncer with a small debounce time for testing
    Debouncer #(.DEBOUNCE_TIME(100)) uut (
        .clk(clk),
        .reset(reset),
        .button_in(button_in),
        .button_out(button_out)
    );

    // Clock generation (10ns period = 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        $display("Starting Debouncer testbench");
        
        // Initialize
        reset = 1;
        button_in = 0;
        #20;
        reset = 0;
        #100;
        
        // Test button press with bouncing
        $display("Testing button press with bouncing");
        button_in = 1;
        #50 button_in = 0;
        #30 button_in = 1;
        #20 button_in = 0;
        #40 button_in = 1;
        #2000;  // Wait for debounce
        
        // Test button release
        $display("Testing button release");
        button_in = 0;
        #2000;
        
        // Test stable press
        $display("Testing stable press");
        button_in = 1;
        #3000;
        button_in = 0;
        #2000;
        
        $display("Debouncer testbench completed");
        $finish;
    end

    // Monitor output changes
    always @(button_out) begin
        $display("Time: %0t - Button output changed to %b", $time, button_out);
    end

endmodule
