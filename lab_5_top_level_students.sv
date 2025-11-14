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
module lab_7_top_level_students (
    input  logic   clk,
    input  logic   reset,
    input  logic [2:0] bin_bcd_select,
   // input  logic [15:0] switches_inputs,
    input          vauxp15, // Analog input (positive) - connect to JXAC4:N2 PMOD pin  (XADC4)
    input          vauxn15, // Analog input (negative) - connect to JXAC10:N1 PMOD pin (XADC4)
    input logic vcompare_state, // Sawtooth comparator ouput (pin JB1)
    output sawtooth_out, // goes to pin JB2
    output logic   CA, CB, CC, CD, CE, CF, CG, DP,
    output logic   AN1, AN2, AN3, AN4,
    output logic [15:0] led
);
    // Internal signal declarations
    logic        ready;              // Data ready from XADC
    logic [15:0] data, ave_data;              // Raw ADC data
    logic [15:0] scaled_adc_data, scaled_adc_data_temp; // Scaled ADC data for display
    logic [6:0]  daddr_in;              // XADC address
    logic        enable;                // XADC enable
    logic        ready_r, ready_pulse;
    logic [3:0]  decimal_pt; // vector to control the decimal point, 1 = DP on, 0 = DP off
                             // [0001] DP right of seconds digit        
                             // [0010] DP right of tens of seconds digit
                             // [0100] DP right of minutes digit        
                             // [1000] DP right of tens of minutes digit
    logic [15:0] bcd_adc, mux_out, bcd_saw;
    logic [7:0] saw_raw, saw_scaled, saw_avg;
    
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
        .ready_pulse(ready_pulse),
        .bcd_value(bcd_adc)
    );
    
    //the sawtooth shit
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

    
 // Connect ADC data to LEDs
assign led = scaled_adc_data;

    // Select which data to display based on switches
    mux4_16_bits MUX4 (
        .in0(scaled_adc_data), // hexadecimal, scaled and averaged
        .in1(bcd_adc),       // decimal, scaled and averaged
        .in2(data[15:4]),      // raw 12-bit ADC hexadecimal
        .in3(ave_data),        // averaged and before scaling 16-bit ADC (extra 4-bits from averaging) hexadecimal
        .in4({8'b0000_0000,saw_raw}),
        .in5({8'b0000_0000,saw_scaled}),
        .in6({8'b0000_0000,saw_avg}),
        .in7(bcd_saw),
        .select(bin_bcd_select),
        .mux_out(mux_out),
        .decimal_point(decimal_point)
    );
    
    

// added these 3 lines for the pulser 
  always_ff@(posedge clk)
    if (reset)
       ready_r <= 0;
    else
       ready_r <= ready;
       
  assign ready_pulse = ~ready_r & ready; // generate 1-clk pulse when ready goes high
  
  always_comb begin
    case(bin_bcd_select)
        3'b000: decimal_pt = 4'b0000;  // averaged ADC with extra 4 bits
        3'b001: decimal_pt = 4'b1000;  // averaged and scaled voltage
        3'b010: decimal_pt = 4'b0000;  // raw ADC (12-bits)
        3'b011: decimal_pt = 4'b0000;
        3'b100: decimal_pt = 4'b0000;  // averaged ADC with extra 4 bits
        3'b101: decimal_pt = 4'b1000;  // averaged and scaled voltage
        3'b110: decimal_pt = 4'b0000;  // raw ADC (12-bits)
        3'b111: decimal_pt = 4'b0000;       
        default: decimal_pt = 16'h0000;  // Default case: output all zeros
    endcase
  end    
  //assign decimal_pt = 4'b0010; // vector to control the decimal point, 1 = DP on, 0 = DP off
                               // [0001] DP right of seconds digit        
                               // [0010] DP right of tens of seconds digit
                               // [0100] DP right of minutes digit        
                               // [1000] DP right of tens of minutes digit
  
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
