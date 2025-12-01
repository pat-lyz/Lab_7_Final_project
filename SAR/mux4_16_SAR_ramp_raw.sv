module mux4_16_SAR_ramp_raw(
    input logic select_signal,
    input logic signal_a,
    input logic signal_b,
    input logic signal_c,
    input logic signal_d,
    
    input logic signal_e,
    input logic signal_f,
    
    output logic [7:0] output_pin_a,        //raw signals
    output logic [7:0] output_pin_b, 
    output logic output_pin_c,              //valid signals
    output logic output_pin_d
    );

    always @(*) begin
        if (select_signal) begin
            output_pin_a = signal_e;
            output_pin_b = signal_f;
            output_pin_c = 1'b1;
            output_pin_d = 1'b1;
            end
        else begin
            output_pin_a = signal_a;
            output_pin_b = signal_b;
            output_pin_c = signal_c;
            output_pin_d = signal_d;
            end
    end

endmodule
