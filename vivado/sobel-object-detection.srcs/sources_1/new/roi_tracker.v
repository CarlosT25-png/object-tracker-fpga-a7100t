`timescale 1ns / 1ps
module roi_tracker(
    input [9:0] ball_x,
    input [9:0] ball_y,
    input [9:0] vga_h_cnt,
    input [9:0] vga_v_cnt,
    input ball_valid,
    output in_roi
);

// Calculate the absolute distance between current pixel and the ball center
wire [9:0] h_dist = (vga_h_cnt > ball_x) ? (vga_h_cnt - ball_x) : (ball_x - vga_h_cnt);
wire [9:0] v_dist = (vga_v_cnt > ball_y) ? (vga_v_cnt - ball_y) : (ball_y - vga_v_cnt);

// A 100x100 box means +/- 50 pixels in any direction
wire inside_box = (h_dist <= 10'd50) && (v_dist <= 10'd50);

// If we don't know where the ball is, search the whole screen (ROI is everywhere).
// If we DO know where it is, only look inside the box.
assign in_roi = (!ball_valid) || inside_box;

endmodule