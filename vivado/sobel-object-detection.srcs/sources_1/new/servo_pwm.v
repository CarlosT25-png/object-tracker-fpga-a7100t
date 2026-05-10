`timescale 1ns / 1ps

module servo_pwm #(
    // 1.5ms center point = 150,000 cycles
    parameter CENTER_PWM = 150000, 
    // How many cycles to swing left/right from center. 
    // 25,000 cycles roughly matches a 60-degree camera FOV.
    parameter SWEEP_RANGE = 25000, 
    // Set to 1 to reverse the servo direction
    parameter INVERT = 0 
)(
    input clk_100mhz,
    input [9:0] pos,      
    input [9:0] max_pos,  
    output reg pwm_out
);

    reg [20:0] counter = 0;
    
    // 1. Handle Inversion
    wire [9:0] actual_pos = INVERT ? (max_pos - pos) : pos;
    
    // 2. Map position to the restricted FOV range
    // Formula: Base_PWM + (Position * Total_Sweep / Max_Position)
    wire [31:0] base_pwm = CENTER_PWM - SWEEP_RANGE;
    wire [31:0] total_sweep = SWEEP_RANGE * 2;
    wire [31:0] duty_cycle = base_pwm + (actual_pos * total_sweep / max_pos);

    always @(posedge clk_100mhz) begin
        if (counter < 2000000) // 20ms period
            counter <= counter + 1;
        else
            counter <= 0;

        pwm_out <= (counter < duty_cycle);
    end
endmodule