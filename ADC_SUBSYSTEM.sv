`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/17/2025 11:41:07 AM
// Design Name: 
// Module Name: ADC_SUBSYSTEM
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


module adc_subsystem(
    input logic vauxp15,
    input logic vauxn15,
    input logic clk,
    input logic reset,    
    output logic ready,        
    output logic enable,
    output logic [15:0] data,
    output logic [15:0] ave_data,
    output logic [15:0] scaled_adc_data,
    output logic ready_pulse
    );

    // Internal Signal declarations
    localparam CHANNEL_ADDR = 7'h1f;      // XA4/AD15 (for XADC4)
    logic        eos_out;                 // End of sequence          
    logic        busy_out;                // XADC Busy signal
    logic [15:0] scaled_adc_data_temp;    // scaled_adc_data, data;   
    
    xadc_wiz_0 XADC_INST (
        .di_in(16'h0000),        // Not used for reading
        .daddr_in(CHANNEL_ADDR), // Channel address
        .den_in(enable),         // Enable signal
        .dwe_in(1'b0),           // Not writing, so set to 0
        .drdy_out(ready),        // Data ready signal (when high, ADC data is valid)
        .do_out(data),           // ADC data output
        .dclk_in(clk),           // Use system clock
        .reset_in(reset),        // Active-high reset
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
            // Calculation: This scales FFFFh to 0CE4h (i.e. 3300d)
            //    mVolts = ave_data/(2^16 - 1) * 3300 = ave_data * 0.050355
            //    mVolts ~ ave_data * 1650/2^15 = (ave_data) * 1250 >> 13
            // NOTE: The 7-seg display will display in volts, 
            //       i.e. 3300 is 3.300 V or 3.300 V
            //       place the decimal point in the correct place!
            // Convert averaged ADC → volts (0–3300 mV)
            scaled_adc_data <= (ave_data * 1650) >> 15;    // was scaled_adc_data_temp
            //scaled_adc_data <= scaled_adc_data_temp; // additional register faciliates pipelining
        end 
   
        
                                      // for higher clock frequencies
    end 

    
endmodule
