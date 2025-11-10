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
module lab_5_top_level_students (
    input  logic   clk,
    input  logic   reset,
    input  logic [1:0] bin_bcd_select,
   // input  logic [15:0] switches_inputs,
    input          vauxp15, // Analog input (positive) - connect to JXAC4:N2 PMOD pin  (XADC4)
    input          vauxn15, // Analog input (negative) - connect to JXAC10:N1 PMOD pin (XADC4)
    output logic   CA, CB, CC, CD, CE, CF, CG, DP,
    output logic   AN1, AN2, AN3, AN4,
    output logic [15:0] led
);
    // Internal signal declarations
    
    // Tie analog inputs to high-impedance to prevent I/O buffer inference
    //assign vauxp5 = 1'bZ;
    //assign vauxn5 = 1'bZ;
        
    logic        ready;              // Data ready from XADC
    logic [15:0] data, ave_data;              // Raw ADC data
    logic [15:0] scaled_adc_data, scaled_adc_data_temp; // Scaled ADC data for display
    logic [6:0]  daddr_in;              // XADC address
    logic        enable;                // XADC enable
   // logic [4:0]  channel_out;           // Current XADC channel
    //logic        eoc_out;               // End of conversion
    //logic        eos_out;               // End of sequence
    //logic        busy_out;              // XADC busy signal
    
    logic        ready_r, ready_pulse;
    logic [3:0]  decimal_pt; // vector to control the decimal point, 1 = DP on, 0 = DP off
                             // [0001] DP right of seconds digit        
                             // [0010] DP right of tens of seconds digit
                             // [0100] DP right of minutes digit        
                             // [1000] DP right of tens of minutes digit
    logic [15:0] bcd_value, mux_out;
    
    // Constants
    //localparam CHANNEL_ADDR = 7'h1f;     // XA4/AD15 (for XADC4)
    
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
    .ready_pulse(ready_pulse)
    );
    
    // XADC Instantiation
    /*xadc_wiz_0 XADC_INST (
        .di_in(16'h0000),        // Not used for reading
        .daddr_in(CHANNEL_ADDR), // Channel address
        .den_in(enable),         // Enable signal
        .dwe_in(1'b0),           // Not writing, so set to 0
        .drdy_out(ready),        // Data ready signal (when high, ADC data is valid)
        .do_out(data),           // ADC data output
        .dclk_in(clk),           // Use system clock
        .reset_in(reset),   // Active-high reset
        .vp_in(1'b0),            // Not used, leave disconnected
        .vn_in(1'b0),            // Not used, leave disconnected
        .vauxp15(vauxp15),       // Auxiliary analog input (positive)
        .vauxn15(vauxn15),       // Auxiliary analog input (negative)
        .channel_out(),          // Current channel being converted
        .eoc_out(enable),        // End of conversion
        .alarm_out(),            // Not used
        .eos_out(eos_out),       // End of sequence
        .busy_out(busy_out)      // XADC busy signal
    );

   averager  
   #( .power(12), //2**N samples, default is 2**8 = 256 samples
      .N(16)     // # of bits to take the average of
    ) 
   AVERAGER
    ( .reset(reset),
      .clk(clk),
      .EN(ready_pulse),
      .Din(data),
      .Q(ave_data)
    );
    always_ff @(posedge clk) begin
        if (reset) begin
            scaled_adc_data <= 0;
            scaled_adc_data_temp <= 0;
        end
        else if (ready_pulse) begin
            // Calculation: This scales FFFFh to 270Fh (i.e. 9999d)
            //    mVolts = ave_data/(2^16 - 1) * 9999 = ave_data * 0.152575
            //    mVolts ~ ave_data * 1250/2^13 = (ave_data) * 1250 >> 13
            // NOTE: The 7-seg display will display in millivolts, 
            //       i.e. 9999 is 0.9999 V or 999.9 mV
            //       place the decimal point in the correct place!
            scaled_adc_data <= (ave_data*1250) >> 13; // was scaled_adc_data_temp
            //scaled_adc_data <= scaled_adc_data_temp; // additional register faciliates pipelining
        end                                          // for higher clock frequencies
    end*/
// Connect ADC data to LEDs
assign led = scaled_adc_data;
    bin_to_bcd BIN2BCD (
        .clk(    clk),
        .reset(  reset),
        .bin_in( scaled_adc_data),
        .bcd_out(bcd_value)
    );

    mux4_16_bits MUX4 (
        .in0(scaled_adc_data), // hexadecimal, scaled and averaged
        .in1(bcd_value),       // decimal, scaled and averaged
        .in2(data[15:4]),      // raw 12-bit ADC hexadecimal
        .in3(ave_data),        // averaged and before scaling 16-bit ADC (extra 4-bits from averaging) hexadecimal
        .select(bin_bcd_select),
        .mux_out(mux_out)
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
        2'b00: decimal_pt = 4'b0000;  // averaged ADC with extra 4 bits
        2'b01: decimal_pt = 4'b0010;  // averaged and scaled voltage
        2'b10: decimal_pt = 4'b0000;  // raw ADC (12-bits)
        2'b11: decimal_pt = 4'b0000;
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
