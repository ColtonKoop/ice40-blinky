`timescale 1ns/1ps

module blinky_tb;
    reg i_Clk = 0;
    wire o_LED_1, o_LED_2, o_LED_3, o_LED_4;

    // Instantiate the DUT
    blinky uut (
        .i_Clk(i_Clk),
        .o_LED_1(o_LED_1),
        .o_LED_2(o_LED_2),
        .o_LED_3(o_LED_3),
        .o_LED_4(o_LED_4)
    );

    // Clock generation
    always #5 i_Clk = ~i_Clk;  // 100MHz clock

    initial begin
        $dumpfile("sim/blinky.vcd");
        $dumpvars(0, blinky_tb);
        #100ms  // simulate for 100ms
        $finish;
    end
endmodule