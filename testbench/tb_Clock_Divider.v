`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for Clock_Divider module
//////////////////////////////////////////////////////////////////////////////////

module tb_Clock_Divider;

    // Testbench signals
    reg clk;
    reg reset;
    wire clk_out;

    // Instantiate the Clock_Divider with a small divider for testing
    Clock_Divider #(.DIVIDER(10)) uut (
        .clk(clk),
        .reset(reset),
        .clk_out(clk_out)
    );

    // Clock generation (10ns period = 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        $display("Starting Clock_Divider testbench");
        
        // Initialize
        reset = 1;
        #20;
        reset = 0;
        
        // Run for several output clock cycles
        #1000;
        
        // Test reset during operation
        reset = 1;
        #20;
        reset = 0;
        #1000;
        
        $display("Clock_Divider testbench completed");
        $finish;
    end

    // Monitor output
    always @(posedge clk_out) begin
        $display("Time: %0t - Clock output toggled", $time);
    end

endmodule
