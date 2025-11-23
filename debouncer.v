`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/30/2025 11:47:26 AM
// Design Name: 
// Module Name: debouncer
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module debouncer (
    input  wire clock,      // 100MHz clock from FPGA
    input  wire reset,      // **Self reminder: Active-low reset
    input  wire buttonIn,   // What is being detected
    output reg  buttonOut   // Actual output 
);

    // Safe bounce time
    parameter bounceTimeUpperbound = 21'd2000000;
    
    reg [20:0] count;       
    reg        previousState;       
    reg        currentState; 

    always @(posedge clock or negedge reset) begin
        if (!reset) begin // **Active-low reset 
            count        <= 21'd0;
            previousState <= 1'b0;
            currentState     <= 1'b0;
            buttonOut     <= 1'b0;
        
        // Button not pressed
        end else begin
            buttonOut <= 1'b0;
            
            // Check if the physical button input has changed since the previous cycle
            if (buttonIn != currentState) begin 
                // If it changed, indicates either noise or just pressed/released
                count <= 21'd0;
                currentState <= buttonIn;
            
            // If nothing has happened and has not reached 2ms cycle, keep the counter going
            end else if (count < bounceTimeUpperbound) begin 
                count <= count + 1; 
            
            // Counter surpassed its max, real button press
            end else begin 
                
                // Surpassed upperbound, now checking to see if it was a long press (if different than previous state)
                if (buttonIn == 1'b1 && previousState == 1'b0) begin
                    buttonOut <= 1'b1; 
                end
                
                previousState <= buttonIn;
            end
        end
    end
endmodule
