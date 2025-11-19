module lab_7_top_level_students (
    input  logic   clk,
    input  logic   reset,
    input  logic [2:0] bin_bcd_select, //sets the values for the switches 
    input          vauxp15, // Analog input (positive) - connect to JXAC4:N2 PMOD pin  (XADC4)
    input          vauxn15, // Analog input (negative) - connect to JXAC10:N1 PMOD pin (XADC4)
    input logic vcompare_state, // Sawtooth comparator ouput (pin JB1)
    output sawtooth_out, // goes to pin JB2
    output logic   CA, CB, CC, CD, CE, CF, CG, DP,  //Seven segment display signals
    output logic   AN1, AN2, AN3, AN4,
    output logic [15:0] led
);
    // Internal signal declarations
    logic        ready;              // Data ready from XADC
    logic [15:0] data, ave_data;              // Raw ADC data
    logic [15:0] scaled_adc_data; // Scaled ADC data for display
    logic [6:0]  daddr_in;              // XADC address
    logic        enable;                // XADC enable
    logic [3:0]  decimal_pt; // vector to control the decimal point, 1 = DP on, 0 = DP off
                             // [0001] DP right of seconds digit        
                             // [0010] DP right of tens of seconds digit
                             // [0100] DP right of minutes digit        
                             // [1000] DP right of tens of minutes digit
   
    logic [15:0] bcd_adc, mux_out;      //decimal adc for the XADC, output for the mux
    
    logic [15:0] bcd_saw, saw_scale;    //decimal scaled voltage for the sawtooth, hex scaled voltage for the sawtooth
    logic [7:0] saw_raw, saw_avg;       // raw data from sawtooth, averaged data for the sawtooth
    
    //XADC subsystem
    adc_subsystem ADC_SUBSYSTEM(
        .vauxp15(vauxp15),
        .vauxn15(vauxn15),
        .clk(    clk),
        .reset(  reset),     
        .ready(  ready),     
        .enable( enable),  
        .data(   data[15:0]),
        .ave_data(ave_data),
        .scaled_adc_data(scaled_adc_data),
        .bcd_value(bcd_adc)
    );
    
    //Sawtooth comparator subsystem
    sawtooth_subsystem SAWTOOTH_SUBSYSTEM(
        .clk(clk),
        .reset(reset),
        .vcompare_state(vcompare_state),
        .sawtooth_out(sawtooth_out),
        .saw_raw_adc_value(saw_raw),
        .saw_scaled_voltage(saw_scale),
        .saw_averaged_adc_value(saw_avg),
        .bcd_out(bcd_saw)
    );

    
 // Connect prefered data to LEDs
assign led = saw_scale;

    // Select which data to display based on switches
    mux4_16_bits MUX4 (
        .in0(scaled_adc_data), // hexadecimal, scaled and averaged
        .in1(bcd_adc),       // decimal, scaled and averaged
        .in2(data[15:4]),      // raw 12-bit ADC hexadecimal
        .in3(ave_data),        // averaged and before scaling 16-bit ADC (extra 4-bits from averaging) hexadecimal
        .in4({8'b0000_0000,saw_raw}),   //raw sawtooth value
        .in5(saw_scale),                //scaled hexidecimal sawtooth value
        .in6(saw_avg),                  // scaled and averaged sawtooth value, hexidecimal
        .in7(bcd_saw),                  // decimal scaled and averaged value
        .select(bin_bcd_select),
        .mux_out(mux_out),
        .decimal_point(decimal_point)
    );
     
    // Seven Segment Display Subsystem
    seven_segment_display_subsystem SEVEN_SEGMENT_DISPLAY (
        .clk(clk), 
        .reset(reset),    
        .sec_dig1(mux_out[3:0]),     // Lowest digit
        .sec_dig2(mux_out[7:4]),     // Second digit
        .min_dig1(mux_out[11:8]),    // Third digit
        .min_dig2(mux_out[15:12]),   // Highest digit
        .decimal_point(decimal_pt),
        .CA(CA), .CB(CB), .CC(CC), .CD(CD), 
        .CE(CE), .CF(CF), .CG(CG), .DP(DP), 
        .AN1(AN1), .AN2(AN2), .AN3(AN3), .AN4(AN4)
    );
    
endmodule


