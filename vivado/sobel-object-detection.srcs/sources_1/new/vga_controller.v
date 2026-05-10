`timescale 1ns / 1ps

module vga_controller(
    input clk_25mhz,
    input rst,
    input scale_sw,
    output reg [16:0] addr,
    output vga_hsync,
    output vga_vsync,
    output video_on,
    output cam_window,

    // centroid
    output [9:0] h_cnt_out,
    output [9:0] v_cnt_out 
);

    // 640x480 timing parameters
    parameter H_ACTIVE = 640;
    parameter H_FP     = 16;
    parameter H_SYNC   = 96;
    parameter H_BP     = 48;
    parameter H_TOTAL  = 800;

    parameter V_ACTIVE = 480;
    parameter V_FP     = 10;
    parameter V_SYNC   = 2;
    parameter V_BP     = 33;
    parameter V_TOTAL  = 525;

    reg [9:0] h_cnt = 0;
    reg [9:0] v_cnt = 0;

    always @(posedge clk_25mhz) begin
        if (rst) begin
            h_cnt <= 0;
            v_cnt <= 0;
        end else begin
            if (h_cnt == H_TOTAL - 1) begin
                h_cnt <= 0;
                if (v_cnt == V_TOTAL - 1)
                    v_cnt <= 0;
                else
                    v_cnt <= v_cnt + 1;
            end else begin
                h_cnt <= h_cnt + 1;
            end
        end
    end

    assign vga_hsync = ~((h_cnt >= (H_ACTIVE + H_FP)) && (h_cnt < (H_ACTIVE + H_FP + H_SYNC)));
    assign vga_vsync = ~((v_cnt >= (V_ACTIVE + V_FP)) && (v_cnt < (V_ACTIVE + V_FP + V_SYNC)));
    assign video_on  = (h_cnt < H_ACTIVE) && (v_cnt < V_ACTIVE);

    // top left camera
    wire small_window = (h_cnt < 320) && (v_cnt < 240);

    // if sw1 is on it will set to full screen
    assign cam_window = scale_sw ? video_on : small_window;

    // centroid
    assign h_cnt_out = h_cnt;
    assign v_cnt_out = v_cnt;

        always @(*) begin
        if (scale_sw) begin
            // pixel double + 180 deg flip
            if (video_on)
                addr = ((239 - v_cnt[9:1]) * 320) + (319 - h_cnt[9:1]);
            else
                addr = 0;
        end else begin
            if (small_window)
                addr = ((239 - v_cnt) * 320) + (319 - h_cnt);
            else
                addr = 0; 
        end
    end

endmodule