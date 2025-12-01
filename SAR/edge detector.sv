// Synchronizer and Falling Edge Detection

`timescale 1ns / 1ps

module edge_detector (input logic clk,
                     input logic reset,
                     input logic comparator_raw, // asynchronous
                     output logic sync_edge_out
                     );
                     
     //internal signal
     logic comp_prev;
     logic comp_sync;
                     
    // Synchronizer
    always_ff @(posedge clk) begin   
        if (reset) begin
            comp_prev <= 1'b0;
            comp_sync <= 1'b0;
        end else begin          
            comp_prev <= comparator_raw;
            comp_sync <= comp_prev;
      end 
    end
      
    
    // Falling Edge Detection
    assign sync_edge_out = comp_prev & ~comparator_raw;

endmodule