
// Project 1 example 4-bit AND gate

// This is an example of using submodules to create a larger module in a hierarchy
// in this file we create a simple 2-bit AND gate
// then we instantiate three 2-bit gates to create a 4-bit AND gate
// notably the 4-bit gate uses NO connecting logic
// it uses variables to connect the modules, but does not contain any logic itself

module and2 (
    input [1:0]  in,
    output logic out
);
    // a 2-bit AND operation
    assign out = in[0] & in[1];

endmodule


module and4 (
    input [3:0]  in,
    output logic out
);
    // use a variable to connect the left/right outputs to top
    logic [1:0] tmp;

    // reuse the logic inside the and2 module
    and2 left (.in(in[1:0]), .out(tmp[0]));
    and2 right(.in(in[3:2]), .out(tmp[1]));

    // combine the left and right to produce the final out signal
    and2 top(.in(tmp), .out(out));

endmodule
