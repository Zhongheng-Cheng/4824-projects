
module ps4 (
    input        [3:0] req,
    input              en,
    output logic [3:0] gnt
);

    // P1 TODO: use assign statements and logic to create a priority selector
    // do not use any always blocks
    // ex:
    // assign x = y[1] & z & ~a;

    assign gnt[3] = en & req[3];
    assign gnt[2] = en & req[2] & ~req[3];
    assign gnt[1] = en & req[1] & ~req[2] & ~req[3];
    assign gnt[0] = en & req[0] & ~req[1] & ~req[2] & ~req[3];


endmodule
