`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/30/2025 05:27:58 PM
// Design Name: 
// Module Name: adc_ramp_subsystem
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


module adc_ramp_subsystem(
    input logic clk,
    input logic reset,
    //sawtooth inputs/outputs
    input logic vcompare_state, //sawtooth comparator output 
    output logic sawtooth_out,  //outputs the sawtooth wave
    output logic [7:0] saw_raw,   //raw comparator value
    output logic saw_valid_ramp,
    //r2r inputs/outputs
    input logic vcompare_state_r2r, // R2R comparator ouput (pin JB3)
    output logic [7:0] r2r_out,
    output logic [7:0] r2r_raw, 
    output logic r2r_valid_ramp
    
    );
    
    
        //Sawtooth comparator subsystem
    sawtooth_subsystem SAWTOOTH_SUBSYSTEM(
        .clk(clk),
        .reset(reset),
        .vcompare_state(vcompare_state),    
        .sawtooth_out(sawtooth_out),        
        .saw_raw_adc_value(saw_raw),            //outputs raw sawtooth value
        .saw_raw_adc_valid(saw_valid_ramp)
    );
    
    //R2R Subsystem
    r2r_subsystem R2R_SUBSYSTEM(
        .clk(clk),
        .reset(reset),
        .vcompare_state_r2r(vcompare_state_r2r),
        .r2r_out(r2r_out),                      //outputting the sawtooth wave to the r2r ladder
        .r2r_raw_adc_value(r2r_raw),            //outputs the raw r2r value
        .r2r_raw_adc_valid(r2r_valid_ramp)
    );

endmodule
