`timescale 1ns / 1ps


module saw_avg_scale(
    input logic clk,
    input logic reset,
    input logic adc_valid,
    input logic [7:0] raw_adc_value,
    output logic [7:0] scaled_voltage,   // Scaled ADC output (mV)    
    output logic [7:0] avg_adc_value      // Unscaled, Average ADC value
    );
    
    // Internal Signals
    logic [7:0] averaged; // changed from [15:0]
    logic pulse;
    logic  begin_process;
    
    always_ff @(posedge clk) begin
            if (reset)
                pulse <= 1'b0;
            else
                pulse <= adc_valid;
        end
    
    assign begin_process = ~pulse & adc_valid;
    
    averager #(
        .power(12),  // 2^12 samples
        .N(16)       // 16-bit data width
    ) AVERAGER (
        .reset(reset),
        .clk(clk),
        .EN(begin_process),      
        .Din(raw_adc_value),           
        .Q(averaged)           
    );
    
    
      always_ff @(posedge clk) begin
      if (reset) begin
          scaled_voltage <= 16'h0000;
      end
      else if (begin_process) begin
          scaled_voltage <= (averaged * 31994) >> 16; //Was 9995 but now multiplied by 3.201
      end
  end
    
    assign avg_adc_value = averaged; // averaged, no scaling
endmodule

