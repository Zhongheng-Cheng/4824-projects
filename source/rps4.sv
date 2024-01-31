
module rps2 (
    input              sel,
    input        [1:0] req,
    input              en,

    output logic [1:0] gnt,
    output logic       req_up
);

    // P1 TODO: create a two-bit rotating priority selector using logic

    always_comb begin
        gnt = 2'b00;
        if (en) begin
            gnt = req;
            if (req == 2'b11) 
                (sel == 1) ? gnt = 2'b10 : gnt = 2'b01;
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

    // P1 TODO: create a 4-bit rotating priority selector using rps2 modules


    // P1 TODO: add the sequential counter here
	always_ff @(posedge clock) begin
	end

endmodule
