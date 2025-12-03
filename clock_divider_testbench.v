module clock_divider_testbench;
    reg  clock;      // 100MHz clock    
    reg  reset;      // active-low reset
    wire clkOut;     // clock output should be 10MHz for divisor param - 10

    // DUT
    clock_divider #(.divisor(10)) dut ( // short input clock period for testbench 
        .clock (clock),
        .reset (reset),
        .clkOut(clkOut)
    );

    // 10 ns period to simulate our 100MHz FPGA clock
    initial begin
        clock = 1'b0;
        forever #5 clock = ~clock;
    end

    // Active low reset test
    initial begin
        reset = 1'b0;
        #30;
        reset = 1'b1;   

        // let the clock divider run for a while
        #500;
        $finish;
    end

endmodule
