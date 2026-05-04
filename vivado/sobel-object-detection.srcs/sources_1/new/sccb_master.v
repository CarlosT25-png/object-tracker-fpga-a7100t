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

    // clock generation
    always @(posedge clk_100mhz) begin
        if (count[14:10] == 0) begin
            sccb_scl <= 1;
        end else if (count[14:10] == 1) begin
            if (count[9:8] == 2'b11) sccb_scl <= 0; // start condition
            else sccb_scl <= 1;
        end else if (count[14:10] == 29) begin
            if (count[9:8] == 2'b00) sccb_scl <= 0; // STOP setup
            else sccb_scl <= 1;
        end else if (count[14:10] == 30 || count[14:10] == 31) begin
            sccb_scl <= 1;
        end //stop condition
        else begin
            if (count[9:8] == 2'b00) sccb_scl <= 0;

            else if (count[9:8] == 2'b01 || count[9:8] == 2'b10) sccb_scl <= 1;
            else sccb_scl <= 0;
        end
    end

    // sccb_data bidirectional control
    always @(posedge clk_100mhz) begin
        if (count[14:10] == 10 || count[14:10] == 19 || count[14:10] == 28) begin
            sda_out_en <= 0;
        end else begin
            sda_out_en <= 1;
        end
    end

    assign sccb_sda = (sda_out_en) ? data_temp[31] : 1'bz; // send MSB or z

    // TODO: main counter and shift register logic
    always @(posedge clk_100mhz) begin
        if (rst) begin
            count <= 0;
            rom_addr <= 0;
            camera_init_done <= 0;
            data_temp <= 32'hFFFF_FFFF;
        end
        else if (!camera_init_done) begin
            if (count == 0) begin
                if (rom_data == 16'hFFFF) begin
                    camera_init_done <= 1; // End of ROM reached
                end else begin
                    // {START(2), ID(8), ACK(1), REG_ADDR(8), ACK(1), VALUE(8), ACK(1), STOP(3)}
                    data_temp <= {2'b10, SLAVE_ID, 1'b1, rom_data[15:8], 1'b1, rom_data[7:0], 1'b1, 3'b011};
                    count <= count + 1;
                end
            end 
            else begin
                // we reached the end of Phase 31, reset to 0 to fetch next word
                if (count[14:10] == 31 && count[9:0] == 1023) begin
                    count <= 0; 
                end else begin
                    count <= count + 1;
                end

                // increment ROM address at Phase 30.
                // because BRAM has a 1 clock cycle read delay, incrementing here
                if (count[14:10] == 30 && count[9:0] == 0) begin
                    rom_addr <= rom_addr + 1;
                end

                // shift data_temp left at the start of every new phase
                if (count[9:0] == 0) begin
                    data_temp <= {data_temp[30:0], 1'b1};
                end
            end
        end
    end

endmodule
