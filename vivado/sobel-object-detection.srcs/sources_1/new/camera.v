`timescale 1ns / 1ps

module camera(
    input clk_100mhz,

    // camera setup
    output cam_xclk, // 24 mhz clock for the camera
    output cam_rst, // high low
    output cam_pwdn, // 0 -> camera on; 1 -> camera off
    output wire cam_scl,
    inout wire cam_sda,

    // camera video
    input cam_vsync,
    input cam_href,
    input cam_dclk,
    input [7:0] cam_data,
    input scale_sw,
    input color_sw,

    // vga output
    output [3:0] vga_red,
    output [3:0] vga_green,
    output [3:0] vga_blue,
    output vga_hsync,
    output vga_vsync,

    // pan and tilt gimbal + laser
    output servo_pan,
    output servo_tilt,
    output laser_en,

    //debug
    output init_led,
    output vsync_led,
    output href_led,
    output pclk_led,
    output ball_valid_led
    );

    wire clk_25mhz;

    clk_wiz_0 clk_0(
        .clk_in1(clk_100mhz),
        .clk_out1(cam_xclk),
        .clk_out2(clk_25mhz)
    );

    // camera init + rom
    wire [7:0] rom_addr_wire;
    wire [15:0] rom_data_wire;
    wire init_done;

    camera_init_rom cam_rom_0 (
        .clk_100mhz(clk_100mhz),
        .rom_addr(rom_addr_wire),
        .rom_data(rom_data_wire)
    );

    sccb_master cam_sccb_0 (
        .clk_100mhz(clk_100mhz),
        .rst(1'b0),
        .rom_data(rom_data_wire),
        .rom_addr(rom_addr_wire),
        .sccb_scl(cam_scl),
        .sccb_sda(cam_sda),
        .camera_init_done(init_done)
    );

    // pixel capture
    wire [11:0] pixel_data;
    wire pixel_valid;
    wire [16:0] pixel_addr;

    camera_pixel_capture cam_capture_0 (
        .pclk(cam_dclk),
        .rst(~init_done),
        .vsync(cam_vsync),
        .href(cam_href),
        .data_in(cam_data),
        .data_out(pixel_data),
        .wr_en(pixel_valid),
        .out_addr(pixel_addr)
    );

    // frame buffer - BRAM IP
    wire video_on;
    wire [16:0] vga_read_addr;
    wire [11:0] vga_read_data;

    frame_buffer bram_vga_0 (
        .clka(cam_dclk),
        .wea(pixel_valid),
        .addra(pixel_addr),
        .dina(pixel_data),

        .clkb(clk_25mhz),
        .enb(1'b1),
        .addrb(vga_read_addr),
        .doutb(vga_read_data)
    );

    wire cam_window;

    wire [9:0] vga_h_cnt, vga_v_cnt;

    vga_controller vga_ctrl_0 (
        .clk_25mhz(clk_25mhz),
        .rst(1'b0),
        .scale_sw(scale_sw),
        .addr(vga_read_addr),
        .vga_hsync(vga_hsync),
        .vga_vsync(vga_vsync),
        .video_on(video_on),
        .cam_window(cam_window),
        .h_cnt_out(vga_h_cnt),
        .v_cnt_out(vga_v_cnt)
    );

    // color filter
    wire ball_pixel;

    color_filter tracker_0 (
        .clk(clk_25mhz),
        .pixel_rgb(vga_read_data),
        .ball_detected(ball_pixel)
    );

    // ball centroid calculator
    wire [9:0] ball_x, ball_y;
    wire ball_valid;

    centroid_calculator brain_0 (
        .clk_25mhz(clk_25mhz),
        .rst(1'b0),
        .h_cnt(vga_h_cnt),
        .v_cnt(vga_v_cnt),
        .is_ball_pixel(ball_pixel && cam_window),
        .vsync(vga_vsync),
        .x_center(ball_x),
        .y_center(ball_y),
        .target_valid(ball_valid)
    );

    wire crosshair = ball_valid && (
        ((vga_h_cnt >= ball_x - 5 && vga_h_cnt <= ball_x + 5) && (vga_v_cnt == ball_y)) ||
        ((vga_v_cnt >= ball_y - 5 && vga_v_cnt <= ball_y + 5) && (vga_h_cnt == ball_x))
    );

    wire [3:0] filter_r = ball_pixel ? 4'hF : 4'h0;
    wire [3:0] filter_g = ball_pixel ? 4'hF : 4'h0;
    wire [3:0] filter_b = ball_pixel ? 4'hF : 4'h0;

    // pan and tilt gimbal
    // x axis
    wire [9:0] pan_offset = 10'd100;  //  laser to the right
    wire [9:0] tilt_offset = 10'd40;  // laser height

    wire [9:0] target_x = (ball_x > pan_offset) ? (ball_x - pan_offset) : 10'd0;
    wire [9:0] target_y = (ball_y > tilt_offset) ? (ball_y - tilt_offset) : 10'd0;

    // Pan Servo (X axis)
    servo_pwm #(
        .CENTER_PWM(150000),
        .SWEEP_RANGE(25000),
        .INVERT(1)
    ) pan_ctrl (
        .clk_100mhz(clk_100mhz),
        .pos(target_x),
        .max_pos(10'd320),
        .pwm_out(servo_pan)
    );

    // Tilt Servo (Y axis)
    servo_pwm #(
        .CENTER_PWM(150000),
        .SWEEP_RANGE(25000),
        .INVERT(0) 
    ) tilt_ctrl (
        .clk_100mhz(clk_100mhz),
        .pos(target_y),
        .max_pos(10'd240),
        .pwm_out(servo_tilt)
    );

    assign vga_red   = crosshair ? 4'hF : (cam_window ? (color_sw ? filter_r : vga_read_data[11:8]) : 4'h0);
    assign vga_green = crosshair ? 4'h0 : (cam_window ? (color_sw ? filter_g : vga_read_data[7:4])  : 4'h0);
    assign vga_blue  = crosshair ? 4'h0 : (cam_window ? (color_sw ? filter_b : vga_read_data[3:0])  : (video_on ? 4'hF : 4'h0));

    assign cam_rst = 1'b1;
    assign cam_pwdn = 1'b0;

    // debug

    assign init_led = init_done;
    assign vsync_led = cam_vsync;
    assign href_led  = cam_href;
    assign pclk_led  = cam_dclk;
    assign ball_valid_led = ball_valid;

endmodule
