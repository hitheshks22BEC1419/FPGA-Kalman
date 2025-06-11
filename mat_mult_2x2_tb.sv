`timescale 1ns/1ps
`default_nettype none

module mat_mult_2x2_tb;

	logic clk, reset;
	logic [15:0] a [0:1][0:1];
	logic [15:0] b [0:1][0:1];
	logic [15:0] out [0:1][0:1];

	// DUT instantiation
	mat_mult_2x2_simple m0 (
		.clk(clk),
		.reset(reset),
		.a(a),
		.b(b),
		.out(out)
	);

	// Clock generation
	always #5 clk = ~clk;

	initial begin
		clk = 1;
		reset = 1;
		#10;
		reset = 0;

		// Test values
		#10;
		$display("Time = %0t ns | out = [[%h, %h], [%h, %h]] value is loaded",
			$time,
			out[0][0], out[0][1],
			out[1][0], out[1][1]
		);
		a = '{ '{16'h3C00, 16'h3C00}, '{16'h3C00, 16'h3C00} };
		b = '{ '{16'h3C00, 16'h3C00}, '{16'h3C00, 16'h3C00} };
		#10;
		a = '{ '{16'h4500, 16'h4600}, '{16'h4800, 16'h4700} };
		b = '{ '{16'h3C00, 16'h4000}, '{16'h4400, 16'h4200} };
		#10;
		a = '{'{16'h3C00, 16'h4000}, '{16'h4200, 16'h4400}}; // 1.0 2.0 | 3.0 4.0
		b = '{'{16'h3C00, 16'h3C00}, '{16'h4000, 16'h4000}}; // 1.0 1.0 | 2.0 2.0
		#10;
		a = '{ '{16'h3C00, 16'h03C00}, '{16'h03C00, 16'h03C00} };
		b = '{ '{16'h3C00, 16'h03C00}, '{16'h03C00, 16'h03C00} };

		// Let simulation run for a while
		#300;
		$stop;
	end

	// Monitor changes in output
	always @(out[0][0], out[0][1], out[1][0], out[1][1]) begin
		$display("Time = %0t ns | out = [[%h, %h], [%h, %h]]",
			$time,
			out[0][0], out[0][1],
			out[1][0], out[1][1]
		);
	end

endmodule
