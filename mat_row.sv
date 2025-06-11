
//`default_nettype none

module mat_row #( parameter size = 4)(
	input logic clk,
	input logic reset,
	input logic [15:0] a[0:size-1],
	input logic [15:0] b[0:size-1],
	output logic [15:0] out
	);
	
	logic [15:0] prod; 
	logic [15:0] acc,sumout;
	logic [3:0] i,j;
	
	fp16_mult u_mult(
		.clk(clk),.reset(reset),.a(a[i]),.b(b[i]),.result(prod)
	);
	
	fp16_sum u_sum(
		.clk(clk),.num1(prod),.num2(acc),.out(acc)
	);
	
	always_ff @(posedge clk or posedge reset) begin
		if(reset)begin
			i <= 0;
			acc <= 0;
			//prod <= 0;
		end
		else if(i<size) begin
			acc <= sumout;
			i <= i+1;
		end
		else begin
			i <= 0;
		end
		
	end
	
	assign out = acc;
	
	
	
	
	
endmodule 