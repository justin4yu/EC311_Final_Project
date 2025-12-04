module top_whackamole (
    input  wire       clock,        // 100MHz from FPGA clock
    input  wire       reset,        // Active-low reset button
    input  wire       startButton,  // Start button 
    input  wire [4:0] moleButton,   // 5 mole buttons
    input  wire       uart_rx_pin,  // UART receive pin from PC
    output wire       uart_tx_pin,  // UART transmit pin to PC
    output wire [4:0] moleLED,      // 5 LEDs for moles respectively
    output wire [7:0] an,           // Output digit select for 7-seg display
    output wire [6:0] seg,          // digitSelect 
    output wire       dp            
);

        // ----------------------------------------------------------------
    // 10) UART Interface
    // ----------------------------------------------------------------
    wire [7:0] tx_data;
    reg        tx_start;
    wire       tx_busy;

    wire [7:0] rx_data;
    wire       rx_ready;

    // UART transmitter: FPGA -> PC
    uart_tx #(
        .CLKS_PER_BIT(10417)   // 100MHz / 9600 baud
    ) uart_tx_inst (
        .clock   (clock),
        .reset   (reset),
        .tx_start(tx_start),
        .tx_data (tx_data),
        .uart_tx (uart_tx_pin), // connect to top-level output pin
        .uart_tx_busy (tx_busy)
    );

    // UART receiver: PC -> FPGA
    uart_rx #(
        .CLKS_PER_BIT(10417)   // must match TX & PC baud
    ) uart_rx_inst (
        .clock   (clock),
        .reset   (reset),
        .uart_rx (uart_rx_pin), // connect to top-level input pin
        .rx_data (rx_data),
        .rx_ready(rx_ready)
    );
    
    // ----------------------------------------------------------------
    // Receives a valid mole click from PC to update score
    // ----------------------------------------------------------------
    reg pc_hit;
    reg start_from_pc;

    always @(posedge clock or negedge reset) begin
        if (!reset) begin
            pc_hit <= 1'b0;
        end else begin
            pc_hit <= 1'b0;  // default each cycle

            if (rx_ready && rx_data == "H") begin // using ASCII 'H' for Hit
                pc_hit <= 1'b1; // one-cycle pulse when PC sends 'H'
            end
        end
    end
    
    // ----------------------------------------------------------------
    // 1) Setup all Clock Dividers (1Hz, 1kHz)
    // ----------------------------------------------------------------
    // 1Hz clock for mole appearance timing
    wire incrementClock;
    clock_divider #(
        .divisor(100_000_000) // divide by 100 million for 1Hz clock (reconfig default param)
    ) div_1Hz (
        .clkIn  (clock),
        .reset  (reset),
        
        .clkOut (incrementClock)
    );

    // 1kHz clock for segment display 
    wire displayClock;
    clock_divider #(
        .divisor(100_000) // divide by 100 thousand for 1kHz clock (reconfig default param)
    ) div_1kHz (
        .clkIn  (clock),
        .reset  (reset),

        .clkOut (displayClock)
    );

    // ----------------------------------------------------------------
    // 2) Debouncer setup + Initialize 5 mole buttons
    // ----------------------------------------------------------------
    wire game_start; 
    debouncer start_debouncer (
        .clock     (clock),
        .reset     (reset),
        .buttonIn  (startButton),

        .buttonOut (game_start)
    );

    // Create a 5-bit wire to hold all 5 debounced mole button signals
    wire [4:0] moleButtonPulses;
    genvar moleIdx;
    generate // Equivalent to 5 debouncers for the 5 mole buttons
        for (moleIdx = 0; moleIdx < 5; moleIdx = moleIdx + 1) begin : moleButtonDebouncers
            debouncer mole_debouncer (
                .clock     (clock),
                .reset     (reset),
                .buttonIn  (moleButton[moleIdx]),

                .buttonOut (moleButtonPulses[moleIdx])
            );
        end
    endgenerate

    // ----------------------------------------------------------------
    // 3) Game_FSM Setup
    // ----------------------------------------------------------------
    wire [5:0] score;
    wire       game_enable;
    wire       game_over;
    wire       moleHit;
    
    wire player_scored;
    wire start_game = game_start | start_from_pc; // OR the start button or PC start signal

    assign player_scored = moleHit | pc_hit; // OR the button or pc valid mole hit
    wire [1:0] fsm_state;  // FSM state exported from game_fsm

    game_fsm whack_a_mole_fsm (
        .clkIn         (clock),       // 100MHz clock from FPGA
        .reset         (reset),
        .startGame     (start_game),  // from button or PC
        .timer_expired (game_over),   // from timer_counter
        .game_active   (game_enable), // game status output 
        .fsm_state     (fsm_state)    // NEW: export state to top-level
    );
    
        // ----------------------------------------------------------------
    // Connect Game Start
    // ----------------------------------------------------------------
    always @(posedge clock or negedge reset) begin
        if (!reset) begin
            start_from_pc <= 1'b0;
        end else begin
            start_from_pc <= 1'b0;

            if (rx_ready && rx_data == "S") begin  // using ASCII 'S' for Start
                start_from_pc <= 1'b1;
            end
        end
    end
    // ----------------------------------------------------------------
    // 4) Mole Generator & Button Press Detection
    // ----------------------------------------------------------------
    
    wire [4:0] molePositions;
    mole_generator mole_gen (
        .clock         (clock),
        .reset         (reset),
        .enable        (game_enable), // from Game_FSM
        .pulse         (incrementClock), // 1Hz pulse for mole appearance timing from 1Hz clock divider

        .mole_position (molePositions) // [4:0] output
    );

    assign moleLED = molePositions;  // Directly map each mole positions to their respective mole LEDs

    // Check if the button pressed matches the current active mole position using bit masking
    assign moleHit = |(molePositions & moleButtonPulses);
    
        // ----------------------------------------------------------------
    // Send mole position to PC when it changes
    // ----------------------------------------------------------------
    reg [4:0] last_mole_pos;
    reg [7:0] tx_data_reg; // holds the data that is being sent via UART
    reg [2:0] mole_index;

    always @* begin
        case (molePositions)
            5'b00001: mole_index = 3'd0;
            5'b00010: mole_index = 3'd1;
            5'b00100: mole_index = 3'd2;
            5'b01000: mole_index = 3'd3;
            5'b10000: mole_index = 3'd4;
            default:  mole_index = 3'd0;  
        endcase
    end

    assign tx_data = tx_data_reg; 

    always @(posedge clock or negedge reset) begin
        if (!reset) begin
            last_mole_pos <= 5'b00000;
            tx_start      <= 1'b0;
            tx_data_reg   <= 8'd0;
        end else begin
            tx_start <= 1'b0;  // default, and reset the tx_busy after each packet sent

            // Send new mole position when it changes
            if (game_enable && (molePositions != last_mole_pos) && !tx_busy) begin
                last_mole_pos <= molePositions;
                tx_data_reg   <= {3'b000, molePositions}; // need to concatenate to feed UART 1 byte data
                tx_start      <= 1'b1; // signal to start TX
            end
        end
    end

    // ----------------------------------------------------------------
    // 5) Timer Counter (for game time - for display only right now)
    // ----------------------------------------------------------------
    wire        timer_done;
    wire [5:0]  current_time;

    timer_counter #(
        .TIMER_BITS (6),
        .MAX_TIME   (30)          // 30-second game, for example
    ) game_timer (
        .clk          (incrementClock), // 1Hz tick
        .reset        (reset),
        .enable       (game_enable),    // count only while game is active
        .timer_done   (game_over),
        .current_time (current_time)
    );
    // NOTE: We are NOT overriding game_over here to keep your behavior the same.
    // If you later want timer-driven game_over, you can connect timer_done to game_over.

    // ----------------------------------------------------------------
    // 6) BCD Converters for Score and Game Timer
    // ----------------------------------------------------------------
    wire [3:0] score_tens;
    wire [3:0] score_ones;
    wire [7:0] score_bcd;

    bcd_converter score_bcd_conv (
        .binary_in  ({2'b00, score}),   // 8-bit
        .tens_digit (score_tens),
        .ones_digit (score_ones)
    );

    wire [3:0] time_tens;
    wire [3:0] time_ones;
    wire [7:0] game_timer_bcd;

    bcd_converter time_bcd_conv (
        .binary_in  ({2'b00, current_time}),
        .tens_digit (time_tens),
        .ones_digit (time_ones)
    );

    assign score_bcd      = {score_tens, score_ones};
    assign game_timer_bcd = {time_tens,  time_ones};

    // ----------------------------------------------------------------
    // 7) Display Controller (select what to show on the 7-seg)
    // ----------------------------------------------------------------
    wire [2:0] current_state;
    wire [3:0] countdown_timer;
    wire [31:0] display_data;
    
    // Local aliases for clarity
    localparam [1:0] FSM_IDLE    = 2'd0;
    localparam [1:0] FSM_RUNNING = 2'd1;
    localparam [1:0] FSM_FINISH  = 2'd2;
    
    localparam [2:0] DISP_IDLE     = 3'd0;
    localparam [2:0] DISP_COUNTDOWN= 3'd1;
    localparam [2:0] DISP_PLAY     = 3'd2;
    localparam [2:0] DISP_GAMEOVER = 3'd3;
    
    reg [2:0] disp_state;
    
    always @(*) begin
        case (fsm_state)
            FSM_IDLE:    disp_state = DISP_IDLE;
            FSM_RUNNING: disp_state = DISP_PLAY;      // show time + score
            FSM_FINISH:  disp_state = DISP_GAMEOVER;  // show GAMEOVER pattern
            default:     disp_state = DISP_IDLE;
        endcase
    end
    
    assign current_state   = disp_state;
    assign countdown_timer = 4'd0;    // you can add a real countdown later
    

    display_control disp_ctrl (
        .current_state   (current_state),
        .countdown_timer (countdown_timer),
        .game_timer_bcd  (game_timer_bcd), // {time_tens, time_ones}
        .score_bcd       (score_bcd),      // {score_tens, score_ones}
        .display_data    (display_data)
    );

    // ----------------------------------------------------------------
    // 8) Seven-Segment Display Driver (Score Display)
    // ----------------------------------------------------------------

    // Instantiate seven-segment driver
    seven_seg_decoder score_display (
        .clk     (displayClock),  // 1kHz display clock
        .reset   (reset),         // active-low in your logic
        .data_in (display_data),  // <--- use the new bus
        .an      (an),
        .seg     (seg),
        .dp      (dp)
    );

    // ----------------------------------------------------------------
    // 9) Score Counter
    // ----------------------------------------------------------------
    score_counter score_count (
        .clkIn        (clock),
        .reset        (reset),
        .game_active  (game_enable),
        .timer_expired(game_over),
        .player_scored(player_scored),
        .score        (score)
    );


endmodule