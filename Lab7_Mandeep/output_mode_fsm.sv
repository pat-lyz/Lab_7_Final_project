module output_mode_fsm (
    input  logic clk,
    input  logic reset,
    input  logic [1:0] mode_select,  // 00 off, 01 triangle, 10 sawtooth, 11 buzzer
    output logic pwm_enable,
    output logic r2r_enable,
    output logic buzzer_enable,
    output logic waveform_select     // 0 = triangle, 1 = sawtooth
);
    typedef enum logic [1:0] {
        OFF_MODE    = 2'b00,
        PWM_TRI     = 2'b01,
        PWM_SAW     = 2'b10,
        CHIRP_MODE = 2'b11
    } statetype;

    statetype current_state, next_state;

    always_ff @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= OFF_MODE;
        else
            current_state <= next_state;
    end

    always_comb begin
        next_state = statetype'(mode_select);
    end

    always_comb begin
        pwm_enable      = 1'b0;
        r2r_enable      = 1'b0;
        buzzer_enable   = 1'b0;
        waveform_select = 1'b0;
   
        case (current_state)
            PWM_TRI: begin
                pwm_enable      = 1'b1;
                r2r_enable      = 1'b1;  // <--- enable JA pins
                waveform_select = 1'b0;  // triangle
            end
            PWM_SAW: begin
                pwm_enable      = 1'b1;
                r2r_enable      = 1'b1;  // <--- enable JA pins
                waveform_select = 1'b1;  // sawtooth
            end
            CHIRP_MODE: begin
                buzzer_enable   = 1'b1;
            end
            default: ; // OFF
        endcase
    end
endmodule