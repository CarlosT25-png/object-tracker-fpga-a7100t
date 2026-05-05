`timescale 1ns / 1ps

module color_filter(
    input clk,
    input [11:0] pixel_rgb,
    output reg ball_detected
    );

    wire [3:0] r = pixel_rgb[11:8];
    wire [3:0] g = pixel_rgb[7:4];
    wire [3:0] b = pixel_rgb[3:0];

    always @(posedge clk) begin
        if (r > 4'h9 && g > 4'h9 && b < 4'h6) begin
            ball_detected <= 1'b1;
        end else begin
            ball_detected <= 1'b0;
        end
    end
endmodule
