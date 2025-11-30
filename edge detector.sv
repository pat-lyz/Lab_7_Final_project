// Synchronizer and Falling Edge Detection

`timescale 1ns / 1ps



// Synchronizer and Falling Edge Detection
`timescale 1ns / 1ps
module edge_detector (input logic clk,
                     input logic reset,
                     input logic comparator_raw, // asynchronous
                     output logic sync_edge_out
                     );
                     
    // Internal signals for two-stage synchronizer
    logic comp_sync1;  // First stage synchronizer
    logic comp_sync2;  // Second stage synchronizer (fully synchronized)
    logic comp_prev;   // Previous value for edge detection
                     
    // Two-Stage Synchronizer (for metastability protection)
    always_ff @(posedge clk) begin   
        if (reset) begin
            comp_sync1 <= 1'b0;
            comp_sync2 <= 1'b0;
            comp_prev  <= 1'b0;
        end
        else begin
            comp_sync1 <= comparator_raw;    // First stage: capture async signal
            comp_sync2 <= comp_sync1;        // Second stage: synchronize to clock domain
            comp_prev  <= comp_sync2;        // Store previous synchronized value
        end
    end 
      
    // Falling Edge Detection
    // Detects transition from 1 to 0 (falling edge)
    assign sync_edge_out = comp_prev & ~comp_sync2;
    
endmodule



//module edge_detector (input logic clk,
//                     input logic reset,
//                     input logic comparator_raw, // asynchronous
//                     output logic sync_edge_out
//                     );
                     
//     //internal signal
//     logic comp_prev;
                     
//    // Synchronizer
//    // NEED TO ADD SYNCHRONIZER *********
//    always_ff @(posedge clk) begin   
//        if (reset)
//            comp_prev <= 1'b0;
//        else               
//            comp_prev <= comparator_raw;
//      end 
      
    
//    // Falling Edge Detection
//    assign sync_edge_out = comp_prev & ~comparator_raw;

//endmodule