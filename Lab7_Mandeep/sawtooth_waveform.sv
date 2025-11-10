// Sawtooth PWM and R2R Generator Module
// Generates a sawtooth waveform using PWM by adjusting the duty cycle.

module sawtooth
    #(
        parameter int WIDTH       = 8,                // Bit width for duty_cycle
        parameter int CLOCK_FREQ  = 100_000_000,      // System clock frequency in Hz
        parameter real WAVE_FREQ  = 1.0               // Desired sawtooth wave frequency in Hz
    )
    (
        input  logic clk,          // System clock (100 MHz)
        input  logic reset,        // Active-high reset
        input  logic enable,       // Active-high enable
        output logic pwm_out,      // PWM output signal
        output logic [WIDTH-1:0] R2R_out // R2R ladder output
    );

    // Max value for the sawtooth
    localparam int MAX_DUTY_CYCLE   = (2 ** WIDTH) - 1;   // 255 for WIDTH = 8

    // For a sawtooth we go: 0,1,2,...,MAX then wrap → so there are (MAX+1) steps per cycle
    localparam int TOTAL_STEPS      = MAX_DUTY_CYCLE + 1; // 256 steps

    // Clock cycles per step to get the wanted sawtooth frequency
    // f_wave = CLOCK_FREQ / (TOTAL_STEPS * DOWNCOUNTER_PERIOD)
    localparam int DOWNCOUNTER_PERIOD = integer'(CLOCK_FREQ / (WAVE_FREQ * TOTAL_STEPS));

    initial begin
        if (DOWNCOUNTER_PERIOD <= 0) begin
            $error("DOWNCOUNTER_PERIOD must be positive. Adjust CLOCK_FREQ or WAVE_FREQ.");
        end
    end

    logic zero;                    // from downcounter
    logic [WIDTH-1:0] duty_cycle;  // current sawtooth value

    // drive R2R directly
    assign R2R_out = duty_cycle;

    // timing: same downcounter you already have
    downcounter #(
        .PERIOD(DOWNCOUNTER_PERIOD)
    ) downcounter_inst (
        .clk    (clk),
        .reset  (reset),
        .enable (enable),
        .zero   (zero)
    );

    // sawtooth counter: only counts up, then wraps to 0
    always_ff @(posedge clk) begin
        if (reset) begin
            duty_cycle <= '0;
        end else if (enable) begin
            if (zero) begin
                if (duty_cycle == MAX_DUTY_CYCLE)
                    duty_cycle <= '0;              // wrap
                else
                    duty_cycle <= duty_cycle + 1;  // count up
            end
        end else begin
            // optional: when disabled, park at 0
            duty_cycle <= '0;
        end
    end

    // same PWM as triangle version
    pwm #(
        .WIDTH(WIDTH)
    ) pwm_inst (
        .clk        (clk),
        .reset      (reset),
        .enable     (enable),
        .duty_cycle (duty_cycle),
        .pwm_out    (pwm_out)
    );

endmodule
