
// P2 TODO: Write a testbench which tests both specific edge cases and random values.
//          Base your testbench on mult_test.sv, specifically the wait_until_done task.

module testbench;






    initial begin

        // if incorrect
        $display("@@@ Incorrect");
        // if correct
        $display("@@@ Passed");

        $finish;
    end

endmodule
