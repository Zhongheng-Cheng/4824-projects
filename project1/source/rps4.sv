
module rps2 (
    input              sel,
    input        [1:0] req,
    input              en,

    output logic [1:0] gnt,
    output logic       req_up
);

    always_comb begin
        req_up = |req;
        if (~en) gnt = 2'b00;
        else begin
            gnt = req;
            if (req == 2'b11) 
                gnt = (sel == 1) ? 2'b10 : 2'b01;
        end
    end

endmodule


module rps4 (
    input              clock,
    input              reset,
    input        [3:0] req,
    input              en,

    output logic [3:0] gnt,
    output logic [1:0] count
);

	always_ff @(posedge clock) begin
        if (reset) count <= 2'b00;
        else begin
            if (count == 2'b11) count <= 2'b00;
            else count <= count + 1'b1;
        end
	end

    logic [1:0] req_up_temp;
    logic [1:0] gnt_temp;
    logic req_up;

    rps2 left(
        .req(req[3:2]), 
        .en(gnt_temp[1]), 
        .sel(count[0]),
        .gnt(gnt[3:2]), 
        .req_up(req_up_temp[1])
    );

    rps2 right(
        .req(req[1:0]), 
        .en(gnt_temp[0]), 
        .sel(count[0]),
        .gnt(gnt[1:0]), 
        .req_up(req_up_temp[0])
    );

    rps2 top(
        .req(req_up_temp[1:0]), 
        .en(en), 
        .sel(count[1]),
        .gnt(gnt_temp[1:0]), 
        .req_up(req_up)
    );

endmodule
