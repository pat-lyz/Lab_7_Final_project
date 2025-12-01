`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2025 08:58:37 PM
// Design Name: 
// Module Name: sar_pwm
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module sar_pwm(
    input logic clk, 
    input logic reset,
    input logic vcompare_state, // SAR comparator ouput (pin JB1)
    output logic sawtooth_out, // pin JB2, outputs the PWM
    output logic [7:0] adc_data
    );
    
        
// INTERNAL SIGNALS

    logic dac_clk;                  // Divided clock for SAR ADC
    logic [7:0] dac_value;          // DAC value from SAR ADC
    logic conversion_done;          // Conversion complete flag
    
    
// INSTANTIATIONS 
    
    // Clock Divider 
    clk_divider #(
        .DIVIDER(1000)
    ) CLK_DIV (
        .clk_100MHz(clk),
        .reset(reset),
        .dac_clk(dac_clk)
    );
    
    // SAR ADC
    sar_adc #(
        .WIDTH(8)
    ) SAR (
        .dac_clk(dac_clk),
        .reset(reset),
        .start_conversion(1'b1),
        .comp_in(vcompare_state),
        .dac_value(dac_value),
        .adc_data(adc_data),
        .conversion_done(conversion_done)
    );
    
    // PWM (DAC Driver)
    pwm #(
        .WIDTH(8)
    ) PWM_DAC (
        .clk(clk), // was dac_clk
        .reset(reset),
        .enable(1'b1),
        .duty_cycle(dac_value),
        .pwm_out(sawtooth_out)
    );
    
endmodule
