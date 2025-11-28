`timescale 1ns / 1ps
/*
This subsystem outputs the sawtooth wave, as well as captures and computes the data recieved from the sawtooth comparator circuit.
It takes the data and outputs the raw, averaged, and scaled hexidecimal and decimal values. 
*/


module sawtooth_subsystem(
    input logic clk,
    input logic reset,
    input logic vcompare_state, //sawtooth comparator output 
    output logic sawtooth_out,  //outputs the sawtooth wave
    output logic [7:0] saw_raw_adc_value,   //raw comparator value
    output logic [15:0] saw_scaled_voltage, // hexidecimal scaled and averaged voltage values
    output logic [7:0] saw_averaged_adc_value  // hexidecimal averaged voltage
);    
// INTERNAL SIGNALS
    
    // Sawtooth Signals
    logic sync_edge_out;
    logic [7:0] saw_duty_cycle_out;
    logic       saw_raw_adc_valid;

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
        .WAVE_FREQ(50)           // 1 Hz
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

endmodule
