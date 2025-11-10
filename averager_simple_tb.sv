//////////////////////////////////////////////////////////////////////////////////
// Module Name: averager_simple_tb
// 
// Description: 
// This testbench validates the averager_simple module by simulating various input
// conditions with added noise. It tests the module's ability to average noisy
// signals and produce higher resolution outputs.
//
// Test Methodology:
// 1. Applies a 100MHz clock (10ns period)
// 2. Tests multiple DC levels with random noise:
//    - 0x10 (16 decimal)
//    - 0x05 (5 decimal)
//    - 0x55 (85 decimal)
//    - 0xB7 (183 decimal)
// 3. For each DC level, runs for 2 * 2^power clock cycles to ensure
//    full settling of the averager
// 4. Adds random noise of ±4 LSBs to each input sample
// 5. Uses 'test' signal to track progress through different test cases
//
// Parameters:
// - power: Must match the DUT's power parameter (default = 8)
//         Determines number of samples averaged (2^power)
//
// Testbench Signals:
// - clk: 100MHz clock signal
// - reset: Active-high reset signal
// - EN: Enable signal for the averager
// - Din[7:0]: Input data with added noise
// - base[7:0]: Base DC level before noise is added
// - Q[15:0]: Averaged output from DUT
// - test: Toggle signal indicating test case transitions
//
// Test Duration:
// The testbench runs for approximately (4 * 2 * 2^power) clock cycles,
// plus setup and completion time. For power=8, this is ~2048 cycles.
//
// Expected Results:
// - The averaged output (Q[15:8]) should approximate the base input level
// - The lower bits (Q[7:0]) should provide additional resolution
// - The averaging should reduce the noise visible in the output
//
// Usage:
// 1. Set the 'power' parameter to match your DUT configuration
// 2. Run the simulation for at least 2500 clock cycles
// 3. Monitor the 'test' signal transitions to track test progress
// 4. The $display message indicates test completion
//
// Note: The commented-out $monitor statement can be uncommented
// for detailed signal tracking during simulation.
//////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module averager_simple_tb();
    // Parameters
    parameter power = 8;  // 2**8 = 256 samples
    
    // Testbench signals
    logic clk;
    logic reset;
    logic EN;
    logic [7:0] Din, base;
    logic [15:0] Q;
    logic test = 0;
    
    // Clock generation
    initial begin
        clk = 0;
        forever #5 clk = ~clk;  // 100MHz clock
    end
    
    // Instantiate the averager
    averager_simple #(
        .power(power)
    ) DUT (
        .clk(clk),
        .reset(reset),
        .EN(EN),
        .Din(Din),
        .Q(Q)
    );
    
    // Random number generation for noise
    function logic [7:0] add_noise;
        input logic [7:0] base_value;
        logic signed [7:0] noise;
        noise = $urandom_range(-4, 4);  // Generate noise between -4 and +4
        return base_value + noise;
    endfunction

    
    // Test stimulus
    initial begin
        // Initialize signals
        reset = 1;
        EN = 0;
        Din = 0;
        #100;
        
        // Release reset
        reset = 0;
        EN = 1;
 /////////////////
       base = 8'h10;
         // Test zero padding
       for(int i = 0; i < 2*2**power; i++) begin
            logic [7:0] temp;
            temp = add_noise(base);
            Din = temp[7:0];  // Take lower 8 bits
            @(posedge clk);
        end
        test = ~test;
 /////////////////
        
        base = 8'h05;
        for(int i = 0; i < 2*2**power; i++) begin
            Din = add_noise(base);  
            @(posedge clk);
        end
        test = ~test;

        base = 8'h55;
        for(int i = 0; i < 2*2**power; i++) begin
            Din = add_noise(base);  
            @(posedge clk);
        end
        test = ~test;

        base = 8'hB7;
        for(int i = 0; i < 2*2**power; i++) begin
            Din = add_noise(base);  
            @(posedge clk);
        end
        test = ~test;
        // Add some test verification
        $display("Test completed!");
        #1000;
        $stop;
    end
    
//    // Monitor the output
//    initial begin
//        $monitor("Time=%0t reset=%b EN=%b Din=%h Q=%h", 
//                 $time, reset, EN, Din, Q);
//    end
endmodule
