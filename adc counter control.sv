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

    logic [7:0] captured_value;
    logic data_captured;
   
    always_ff @(posedge clk) begin
        if (reset) begin
            captured_value <= '0;
            data_captured <= 1'b0;
            raw_adc_value <= '0;
            raw_adc_valid <= 1'b0;
        end else begin
            // Capture new data when enabled and sync edge detected
            if (enable && sync_edge_out) begin
                captured_value <= duty_cycle_out;
                data_captured <= 1'b1;

            end
           
            // Always output the captured value
            raw_adc_value <= captured_value;
           
            // raw_adc_valid is high when we have captured data
            // This ensures it's always assigned and prevents timing warnings
            raw_adc_valid <= data_captured;
        end
    end

endmodule