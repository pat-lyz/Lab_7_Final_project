module sar_adc #(
    parameter WIDTH = 8
)(
    input  logic dac_clk,
    input  logic reset,
    input  logic start_conversion,
    input  logic comp_in,           // Asynchronous comparator input
    output logic [WIDTH-1:0] dac_value,
    output logic [WIDTH-1:0] adc_data,
    output logic conversion_done
);
    
    // FSM States
    typedef enum logic [1:0] {
        IDLE,
        SET_BIT,
        WAIT_SETTLE,
        EVALUATE
    } state_t;
    
    // Synchronizer for comparator input
    logic comp_sync, comp_meta;
    logic [WIDTH-1:0] dac_register;
    state_t state;
    logic [2:0] bit_index;
    logic [3:0] settle_counter;
    
    // Comparator input synchronizer
    always_ff @(posedge dac_clk or posedge reset) begin
        if (reset) begin
            comp_meta <= 1'b0;
            comp_sync <= 1'b0;
        end else begin
            comp_meta <= comp_in;
            comp_sync <= comp_meta;
        end
    end
    
    // SAR Control FSM
    always_ff @(posedge dac_clk or posedge reset) begin
        if (reset) begin
            state <= IDLE;
            dac_register <= '0;
            adc_data <= '0;
            bit_index <= WIDTH-1;
            conversion_done <= 1'b0;
            settle_counter <= '0;
        end else begin
            conversion_done <= 1'b0;  // Pulse for one cycle
            
            case (state)
                IDLE: begin
                    dac_register <= '0;
                    if (start_conversion) begin
                        state <= SET_BIT;
                        bit_index <= WIDTH-1;
                    end
                end
                
                SET_BIT: begin
                    // Set current bit for testing
                    dac_register[bit_index] <= 1'b1;
                    state <= WAIT_SETTLE;
                    settle_counter <= 4'd200;  // Wait 50 clock cycles (previously 10)
                end
                
                WAIT_SETTLE: begin
                    if (settle_counter == 0) begin
                        state <= EVALUATE;
                    end else begin
                        settle_counter <= settle_counter - 1;
                    end
                end
                
                EVALUATE: begin
                    // Make decision based on comparator
                    if (comp_sync == 1'b0) begin  // V_analog < V_dac
                        dac_register[bit_index] <= 1'b0;  // Clear the bit
                    end
                    // else: bit stays at 1 (V_analog > V_dac)
                    
                    if (bit_index == 0) begin
                        // Conversion complete
                        adc_data <= dac_register;
                        conversion_done <= 1'b1;
                        state <= IDLE;
                    end else begin
                        bit_index <= bit_index - 1;
                        state <= SET_BIT;
                    end
                end
                
                default: state <= IDLE;
            endcase
        end
    end
    
    // Output the current DAC value
    assign dac_value = dac_register;
    
endmodule