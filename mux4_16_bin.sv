module mux4_16_bin(
    input  logic [15:0] in0,  
    input  logic [15:0] in1,
    input  logic select,  
    output logic [15:0] mux_out,
    output logic  [3:0] decimal_point  
    );

    always_comb begin
        case(select)
            1'b0: mux_out = in0;  
            1'b1: mux_out = in1;
            default: mux_out = 16'h0000;  // Default case: output all zeros
        endcase
    end      

endmodule
