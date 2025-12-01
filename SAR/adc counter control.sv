// Captures ADC value based on Sawtooth duty cycle and sync_edge_out from the edge detetor module
// Explanation:
// For 3.3V system:
//100% duty cycle (duty_cycle_out = 255) = 3.3V analog
//50% duty cycle (duty_cycle_out = 127) = 1.65V analog  
//0% duty cycle (duty_cycle_out = 0) = 0V analog

// So, when saw_adc_value <= duty_cycle_out; capture 127 value, which digitally represents 1.65V

module adc_capture_control(
    input logic clk,
    input logic reset,
    input logic enable,
    input logic sync_edge_out, // indicates when to sample duty cycle
    input logic [7:0] duty_cycle_out,
    output logic [7:0] raw_adc_value,
    output logic raw_adc_valid
);
    
    
    always_ff @(posedge clk) begin
        if (reset) begin
            raw_adc_value <= '0;
            raw_adc_valid <= 1'b0;
            end
        else begin
            raw_adc_valid <= 1'b0; // low until adc data is captured
            
            if (enable && sync_edge_out) begin
                raw_adc_value <= duty_cycle_out; // capture the duty cycle
                raw_adc_valid <= 1'b1;
                end
            end
    end
    
endmodule