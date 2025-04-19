// src/led_driver.v
module led_driver (
    input [25:0] counter,
    output [3:0] led
);
    assign led[0] = counter[23];
    assign led[1] = counter[24];
    assign led[2] = counter[25];
    assign led[3] = ~counter[23];
endmodule