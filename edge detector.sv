// Synchronizer and Falling Edge Detection

`timescale 1ns / 1ps

module edge_detector (input logic clk,
                     input logic reset,
                     input logic comparator_raw, // asynchronous
                     output logic sync_edge_out
                     );
                     
     //internal signal
     logic comp_prev;
                     
    // Synchronizer
    always_ff @(posedge clk) begin   
        if (reset)
            comp_prev <= 1'b0;
        else               
            comp_prev <= comparator_raw;
      end 
      
    
    // Falling Edge Detection
    assign sync_edge_out = comp_prev & ~comparator_raw;

endmodule
