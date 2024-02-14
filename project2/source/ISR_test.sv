module testbench();

	logic [63:0] val;
	logic clock, reset, done;
	logic [31:0] result;
	logic [31:0] ground_truth;

    // P2 NOTE: Constructing a correct result can be difficult for the ISR
    //          it can be easier to just check two things:
    //          - result isn't too large: result*result <=value
    //          - result isn't too small: (result+1)*(result+1) > value
    // logic check = (result * result <= val) && ((result + 1) * (result + 1) > val);
    // logic correct = ~done || (check);
	wire correct = (ground_truth===result)|~done|reset;

    ISR isr(
        .reset(reset), 
        .value(val), 
        .clock(clock),
        .result(result), 
        .done(done)
    );

	always @(posedge clock)
		#2 if(!correct) begin
			$display("@@@Failed");
			$finish;
		end

	always begin
		#(`CLOCK_PERIOD/2.0);
		clock=~clock;
	end

	task cal_ground_truth;
        input [63:0] value;
        output [31:0] ground_truth;
        begin
            integer j;
			ground_truth = 32'h00000000;
            for (j=31; j >= 0; j--) begin
				ground_truth[j] = 1'b1;
				if (ground_truth * ground_truth > value) ground_truth[j] = 1'b0;
            end
        end
    endtask

	task wait_until_done;
		forever begin : wait_loop
			@(posedge done);
			@(negedge clock);
			if (done) begin
				disable wait_until_done;
			end
		end
	endtask

    task test_value;
        input [63:0] value;
        val = value;
		reset = 1;
		cal_ground_truth(val, ground_truth);
        clock = 0;
		@(negedge clock);
		reset = 0;
		wait_until_done();
		@(negedge clock);
    endtask

	initial begin
        // $monitor("Time:%4.0f done:%b result:%h reset:%h",$time,done,result,reset);
        

        // test on normal values
        test_value(100);
        test_value(200);
        test_value(300);
        test_value(225);

        // test on edge values
        test_value(0);
        test_value(64'hFFFF_FFFF_FFFF_FFFF);

        // test on random values
        for (integer i = 0; i < 1000; i++) begin
			test_value({$random, $random});
		end
        
		$display("@@@Passed");
		$finish;
	end

endmodule



