`timescale 1ns / 1ps


module camera(
    input clk_100mhz,

    // camera setuo
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

    // spi output video
    output spi_cs,
    output spi_sclk,
    output spi_mosi
    );


    clk_wiz_0 clk_0(
        .clk_in1(clk_100mhz),
        .clk_out1(cam_xclk)
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
        .rst(1'b0),                     // Tie to 0 if not using a reset button
        .rom_data(rom_data_wire),
        .rom_addr(rom_addr_wire),
        .sccb_scl(cam_scl),             // Goes to PMOD JA1
        .sccb_sda(cam_sda),             // Goes to PMOD JA2
        .camera_init_done(init_done)
    );

    // pixel capture
    wire [11:0] pixel_data;
    wire pixel_valid;
    wire [18:0] pixel_addr;

    camera_pixel_capture cam_capture_0 (
        .pclk(cam_dclk),          // Driven by the camera's incoming clock
        .rst(~init_done),         // Hold in reset until SCCB init is completely done
        .vsync(cam_vsync),
        .href(cam_href),
        .data_in(cam_data),
        .data_out(pixel_data),    // The combined 12-bit RGB444 pixel
        .wr_en(pixel_valid),      // Goes HIGH when the pixel is fully assembled
        .out_addr(pixel_addr)     // The target memory address
    );

    // frame buffer - BRAM IP

    wire [15:0] spi_read_data;
    wire [18:0] spi_read_addr;

    frame_buffer bram_spi_0 (
        // port A, write to BRAM from camera
        .clka(cam_dclk),
        .wea(pixel_valid),
        .addra(pixel_addr),
        .dina({4'b0000, pixel_data}), // pad 12 bit RGB44 to 16 bits

        // port b, read from SPI master
        .clkb(clk_100mhz),
        .addrb(spi_read_addr),
        .doutb(spi_read_data)
    );

    spi_frame_tx spi_tx (
        .clk_100mhz(clk_100mhz),
        .rst(1'b0),
        .vsync(cam_vsync),
        .bram_addr(spi_read_addr),
        .bram_data(spi_read_data),
        .spi_cs(spi_cs),
        .spi_sclk(spi_sclk),
        .spi_mosi(spi_mosi)
    );

    assign cam_rst = 1'b1;
    assign cam_pwdn = 1'b0;

endmodule
