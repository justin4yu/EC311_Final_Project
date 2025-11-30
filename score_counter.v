module score_counter (
    input            clkIn,          // 100MHz FPGA clock input
    input            reset,          // Still active low reset
    input            gameStart,      // Corner case to account for score increment bug even after starting a new game
    input            timer_expired,  // To signal score reset at start of a new game
    input            player_scored,  // Signal when player scores
    output reg [5:0] score           // (2^6)-1 score range (0-63) ** can revise if needed if we increase game timer range
);

    // Score logic at each input signal instance
    always @(*) begin

    end

endmodule

