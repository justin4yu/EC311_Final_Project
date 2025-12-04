module display_control (
    input wire [2:0]  current_state,      // FSM state (IDLE, COUNTDOWN, PLAY, GAMEOVER)
    input wire [3:0]  countdown_timer,    // 4-bit countdown value (0-5)
    input wire [7:0]  game_timer_bcd,     // 8-bit BCD (Time Tens/Ones)
    input wire [7:0]  score_bcd,          // 8-bit BCD (Score Tens/Ones)
    output reg [31:0] display_data       // 32-bit data for 8 digits (AN7 to AN0)
);

    // FSM States (Local parameters must match those defined in the top module)
    localparam IDLE      = 3'd0;
    localparam COUNTDOWN = 3'd1;
    localparam PLAY      = 3'd2;
    localparam GAMEOVER  = 3'd3;

    // --- Display Data Mux (Combinational Behavioral) ---
    // Defines the 8-digit pattern for each state (AN7...AN0)
    always @(*) begin
        case (current_state)
            // Display: [AN7 AN6 AN5 AN4 AN3 AN2 AN1 AN0]
            
            // IDLE: Blank Blank Blank Blank Blank Blank 0 0
            IDLE:      display_data = {4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'hF, 4'h0, 4'h0}; 
            
            // COUNTDOWN: C d Blank Blank Blank Blank 0 COUNT
            COUNTDOWN: display_data = {4'hC, 4'hD, 4'hF, 4'hF, 4'hF, 4'hF, 4'h0, countdown_timer};
            
            // PLAY: Blank Blank TIME_T TIME_O Blank Blank SCORE_T SCORE_O
            PLAY:      display_data = {4'hF, 4'hF, game_timer_bcd, 4'hF, 4'hF, score_bcd};
            
            // GAMEOVER: E E E Blank Blank Blank SCORE_T SCORE_O
            GAMEOVER:  display_data = {4'hE, 4'hE, 4'hE, 4'hF, 4'hF, 4'hF, score_bcd};
            
            default:   display_data = 32'hFFFFFFFF;
        endcase
    end

endmodule