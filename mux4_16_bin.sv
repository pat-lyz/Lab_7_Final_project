module mux4_16_bin(
    input  logic [15:0] in0,  
    input  logic [15:0] in1,
    input  logic select,  
    output logic [15:0] mux_out,
    output logic  [3:0] decimal_point  
    );

    always_comb begin
        case(select)
            1'b0: mux_out = in0;    //outputs the hexidecimal
            1'b1: mux_out = in1;    //outputs the decimal
            default: mux_out = 16'h0000;  // Default case: output all zeros
        endcase
    end    

   always_comb begin
     case(select)
         1'b0: decimal_point = 4'b0000; 
         1'b1: decimal_point = 4'b1000; 
         default: decimal_point = 16'h0000;  // Default case: output all zeros
     endcase
   end    
   //assign decimal_pt = 4'b0010; // vector to control the decimal point, 1 = DP on, 0 = DP off
                                // [0001] DP right of seconds digit        
                                // [0010] DP right of tens of seconds digit
                                // [0100] DP right of minutes digit        
                                // [1000] DP right of tens of minutes digit    

endmodule
