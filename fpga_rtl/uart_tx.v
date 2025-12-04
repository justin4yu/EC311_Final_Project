// ---------------------------------------------------------------
// Reference:
// https://forum.digilent.com/topic/24424-arty-a7-100-uart-echo-example-repost/
// ---------------------------------------------------------------

// Using PuTTy as debug terminal -Justin
module uart_tx #(
    // UART Baud rate config
    // (100,000,000 (CLK) / 9600 (BAUD)) =  10417
    parameter CLKS_PER_BIT = 10417 // number of clock cycles per bit
)(
    input wire       clock, // 100MHz FPGA clock
    input wire       reset, // active-low reset
    input wire       tx_start, // 1 bit flag to start TX
    input wire [7:0] tx_data, // one byte of data to send to PC/USB-UART
    output reg       uart_tx, // UART -> PC TX line (shows the 1 or 0 being sent)
    output reg       uart_tx_busy // 1 bit flag to indicate TX is in progress
);

 reg [31:0] reg_clks_cnt = 0;

 // TX states
 localparam TX_IDLE      = 3'b000;
 localparam TX_START_BIT = 3'b001;
 localparam TX_DATA_BITS = 3'b010;
 localparam TX_STOP_BIT  = 3'b011;
 localparam TX_CLEANUP   = 3'b101;

 reg [2:0] tx_state;
 reg [7:0] tx_shift_reg = 8'd0;  // holds each byte of data being sent
 reg [2:0] tx_bit_idx   = 3'd0;  // index of the bit being sent

 always @(posedge clock)
    if (!reset) begin
        tx_state     <= TX_IDLE;
        reg_clks_cnt <= 32'd0;
        tx_shift_reg <= 8'd0;
        tx_bit_idx   <= 3'd0;
        uart_tx      <= 1'b1;   
        uart_tx_busy      <= 1'b0;
    end else begin
        case(tx_state)
            // Stay in idle until tx_start is signaled
            TX_IDLE: begin
                reg_clks_cnt <= 32'd0;
                tx_bit_idx   <= 3'd0;
                uart_tx      <= 1'b1;   
                uart_tx_busy      <= 1'b0;

                if (tx_start) begin
                    tx_shift_reg <= tx_data;
                    tx_busy      <= 1'b1;
                    tx_state     <= TX_START_BIT;
                end else begin
                    tx_state       <= TX_IDLE;
                end
            end

            // Send start bit
            TX_START_BIT: begin
                uart_tx <= 1'b0; // start bit is always 0 for UART peripheral

                if (reg_clks_cnt < CLKS_PER_BIT - 1) begin
                    reg_clks_cnt <= reg_clks_cnt + 1;
                    tx_state     <= TX_START_BIT;
                end else begin
                    reg_clks_cnt <= 32'd0;
                    tx_state     <= TX_DATA_BITS;
                end
            end

            // Send data bits
            TX_DATA_BITS: begin
                uart_tx <= tx_shift_reg[tx_bit_idx];

                if (reg_clks_cnt < CLKS_PER_BIT - 1) begin
                    reg_clks_cnt <= reg_clks_cnt + 1;
                    tx_state     <= TX_DATA_BITS;
                end else begin
                    reg_clks_cnt <= 32'd0;
                    
                    if (tx_bit_idx < 3'd7) begin
                        tx_bit_idx <= tx_bit_idx + 1;
                        tx_state   <= TX_DATA_BITS; 
                    end else begin
                        tx_bit_idx <= 3'd0;
                        tx_state   <= TX_STOP_BIT; 
                    end
                end 
            end

            // Send stop bit, no parity bit
            TX_STOP_BIT: begin
                uart_tx <= 1'b1; // stop bit is always 1 for UART peripheral

                if (reg_clks_cnt < CLKS_PER_BIT - 1) begin
                    reg_clks_cnt <= reg_clks_cnt + 1;
                    tx_state     <= TX_STOP_BIT;
                end else begin
                    reg_clks_cnt <= 0;
                    tx_state     <= TX_CLEANUP;
                end      
            end

            // Packet sent, reset back to idle state, wait for next packet send
            TX_CLEANUP: begin
                tx_state <= TX_IDLE;
            end

            default: begin
                tx_state <= TX_IDLE;
            end
            endcase
    end

endmodule