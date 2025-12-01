
module dac_driver #(
    parameter WIDTH = 8
)(
    input  logic [WIDTH-1:0] dac_value,
    output logic [WIDTH-1:0] dac_bus
);
    
    // Simple direct connection for R-2R ladder
    assign dac_bus = dac_value;
    // this is the r2r_out bus in the constraints file
    
endmodule