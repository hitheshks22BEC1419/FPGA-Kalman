
//this is the final adder / subtractor 

`default_nettype none
module fp16_sum(input wire clk,input wire [15:0] num1,num2,output reg [15:0] out);

	reg big_sign,sma_sign;
	reg [4:0] big_exp,sma_exp;
	reg [9:0] big_mant,sma_mant;
	
	//big number is found and norm_mant is pushed sma_mant also shifted
	//clk1
	always @(posedge clk) begin
	
		if (num2[14:10] > num1[14:10]) begin
				 {big_sign,big_exp,big_mant} <= num2; 
				 {sma_sign,sma_exp,sma_mant} <= num1; 
		end
		
		else if (num2[14:10] == num1[14:10]) begin
			if (num2[9:0] > num1[9:0]) begin
				 {big_sign,big_exp,big_mant} <= num2;
				 {sma_sign,sma_exp,sma_mant} <= num1;
			end	
			else begin
				 {big_sign,big_exp,big_mant} <= num1;		//num1 given priority when equal values		 
				 {sma_sign,sma_exp,sma_mant} <= num2;				 
			end
		end
		
		else begin
			{big_sign,big_exp,big_mant} <= num1;		 
			{sma_sign,sma_exp,sma_mant} <= num2;
		end
	end
	
	reg [4:0] tobig_exp;
	reg tobig_sign;
	reg[10:0] big_norm_mant, sma_norm_mant;
	//shifting of sma and loading big
	//clk2
	always@(posedge clk)begin
		tobig_sign <= big_sign;
		tobig_exp <= big_exp;
		big_norm_mant <= {1'b1,big_mant};
		sma_norm_mant <= {1'b1,sma_mant} >> (big_exp - sma_exp);
	end
	
	reg f_add_sub;
	reg add_sub;
	reg t_add_sub;
	//add or sub decided
	//clk1 only   accessing num1 multiple times in the same time slot though
	always@(posedge clk)begin
		t_add_sub <= (num1[15] == num2[15]); // clk1
		add_sub <= t_add_sub;                //clk 2
		f_add_sub <= add_sub;                //clk 3
	end
	
	reg tbig_sign;
	reg [4:0] tbig_exp;
	reg [11:0] pre_mant;
	//adding or subtracting is done
	//clk3
		always @(posedge clk) begin
		  tbig_sign <= tobig_sign;
		  tbig_exp <= tobig_exp;
        if (add_sub) begin // If adding
            pre_mant <= big_norm_mant + sma_norm_mant;
        
        end
        else begin // If subtracting
            pre_mant <= big_norm_mant - sma_norm_mant;
        end
	end
	
	reg res_sign;
	reg [4:0] res_exp;
	reg [9:0] res_mant;
	//normalization before output
	//clk4
	always @(posedge clk)begin
		res_sign <= tbig_sign;
		if(f_add_sub)begin
			res_exp <= pre_mant[11] ? tbig_exp+1:tbig_exp;
			res_mant <= pre_mant[11] ? pre_mant[10:1] : pre_mant[9:0]; //anyway 11th or 10th bit will be 1
		end
		else begin
			casez (pre_mant)
				//12'b1_????_????_???: begin res_mant <= pre_mant[11:2] << 1; res_exp <= big_exp + 1; end // wont happen but yeah
				12'b0_1???_????_???: begin res_mant <= pre_mant[11:2] << 2; res_exp <= tbig_exp ; end
				12'b0_01??_????_???: begin res_mant <= pre_mant[11:2] << 3; res_exp <= tbig_exp - 1; end
				12'b0_001?_????_???: begin res_mant <= pre_mant[11:2] << 4; res_exp <= tbig_exp - 2; end
				12'b0_0001_????_???: begin res_mant <= pre_mant[11:2] << 5; res_exp <= tbig_exp - 3; end
				12'b0_0000_1???_???: begin res_mant <= pre_mant[11:2] << 6; res_exp <= tbig_exp - 4; end
				12'b0_0000_01??_???: begin res_mant <= pre_mant[11:2] << 7; res_exp <= tbig_exp - 5; end
				12'b0_0000_001?_???: begin res_mant <= pre_mant[11:2] << 8; res_exp <= tbig_exp - 6; end
				12'b0_0000_0001_???: begin res_mant <= pre_mant[11:2] << 9; res_exp <= tbig_exp - 7; end
				12'b0_0000_0000_1??: begin res_mant <= pre_mant[11:2] << 10; res_exp <= tbig_exp - 8; end
				12'b0_0000_0000_01?: begin res_mant <= pre_mant[11:2] << 11; res_exp <= tbig_exp - 9; end
				12'b0_0000_0000_001: begin res_mant <= pre_mant[11:2] << 12; res_exp <= tbig_exp - 10; end
				
				default: begin res_mant <= 10'b00_0000_0000; res_exp <= 5'b00_000; end
			endcase
		end
	end
	
	//output value is pushed
	//clk5
	always @(posedge clk)begin
		out <= {res_sign,res_exp,res_mant};
	end
	
endmodule





