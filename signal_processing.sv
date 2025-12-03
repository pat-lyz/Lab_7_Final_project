`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2025 07:18:26 PM
// Design Name: 
// Module Name: signal_processing
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


module signal_processing(
    input logic clk,
    input logic reset,
    input logic [7:0] saw_raw_adc_value,
    input logic saw_raw_adc_valid,
    input logic r2r_raw_adc_valid,
    input logic [7:0] r2r_raw_adc_value,
    output logic [15:0] r2r_averaged_adc_value,
    output logic [15:0] r2r_scaled_voltage,
    output logic [15:0] saw_averaged_adc_value,
    output logic [15:0] saw_scaled_voltage
    );

   saw_avg_scale SAW_PROCESSING (
        .clk(clk),
        .reset(reset),
        .adc_valid(saw_raw_adc_valid),
        .raw_adc_value(saw_raw_adc_value),
        .scaled_voltage(saw_scaled_voltage),
        .avg_adc_value(saw_averaged_adc_value)
    );   
    
        // Average and Scale Raw ADC Data
    R2R_avg_scale R2R_PROCESSING (
        .clk(clk),
        .reset(reset),
        .adc_valid(r2r_raw_adc_valid),
        .raw_adc_value(r2r_raw_adc_value),
        .scaled_voltage(r2r_scaled_voltage),
        .avg_adc_value(r2r_averaged_adc_value)
    );
    
    
endmodule
