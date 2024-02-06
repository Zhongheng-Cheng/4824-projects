
module ps2 (
    input        [1:0] req,
    input              en,
    output logic [1:0] gnt,
    output logic       req_up
);

    assign req_up = |req;
    assign gnt[1] = en & req[1];
    assign gnt[0] = en & req[0] & ~req[1];

endmodule


module ps4 (
    input        [3:0] req,
    input              en,
    output logic [3:0] gnt,
    output logic       req_up
);

    logic req_high;
    logic req_low;

    ps2 high(
        .req(req[3:2]), 
        .en(en), 
        .gnt(gnt[3:2]),
        .req_up(req_high)
    );

    ps2 low(
        .req(req[1:0]), 
        .en(en & ~req_high), 
        .gnt(gnt[1:0]),
        .req_up(req_low)
    );

    assign req_up = req_high | req_low;


endmodule


module ps8 (
    input        [7:0] req,
    input              en,
    output logic [7:0] gnt,
    output logic       req_up

);

    logic req_high;
    logic req_low;

    ps4 high(
        .req(req[7:4]), 
        .en(en), 
        .gnt(gnt[7:4]),
        .req_up(req_high)
    );

    ps4 low(
        .req(req[3:0]), 
        .en(en & ~req_high), 
        .gnt(gnt[3:0]),
        .req_up(req_low)
    );

    assign req_up = req_high | req_low;


endmodule
