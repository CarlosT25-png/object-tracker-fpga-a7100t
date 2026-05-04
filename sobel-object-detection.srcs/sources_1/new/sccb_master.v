`timescale 1ns / 1ps


module sccb_master(
    input clk_100mhz,
    input rst,

    // rom
    input [15:0] rom_data, // data comming from camera_init_rom
    output reg [7:0] rom_addr, // address ptr to rom

    // camera interface
    output reg sccb_scl, // SCCB clock out
    inout wire sccb_sda, // SCCB data in/out

    //status
    output reg camera_init_done // goes to 1 when all registers in the ROM are initilialized
    );

    localparam SLAVE_ID = 8'h60; // OV2640 Device ID

    // global counter
    reg [14:0] count; // [14:10] -> 5 bits for 32 transmission phases ; [9:0] for clock divider (100mhz / 1024 = ~97.6khz)
    reg [31:0] data_temp;
    reg sda_out_en;

    initial begin
        count = 0;
        rom_addr = 0;
        camera_init_done = 0;
        sccb_scl = 1;
        sda_out_en = 1;
        data_temp = 32'hFFFF_FFFF;
    end

    // TODO: main counter and shift register logic

endmodule
