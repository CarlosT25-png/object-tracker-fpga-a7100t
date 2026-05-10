`timescale 1ns / 1ps
module color_filter(
    input clk,
    input [11:0] pixel_rgb,
    output reg ball_detected
);

// extract the RGB
wire [3:0] r = pixel_rgb[11:8];
wire [3:0] g = pixel_rgb[7:4];
wire [3:0] b = pixel_rgb[3:0];


// calculate Y (Brightness). Formula: (R + 2G + B) / 4
wire [5:0] sum_y = r + (g << 1) + b;
wire [3:0] y = sum_y[5:2];

// color difference from brightness using
wire signed [5:0] cb = $signed({2'b00, b}) - $signed({2'b00, y}); // Chroma Blue
wire signed [5:0] cr = $signed({2'b00, r}) - $signed({2'b00, y}); // Chroma Red
wire signed [5:0] cg = $signed({2'b00, g}) - $signed({2'b00, y}); // Chroma Green


// =========================================================================
// 2. TUNING INSTRUCTIONS
// =========================================================================
// STEP 1: GET THE WHOLE BALL BACK
// If the ball mask is spotty/sparse, you need to LOOSEN the rules:
// -> Change RULE B (cg) to >= -$signed(6'd1)  [Allows less green]
// -> Change RULE A (cb) to <= $signed(6'd2)   [Allows more blue]
// Keep loosening until the ball is a solid white circle. Don't worry about noise yet.
//
// STEP 2: KILL THE SKIN & DESK (The "Cr" Knob)
// If your hand or the wood desk is glowing white on the mask, TIGHTEN RULE C.
// -> Lower 'cr' from 1 down to 0:          (cr <= $signed(6'd0))
// -> Or even lower it to -1 if needed:     (cr <= -$signed(6'd1))
// (Why? Skin and wood reflect a lot of Red. Lowering Cr deletes skin!)
//
// STEP 3: KILL GLARE & WINDOWS (The "Cb" Knob)
// If the window or white keyboard keys show up, TIGHTEN RULE A.
// -> Lower 'cb' from 1 down to 0:          (cb <= $signed(6'd0))
// -> Or even lower it to -1 if needed:     (cb <= -$signed(6'd1))
// (Why? Yellow absorbs blue light. Windows reflect blue light.)
// =========================================================================

// tuning params
wire low_blue = (cb <= -$signed(6'd1)); // best val -1 - fixed

wire high_green = (cg >= $signed(6'd0)); // best val 0

wire low_red = (cr <= $signed(6'd1)); // fixed - best val 1

wire bright_enough = (y >= 4'd3);

// ----------------------------------------

wire raw_match = low_blue && high_green && low_red && bright_enough;

reg [2:0] history_shift;

always @(posedge clk) begin
    history_shift <= {history_shift[1:0], raw_match};
    if (history_shift == 3'b111) begin
        ball_detected <= 1'b1;
    end else begin
        ball_detected <= 1'b0;
    end
end

endmodule
