// ---------------------------------------------------------------
// Reference:
// https://forum.digilent.com/topic/24424-arty-a7-100-uart-echo-example-repost/
// ---------------------------------------------------------------

module uart_tx(
  input        clock,
  input        sw1,
  input        sw2,
  output[0:3]  led,
  output[0:3]  led_g,
  input        uart_rx, 
  output       uart_tx 
);

 // UART BAUD
 // (100,000,000 (CLK) / 9600 (BAUD)) =  10417
 parameter CLKS_PER_BIT    = 10417;
 reg [31:0] reg_clks_cnt = 0;

 // RX
 localparam IDLE         = 3'b000;
 localparam RX_START_BIT = 3'b001;
 localparam RX_DATA_BITS = 3'b010;
 localparam RX_STOP_BIT  = 3'b011;
 localparam CLEANUP      = 3'b101;

 reg [3:0] rx_state;
 reg [7:0] rx_byte;
 reg [2:0] rx_byte_idx;
 reg [7:0] led_reg;
 reg [3:0] debug_reg;

 always @(posedge clock)
 begin
     case(rx_state)
     IDLE:
     begin
        reg_clks_cnt <= 0;
        rx_byte_idx  <= 0;
        if (uart_rx == 1'b0) // start bit
        begin
            rx_state       <= RX_START_BIT;
            debug_reg            <= 4'b1111;
        end
        else
        begin
            rx_state       <= IDLE;
        end     
     end
     RX_START_BIT:
     begin
        if (reg_clks_cnt == (CLKS_PER_BIT - 1) / 2)
        begin
            if (uart_rx == 1'b0) // check start bit still low at the middle of BAUD period
            begin
                reg_clks_cnt <= 0;
                rx_state     <= RX_DATA_BITS;                 
            end
            else
            begin
                rx_state     <= IDLE;
            end          
        end
        else
        begin
            // still sampling for the middle of start bit
            reg_clks_cnt <= reg_clks_cnt + 1;
            rx_state     <= RX_START_BIT;
        end     
     end
     RX_DATA_BITS:
     begin
        if (reg_clks_cnt < CLKS_PER_BIT - 1)
        begin
            reg_clks_cnt <= reg_clks_cnt + 1;
            rx_state     <= RX_DATA_BITS;
        end
        else
        begin
            reg_clks_cnt         <= 0;
            rx_byte[rx_byte_idx] <= uart_rx;
            
            if (rx_byte_idx < 7)
            begin
                rx_byte_idx <= rx_byte_idx + 1;
                rx_state     <= RX_DATA_BITS; 
            end
            else
            begin
                rx_byte_idx <= 0;
                rx_state    <= RX_STOP_BIT; 
            end
        end 
     end
     RX_STOP_BIT:
     begin
        if (reg_clks_cnt < CLKS_PER_BIT - 1)
        begin
            reg_clks_cnt <= reg_clks_cnt + 1;
            rx_state     <= RX_STOP_BIT;
        end
        else
        begin
            reg_clks_cnt <= 0;
            rx_state     <= CLEANUP;
        end      
     end
     CLEANUP:
     begin
        rx_state <= IDLE;
     end
     default:
     begin
        rx_state <= IDLE;
     end
     endcase
  end
 
  always @ (posedge clock)
  begin
    if (sw1) begin
        led_reg <= debug_reg;
    end
    else begin
        led_reg <= rx_byte;
    end
  end 
  
  assign led = led_reg;

endmodule