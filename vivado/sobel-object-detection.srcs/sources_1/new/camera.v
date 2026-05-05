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

    //debug
    output init_led,
    output vsync_led,
    output href_led,
    output pclk_led
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
        .data_out(pixel_data),    // 12 bits
        .wr_en(pixel_valid),
        .out_addr(pixel_addr)
    );

    assign init_led = init_done;
    assign vsync_led = cam_vsync;
    assign href_led  = cam_href;
    assign pclk_led  = cam_dclk;

    // frame buffer - BRAM IP
    wire video_on;
    wire [16:0] vga_read_addr;
    wire [11:0] vga_read_data;    // 12 bits

    frame_buffer bram_vga_0 (
        .clka(cam_dclk),
        .wea(pixel_valid),
        .addra(pixel_addr),
        .dina(pixel_data),        // 12 bits

        .clkb(clk_25mhz),
        .enb(1'b1),
        .addrb(vga_read_addr),
        .doutb(vga_read_data)     // 12 bits
    );

    wire cam_window;

    vga_controller vga_ctrl_0 (
        .clk_25mhz(clk_25mhz),
        .rst(1'b0),
        .scale_sw(scale_sw),
        .addr(vga_read_addr),
        .vga_hsync(vga_hsync),
        .vga_vsync(vga_vsync),
        .video_on(video_on),
        .cam_window(cam_window)
    );

    // color filter
    wire ball_pixel;

    color_filter tracker_0 (
        .clk(clk_25mhz),
        .pixel_rgb(vga_read_data),
        .ball_detected(ball_pixel)
    );

    wire [3:0] filter_r = ball_pixel ? 4'hF : 4'h0;
    wire [3:0] filter_g = ball_pixel ? 4'hF : 4'h0;
    wire [3:0] filter_b = ball_pixel ? 4'hF : 4'h0;

    assign vga_red   = cam_window ? (color_sw ? filter_r : vga_read_data[11:8]) : 4'h0;
    assign vga_green = cam_window ? (color_sw ? filter_g : vga_read_data[7:4])  : 4'h0;
    assign vga_blue  = cam_window ? (color_sw ? filter_b : vga_read_data[3:0])  : (video_on ? 4'hF : 4'h0);

    assign cam_rst = 1'b1;
    assign cam_pwdn = 1'b0;

endmodule
