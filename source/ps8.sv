
module ps2 (
    input        [1:0] req,
    input              en,
    output logic [1:0] gnt,
    output logic       req_up
);

    // P1 TODO: create a two-bit priority selector using if/else or assign statements

endmodule


module ps4 (
    input        [3:0] req,
    input              en,
    output logic [3:0] gnt,
    output logic       req_up
);

    // P1 TODO: create a four-bit priority selector from three ps2 modules
    // see and4.sv for an example
    // do not use any glue logic: AND, OR, +, *, etc (indexing by bits is ok)
    // you can create new variables and index into them
    // ex:
    // ps2 my_ps2(.req(), .en(), .gnt(), .req_up());


endmodule


// P1 TODO: declare and implement a ps8 module using a combination of ps4 and ps2 modules
module ps8 (
    // input/output declarations go here

);

    // implementation goes here (this should look very similar to ps4)


endmodule
