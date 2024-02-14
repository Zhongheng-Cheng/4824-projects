
// typedef enum logic [1:0] {START, CALCULATE, STOP} STATE;

// module ISR (
//     input               reset,
//     input        [63:0] value,
//     input               clock,
//     output logic [31:0] result,
//     output logic        done,
//     output [4:0] i
// );

//     // P2 TODO: Finish answering questions for the mult module,
//     //          then implement the Integer Square Root algorithm as specified

//     // P2 NOTE: reset mult_defs.svh to 8 stages when using this module.

//     logic [4:0] i, last_i;
//     STATE state, n_state;
//     logic [63:0] square;

//     // assign i = (state == START) ? 5'b11111
//     // assign n_i = (state == CALCULATE) ? i - 5'b1 : i;
//     // assign square = (state == CALCULATE) ? result * result : 0;
//     // assign result[i] = (square <= value);

//     // assign done = (state == STOP);
    
//     // // Next-state logic
//     // always_comb begin
//     //     case (state)
//     //         START:
//     //             n_state = CALCULATE;

//     //         CALCULATE:
//     //             if (i >= 5'h0) n_state = CALCULATE;
//     //             else n_state = STOP;

//     //         STOP:
//     //             n_state = STOP;

//     //         default: n_state = STOP;
//     //     endcase
//     // end

//     // always_ff @(posedge clock) begin
//     //     if (reset) begin
//     //         state <= START;
//     //         square <= 0;
//     //         result <= 0;
//     //         done <= 0;
//     //         i <= 5'b11111;
//     //     end else begin
//     //         state <= n_state;
//     //         i <= n_i;
//     //         result <= 32'h0;
//     //     end
//     // end



//     ////////////////////////
//     always_ff @(posedge clock or posedge reset) begin
//         if (reset) begin
//             state <= START;
//             square <= 0;
//             result <= 0;
//             done <= 0;
//             i <= 5'b11111;
//         end else begin
//             case (state)
//                 START:
//                     state <= CALCULATE;
//                 CALCULATE:
//                     if (i > 0) begin
//                         result[i] <= 1;
//                         // square <= result * result;
//                         // square <= result;
//                         // if (square > value) begin
//                         //     result[last_i] <= 0;
//                         //     result[0] <= ~result[0];
//                         // end
//                         // result[i] <= (square > value) ? 0 : 1;
//                         i <= i - 1;
//                         // if (i == 5'd25) state <= STOP;
//                     end else begin
//                         state <= STOP;
//                     end
//                 STOP:
//                     done <= 1;
//             endcase
//         end
//     end

// endmodule


`include "mult.sv"

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

    logic [63:0] stored_value; // To store the input value upon reset
    logic [63:0] mplier_input; // Input for the mult module
    logic mult_start, mult_done; // Start and done signals for the mult module
    logic [63:0] mult_result; // Result from the mult module
    logic [31:0] test_result;
    integer cycle_count;  //Cycle counter
    integer i;

    mult multiplication(
        .reset(reset),
        .clock(clock),
        .mcand(mplier_input),
        .mplier(mplier_input),
        .start(mult_start),
        .product(mult_result),
        .done(mult_done)
    );

    typedef enum {IDLE, CALCULATING, COMPARE, FINISH, DONE} state_t;
    state_t state;

always_ff @(posedge clock or posedge reset) begin
    if (reset) begin
        stored_value <= value;
        result <= 0;
        done <= 0;
        cycle_count <= 0;
        i <= 31;
        mplier_input <= 0;
        mult_start <= 0;
        test_result <= 0;
        state <= IDLE;
    end else begin
        cycle_count <= cycle_count + 1;
        casez (state)
            IDLE: begin
		$display("ISR State: IDLE");
		stored_value <= value;
                if (stored_value != 0) begin
                    state <= CALCULATING;
                end else begin 
                    state <= IDLE;
                end
            end

            CALCULATING: begin
		$display("ISR State: CALCULATING", i);
                test_result <= result | (32'd1 << i);
                mplier_input <= {32'd0, result | (32'd1 << i)};
                mult_start <= 1;
                state <= COMPARE;
		$display("mplier_input:%h, test_result:%h", mplier_input,test_result,i);
            end

            COMPARE: begin
		mult_start <= 0;
		$display("ISR State: COMPARE, test_result:%h, mplier_input: %h, mult_done:%h", test_result,mplier_input, mult_done,i);
                if (mult_done) begin 
                    if (mult_result > stored_value) begin
                        test_result <= test_result & ~(32'd1 << i); 
			$display("mult_result:%h, test_result:%h, i:%d, stored_value:%d, mult_done=1  >", mult_result,test_result,i,stored_value);
                    end else begin
                        result <= test_result; 
			$display("mult_result:%h, test_result:%h, i:%d,stored_value:%d, mult_done=1 <=", mult_result,test_result,i,stored_value);
                    end
                    i <= i - 1; 
                    if (i < 0) begin
                        state <= FINISH; 
			 
			i <= 31;
                    end else begin
                        state <= CALCULATING; 
                    end
                end
                
            end

            FINISH: begin
		$display("ISR State: FINISH");
                done <= 1;
                state <= DONE;
            end

            DONE: begin
		$display("ISR State: DONE");
                done <= 0;
                state <= IDLE;
                cycle_count <= 0;
            end
	    default: begin
		stored_value <= value;
		
	    end
        endcase
    end

    if (cycle_count >= 600) begin
                state <= FINISH;
    end else begin
        // No operation needed here to avoid latches, explicitly showing the intention
    end
end
endmodule
