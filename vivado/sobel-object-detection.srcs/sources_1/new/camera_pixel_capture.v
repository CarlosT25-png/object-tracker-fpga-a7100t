`timescale 1ns / 1ps

module camera_pixel_capture(
    input pclk, // pixel clock camera
    input rst,
    input vsync, // vertical sync
    input href, // horizontal ref
    input [7:0] data_in, // 8 bit data from PMOD JB

    output reg [11:0] data_out, // 12 bit rgb to store in memory
    output reg wr_en, // write enable flah
    output reg [18:0] out_addr // mem addr to write to
    );

    reg [15:0] rgb565 = 0;
    reg [18:0] next_addr = 0;
    reg [1:0] byte_state = 0; // shift reg to track the two bytes of pixel data

    always @(posedge pclk) begin
        if (rst) begin
            out_addr <= 0;
            next_addr <= 0;
            byte_state <= 0;
            wr_en <= 0;
        end

        else if (vsync == 0) begin // is vsync is low, the fram is over, reset mem ptr to 0
            out_addr <= 0;
            next_addr <= 0;
            byte_state <= 0;
            wr_en <= 0;
        end

        else begin
            rgb565 <= {rgb565[7:0], data_in};

            // output adrr + wr flag
            out_addr <= next_addr;
            wr_en <= byte_state[1];

            // output the 12 bit rgb444 color
            data_out <= {rgb565[15:12], rgb565[10:7], rgb565[4:1]};

            // FSM; byte_state[1] goes high evey 2 cc when HREF is high
            byte_state <= {byte_state[0], (href && !byte_state[0])};

            if(byte_state[1]) begin
                next_addr <= next_addr + 1;
            end
        end
    end
endmodule
