`timescale 1ns / 1ps

module tb_servo_pwm();

    reg clk_100mhz;
    reg [9:0] pos;
    reg [9:0] max_pos;

    // output
    wire pwm_out;

    servo_pwm #(
        .CENTER_PWM(150000),
        .SWEEP_RANGE(25000),
        .INVERT(0)
    ) uut (
        .clk_100mhz(clk_100mhz),
        .pos(pos),
        .max_pos(max_pos),
        .pwm_out(pwm_out)
    );

    // 10 ns perioud
    always #5 clk_100mhz = ~clk_100mhz;

    initial begin
        clk_100mhz = 0;
        max_pos = 10'd320; // max x axis limit

        // center position
        pos = 10'd160;
        #40000000; // Wait 40ms

        // min bound - far left
        pos = 10'd0;
        #40000000; // Wait 40ms

        // far right
        pos = 10'd320;
        #40000000; // Wait 40ms

        $finish; // End simulation
    end

endmodule
