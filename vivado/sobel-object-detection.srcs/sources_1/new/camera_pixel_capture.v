`timescale 1ns / 1ps

module camera_pixel_capture(
    input pclk,
    input rst,
    input vsync,
    input href,
    input [7:0] data_in,
    output reg [11:0] data_out,
    output reg wr_en,
    output reg [16:0] out_addr
);

    reg byte_flag;
    reg [7:0] latched_data;

    reg last_vsync;
    reg last_href;

    reg [9:0] cam_x;
    reg [9:0] cam_y;

    always @(posedge pclk) begin
    last_vsync <= vsync;
    last_href  <= href;

    if (rst || (last_vsync == 1'b0 && vsync == 1'b1)) begin
        out_addr <= 0;
        byte_flag <= 0;
        wr_en <= 0;
        cam_x <= 0;
        cam_y <= 0;
    end else begin
        // reset X on every line to prevent horizontal drift
        if (last_href == 1'b0 && href == 1'b1) begin
            cam_x <= 0;
        end
        // increment Y on end of line
        if (last_href == 1'b1 && href == 1'b0) begin
            cam_y <= cam_y + 1;
        end

        if (href) begin
            if (byte_flag == 0) begin
                latched_data <= data_in;
                byte_flag <= 1;
                wr_en <= 0;
            end else begin
                byte_flag <= 0;
                // reconstruct RGB444
                data_out <= {latched_data[7:4], latched_data[2:0], data_in[7], data_in[4:1]};

                if (cam_x[0] == 1'b0 && cam_y[0] == 1'b0) begin
                    wr_en <= 1;
                    // logic: (Y/2 * 320) + (X/2)
                    out_addr <= (cam_y[9:1] * 320) + cam_x[9:1];
                end else begin
                    wr_en <= 0;
                end

                cam_x <= cam_x + 1;
            end
        end else begin
            wr_en <= 0;
            byte_flag <= 0;
        end
    end
end
endmodule
