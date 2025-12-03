// ---------------------------------------------------------------
// Reference:
// https://forum.digilent.com/topic/24424-arty-a7-100-uart-echo-example-repost/
// ---------------------------------------------------------------

// Using PuTTy as debug terminal -Justin

module uart_rx #(
    // UART Baud rate config
    // (100,000,000 (CLK) / 9600 (BAUD)) =  10417
    parameter CLKS_PER_BIT = 10417  // number of clock cycles per bit
)(
    input  wire       clock,  // 100MHz FPGA clock
    input  wire       reset,  // active-low reset
    input  wire       uart_rx,  // serial line from PC/USB-UART
    output reg  [7:0] rx_data,  // // one byte of data from PC/USB-UART
    output reg        rx_ready  // 1 bit flag to indicate RX is in progress
);

    reg [31:0] reg_clks_cnt = 0;

    // RX states
    localparam RX_IDLE      = 3'b000;
    localparam RX_START_BIT = 3'b001;
    localparam RX_DATA_BITS = 3'b010;
    localparam RX_STOP_BIT  = 3'b011;
    localparam RX_CLEANUP   = 3'b101;

    reg [2:0]  rx_state = RX_IDLE; // by default, receiving end is idle
    reg [7:0]  rx_shift_reg = 8'd0;
    reg [2:0]  rx_bit_idx = 0;

    always @(posedge clock or negedge reset) begin
        if (!reset) begin
            rx_state     <= RX_IDLE;
            reg_clks_cnt <= 32'd0;
            rx_shift_reg <= 8'd0;
            rx_bit_idx    <= 3'd0;
            rx_data      <= 8'd0;
            rx_ready     <= 1'b0;
        end else begin
            rx_ready <= 1'b0;  // default

            case (rx_state)
                RX_IDLE: begin
                    reg_clks_cnt <= 32'd0;
                    rx_bit_idx    <= 3'd0;
                    // wait for start bit (line goes low)
                    if (uart_rx == 1'b0)
                        rx_state <= RX_START_BIT; // receives nothing if no mouse clicks
                end

                // Receiving start bit
                // grab each data bit at the half clock pulse to avoid skew or delay
                RX_START_BIT: begin
                    if (reg_clks_cnt == (CLKS_PER_BIT-1)/2) begin
                        if (uart_rx == 1'b0) begin
                            reg_clks_cnt <= 32'd0;
                            rx_state  <= RX_DATA_BITS;
                        end else begin
                            rx_state  <= RX_IDLE;  // false start
                        end
                    end else begin
                        reg_clks_cnt <= reg_clks_cnt + 1;
                    end
                end

                // Receiving data bits
                RX_DATA_BITS: begin
                    if (reg_clks_cnt < CLKS_PER_BIT-1) begin
                        reg_clks_cnt <= reg_clks_cnt + 1;
                    end else begin
                        reg_clks_cnt <= 32'd0;
                        // grab each data bit at the half clock pulse to avoid skew or delay
                        rx_shift_reg[rx_bit_idx] <= uart_rx;

                        if (rx_bit_idx < 3'd7) begin
                            rx_bit_idx <= rx_bit_idx + 1;
                        end else begin
                            rx_bit_idx <= 3'd0;
                            rx_state  <= RX_STOP_BIT;
                        end
                    end
                end

                // Receiving stop bit
                RX_STOP_BIT: begin
                    if (reg_clks_cnt < CLKS_PER_BIT-1) begin
                        reg_clks_cnt <= reg_clks_cnt + 1;
                    end else begin
                        reg_clks_cnt <= 32'd0;
                        rx_data   <= rx_shift_reg;
                        rx_ready  <= 1'b1;   // pulse new-byte flag
                        rx_state  <= RX_CLEANUP;
                    end
                end

                // Packet received, go back to idle state wait for another start bit
                RX_CLEANUP: begin
                    rx_state <= RX_IDLE;
                end

                default: rx_state <= RX_IDLE;
            endcase
        end
    end
endmodule
