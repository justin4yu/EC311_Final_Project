`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Testbench for Encoder_7Seg module
//////////////////////////////////////////////////////////////////////////////////

module tb_Encoder_7Seg;

    // Testbench signals
    reg [3:0] bcd;
    reg enable;
    wire [6:0] segments;

    // Instantiate the Encoder_7Seg (common cathode)
    Encoder_7Seg #(.COMMON_ANODE(0)) uut (
        .bcd(bcd),
        .enable(enable),
        .segments(segments)
    );

    // Test stimulus
    initial begin
        $display("Starting Encoder_7Seg testbench");
        $display("Testing all hex digits (0-F)");
        
        enable = 1;
        
        // Test all hex values
        for (integer i = 0; i < 16; i = i + 1) begin
            bcd = i;
            #10;
            $display("BCD: %h -> Segments: %b", bcd, segments);
        end
        
        // Test enable/disable
        $display("Testing enable control");
        bcd = 4'h8;
        #10;
        $display("Enabled - BCD: %h -> Segments: %b", bcd, segments);
        
        enable = 0;
        #10;
        $display("Disabled - BCD: %h -> Segments: %b", bcd, segments);
        
        enable = 1;
        #10;
        $display("Re-enabled - BCD: %h -> Segments: %b", bcd, segments);
        
        $display("Encoder_7Seg testbench completed");
        $finish;
    end

endmodule
