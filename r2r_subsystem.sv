`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/28/2025 11:31:38 AM
// Design Name: 
// Module Name: r2r_subsystem
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


module r2r_subsystem(
    input logic clk,
    input logic reset,
    input logic vcompare_state_r2r, // R2R comparator ouput (pin JB3)
    output logic [7:0] r2r_out,
    output logic [7:0] r2r_raw_adc_value, 
    output logic [15:0] r2r_scaled_voltage,
    output logic [15:0] r2r_averaged_adc_value
    );
    
// INTERNAL SIGNALS
    
    // R2R Signals
    logic r2r_sync_edge_out;
    logic [7:0]  r2r_counter;
    logic r2r_raw_adc_valid;
    
// INSTANTIATIONS
  
    // Comparator edge detector
    edge_detector EDGE_DETECTOR (
        .clk(clk),
        .reset(reset),
        .comparator_raw(vcompare_state_r2r),
        .sync_edge_out(r2r_sync_edge_out)  
    );



    r2r_waveform R2R_waveform(
        .clk(clk),
        .reset(reset),
        .r2r_counter(r2r_counter)
    );
    
      // Connect R2R output to external pins
   assign r2r_out = r2r_counter; 
    
    // ADC Count
    adc_capture_control R2R_ADC_CAPTURE (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),             // always enabled
        .sync_edge_out(r2r_sync_edge_out),
        .duty_cycle_out(r2r_counter), // *********************************************************************
        .raw_adc_value(r2r_raw_adc_value),
        .raw_adc_valid(r2r_raw_adc_valid)
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
  
    assign r2r_out = r2r_counter; 
    
endmodule

