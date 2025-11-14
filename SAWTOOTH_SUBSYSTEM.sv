`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/14/2025 02:21:28 PM
// Design Name: 
// Module Name: SAWTOOTH_SUBSYSTEM
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


module sawtooth_subsystem(
    input logic clk,
    input logic reset,
    input logic vcompare_state,  
    output logic sawtooth_out,  
    output logic [7:0] saw_raw_adc_value,
    output logic [7:0] saw_scaled_voltage,
    output logic [7:0] saw_averaged_adc_value,
    output logic [15:0] bcd_out
);    
// INTERNAL SIGNALS
    
    // Sawtooth Signals
    logic sync_edge_out;
    logic [7:0] saw_duty_cycle_out;
    //logic [7:0] saw_raw_adc_value;
    logic       saw_raw_adc_valid;
   // logic [7:0] saw_scaled_voltage;
    //logic [7:0] saw_averaged_adc_value;
    
    // Display Signals
    //logic [3:0] decimal_point;
    logic [15:0] display_data;
    //logic [15:0] bcd_out;
    //logic [15:0] bcd_mux_out;
    
// INSTANTIATIONS
  
    // Comparator edge detector
    edge_detector EDGE_DETECTOR (
        .clk(clk),
        .reset(reset),
        .comparator_raw(vcompare_state),
        .sync_edge_out(sync_edge_out)  
    );

    
    // Sawtooth Waveform 
    sawtooth #(
        .WIDTH(8),
        .CLOCK_FREQ(100_000_000),
        .WAVE_FREQ(1.0)           // 1 Hz
    ) SAWTOOTH_WAVEFORM (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),             // sawtooth waveform always enabled
        .pwm_out(sawtooth_out),   // goes to pin JB2
        .duty_cycle_out(saw_duty_cycle_out) // goes to ADC counter control
    );

    // ADC Count
    adc_capture_control SAWTOOTH_ADC_CAPTURE (
        .clk(clk),
        .reset(reset),
        .enable(1'b1),             // always enabled
        .sync_edge_out(sync_edge_out),
        .duty_cycle_out(saw_duty_cycle_out),
        .raw_adc_value(saw_raw_adc_value),
        .raw_adc_valid(saw_raw_adc_valid)
    );

    // Average and Scale Raw ADC Data
    saw_avg_scale SAW_PROCESSING (
        .clk(clk),
        .reset(reset),
        .adc_valid(saw_raw_adc_valid),
        .raw_adc_value(saw_raw_adc_value),
        .scaled_voltage(saw_scaled_voltage),
        .avg_adc_value(saw_averaged_adc_value)
    );
    
       
    // BCD converter
    bin_to_bcd_saw BIN_TO_BCD_SAW (
        .clk(clk),
        .reset(reset),
        .bin_in({8'b0000_0000,saw_scaled_voltage}),
        .bcd_out(bcd_out)
    );
    

endmodule
