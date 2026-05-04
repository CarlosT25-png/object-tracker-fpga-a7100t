`timescale 1ns / 1ps

module spi_frame_tx (
    input clk_100mhz,
    input rst,
    input vsync,  // from camera, trigger transmission

    output reg [18:0] bram_addr,  // addr to read from
    input [15:0] bram_data,  // 12 bit rgb data from BRAM

    output reg spi_cs,
    output reg spi_sclk,
    output reg spi_mosi
);

    localparam MAX_ADDR = 19'd76799; // Frame size - 320 * 24- = 76800 px

    localparam IDLE = 3'd0;
    localparam FETCH = 3'd1;
    localparam LOAD = 3'd2;
    localparam SHIFT = 3'd3;
    localparam NEXT = 3'd4;

    reg [2:0] state = IDLE;

    reg vsync_prev = 0;
    wire vsync_falling_edge = (vsync_prev == 1 && vsync == 0);

    reg [3:0] clk_div = 0; // clock divider 100mhz / 10 = 10mhz
    wire tick = (clk_div == 9);

    // data shift reg and bit counter
    reg [15:0] tx_shift_reg;
    reg [4:0] bit_count;

    initial begin
        spi_cs = 1;
        spi_sclk = 0;
        spi_mosi = 0;
        bram_addr = 0;
    end

    always @(posedge clk_100mhz) begin
        if (rst) begin
            state <= IDLE;
            spi_cs <= 1;
            spi_sclk <= 0;
            clk_div <= 0;
            bram_addr <= 0;
            vsync_prev <= 0;
        end else begin
            vsync_prev <= vsync;

            case (state)
                IDLE: begin
                    spi_cs <= 1;
                    spi_sclk <= 0;
                    bram_addr <= 0;
                    if (vsync_falling_edge) begin
                        state <= FETCH;
                        spi_cs <= 0; // start tx
                    end
                end

                FETCH: begin
                    state <= LOAD; // wait 1 cc for BRAM read latency
                end

                LOAD: begin
                    // BRAM -> shift reg
                    tx_shift_reg <= bram_data;
                    bit_count <= 16;
                    clk_div <= 0;
                    spi_sclk <= 0;
                    state <= SHIFT;
                end

                SHIFT: begin
                    clk_div <= clk_div + 1;

                    // clk_div 0 - 4: sclk is low; clk_div 5 - 9: sclk is high
                    if (clk_div == 0) begin
                        spi_sclk <= 0;
                        spi_mosi <= tx_shift_reg[15];
                    end

                    else if (clk_div == 5) begin
                        spi_sclk <= 1; // samples data here on rising edge
                    end

                    else if (clk_div == 9) begin
                        clk_div <= 0;
                        tx_shift_reg <= {tx_shift_reg[14:0], 1'b0};
                        bit_count <= bit_count - 1;

                        if (bit_count == 1) begin
                            state <= NEXT;
                        end
                    end
                end

                NEXT: begin
                    spi_sclk <= 0;

                    if (bram_addr == MAX_ADDR) begin
                        state <= IDLE;
                        spi_cs <= 1; // tx completed
                    end else begin
                        bram_addr <= bram_addr + 1;
                        state <= FETCH;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule
