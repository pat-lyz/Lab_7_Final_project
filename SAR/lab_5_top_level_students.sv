/*
This design uses the XADC from the IP Catalog. The specific channel is XADC4.
The Auxiliary Analog Inputs are VAUXP[15] and VAUXN[15].
These map to the FPGA pins of N2 and N1, respecitively (also in .XDC).
These map to the JXADC PMOD and the specific PMOD inputs are
JXADC4:N2 and JXAC10:N1, respectively. These pin are right beside the PMOD GND
on JXAC11:GND and JXAC5:GND.

The ADC is set to single-ended, continuous sampling, 1 MSps, 256 averaging. 
Additional averaging is done using the averager module below.
*/
module lab_7 (
    // overall signals
    input  logic        clk,
    input  logic        reset,
    input  logic [3:0]  bin_bcd_select,                     // Sets the values for the switches 
    input  logic        dec_hex,                            // Decides between decimal and hexidecimal values 
    //XADC specific 
    input               vauxp15,                            // Analog input (positive) - connect to JXAC4:N2 PMOD pin  (XADC4)
    input               vauxn15,                            // Analog input (negative) - connect to JXAC10:N1 PMOD pin (XADC4)
    //Sawtooth specific
    input  logic         vcompare_state,                    // Sawtooth comparator ouput (pin JB1)
    output               sawtooth_out,                       // Goes to pin JB2
    //R2R specific
    input  logic         vcompare_state_r2r,                // R2R comparator ouput (pin JB3)    output              sawtooth_out,                       // Goes to pin JB2
    output logic [7:0]   r2r_out,                            // Pins to collect the r2r data
    //Seven segment display signals
    output logic        CA, CB, CC, CD, CE, CF, CG, DP,     
    output logic        AN1, AN2, AN3, AN4,
    output logic [15:0] led,
    
    //SAR signals
    input logic button
);
    // Top level internal signal declarations
    logic [3:0]  decimal_pt;                    // vector to control the decimal point, 1 = DP on, 0 = DP off
                                                // [0001] DP right of seconds digit        
                                                // [0010] DP right of tens of seconds digit
                                                // [0100] DP right of minutes digit        
                                                // [1000] DP right of tens of minutes digit
    logic [15:0] mux_out, dec_out, bin_or_bcd;  // Outputs for display mux's
    logic saw_valid, r2r_vaid;
    logic sawtooth;
    logic [7:0] r2r;
    logic [15:0] r2r_avg;
    logic [15:0] r2r_scaled;
    logic [15:0] saw_avg;
    logic [15:0] saw_scale;
    logic [7:0] r2r_raw;
    logic [7:0] saw_raw;
    logic r2r_valid, saw_valid;
    
                                                        
    //XACD signals                      
    logic [15:0] data, ave_data;                // Raw ADC data
    logic [15:0] scaled_adc_data;               // Scaled ADC data for display                   

    // Ramp signals
    logic [7:0] saw_raw_ramp, r2r_raw_ramp;       // raw data from sawtooth, averaged data for the sawtooth
    logic [7:0] r2r_out_ramp;
    logic saw_valid_ramp;
    logic r2r_valid_ramp;
    logic sawtooth_out_ramp;
    
    // SAR signals
    logic sawtooth_out_sar;
    logic [7:0] r2r_out_sar;
    logic [7:0] r2r_raw_sar;
    logic [7:0] saw_raw_sar;
    
    
    //XADC subsystem
    adc_subsystem ADC_SUBSYSTEM(
        .vauxp15(vauxp15),
        .vauxn15(vauxn15),
        .clk(    clk),
        .reset(  reset),          
        .data(   data[15:0]),
        .ave_data(ave_data),
        .scaled_adc_data(scaled_adc_data)
    );
   
    adc_ramp_subsystem ADC_RAMP(
        .clk(clk),
        .reset(reset),
        .vcompare_state(vcompare_state),    
        .sawtooth_out(sawtooth_out_ramp),        
        .saw_raw(saw_raw_ramp),            //outputs raw sawtooth value
        .vcompare_state_r2r(vcompare_state_r2r),
        .r2r_out(r2r_out_ramp),                      //outputting the sawtooth wave to the r2r ladder
        .r2r_raw(r2r_raw_ramp),            //outputs the raw r2r value
        .r2r_valid_ramp(r2r_valid_ramp),
        .saw_valid_ramp(saw_valid_ramp)
    );
    
    sar_subsystem SAR_SUBSYSTEM(
        .clk(clk),
        .reset(reset),
        .vcompare_state_SAR(vcompare_state_r2r),
        .r2r_out_sar(r2r_out_sar),
        .adc_data(r2r_raw_sar),
        .pwm_adc_data(saw_raw_sar),
        .vcompare_state(vcompare_state),
        .sawtooth_out(sawtooth_out_sar)
    );
    
    mux4_16_SAR_ramp SAR_OR_RAMP(
        .select_signal(button),
        .signal_a(r2r_out_ramp),
        .signal_b(r2r_out_sar),
        .signal_c(sawtooth_out_ramp),
        .signal_d(sawtooth_out_sar),
        .output_pin_a(r2r),
        .output_pin_b(sawtooth)
    );
    assign sawtooth_out = sawtooth;
    assign r2r_out = r2r;
    
    mux4_16_SAR_ramp_raw SAR_OR_RAMP_RAW(
        //ramp raw and valid signals
        .select_signal(button),
        .signal_a(saw_raw_ramp),
        .signal_b(r2r_raw_ramp),
        .signal_c(r2r_valid_ramp),
        .signal_d(saw_valid_ramp),
        //sar raw signals (no valid, outputs a logic 1 instead
        .signal_e(r2r_raw_sar),
        .signal_f(saw_raw_sar),
        
        .output_pin_a (r2r_raw),
        .output_pin_b (saw_raw),
        .output_pin_c(r2r_valid),
        .output_pin_d(saw_valid)
    );

    signal_processing SIGNAL_PROCESSING(
        .clk(clk),
        .reset(reset),  
        .saw_raw_adc_value(saw_raw),            //outputs raw sawtooth value\
        .saw_raw_adc_valid(saw_valid),
        .saw_scaled_voltage(saw_scale),         //outputs scaled sawtooth voltage
        .saw_averaged_adc_value(saw_avg),
        .r2r_raw_adc_valid(r2r_valid),
        .r2r_raw_adc_value(r2r_raw),            //outputs the raw r2r value
        .r2r_scaled_voltage(r2r_scaled),        //outputs the scaled r2r value
        .r2r_averaged_adc_value(r2r_avg)        //outputs the averaged r2r value
    );

    
 // Connect prefered data to LEDs
assign led = bin_bcd_select;

    // Select which data to display based on switches
    mux4_16_bits MUX4 (
        .in0(data[15:4]),               // raw 12-bit ADC hexadecimal
        .in1(ave_data),                 // averaged ADC hexadecimal
        .in2(scaled_adc_data),          // hexadecimal, scaled and averaged
        .in3({8'b0000_0000,saw_raw}),   // raw sawtooth value
        .in4(saw_avg),                  // scaled and averaged sawtooth value, hexidecimal
        .in5(saw_scale),                // scaled hexidecimal sawtooth value
        .in6({8'b0000_0000,r2r_raw}),   // Raw r2r data
        .in7(r2r_avg),                  // averaged r2r data
        .in8(r2r_scaled),               // scaled r2r data
        .select(bin_bcd_select),
        .mux_out(mux_out),
        .decimal_point(decimal_point)
    );
    
    bin_to_bcd BIN_TO_BCD(
        .clk(    clk),
        .reset(  reset),
        .bin_in( mux_out),
        .bcd_out(dec_out)
    );
    

    mux4_16_bin BIN_BCD_MUX(
        .in0(mux_out), // switches value to hex
        .in1(dec_out),// switches value to dec
        .select(dec_hex),
        .mux_out(bin_or_bcd),
        .decimal_point(decimal_pt)
    );
     
    // Seven Segment Display Subsystem
    seven_segment_display_subsystem SEVEN_SEGMENT_DISPLAY (
        .clk(clk), 
        .reset(reset),    
        .sec_dig1(bin_or_bcd[3:0]),     // Lowest digit
        .sec_dig2(bin_or_bcd[7:4]),     // Second digit
        .min_dig1(bin_or_bcd[11:8]),    // Third digit
        .min_dig2(bin_or_bcd[15:12]),   // Highest digit
        .decimal_point(decimal_pt),
        .CA(CA), .CB(CB), .CC(CC), .CD(CD), 
        .CE(CE), .CF(CF), .CG(CG), .DP(DP), 
        .AN1(AN1), .AN2(AN2), .AN3(AN3), .AN4(AN4)
    );
    
endmodule
