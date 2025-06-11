
module mat_sum_2x2(
	input logic clk,reset,
	input logic [15:0] a [0:1][0:1],
	input logic [15:0] b [0:1][0:1],
	output logic [15:0] out [0:1][0:1]
);

	logic [15:0] num1 [0:1][0:1];
	logic [15:0] num2 [0:1][0:1];
	
	
	fp16_sum s0(.clk(clk),.reset(reset),.num1(num1[0][0]),.num2(num2[0][0]),.out(out[0][0]));	
	fp16_sum s1(.clk(clk),.reset(reset),.num1(num1[0][1]),.num2(num2[0][1]),.out(out[0][1]));	
	fp16_sum s2(.clk(clk),.reset(reset),.num1(num1[1][0]),.num2(num2[1][0]),.out(out[1][0]));	
	fp16_sum s3(.clk(clk),.reset(reset),.num1(num1[1][1]),.num2(num2[1][1]),.out(out[1][1]));	
	
endmodule 