`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Module: LEDGen
// Description: LED pattern generator with multiple display modes
//              Can generate various patterns like running lights, blinking, etc.
//////////////////////////////////////////////////////////////////////////////////

module LEDGen #(
    parameter NUM_LEDS = 16
)(
    input wire clk,                    // System clock
    input wire reset,                  // Asynchronous reset
    input wire enable,                 // Enable pattern generation
    input wire [1:0] mode,            // Pattern mode selection
    output reg [NUM_LEDS-1:0] leds    // LED outputs
);

    reg [31:0] counter;
    reg [3:0] position;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            leds <= {NUM_LEDS{1'b0}};
            counter <= 32'd0;
            position <= 4'd0;
        end
        else if (enable) begin
            counter <= counter + 1;
            
            // Update pattern every 2^20 cycles (adjustable)
            if (counter[19:0] == 20'd0) begin
                case (mode)
                    2'b00: begin  // Running light
                        leds <= {NUM_LEDS{1'b0}};
                        leds[position] <= 1'b1;
                        position <= (position < NUM_LEDS-1) ? position + 1 : 4'd0;
                    end
                    
                    2'b01: begin  // Binary counter
                        leds <= leds + 1;
                    end
                    
                    2'b10: begin  // Alternating pattern
                        leds <= ~leds;
                    end
                    
                    2'b11: begin  // Knight Rider effect
                        if (position < NUM_LEDS-1) begin
                            leds <= (1 << position);
                            position <= position + 1;
                        end
                        else begin
                            position <= 4'd0;
                        end
                    end
                endcase
            end
        end
    end

endmodule
