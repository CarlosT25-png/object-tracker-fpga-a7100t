`timescale 1ns / 1ps


module camera(
    input clk_100mhz,
    output cam_xclk, // 24 mhz clock for the camera
    output cam_rst, // high low
    output cam_pwdn // 0 -> camera on; 1 -> camera off
    );

    clk_wiz_0 clk_0(
        .clk_in1(clk_100mhz),
        .clk_out1(cam_xclk)
    );

    assign cam_rst = 1'b1;
    assign cam_pwdn = 1'b0;

endmodule
