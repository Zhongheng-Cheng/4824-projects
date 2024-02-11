
// This is a pipelined multiplier that multiplies two 64-bit integers and
// returns the low 64 bits of the result.
// This is not an ideal multiplier but is sufficient to allow a faster clock
// period than straight multiplication.

`include "mult_defs.svh" // for `STAGES

module mult (
    input clock, reset,
    input [63:0] mcand, mplier,
    input start,

    output [63:0] product,
    output done
);

    logic [`STAGES-2:0] internal_dones;
    logic [(64*(`STAGES-1))-1:0] internal_product_sums, internal_mcands, internal_mpliers;
    logic [63:0] mcand_out, mplier_out; // unused, just for wiring

    // instantiate an array of mult_stage modules
    // this uses concatenation syntax for internal wiring, see lab 2 slides
    mult_stage mstage [`STAGES-1:0] (
        .clock (clock),
        .reset (reset),
        .start       ({internal_dones,        start}), // forward prev done as next start
        .prev_sum    ({internal_product_sums, 64'h0}), // start the sum at 0
        .mplier      ({internal_mpliers,      mplier}),
        .mcand       ({internal_mcands,       mcand}),
        .product_sum ({product,    internal_product_sums}),
        .next_mplier ({mplier_out, internal_mpliers}),
        .next_mcand  ({mcand_out,  internal_mcands}),
        .done        ({done,       internal_dones}) // done when the final stage is done
    );

endmodule
