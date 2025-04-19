module blinky (
    input i_Clk,
    output o_LED_1,
    output o_LED_2,
    output o_LED_3,
    output o_LED_4
);
    reg [25:0] counter = 0;
    wire [3:0] leds;

    always @(posedge i_Clk) begin
        counter <= counter + 1;
    end

    led_driver drv (
        .counter(counter),
        .led(leds)
    );

    assign o_LED_1 = leds[3]; // inverted in led_driver if needed
    assign o_LED_2 = leds[0];
    assign o_LED_3 = leds[1];
    assign o_LED_4 = leds[2];

    `ifdef FORMAL
        reg past_valid = 0;
        always @(posedge i_Clk) begin
            past_valid <= 1;
            if (past_valid) begin
                assert(counter == $past(counter) + 1);
            end
        end
    `endif
        
endmodule

