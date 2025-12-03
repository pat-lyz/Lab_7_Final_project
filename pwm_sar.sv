module pwm_sar #( 
    parameter int WIDTH = 8
) (
    input  logic             clk,
    input  logic             reset,
    input  logic             enable,
    input  logic [WIDTH-1:0] duty_cycle,
    output logic             pwm_out
);
    logic [WIDTH-1:0] counter;
    logic [WIDTH-1:0] duty_cycle_latched;
    
    // Latch duty cycle at the start of each PWM period (when counter wraps to 0)
    always_ff @(posedge clk) begin
        if (reset) begin
            counter <= 0;
            duty_cycle_latched <= 0;
        end else if (enable) begin
            counter <= counter + 1;
            // Latch new duty cycle at start of PWM period
            if (counter == 0)
                duty_cycle_latched <= duty_cycle;
        end
    end
    
    always_comb begin
        if (!enable)
            pwm_out = 1'b0;  // Output low when not enabled
        else if (duty_cycle_latched == {WIDTH{1'b1}})
            pwm_out = 1'b1;
        else if (counter < duty_cycle_latched)
            pwm_out = 1'b1;
        else 
            pwm_out = 1'b0; 
    end
endmodule



//module pwm #( 
//    parameter int WIDTH = 8
//) (
//    input  logic             clk,
//    input  logic             reset,
//    input  logic             enable,
//    input  logic [WIDTH-1:0] duty_cycle,
//    output logic             pwm_out
//);

//    logic [WIDTH-1:0] counter;

//    always_ff @(posedge clk) begin
//        if (reset)
//            counter <= 0;
//        else if (enable)
//            counter <= counter + 1;
//    end

//    always_comb begin
//        if (!enable)
//            pwm_out = 1'b0;  // Output low when not enabled
//        else if (duty_cycle == {WIDTH{1'b1}})
//            pwm_out = 1'b1;
//        else if (counter < duty_cycle)
//            pwm_out = 1'b1;
//        else 
//            pwm_out = 1'b0; 
//    end

//endmodule
//endmodule
