`timescale 1ns / 1ps
module servo_deadband(
    input clk,
    input ball_valid,
    input [9:0] ball_x,
    input [9:0] ball_y,
    output reg [9:0] stable_pan = 0,
    output reg [9:0] stable_tilt = 0
);

// offsets
wire [9:0] pan_offset = 10'd0;
wire [9:0] tilt_offset = 10'd0;

wire [9:0] raw_target_x = (ball_x > pan_offset) ? (ball_x - pan_offset) : 10'd0;
wire [9:0] raw_target_y = (ball_y > tilt_offset) ? (ball_y - tilt_offset) : 10'd0;

always @(posedge clk) begin
    if (ball_valid) begin
        // pan - requires 3 pixels of movement to update
        if (raw_target_x > stable_pan + 10'd8)
            stable_pan <= raw_target_x;
        else if (raw_target_x < stable_pan - 10'd3)
            stable_pan <= raw_target_x;

        // tilt - requires 3 pixels of movement to update
        if (raw_target_y > stable_tilt + 10'd8)
            stable_tilt <= raw_target_y;
        else if (raw_target_y < stable_tilt - 10'd3)
            stable_tilt <= raw_target_y;
    end
end
endmodule