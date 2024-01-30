
module testbench;

    logic [3:0] in;
    logic out;
    logic tb_out;

    // dut stands for Device Under Test, the module we're testing
    and4 dut(
        .in  (in),
        .out (out)
    );

    // the prepend ampersand operator ANDs all bits of a variable together
    assign tb_out = &in;

    assign correct = (out == tb_out);

    always @(correct) begin
        #2
        if (!correct) begin
            $display("@@@ Incorrect at time %4.0f", $time);
            $display("@@@ in:%b out:%b", in, out);
            $display("@@@ expected result=%b", tb_out);
            $finish;
        end
    end

    initial begin
        $monitor("Time:%4.0f in:%b out:%b", $time, in, out);

        in = 4'b0000; #5
        in = 4'b1100; #5
        in = 4'b0110; #5
        in = 4'b1111; #5
        in = 4'b0111; #5

        $display("@@@ Passed");
        $finish;
    end

endmodule
