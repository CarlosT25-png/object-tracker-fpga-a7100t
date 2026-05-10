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

    // ==========================================
    // DIGITAL MANUAL WHITE BALANCE
    // ==========================================
    // Convert to Signed 6-bit so we can do safe math without wrapping around
    wire signed [5:0] raw_r = $signed({2'b00, vga_read_data[11:8]});
    wire signed [5:0] raw_g = $signed({2'b00, vga_read_data[7:4]});
    wire signed [5:0] raw_b = $signed({2'b00, vga_read_data[3:0]});

    // Apply White Balance Gain here! 
    // (e.g., Subtract 2 from Red, Add 4 to Blue to fix a "Yellow" room)
    wire signed [5:0] math_r = raw_r - 6'd2; 
    wire signed [5:0] math_b = raw_b + 6'd4;

    // Clamp values to prevent them from dropping below 0 or going above 15
    wire [3:0] wb_r = (math_r < 0) ? 4'h0 : (math_r > 15 ? 4'hF : math_r[3:0]);
    wire [3:0] wb_g = vga_read_data[7:4]; // Leave Green as the baseline
    wire [3:0] wb_b = (math_b < 0) ? 4'h0 : (math_b > 15 ? 4'hF : math_b[3:0]);

    // The new, color-corrected pixel!
    wire [11:0] balanced_rgb = {wb_r, wb_g, wb_b};

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
        .pixel_rgb(balanced_rgb),
        .ball_detected(ball_pixel)
    );

    // region of interest
    wire in_roi;
    wire [9:0] ball_x, ball_y;
    wire ball_valid;
    roi_tracker roi_0 (
        .ball_x(ball_x),
        .ball_y(ball_y),
        .vga_h_cnt(vga_h_cnt),
        .vga_v_cnt(vga_v_cnt),
        .ball_valid(ball_valid),
        .in_roi(in_roi)
    );


    // ball centroid calculator

    centroid_calculator brain_0 (
        .clk_25mhz(clk_25mhz),
        .rst(1'b0),
        .h_cnt(vga_h_cnt),
        .v_cnt(vga_v_cnt),
        // Require: Color match + Inside Camera + Inside ROI box
        .is_ball_pixel(ball_pixel && cam_window && in_roi),
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

    wire [9:0] target_x, target_y;
    servo_deadband deadband_0 (
        .clk(clk_25mhz),
        .ball_valid(ball_valid),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .stable_pan(target_x),
        .stable_tilt(target_y)
    );

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

    assign vga_red   = crosshair ? 4'hF : (cam_window ? (color_sw ? filter_r : balanced_rgb[11:8]) : 4'h0);
    assign vga_green = crosshair ? 4'h0 : (cam_window ? (color_sw ? filter_g : balanced_rgb[7:4])  : 4'h0);
    assign vga_blue  = crosshair ? 4'h0 : (cam_window ? (color_sw ? filter_b : balanced_rgb[3:0])  : (video_on ? 4'hF : 4'h0));

    assign cam_rst = 1'b1;
    assign cam_pwdn = 1'b0;

    // debug

    assign init_led = init_done;
    assign vsync_led = cam_vsync;
    assign href_led  = cam_href;
    assign pclk_led  = cam_dclk;
    assign ball_valid_led = ball_valid;

endmodule
