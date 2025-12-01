`timescale 1ns / 1ps


module sar_subsystem(
    input logic clk, 
    input logic reset,
    input logic vcompare_state_SAR, // SAR comparator ouput (pin JB3)
    output logic [7:0] r2r_out_sar, // JA pins
    output logic [7:0] adc_data,
    output logic [7:0] pwm_adc_data,
    input logic vcompare_state, // SAR comparator ouput (pin JB1)
    output logic sawtooth_out // pin JB2, outputs the PWM
    );
    
    sar_r2r SAR_R2R(
    .clk(clk),
    .reset(reset),
    .vcompare_state_SAR(vcompare_state_SAR),
    .r2r_out_sar(r2r_out_sar),
    .adc_data(adc_data)
    );
  
    sar_pwm SAR_PWM(
    .clk(clk),
    .reset(reset),
    .vcompare_state(vcompare_state),
    .sawtooth_out(sawtooth_out),
    .adc_data(pwm_adc_data)
    );
    
endmodule
