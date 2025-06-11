`timescale 1ns / 1ps

module fp16_sum_tb;
    reg clk;
    reg [15:0] num1, num2;
    wire [15:0] out;
    //wire f_z;

    // Instantiate the module under test
    fp16_sum uut (
        .clk(clk),
        .num1(num1),
        .num2(num2),
        .out(out)
    );

    // Clock generation
    always #5 clk = ~clk;

    initial begin
        // Initialize values
        clk = 0;
        num1 = 16'b0;
        num2 = 16'b0;
		  
		  $monitor("Time = %0t | num1 = %b | num2 = %b | out = %b %d %d", $time, num1, num2, out[15],out[14:10],out[9:0]);
        
        // Apply test cases
				num1 <= 16'b0_10001_0000000000; // 4.0 in FP16
            num2 <= 16'b0_10000_0000_0000_00; // 2.0 in FP16
        
		  #10 num1 <= 16'b1_11111_1111_1111_11; // 64
				num2 <= 16'b1_10010_0000000000; // 8
				
			#10 num1 <= 16'b1_10100_1000000000; //-24
				num2 <= 16'b0_10100_1000000000; //+24
			
			#10 num1 <= 16'b1_10000_0000000000; //-2
				num2 <= 16'b1_10001_0000000000; //-4
				
				#10 num1 <= 16'b1_10100_0000000000; //-32
					num2 <= 16'b0_10000_0000000000; //2
			
        
        #100 $stop;
    end
endmodule 