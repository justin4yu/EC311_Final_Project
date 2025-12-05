module timer_counter #(
    parameter TIMER_BITS = 6,  // Bits needed to represent the max time (e.g., 6 for 0-63)
    parameter MAX_TIME   = 30  // The starting value for the countdown
)(
    input  wire                  clk, // System clock
    input  wire                  reset,
    input  wire                  enable, // Slow clock enable (e.g., 1 Hz pulse)
    output wire                  timer_done, // Flag set when timer reaches zero
    output wire [TIMER_BITS-1:0] current_time // Current countdown value
);

    reg [TIMER_BITS-1:0] timer_reg;

    // Sequential Logic
    always @(posedge clk or negedge reset) begin
        if (!reset) begin
            timer_reg <= MAX_TIME;
        end else if (!enable) begin
            timer_reg <= MAX_TIME;
        end else if (enable && timer_reg > 0) begin
            timer_reg <= timer_reg - 1;
        end
    end

    // Combinational Outputs
    // Note: The comparison (current_time != MAX_TIME) is to prevent timer_done from being true on reset, 
    // when timer_reg is first loaded with MAX_TIME and current_time is combinational and immediately equal.
    assign timer_done = (timer_reg == 0); 
    assign current_time = timer_reg;

endmodule