
typedef enum logic [1:0] {START, CALCULATE, STOP} STATE;

module ISR (
    input               reset,
    input        [63:0] value,
    input               clock,
    output logic [31:0] result,
    output logic        done
);

    // P2 TODO: Finish answering questions for the mult module,
    //          then implement the Integer Square Root algorithm as specified

    // P2 NOTE: reset mult_defs.svh to 8 stages when using this module.

    logic [4:0] i, n_i;

    assign n_i = (state == CALCULATE) ? i - 5'b1 : i;
    assign square = (state == CALCULATE) ? result * result : 0; // TODO: calculate result * result
    assign result[i] = (square > value) ? 0 : 1;

    assign done = (state == STOP);
    
    // Next-state logic
    always_comb begin
        case (state)
            START:
                n_state = CALCULATE;

            CALCULATE:
                if (i >= 5'h0) n_state = CALCULATE;
                else n_state = STOP;

            STOP:
                n_state = STOP;

            default: n_state = STOP;
        endcase
    end

    always_ff @(posedge clock) begin
        if (reset) begin
            state <= START;
            square <= '0;
            result <= '0;
            done <= 0;
            i <= 5'b10000;
        end else begin
            state <= n_state;
            i <= n_i;
            result <= 32'h0;
        end
    end

endmodule
