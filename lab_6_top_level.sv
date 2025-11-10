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
module lab_6_top_level (
    input  logic   clk,
    input  logic   reset,
    input  logic [1:0] bin_bcd_select,
    input  logic [1:0] mode_select,
   // input  logic [15:0] switches_inputs,
    input          vauxp15, // Analog input (positive) - connect to JXAC4:N2 PMOD pin  (XADC4)
    input          vauxn15, // Analog input (negative) - connect to JXAC10:N1 PMOD pin (XADC4)
    output logic   CA, CB, CC, CD, CE, CF, CG, DP,
    output logic   AN1, AN2, AN3, AN4,
    output logic [15:0] led,
    output logic   pwm_out,buzzer_out,
    output logic [7:0] R2R_out
);
    // Internal signal declarations
    
    // Tie analog inputs to high-impedance to prevent I/O buffer inference
    //assign vauxp5 = 1'bZ;
    //assign vauxn5 = 1'bZ;
        
    logic        ready;              // Data ready from XADC
    logic [15:0] data;              // Raw ADC data
    logic [15:0] scaled_adc_data; // Scaled ADC data for display, plus pipelinging register
    logic [6:0]  daddr_in;              // XADC address
    logic        enable;                // XADC enable
   // logic [4:0]  channel_out;           // Current XADC channel
    //logic        eoc_out;               // End of conversion
    logic        eos_out;               // End of sequence
    logic        busy_out;              // XADC busy signal
    logic        ready_pulse;
    logic [15:0] bcd_value, mux_out;
    logic pwm_enable, r2r_enable, buzzer_enable;
    logic pwm_out_internal, buzzer_out_internal;
    logic [7:0] R2R_out_internal;
    
    // Constants
    localparam CHANNEL_ADDR = 7'h1f;     // XA4/AD15 (for XADC4)
    
    // XADC Instantiation
    xadc_wiz_0 XADC_INST (
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

    // Instantiate the FSM
    output_mode_fsm FSM (
        .clk(clk),
        .reset(reset),
        .mode_select(mode_select),
        .pwm_enable(pwm_enable),
        .r2r_enable(r2r_enable),
        .buzzer_enable(buzzer_enable)
    );

    // Instantiate the adc_processing module
    adc_processing ADC_PROC (
        .clk(clk),
        .reset(reset),
        .ready(ready),
        .data(data),
        .scaled_adc_data(scaled_adc_data),
        .ready_pulse(ready_pulse)
    );
    
    // Connect ADC data to LEDs, make LEDs' brightness pulse with pwm_out
    assign led = pwm_out_internal ? scaled_adc_data : '0;

    bin_to_bcd BIN2BCD (
        .clk(    clk),
        .reset(  reset),
        .bin_in( scaled_adc_data),
        .bcd_out(bcd_value)
    );
    
    logic [3:0] decimal_pt;
    mux4_16_bits MUX4 (
        .in0(scaled_adc_data), // hexadecimal, scaled and averaged
        .in1(bcd_value),       // decimal, scaled and averaged
        .in2(data[15:4]),      // raw 12-bit ADC hexadecimal
        .in3(ave_data),        // averaged and before scaling 16-bit ADC (extra 4-bits from averaging) hexadecimal
        .select(bin_bcd_select),
        .mux_out(mux_out),
        .decimal_point(decimal_pt)
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
    
    logic triangle_en;
    assign triangle_en = pwm_enable | r2r_enable;
    // Instantiate the triangle_generator module
    triangle_generator #(
        .WIDTH(8),           // Bit width for duty_cycle (e.g. 8)
        .CLOCK_FREQ(100_000_000), // System clock frequency in Hz (e.g. 100_000_000)
        .WAVE_FREQ(1.0)    // Desired triangle wave frequency in Hz (e.g. 1.0)
    ) triangle_pwm_inst (
        .clk(clk),           // Connect to system clock
        .reset(reset),       // Connect to system reset
        .enable(triangle_en), // Connect to enable signal
        .pwm_out(pwm_out_internal), // Connect to PWM output signal
        .R2R_out(R2R_out_internal)  // Connect to R2R ladder header, can leave empty if 
    );                              // not required, i.e. .R2R_out()

    logic sawtooth_en;
    assign sawtooth_en = pwm_enable | r2r_enable;
    logic saw_pwm, saw_r2r;

    sawtooth #(
         .WIDTH(8),           // Bit width for duty_cycle (e.g. 8)
        .CLOCK_FREQ(100_000_000), // System clock frequency in Hz (e.g. 100_000_000)
        .WAVE_FREQ(1.0)
    )sawtooth_inst(
        .clk(clk),           // Connect to system clock
        .reset(reset),       // Connect to system reset
        .enable(sawtooth_en), // Connect to enable signal
        .pwm_out(saw_pwm), // Connect to PWM output signal
        .R2R_out(saw_r2r)  // Connect to R2R ladder header, can leave empty if 
    );        
    
    
    buzzer_pwm #(
        .CLOCK_FREQ(100_000_000), // System clock frequency in Hz
        .BUZZER_FREQ(1000)        // Desired buzzer frequency in Hz
    ) buzzer_inst (
        .clk(clk),
        .reset(reset),
        .enable(buzzer_enable),
        .pwm_out(buzzer_out_internal) // Connect this to the buzzer output pin
    );

    // Output multiplexing based on FSM state
    always_comb begin
        pwm_out = pwm_enable ? pwm_out_internal : 0;
        R2R_out = r2r_enable ? R2R_out_internal : '0;
        buzzer_out = buzzer_enable ? buzzer_out_internal : 0;
    end
    
endmodule
