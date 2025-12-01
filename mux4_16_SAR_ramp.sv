module mux4_16_SAR_ramp(
input logic select_signal,
input logic signal_a,
input logic signal_b,
input logic signal_c,
input logic signal_d,
output logic [7:0] output_pin_a,
output logic output_pin_b
    );

always @(*) begin
    if (select_signal) begin
        output_pin_a = signal_b;
        output_pin_b = signal_d;
        end
    else begin
        output_pin_a = signal_a;
        output_pin_b = signal_c;
        end
end

endmodule
