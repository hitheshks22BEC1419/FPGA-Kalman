
//this is the final multiplier imported from another project

`default_nettype none


module fp16_mult (
	input wire clk, reset,
   input wire [15:0] a, b,
   output reg [15:0] result
);
    
	reg sign_a, sign_b, sign_res;
	reg [4:0] exp_a, exp_b, exp_res;
	reg [10:0] mant_a, mant_b;
	reg [21:0] mant_res;

	
	// clock depends on the multiplying and adding...
	always @(posedge clk or posedge reset) begin
		if (reset) 
			result <= 0;
		
		else begin
		
			//stage 1
			sign_a <= a[15];
			sign_b <= b[15];
			exp_a  <= a[14:10];
			exp_b  <= b[14:10];
			mant_a <= {1'b1, a[9:0]};  // implicit leading 1
			mant_b <= {1'b1, b[9:0]};

			//stage 2 multiply mantissa and adding exponents
			mant_res <= mant_a * mant_b;
			exp_res  <= exp_a + exp_b - 15;  // bias adjustment
			sign_res <= sign_a ^ sign_b;

			//stage 3 normalize
			if (mant_res[21]) begin
				mant_res <= mant_res >> 1;
				exp_res  <= exp_res + 1;
			end

			//stage 4
			result <= {sign_res, exp_res[4:0], mant_res[19:10]};  //rounded by 10 bits
		end
	end
endmodule
