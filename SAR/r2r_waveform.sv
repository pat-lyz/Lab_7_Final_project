`timescale 1ns / 1ps
// working R2R ramp - just low freq (ie wide)
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/13/2025 06:31:05 PM
// Design Name: 
// Module Name: r2r_dac
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


// THIS WAS FOR NOV 26 NIGHT, problem: curvy triangle instead of sawtooth
module r2r_waveform(
    input logic clk,
    input logic reset,
    output logic [7:0] r2r_counter  
);
    
    logic [13:0] slow_counter; // changed from 18 bits to 14 bit
    
    always_ff @(posedge clk) begin
        if (reset) begin
            r2r_counter <= 8'b0;
            slow_counter <= 14'b0;
        end else begin
            slow_counter <= slow_counter + 1;
            if (slow_counter == 14'b0) begin
                r2r_counter <= r2r_counter + 1;  // Direct increment
            end
        end
    end
endmodule


//module r2r_waveform(
//    input logic clk,
//    input logic reset,
//    output logic [7:0] r2r_counter  
//);
    
//    logic [7:0] counter;
//    logic [19:0] slow_counter;  // Larger counter for slower counting
    
//    always_ff @(posedge clk) begin
//        if (reset) begin
//            counter <= 8'b0;
//            slow_counter <= 20'b0;
//            r2r_counter <= 8'b0;
//        end else begin
//            // Only increment main counter every 1024 clocks
//            slow_counter <= slow_counter + 1;
//            if (slow_counter == 20'b0) begin
//                if (counter == 8'hFF) begin
//                    counter <= 8'b0;
//                end else begin
//                    counter <= counter + 1;
//                end
//                r2r_counter <= counter;
//            end
//        end
//    end
//endmodule