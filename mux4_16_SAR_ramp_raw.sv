module mux4_16_SAR_ramp_raw(
    input  logic [7:0] in0,  
    input  logic [7:0] in1,  
    input  logic in2, 
    input  logic in3, 
    input  logic [7:0] in4,
    input  logic [7:0] in5, 
    input  logic select,  
    output logic [7:0] mux_out,
    output logic [7:0] mux_out2,
    output logic mux_out3,
    output logic mux_out4

    );

    always_comb begin
        case(select)
            1'b0: mux_out = in0;                          
            1'b1: mux_out = in4;                                                                        
            default: mux_out = '0;  
        endcase
    end    

   always_comb begin
     case(select)
         1'b0: mux_out2 = in1;  
         1'b1: mux_out2 = in5;  
         default: mux_out2 = '0; 
     endcase
   end  
      
   always_comb begin
     case(select)
         1'b0: mux_out3 = in2;  
         1'b1: mux_out3 = '1;  
         default: mux_out3 = '0; 
     endcase
   end
     
   always_comb begin
     case(select)
         1'b0: mux_out4 = in3;  
         1'b1: mux_out4 = '1;  
         default: mux_out4 = '0; 
     endcase
   end    

endmodule
