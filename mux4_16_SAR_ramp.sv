module mux4_16_SAR_ramp(
    input  logic [7:0] in0,  
    input  logic  in1,  
    input  logic [7:0] in2, 
    input  logic in3,  
    input  logic select,  
    output logic [7:0] mux_out,
    output logic mux_out2

    );
    

    always_comb begin
        case(select)
            1'b0: mux_out = in0;                          
            1'b1: mux_out = in2;                                                                        
            default: mux_out = '0;  
        endcase
    end    

   always_comb begin
     case(select)
            1'b0: mux_out2 = in1;  
            1'b1: mux_out2 = in3;  
         default: mux_out2 = '0; 
     endcase
   end       

endmodule
