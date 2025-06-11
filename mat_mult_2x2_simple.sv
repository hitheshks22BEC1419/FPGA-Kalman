
//Total Latency is 9 

module mat_mult_2x2_simple(
	input logic clk,reset,
	input logic [15:0] a [0:1][0:1],
	input logic [15:0] b [0:1][0:1],
	output logic [15:0] out [0:1][0:1]
);
	
	
	//logic [15:0] pp [0:1][0:1];
	
	logic [15:0] addn1 [3:0], addn2 [3:0] , addo[3:0];		//2adders
	logic [15:0] multn1 [7:0], multn2 [7:0] , multo[7:0];	//4 multipliers at a time
	
	fp16_mult m0(.clk(clk), .reset(reset),.a(multn1[0]), .b(multn2[0]),.result(multo[0]));
	fp16_mult m1(.clk(clk), .reset(reset),.a(multn1[1]), .b(multn2[1]),.result(multo[1]));
	fp16_mult m2(.clk(clk), .reset(reset),.a(multn1[2]), .b(multn2[2]),.result(multo[2]));
	fp16_mult m3(.clk(clk), .reset(reset),.a(multn1[3]), .b(multn2[3]),.result(multo[3]));
	
	fp16_mult m4(.clk(clk), .reset(reset),.a(multn1[4]), .b(multn2[4]),.result(multo[4]));
	fp16_mult m5(.clk(clk), .reset(reset),.a(multn1[5]), .b(multn2[5]),.result(multo[5]));
	fp16_mult m6(.clk(clk), .reset(reset),.a(multn1[6]), .b(multn2[6]),.result(multo[6]));
	fp16_mult m7(.clk(clk), .reset(reset),.a(multn1[7]), .b(multn2[7]),.result(multo[7]));
	
	fp16_sum s0(.clk(clk),.reset(reset),.num1(addn1[0]),.num2(addn2[0]),.out(addo[0]));
	fp16_sum s1(.clk(clk),.reset(reset),.num1(addn1[1]),.num2(addn2[1]),.out(addo[1]));
	fp16_sum s2(.clk(clk),.reset(reset),.num1(addn1[2]),.num2(addn2[2]),.out(addo[2]));
	fp16_sum s3(.clk(clk),.reset(reset),.num1(addn1[3]),.num2(addn2[3]),.out(addo[3]));
	
	
	always_comb begin
		 // Multiplier input setup (Latency of 4 )
		 multn1[0] = a[0][0]; multn2[0] = b[0][0]; // a00 * b00
		 multn1[1] = a[0][1]; multn2[1] = b[1][0]; // a01 * b10

		 multn1[2] = a[0][0]; multn2[2] = b[0][1]; // a00 * b01
		 multn1[3] = a[0][1]; multn2[3] = b[1][1]; // a01 * b11

		 multn1[4] = a[1][0]; multn2[4] = b[0][0]; // a10 * b00
		 multn1[5] = a[1][1]; multn2[5] = b[1][0]; // a11 * b10

		 multn1[6] = a[1][0]; multn2[6] = b[0][1]; // a10 * b01
		 multn1[7] = a[1][1]; multn2[7] = b[1][1]; // a11 * b11

		 // Adder input setup (summing products for final matrix output) (Latency of 5)
		 addn1[0] = multo[0]; addn2[0] = multo[1]; // c00 = a00*b00 + a01*b10
		 addn1[1] = multo[2]; addn2[1] = multo[3]; // c01 = a00*b01 + a01*b11
		 addn1[2] = multo[4]; addn2[2] = multo[5]; // c10 = a10*b00 + a11*b10
		 addn1[3] = multo[6]; addn2[3] = multo[7]; // c11 = a10*b01 + a11*b11
		 
		out[0][0] = addo[0];
		out[0][1] = addo[1];
		out[1][0] = addo[2];
		out[1][1] = addo[3];
	end



endmodule 