module sev_seg_driver(
    input wire clk,              
    input wire reset,
    input wire [31:0] data_in,   
    output reg [7:0] an,         
    output reg [6:0] seg,        
    output wire dp
    );

    reg [2:0] digit_select;
    reg [3:0] current_digit;

    assign dp = 1'b1; 

    always @(posedge clk or negedge reset) begin
        if (!reset) 
            digit_select <= 0;
        else 
            digit_select <= digit_select + 1;
    end


    always @(*) begin
        case(digit_select)
            3'd0: an = 8'b11111110; 
            3'd1: an = 8'b11111101;
            3'd2: an = 8'b11111011;
            3'd3: an = 8'b11110111;
            3'd4: an = 8'b11101111;
            3'd5: an = 8'b11011111;
            3'd6: an = 8'b10111111;
            3'd7: an = 8'b01111111; 
            default: an = 8'b11111111;
        endcase
    end

   
    always @(*) begin
        case(digit_select)
            3'd0: current_digit = data_in[3:0];
            3'd1: current_digit = data_in[7:4];
            3'd2: current_digit = data_in[11:8];
            3'd3: current_digit = data_in[15:12];
            3'd4: current_digit = data_in[19:16];
            3'd5: current_digit = data_in[23:20];
            3'd6: current_digit = data_in[27:24];
            3'd7: current_digit = data_in[31:28];
            default: current_digit = 4'h0;
        endcase
    end

 
    always @(*) begin
        case(current_digit)
            4'h0: seg = 7'b1000000; // 0
            4'h1: seg = 7'b1111001; // 1
            4'h2: seg = 7'b0100100; // 2
            4'h3: seg = 7'b0110000; // 3
            4'h4: seg = 7'b0011001; // 4
            4'h5: seg = 7'b0010010; // 5
            4'h6: seg = 7'b0000010; // 6
            4'h7: seg = 7'b1111000; // 7
            4'h8: seg = 7'b0000000; // 8
            4'h9: seg = 7'b0010000; // 9
            4'hA: seg = 7'b0001000; // A
            4'hB: seg = 7'b0000011; // B
            4'hC: seg = 7'b1000110; // C
            4'hD: seg = 7'b0100001; // D
            4'hE: seg = 7'b0000110; // E
            4'hF: seg = 7'b1111111; // Blank
            default: seg = 7'b1111111;
        endcase
    end

endmodule