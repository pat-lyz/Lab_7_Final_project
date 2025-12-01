`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/29/2025 04:38:50 PM
// Design Name: 
// Module Name: clk_divider
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

module clk_divider #(
    parameter DIVIDER = 1000  // 100 MHz / 1000 
)(
    input  logic clk_100MHz,
    input  logic reset,
    output logic dac_clk
);
    
    logic [$clog2(DIVIDER)-1:0] counter;
    
    always_ff @(posedge clk_100MHz or posedge reset) begin
        if (reset) begin
            counter <= 0;
            dac_clk <= 0;
        end else begin
            if (counter == DIVIDER-1) begin
                counter <= 0;
                dac_clk <= ~dac_clk;
            end else begin
                counter <= counter + 1;
            end
        end
    end
    
endmodule