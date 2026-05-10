`timescale 1ns / 1ps
module color_filter(
    input clk,
    input [11:0] pixel_rgb,
    output reg ball_detected
);

wire [3:0] r = pixel_rgb[11:8];
wire [3:0] g = pixel_rgb[7:4];
wire [3:0] b = pixel_rgb[3:0];

// Pad to 5 bits to prevent overflow/wrap-around bugs!
wire [4:0] r5 = {1'b0, r};
wire [4:0] g5 = {1'b0, g};
wire [4:0] b5 = {1'b0, b};

// Calculate the difference between Red and Green
wire [4:0] rg_diff = (r5 > g5) ? (r5 - g5) : (g5 - r5);

// Define the rules:

// RULE A: Red and Green must be balanced (Not skin/wood)
wire not_skin = (rg_diff <= 5'd3); 

// RULE B: Yellow means Red and Green are BOTH much higher than Blue.
// (Using 5-bit math so 15 + 3 = 18, not 2!)
wire is_yellow = (r5 > b5 + 5'd1) && (g5 > b5 + 5'd1);

// RULE C: Reject the window! 
// If the blue channel is high, it's a white light or glare.
// A yellow ball reflects very little blue light.
wire not_window = (b < 4'hA); // Blue must be less than 10.

// RULE D: Ignore dark shadows
wire bright_enough = (r > 4'h3) && (g > 4'h3);

// The pixel is a candidate if it passes ALL rules
wire raw_match = not_skin && is_yellow && not_window && bright_enough;


// 4. Spatial Noise Filter (Pixel Debouncing)
reg [2:0] history_shift;

always @(posedge clk) begin
    history_shift <= {history_shift[1:0], raw_match};
    
    // Require 3 consecutive matching pixels to delete static
    if (history_shift == 3'b111) begin
        ball_detected <= 1'b1;
    end else begin
        ball_detected <= 1'b0;
    end
end

endmodule