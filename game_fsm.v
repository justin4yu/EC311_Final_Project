module game_fsm #(parameter game_timer = 30)(
    input            clkIn,            // 100MHz FPGA clock input
    input            reset,            // Still active low reset
    input            startGame,        // Signal to start the game
    input            timer_expired,    // Signal when game timer expires
    output reg       game_active,      // Indicates if the game is active, over, or idle
    output reg [1:0] fsm_state 

    // Moving output to score_counter 
    // output reg [5:0] score             // (2^6)-1 score range (0-63) ** can revise if needed if we increase game timer range
);
   // States definition
    localparam IDLE    = 2'd0;
    localparam RUNNING = 2'd1;
    localparam FINISH  = 2'd2;

    reg [1:0] current_state, next_state;

    // State reward and logic
    always @(posedge clkIn or negedge reset) begin
        if (!reset) begin
            current_state <= IDLE;
            fsm_state     <= IDLE;
            game_active   <= 1'b0;
        end else begin
            current_state <= next_state;
            fsm_state     <= next_state;
            case(next_state) // Game can only transition in the following ways unless reset has been pressed
                IDLE:    game_active <= 1'b0; // at start, reset score
                RUNNING: game_active <= 1'b1; // game is active
                FINISH:  game_active <= 1'b0; // end game and keep the score
                default: game_active <= 1'b0;
            endcase
        end
    end

    // State transition logic
    always @(*) begin
        next_state = current_state; // default to hold state
        case (current_state)
            IDLE:    if (startGame)     next_state = RUNNING;
            RUNNING: if (timer_expired) next_state = FINISH;
            FINISH:  if (startGame)     next_state = RUNNING;
            // corner case after a game ends, reset to IDLE if anything otherwise player has option to replay or reset
            default:                    next_state = IDLE;
        endcase
    end

endmodule