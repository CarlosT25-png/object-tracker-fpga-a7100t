`timescale 1ns / 1ps

module centroid_calculator(
    input clk_25mhz,
    input rst,
    input [9:0] h_cnt,
    input [9:0] v_cnt,
    input is_ball_pixel,
    input vsync,
    output reg [9:0] x_center,
    output reg [9:0] y_center,
    output reg target_valid
);

    reg [31:0] sum_x = 0;
    reg [31:0] sum_y = 0;
    reg [19:0] count = 0;
    reg last_vsync;
    wire vsync_edge = (last_vsync == 1'b0 && vsync == 1'b1);

    always @(posedge clk_25mhz) begin
        last_vsync <= vsync;

        if (rst) begin
            sum_x <= 0; sum_y <= 0; count <= 0;
            x_center <= 0; y_center <= 0;
        end else if (vsync_edge) begin
            // If we found enough pixels to trust it's the ball
        if (count > 300) begin
            x_center <= sum_x / count;
            y_center <= sum_y / count;
            target_valid <= 1'b1;
        end else begin
            target_valid <= 1'b0;
        end
            // reset for the next frame
            sum_x <= 0;
            sum_y <= 0;
            count <= 0;
        end else if (is_ball_pixel) begin
            sum_x <= sum_x + h_cnt;
            sum_y <= sum_y + v_cnt;
            count <= count + 1;
        end
    end
endmodule