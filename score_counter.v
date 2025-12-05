module score_counter (
    input            clkIn,          // 100MHz FPGA clock input
    input            reset,          // Still active low reset
    input            game_active,    // To indicate if the game is running
    input            timer_expired,  // To signal score reset at start of a new game
    input            player_scored,  // Signal when player scores
    output reg [5:0] score           // (2^6)-1 score range (0-63) ** can revise if needed if we increase game timer range
);

    // Score logic 
    always @(posedge clkIn or negedge reset) begin
        if (!reset) begin
            score <= 6'd0;
        end else if (timer_expired || !game_active) begin
            // whenever the game is not running, keep score at 0
            score <= 6'd0;
        end else begin
            // each valid mole hit increments score by 1, max score is currently 63
            if (player_scored && score != 8'd200) 
                score <= score + 6'd1;
        end
    end

endmodule

