module game_fsm_testbench;

    // Testbench signals
    reg        clkIn;         // 100MHz FPGA clock input
    reg        incrementClk;  // 1Hz clock for game timing
    reg        reset;         // Still active low reset
    reg        startGame;     // Signal to start the game
    reg        player_scored; // Signal when player scores
    reg        timer_expired; // Signal when game timer expires
    wire       game_active;   // Indicates if the game is active, over, or idle
    wire [5:0] score;

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

    // 100 MHz clock (10 ns period)
    initial begin
        clkIn = 1'b0;
        forever #5 clkIn = ~clkIn;
    end

    // **200ns period instead of 1s for faster simulation**
    initial begin
        incrementClk = 1'b0;
        forever #100 incrementClk = ~incrementClk;
    end

    // Manually drive inputs at each state to see the transitions
    initial begin
        reset         = 1'b0;   // assert active-low reset
        startGame     = 1'b0;
        player_scored = 1'b0;
        timer_expired = 1'b0;

        #20;
        reset = 1'b1; // test idle state before forcing an early reset

        // start game
        #20;
        startGame = 1'b1;
        #10;
        startGame = 1'b0;

        // feed the player some points
        #50;
        player_scored = 1'b1;
        #10;
        player_scored = 1'b0;

        #100;
        player_scored = 1'b1;
        #10;
        player_scored = 1'b0;

        // force timer expiration
        #200;
        timer_expired = 1'b1;
        #10;
        timer_expired = 1'b0;

        #200;
        $finish;
    end

endmodule
