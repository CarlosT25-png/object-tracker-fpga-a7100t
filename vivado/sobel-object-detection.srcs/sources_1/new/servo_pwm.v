`timescale 1ns / 1ps
module servo_pwm #(
    parameter CENTER_PWM = 150000, 
    parameter SWEEP_RANGE = 25000, 
    parameter INVERT = 0 
)(
    input clk_100mhz,
    input [9:0] pos,      
    input [9:0] max_pos,  
    output reg pwm_out
);

    reg [20:0] counter = 0;
    
    wire [9:0] actual_pos = INVERT ? (max_pos - pos) : pos;
    
    wire [31:0] base_pwm = CENTER_PWM - SWEEP_RANGE;
    wire [31:0] total_sweep = SWEEP_RANGE * 2;
    
    // target pos servo
    wire [31:0] target_duty = base_pwm + (actual_pos * total_sweep / max_pos);
    
    // current pos
    reg [31:0] current_duty = CENTER_PWM;

    always @(posedge clk_100mhz) begin
        if (counter < 2000000) begin // 20ms period
            counter <= counter + 1;
        end else begin
            counter <= 0;
            current_duty <= target_duty;
        end

        pwm_out <= (counter < current_duty);
    end
endmodule