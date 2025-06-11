
//`default_nettype none

module mat_mult_2x2 (
	input logic clk,reset,
	input logic [15:0] a [0:1][0:1],
	input logic [15:0] b [0:1][0:1],
	output logic [15:0] out [0:1][0:1]
);

	
	logic [15:0] pp [0:1][0:1];
	
	logic [15:0] addn1 [1:0], addn2 [1:0] , addo[1:0];		//2adders
	logic [15:0] multn1 [3:0], multn2 [3:0] , multo[3:0];	//4 multipliers at a time
	
	fp16_mult m0(.clk(clk), .reset(reset),.a(multn1[0]), .b(multn2[0]),.result(multo[0]));
	fp16_mult m1(.clk(clk), .reset(reset),.a(multn1[1]), .b(multn2[1]),.result(multo[1]));
	fp16_mult m2(.clk(clk), .reset(reset),.a(multn1[2]), .b(multn2[2]),.result(multo[2]));
	fp16_mult m3(.clk(clk), .reset(reset),.a(multn1[3]), .b(multn2[3]),.result(multo[3]));
	
	fp16_sum s0(.clk(clk),.reset(reset),.num1(addn1[0]),.num2(addn2[0]),.out(addo[0]));
	fp16_sum s1(.clk(clk),.reset(reset),.num1(addn1[1]),.num2(addn2[1]),.out(addo[1]));
	
	
	
	typedef enum logic[1:0]{
		IDLE, LOAD1, LOAD2, ADD2
	}state_t;
	
	logic [1:0] state;
	logic [1:0] counter;
	
	
	always@(posedge clk or posedge reset)begin
		if(reset)begin
			state <= IDLE;
		end
		else begin
			//if(counter != 3'd5)
				//counter <= counter+1;
			case(state)
				IDLE: begin
						
						out <= '{ '{16'b0, 16'b0}, '{16'b0, 16'b0} };
						state <= LOAD1;
						counter <= 2'b0;
						
						end
				
				LOAD1: begin
						
						multn1[0] <= a[0][0];
						multn2[0] <= b[0][0];
						
						multn1[1] <= a[0][1];
						multn2[1] <= b[1][0];
						
						multn1[2] <= a[1][0];
						multn2[2] <= b[0][1];

						multn1[3] <= a[1][1];
						multn2[3] <= b[1][1];
						
						//state <= LOAD2;
						
						end
						
				LOAD2: begin
						
						multn1[0] <= a[0][0];
						multn2[0] <= b[0][1];
						
						multn1[1] <= a[0][1];
						multn2[1] <= b[1][1];
						
						multn1[2] <= a[1][0];
						multn2[2] <= b[0][0];

						multn1[3] <= a[1][1];
						multn2[3] <= b[1][0];
						
						//adders input
						
						addn1[0] <= multo[0];
						addn2[0] <= multo[1];
						
						addn1[1] <= multo[2];
						addn2[1] <= multo[3];
						
						state <= ADD2;
		
						///OUTPUTS///
			
						pp[0][0] <= addo[0];
						pp[1][1] <= addo[1];
						
						out <= pp;
					
						end
						 
				ADD2: begin
						
						addn1[0] <= multo[0];
						addn2[0] <= multo[1];
						
						addn1[1] <= multo[2];
						addn2[1] <= multo[3];
						
						//high throughput//
						
						state <= LOAD1;
						//counter <= 2'b0;  
			
						///OUTPUTS///
						pp[0][1] <= addo[0];
						pp[1][0] <= addo[1];
						
						end
							
				default: begin
						out <= '{ '{16'b0, 16'b0}, '{16'b0, 16'b0} };
						state <= IDLE;
						end
					
			endcase

		end
	end

	
	
endmodule 