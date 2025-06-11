`timescale 1ns/1ps


module mat_inv_2x2_tb;

    // Clock and reset
    logic clk, reset;

    // Inputs
    logic [15:0] a [0:1][0:1];

    // Outputs
    logic [15:0] o [0:1][0:1];

    // Instantiate DUT (Device Under Test)
    mat_inv_2x2 uut (
        .clk(clk),
        .reset(reset),
        .a(a),
        .o(o)
    );

    // Clock generation
    initial clk = 1;
    always #5 clk = ~clk;  // 10 ns clock period (100 MHz)

    // Task to apply matrix input
    task apply_matrix(input [15:0] aa, input [15:0] ab, input [15:0] ac, input [15:0] ad);
        begin
            a[0][0] = aa;
            a[0][1] = ab;
            a[1][0] = ac;
            a[1][1] = ad;
        end
    endtask

    // Reset sequence
    initial begin
        reset = 1;
        #20;
        reset = 0;
    end

    // Test sequence
    initial begin
        // Wait after reset
        #40;

        // Apply example matrix
		  $display("Time = %0t ns | out = [[%h, %h], [%h, %h]] Matrix Values uploaded	",
				$time,
				o[0][0], o[0][1],
				o[1][0], o[1][1]
			);
        apply_matrix(16'h3C00, 16'h4000, 16'h4200, 16'h3C00); // Matrix = [1 2; 3 1]
		  #10;
		  apply_matrix(16'h3C00, 16'h4000, 16'h4200, 16'h4400); // 1.0 2.0 | 3.0 4.0
		  #10;
		  apply_matrix(16'h3C00, 16'h3C00, 16'h4000, 16'h4000); // 1.0 1.0 | 2.0 2.0
	
        // Wait for pipeline to process (4 + 5 + 0 + 4 = around 13 clocks)
        #300;

        // Display output
        $display("Output Inverse Matrix:");

		  

        // Finish
        #50;
        $stop;
    end
	
	always @(o[0][0], o[0][1], o[1][0], o[1][1]) begin
			$display("Time = %0t ns | out = [[%h, %h], [%h, %h]]",
				$time,
				o[0][0], o[0][1],
				o[1][0], o[1][1]
			);
	end
endmodule
