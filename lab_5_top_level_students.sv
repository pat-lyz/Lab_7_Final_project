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
    input  logic   clk,
    input  logic   reset,
    input  logic [3:0] bin_bcd_select, //sets the values for the switches 
    input  logic dec_hex,              // decides between decimal and hexidecimal values 
    output logic [7:0] r2r_out,         // pins to collect the r2r data
    input          vauxp15, // Analog input (positive) - connect to JXAC4:N2 PMOD pin  (XADC4)
    input          vauxn15, // Analog input (negative) - connect to JXAC10:N1 PMOD pin (XADC4)
    input logic vcompare_state, // Sawtooth comparator ouput (pin JB1)
    input logic vcompare_state_r2r, // R2R comparator ouput (pin JB3)
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
   
    logic [15:0] mux_out, dec_out, bin_or_bcd;      //decimal adc for the XADC, output for the mux
    
    logic [15:0] bcd_saw, saw_scale, r2r_scaled, r2r_avg;    //decimal scaled voltage for the sawtooth, hex scaled voltage for the sawtooth
    logic [7:0] saw_raw, saw_avg, r2r_raw;       // raw data from sawtooth, averaged data for the sawtooth
    
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
        .scaled_adc_data(scaled_adc_data)
    );
    
    //Sawtooth comparator subsystem
    sawtooth_subsystem SAWTOOTH_SUBSYSTEM(
        .clk(clk),
        .reset(reset),
        .vcompare_state(vcompare_state),
        .sawtooth_out(sawtooth_out),
        .saw_raw_adc_value(saw_raw),
        .saw_scaled_voltage(saw_scale),
        .saw_averaged_adc_value(saw_avg)
    );
    
    //R2R Subsystem
    r2r_subsystem R2R_SUBSYSTEM(
        .clk(clk),
        .reset(reset),
        .vcompare_state_r2r(vcompare_state_r2r),
        .r2r_out(r2r_out),
        .r2r_raw_adc_value(r2r_raw),
        .r2r_scaled_voltage(r2r_scaled),
        .r2r_averaged_adc_value(r2r_avg)
    );

    
 // Connect prefered data to LEDs
assign led = bin_bcd_select;

    // Select which data to display based on switches
    mux4_16_bits MUX4 (
        .in0(data[15:4]),               // raw 12-bit ADC hexadecimal
        .in1(ave_data),                 // averaged and before scaling 16-bit ADC (extra 4-bits from averaging) hexadecimal
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
        .decimal_point(decimal_point)
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
