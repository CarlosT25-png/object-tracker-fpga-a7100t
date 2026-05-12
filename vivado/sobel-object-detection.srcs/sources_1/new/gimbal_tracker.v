`timescale 1ns / 1ps
module gimbal_tracker(
    input clk_25mhz,
    input ball_valid,
    input [9:0] ball_x,
    input [9:0] ball_y,
    output reg [9:0] stable_pan = 160,
    output reg [9:0] stable_tilt = 160  // center
);

    reg [23:0] tick_counter = 0;

    // Hardware limits from 3d gimbal
    wire [9:0] TILT_MAX_UP = 10'd150;
    wire [9:0] TILT_MAX_DOWN = 10'd400;
    wire [9:0] PAN_MAX_LEFT = 10'd40;
    wire [9:0] PAN_MAX_RIGHT = 10'd280;

    wire [9:0] err_x = (ball_x > 160) ? (ball_x - 160) : (160 - ball_x);
    wire [9:0] err_y = (ball_y > 120) ? (ball_y - 120) : (120 - ball_y);

    // dynamc spped
    wire [9:0] step_x = (err_x >> 3) + 1;
    wire [9:0] step_y = (err_y >> 3) + 1;

    always @(posedge clk_25mhz) begin
        tick_counter <= tick_counter + 1;

        // 3,000,000 ticks = 120ms.
        if (tick_counter >= 3000000) begin
            tick_counter <= 0;

            if (ball_valid) begin

                if (ball_x > 166 && stable_pan > PAN_MAX_LEFT)
                    stable_pan <= stable_pan - step_x;
                else if (ball_x < 154 && stable_pan < PAN_MAX_RIGHT)
                    stable_pan <= stable_pan + step_x;

                if (ball_y > 126 && stable_tilt < TILT_MAX_DOWN)
                    stable_tilt <= stable_tilt + step_y;
                else if (ball_y < 114 && stable_tilt > TILT_MAX_UP)
                    stable_tilt <= stable_tilt - step_y;
            end
        end
    end
endmodule
