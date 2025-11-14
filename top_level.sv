module lab_7_saw_top_level (
    input logic clk,
    input logic reset,
    input logic vcompare_state, // Sawtooth comparator ouput (pin JB1)
    input [1:0] switches_inputs,
    input bcd_select,
    output sawtooth_out, // goes to pin JB2
    output logic CA, CB, CC, CD, CE, CF, CG, DP,
    output logic AN1, AN2, AN3, AN4
    );
    
    
// INTERNAL SIGNALS
    
    // Sawtooth Signals
    logic sync_edge_out;
    logic [7:0] saw_duty_cycle_out;
    logic [7:0] saw_raw_adc_value;
    logic       saw_raw_adc_valid;
    logic [7:0] saw_scaled_voltage;
    logic [7:0] saw_averaged_adc_value;
    
    // Display Signals
    logic [3:0] decimal_point;
    logic [15:0] display_data;
    logic [15:0] bcd_out;
    logic [15:0] bcd_mux_out;
    
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

    // Select which data to display based on switches
    mux4_16_bits SAW_DISPLAY_MUX (
        .raw_adc({8'b0000_0000, saw_raw_adc_value}), // pad with zeroes to make 16 bit
        .averaged_adc({8'b0000_0000,saw_averaged_adc_value}),
        .scaled_voltage({8'b0000_0000, saw_scaled_voltage}),
        .in3(), // unused
        .select(switches_inputs), // two right-most switches
        .display_data(display_data),
        .decimal_point(decimal_point)
    );
    
    // BCD converter
    bin_to_bcd BIN_TO_BCD (
        .clk(clk),
        .reset(reset),
        .bin_in(display_data),
        .bcd_out(bcd_out)
    );
    
    // Select between binary and decimal
    bcd_mux BCD_MUX (
        .bin_data(display_data),
        .bcd_out(bcd_out),
        .bcd_mux_out(bcd_mux_out),
        .select(bcd_select) // leftmost switch
    );
    
    
    // Seven Segment Display
    seven_segment_display_subsystem SEVEN_SEG_DISPLAY (
        .clk(clk),
        .reset(reset),
        .sec_dig1(bcd_mux_out[3:0]),
        .sec_dig2(bcd_mux_out[7:4]),
        .min_dig1(bcd_mux_out[11:8]),
        .min_dig2(bcd_mux_out[15:12]),
        .decimal_point(decimal_point),
        .CA(CA), .CB(CB), .CC(CC), .CD(CD),
        .CE(CE), .CF(CF), .CG(CG), .DP(DP),
        .AN1(AN1), .AN2(AN2), .AN3(AN3), .AN4(AN4)
    );
    
endmodule