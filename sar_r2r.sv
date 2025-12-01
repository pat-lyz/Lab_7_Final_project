`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2025 07:51:23 PM
// Design Name: 
// Module Name: sar_r2r
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


module sar_r2r(
    input logic clk, 
    input logic reset,
    input logic vcompare_state_SAR, // SAR comparator ouput (pin JB3)
    output logic [7:0] r2r_out_sar, // JA pins
    output logic [7:0] adc_data
    );
      
    logic dac_clk;                  // Divided clock for SAR ADC
    logic [7:0] dac_value;          // DAC value from SAR ADC
    logic conversion_done;          // Conversion complete flag
    
// INSTANTIATIONS 
    
    // Clock Divider 
    clk_divider #(
        .DIVIDER(1000)
    ) CLK_DIV (
        .clk_100MHz(clk),
        .reset(reset),
        .dac_clk(dac_clk)
    );
    
    // SAR ADC
    
    sar_adc #(
        .WIDTH(8)
    ) SAR (
        .dac_clk(dac_clk),
        .reset(reset),
        .start_conversion(1'b1),
        .comp_in(vcompare_state_SAR),
        .dac_value(dac_value),
        .adc_data(adc_data),
        .conversion_done(conversion_done)
    );
    
    // DAC Driver
    
    dac_driver #(
        .WIDTH(8)
    ) DAC (
        .dac_value(dac_value),
        .dac_bus(r2r_out_sar)
    );  
endmodule
