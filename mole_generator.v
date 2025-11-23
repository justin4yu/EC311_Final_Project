module mole_generator (
    input  wire      clock,        // 100MHz clock from FPGA
    input  wire      reset,        // **Self reminder: Active-low reset
    input  wire      enable,       // Game running or not
    input  wire      pulse,        // Pulse to generate new mole position, from 1Hz clock divider
    output reg [4:0] mole_position // Indicates which LED is on for each mole
);
    // 3-bit LFSR for "random" number generation
    reg  [2:0]  lfsr; // max states (1-7)
    wire        feedback = lfsr[2] ^ lfsr[0]; // XOR of MSB and LSB (can be changed for different sequences)
    wire [2:0]  nxt_bit = {lfsr[1:0], feedback}; // ***Might not be the most optimial feedback sequence***
    //wire [2:0]  idx = nxt_bit % 5 // Method 1 for randomization
    
    // Method 2: Direct Mapping
    reg [2:0]  idx;
    always @(*) begin
        case (nxt_bit)
            3'b001: idx = 3'd0; // Mole 1
            3'b010: idx = 3'd1; // Mole 2
            3'b011: idx = 3'd2; // Mole 3
            3'b100: idx = 3'd3; // Mole 4
            3'b101: idx = 3'd4; // Mole 5
            3'b110: idx = 3'd0; // Can play around with these wrap arounds
            3'b111: idx = 3'd1; // Can play around with these wrap arounds
            default: idx = 3'd0; // Default to Mole 1: maybe change for (000,110,111)
        endcase
    end

    always @(posedge clock or negedge reset) begin
        //Using one-hot encoding for mole positions
        if (!reset) begin
            mole_position <= 5'b00000; 
            lfsr <= 3'b001; // Initialize LFSR with the nonzero seed
        end else begin
            // If game is finished, turn off all moles
            if (!enable) begin
                mole_position <= 5'b00000;
            end else if (pulse) begin
                // Generate a random mole position using LFSR, LSB (Mole 1) to MSB (Mole 5)
                lfsr <= nxt_bit; // Update LFSR 
                mole_position <= (5'b00001 << idx); // Shift to turn on a new random mole
            end
        end
    end
endmodule

