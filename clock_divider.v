// **parameter set is only for default**
module clock_divider #(parameter divisor = 100_000_000)(
    input  wire        clkIn,     // 100MHz clock from FPGA
    input  wire        reset,     // **Self reminder: Active-low reset
    output reg         clkOut     // clock output
);
    
    reg [26:0] count;
    
    always @(posedge clkIn or negedge reset) begin
        if (!reset) begin
            count  <= 27'd0;
            clkOut <= 1'b0;
        end else begin
            clkOut <= 1'b0;
            
            if(count == divisor-1) begin // every 100MHz, send pulse (1Hz)
                count  <= 27'd0;
                clkOut <= 1'b1;
            end else begin
                count <= count + 1;
            end
        end  
    end
endmodule