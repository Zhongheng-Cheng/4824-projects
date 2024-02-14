`include "mult.sv"

module ISR(
    input reset,
    input [63:0] value,
    input clock,
    output logic [31:0] result,
    output logic done
);

    logic [4:0] i;
    logic reset_sig;
    logic [31:0] res_tmp;
    logic [63:0] square;
    logic mult_start, mult_done, mult_clear;

    mult mult (
        .clock(clock), 
        .reset(reset), 
        .mcand({32'h0, res_tmp[31:0]}),
        .mplier({32'h0, res_tmp[31:0]}), 
        .start(mult_start), 
        .product(square), 
        .done(mult_done)
    );
    
    always_ff @(posedge clock or posedge reset) begin
        if (reset) begin
            i <= 5'b11111;
            mult_start <= 1'b0;
            reset_sig <= 1'b1;
            res_tmp[31:0] <= 32'h80000000;
            mult_clear <= 1'b0;
        end else begin
            reset_sig <= 1'b0;
            if (mult_clear && mult_done) begin
                mult_start <= 1'b0;
            end else if (mult_clear && !mult_done) begin
                mult_start <= 1'b1;
                mult_clear <= 1'b0;
            end else mult_start <= 1'b1;
            
            if (i != 5'b00000 && mult_done && !mult_clear) begin
                res_tmp[i] <= result[i];
                res_tmp[i - 1] <= 1'b1;
                i <= (i - 1);
		        mult_clear <= 1'b1;
            end
        end
    end

    always_comb begin
        if (reset_sig == 1'b1) begin
            done = 1'b0;
            result[31:0] = 32'h0;
        end else begin
            done = mult_done & (!i) & ~mult_clear;
            result[i] = ((square > value) ? 1'b0 : 1'b1) & mult_done;
        end
    end

endmodule