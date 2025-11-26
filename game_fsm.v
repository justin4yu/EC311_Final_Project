module game_fsm #(parameter game_timer = 30)(
    input clkIn,            // 100MHz FPGA clock input
    input incrementClk,     // 1Hz clock for game timing
    input reset,            // Still active low reset
    input startGame,        // Signal to start the game
    input player_scored,    // Signal when player scores
    input timer_expired,    // Signal when game timer expires
    output reg game_active, // Indicates if the game is active, over, or idle
    output reg [5:0] score
);
   // States definition
    localparam IDLE    = 2'd0;
    localparam RUNNING = 2'd1;
    localparam DONE    = 2'd2;

    reg [1:0] current_state, next_state;

    // State transitions
    always @(*) begin
       next_state = current_state;
       case (current_state)
            IDLE: begin
                 if (startGame) begin
                    next_state = RUNNING;
                 end
            end
            RUNNING: begin
                 if (timer_expired) begin
                    next_state = DONE;
                 end
            end
            DONE: begin
                 if (reset) begin
                    next_state = IDLE;
                 end
            end

            default: next_state = IDLE;
        endcase
    end

endmodule