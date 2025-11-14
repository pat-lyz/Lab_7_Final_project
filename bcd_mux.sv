`timescale 1ns / 1ps


module bcd_mux(
    input  logic [15:0] bin_data,  
    input  logic [15:0] bcd_out,  
    input  logic  [1:0] select,  
    output logic [15:0] bcd_mux_out
    );
    
    always_comb begin
        case(select)
            1'b0:bcd_mux_out = bin_data;  // binary
            1'b1:bcd_mux_out = bcd_out;  // decimal
            default: bcd_mux_out = 16'h0000;  // Default case: output all zeros
        endcase
    end     
    
endmodule
