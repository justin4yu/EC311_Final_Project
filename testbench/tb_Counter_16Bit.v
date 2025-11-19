`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for Counter_16Bit module
//////////////////////////////////////////////////////////////////////////////////

module tb_Counter_16Bit;

    // Testbench signals
    reg clk;
    reg reset;
    reg enable;
    reg up_down;
    reg load;
    reg [15:0] load_value;
    wire [15:0] count;
    wire carry_out;
    wire zero;

    // Instantiate the Counter_16Bit
    Counter_16Bit uut (
        .clk(clk),
        .reset(reset),
        .enable(enable),
        .up_down(up_down),
        .load(load),
        .load_value(load_value),
        .count(count),
        .carry_out(carry_out),
        .zero(zero)
    );

    // Clock generation (10ns period = 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test stimulus
    initial begin
        $display("Starting Counter_16Bit testbench");
        
        // Initialize
        reset = 1;
        enable = 0;
        up_down = 1;
        load = 0;
        load_value = 16'h0000;
        #20;
        reset = 0;
        #10;
        
        // Test counting up
        $display("Testing count up");
        enable = 1;
        up_down = 1;
        #200;
        $display("Count after up: %h", count);
        
        // Test load function
        $display("Testing load function");
        enable = 0;
        load = 1;
        load_value = 16'hFFF0;
        #10;
        load = 0;
        $display("Count after load: %h", count);
        
        // Test counting up to overflow
        $display("Testing overflow");
        enable = 1;
        #200;
        $display("Count near overflow: %h, Carry: %b", count, carry_out);
        
        // Test counting down
        $display("Testing count down");
        up_down = 0;
        load = 1;
        load_value = 16'h0010;
        #10;
        load = 0;
        enable = 1;
        #200;
        $display("Count after down: %h, Zero: %b", count, zero);
        
        // Test underflow
        $display("Testing underflow");
        #200;
        $display("Count near underflow: %h", count);
        
        $display("Counter_16Bit testbench completed");
        $finish;
    end

    // Monitor important events
    always @(posedge carry_out) begin
        $display("Time: %0t - Carry out detected at count: %h", $time, count);
    end
    
    always @(posedge zero) begin
        $display("Time: %0t - Zero flag set", $time);
    end

endmodule
