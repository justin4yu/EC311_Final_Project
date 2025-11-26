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
    localparam FINISH  = 2'd2;

    reg [1:0] current_state, next_state;

    // Game RESET
    always @(posedge clkIn or posedge reset) begin
        if (!reset) begin
            current_state <= IDLE;
            score         <= 6'd0;
            game_active   <= 1'b0;
        end else begin
            current_state <= next_state;
        end
    end

    // State transitions
    always @(*) begin
       next_state = current_state;
       case (current_state) // Game can only transition in the following ways unless reset has been pressed
            IDLE: begin
                 if (startGame) begin
                    next_state = RUNNING;
                 end
            end
            RUNNING: begin
                 if (timer_expired) begin
                    next_state = FINISH;
                 end
            end
            FINISH: begin
                 if (reset) begin
                    next_state = IDLE;
                 end
            end

            default: next_state = IDLE; // At reset, always start with IDLE state requiring user start input
        endcase
    end

endmodule