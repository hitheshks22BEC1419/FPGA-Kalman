`timescale 100ps / 1ps
`default_nettype none

module fp16_mult_tb;

    reg clk;
    reg reset;
    reg [15:0] a;
    reg [15:0] b;
    
    // Output
    wire [15:0] result;
    
    // Instantiate the DUT (Device Under Test)
    fp16_mult uut (
        .clk(clk),
        .reset(reset),
        .a(a),
        .b(b),
        .result(result)
    );
    
    // Clock generation (10 ns period -> 100 MHz)
    always #5 clk = ~clk;
    
    // Test sequence
    initial begin
        // Initialize
        clk = 0;
        reset = 1;
        a = 0;
        b = 0;
        
        #10;
        reset = 0;
        
        // Test 1: Multiply 1.5 * 2.0
        a = 16'b0011111000000000; // 1.5 in FP16
        b = 16'b0100000000000000; // 2.0 in FP16
        #20;
        
        // Test 2: Multiply -1.25 * 0.5
        a = 16'b1011110100000000; // -1.25 in FP16
        b = 16'b0011100000000000; // 0.5 in FP16
		  
        #20;
        
        // Test 3: Multiply 0.0 * 3.5
        a = 16'b0000000000000000; // 0.0 in FP16
        b = 16'b0100001100000000; // 3.5 in FP16
        #20;
        
        // Test 4: Multiply -2.0 * -2.0
        a = 16'b1100000000000000; // -2.0 in FP16
        b = 16'b1100000000000000; // -2.0 in FP16
        #20;
        
        // Test 5: Multiply small values
        a = 16'b0011000000000000; // 0.125 in FP16
        b = 16'b0011000000000000; // 0.125 in FP16
        #20;
        
        // End simulation
        $stop;
    end
    
endmodule
