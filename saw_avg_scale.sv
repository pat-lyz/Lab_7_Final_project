`timescale 1ns / 1ps


module saw_avg_scale(
    input logic clk,
    input logic reset,
    input logic adc_valid,
    input logic [7:0] raw_adc_value, // raw ADC value, 8 bits (0 - 255)
    output logic [15:0] scaled_voltage,   // Scaled ADC output (0 - 3300mV), 16 bits
    output logic [15:0] avg_adc_value      // Unscaled, Average ADC value, 16 bits
    );
    
    
    // Constants
    localparam int TOTAL_SAMPLE_NUMBER = 16; // How many samples we average over.
    localparam int LOG = 4;  // log2(16) = 4, used for division via right shift
    
    // Internal Signals
    logic [11:0] sample_sum; // sum of all samples in array
    logic [7:0] averaged; // 8 bits, average: (sample_sum / 16)
    logic [3:0] samples_in_buffer; // number of samples in the buffer
    logic [7:0] sample_array [TOTAL_SAMPLE_NUMBER-1:0]; 
        // array
        // each element is 8 bits wide
        // holds 16 elements (so 16 samples)
    logic [7:0] oldest_sample; // store the value being overwritten
        
    
    // AVERAGING
    
    always_ff @(posedge clk) begin
            
            // Reset
            if (reset) begin
                for (int i = 0; i < TOTAL_SAMPLE_NUMBER; i++) begin
                    sample_array[i] <=  8'h00; // all elements in array initalized to 0
                end
                samples_in_buffer <= '0; // no samples in buffer
                sample_sum <= '0; // sum of all samples is zero
                oldest_sample <= '0;
            end
            
            // Operating
            else if (adc_valid) begin
                // Store the value that will be overwritten
                oldest_sample <= sample_array[TOTAL_SAMPLE_NUMBER-1]; // might not need
            
                // shift all samples over 1 position to fit a new sample
                for (int i = TOTAL_SAMPLE_NUMBER-1; i > 0; i --) begin
                    sample_array[i] <= sample_array[i-1];
                end
                // insert new adc raw value into the buffer, at beginning 
                sample_array[0] <= raw_adc_value;
                
                // increment counter. Count up to 16 samples in the array. 
                if (samples_in_buffer < TOTAL_SAMPLE_NUMBER)
                    samples_in_buffer <= samples_in_buffer + 1;
                    
                // total sum off all samples in the array
                sample_sum = '0; // initially 0
                for (int i = 0; i < TOTAL_SAMPLE_NUMBER; i++) begin
                    sample_sum = sample_sum + sample_array[i]; // add each sample in array
                end
            end
        end
    
    
        // calculate averaged adc value
        assign averaged = (samples_in_buffer > 0) ? (sample_sum >> LOG) : 8'h00;
            // Right shift by 4 = division by 16
            // Check sample_count > 0 to avoid division by zero during startup
            // If no samples available, output zero
        
        assign avg_adc_value = {8'b0000_0000, averaged}; // padd with 0 to make 16 bit for display
    
    // SCALING
   
        // scaling internal signal
        logic [15:0] scaling_internal;
    
      always_ff @(posedge clk) begin
      
        if (reset) begin
            scaled_voltage <= '0; // during reset, is 0
        end
        
        else begin
        scaling_internal = averaged * 13;
        // ideally scaled_voltage = (averaged * 3300) / 255
        // 3300/255 = 12.941176
        // we are using 13 instead
        // so our max value will be: 255 * 13 = 3315 (instead of ideal max: 3300)
        // Error: +15 mV (about 0.45% error)
        
        scaled_voltage <= scaling_internal;
        // Output range: 0 × 13 = 0 mV to 255 × 13 = 3315 mV
        end
      
      end 
      
endmodule

