module game_fsm_tb;
    input clkIn,            // 100MHz FPGA clock input
    input incrementClk,     // 1Hz clock for game timing
    input reset,            // Still active low reset
    input startGame,        // Signal to start the game
    input player_scored,    // Signal when player scores
    input timer_expired,    // Signal when game timer expires
    output reg game_active, // Indicates if the game is active, over, or idle
    output reg [5:0] score

    // DUT
    game_fsm #(.game_timer(30)) dut (
        .clkIn        (clkIn),
        .incrementClk (incrementClk),
        .reset        (reset),
        .startGame    (startGame),
        .player_scored(player_scored),
        .timer_expired(timer_expired),
        .game_active  (game_active),
        .score        (score)
    );

    // Simulated 100 MHz clock
    initial begin
        clkIn = 0;
        forever #5 clkIn = ~clkIn;
    end

    // **200ns period instead of 1s for faster simulation**
    initial begin
        incrementClk = 0;
        forever #100 incrementClk = ~incrementClk;
    end

    // Manually drive inputs at each state to see the transitions
    initial begin
        reset         = 0;   // perform active-low reset
        startGame     = 0;
        player_scored = 0;
        timer_expired = 0;

        #20;
        reset = 1;           // test idle state before forcing an early reset

        // start game
        #20;
        startGame = 1;
        #10;
        startGame = 0;

        // feed the player some points
        #50;
        player_scored = 1;
        #10;
        player_scored = 0;

        #100;
        player_scored = 1;
        #10;
        player_scored = 0;

        // force timer expiration
        #200;
        timer_expired = 1;
        #10;
        timer_expired = 0;

        #200;
        $finish;
    end

endmodule
