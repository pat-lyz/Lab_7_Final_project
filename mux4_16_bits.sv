module mux4_16_bits(
    input  logic [15:0] in0,  
    input  logic [15:0] in1,  
    input  logic [15:0] in2, 
    input  logic [15:0] in3,  
    input  logic [15:0] in4,
    input  logic [15:0] in5,
    input  logic [15:0] in6,
    input  logic [15:0] in7,
    input  logic [15:0] in8,
    input  logic  [3:0] select,  
    output logic [15:0] mux_out,
    output logic  [3:0] decimal_point  
    );

    always_comb begin
        case(select)
            4'b0000: mux_out = in0;  
            4'b0001: mux_out = in1;  
            4'b0010: mux_out = in2;
            4'b0011: mux_out = in3;
            4'b0100: mux_out = in4;
            4'b0101: mux_out = in5;
            4'b0110: mux_out = in6;
            4'b0111: mux_out = in7;
            4'b1000: mux_out = in8;
            default: mux_out = 16'h0000;  // Default case: output all zeros
        endcase
    end    

   always_comb begin
     case(select)
         4'b0000: decimal_point = 4'b0000;  // averaged ADC with extra 4 bits
         4'b0001: decimal_point = 4'b0000;  // averaged and scaled voltage
         4'b0010: decimal_point = 4'b0000;  // raw ADC (12-bits)
         4'b0011: decimal_point = 4'b0000;
         4'b0100: decimal_point = 4'b0000;
         4'b0101: decimal_point = 4'b0000;
         4'b0110: decimal_point = 4'b0000;
         4'b0111: decimal_point = 4'b0000;
         4'b1000: decimal_point = 4'b0000;
         default: decimal_point = 16'h0000;  // Default case: output all zeros
     endcase
   end    
   //assign decimal_pt = 4'b0010; // vector to control the decimal point, 1 = DP on, 0 = DP off
                                // [0001] DP right of seconds digit        
                                // [0010] DP right of tens of seconds digit
                                // [0100] DP right of minutes digit        
                                // [1000] DP right of tens of minutes digit    

endmodule

