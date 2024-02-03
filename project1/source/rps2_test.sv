
module testbench;

    logic [1:0] req;
    logic       en;
    logic       sel;
    logic [1:0] gnt;
    logic [1:0] tb_gnt;
    logic       correct;

    // dut stands for Device Under Test, the module we're testing
    rps2 dut(
        .req (req),
        .en  (en),
        .sel (sel),
        .gnt (gnt)
    );

    always_comb begin
        if (~en) tb_gnt = 2'b00;
        else begin
            if (sel) begin
                casez (req)
                    2'b00: tb_gnt = 00;
                    2'b01: tb_gnt = 01;
                    2'b10: tb_gnt = 10;
                    2'b11: tb_gnt = 10;
                endcase
            end else begin
                casez (req)
                    2'b00: tb_gnt = 00;
                    2'b01: tb_gnt = 01;
                    2'b10: tb_gnt = 10;
                    2'b11: tb_gnt = 01;
                endcase
            end
        end
    end

    // assign tb_gnt[3] = en & req[3];
    // assign tb_gnt[2] = en & req[2] & ~req[3];
    // assign tb_gnt[1] = en & req[1] & ~req[2] & ~req[3];
    // assign tb_gnt[0] = en & req[0] & ~req[1] & ~req[2] & ~req[3];

    assign correct = (tb_gnt === gnt);

    always @(correct) begin
        #2
        if (!correct) begin
            $display("@@@ Incorrect at time %4.0f", $time);
            $display("@@@ gnt=%b, en=%b, req=%b", gnt, en, req);
            $display("@@@ expected result=%b", tb_gnt);
            $finish;
        end
    end

    initial begin
        $monitor("Time:%4.0f req:%b en:%b sel:%b gnt:%b", $time, req, en, sel, gnt);

        req = 2'b00;
        en = 1;
        sel = 1;

        #5 req = 2'b00;
        #5 req = 2'b01;
        #5 req = 2'b10;
        #5 req = 2'b11;
        #5 sel = 0;
        #5 req = 2'b00;
        #5 req = 2'b01;
        #5 req = 2'b10;
        #5 req = 2'b11;
        #5 en = 0;
        #5 req = 2'b01;
        #5

        $display("@@@ Passed");
        $finish;
    end

endmodule
