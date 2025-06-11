`timescale 1ns/1ps

module fp16_recip_tb;

  logic clk;
  logic [15:0] in_fp16;
  logic [15:0] out_fp16;

  // Instantiate the module
  fp16_recip uut (
    .clk(clk),
    .in_fp16(in_fp16),
    .out_fp16(out_fp16)
  );

  // Clock generation: 10ns period
  initial begin
    clk = 0;
    forever #5 clk = ~clk;
  end

  // Stimulus
  initial begin

    // Initialize input
    in_fp16 = 16'h0000; // Zero input
    @(posedge clk);
    #10;
    $display("Input: %h, Output: %h", in_fp16, out_fp16);

    in_fp16 = 16'h3C00; // 1.0 in FP16
    @(posedge clk);
    #10;
    $display("Input: %h, Output: %h", in_fp16, out_fp16);

    in_fp16 = 16'h4400; // 2.0 in FP16
    @(posedge clk);
    #10;
    $display("Input: %h, Output: %h", in_fp16, out_fp16);

    in_fp16 = 16'h4200; // 3.0 in FP16
    @(posedge clk);
    #10;
    $display("Input: %h, Output: %h", in_fp16, out_fp16);

    in_fp16 = 16'hC000; // -2.0 in FP16 (negative)
    @(posedge clk);
    #10;
    $display("Input: %h, Output: %h", in_fp16, out_fp16);

    in_fp16 = 16'h7C00; // Infinity input
    @(posedge clk);
    #10;
    $display("Input: %h, Output: %h", in_fp16, out_fp16);

    in_fp16 = 16'h7E00; // NaN input
    @(posedge clk);
    #10;
    $display("Input: %h, Output: %h", in_fp16, out_fp16);

    // Random normal value
    in_fp16 = 16'h3555; // Random normal FP16 number
    @(posedge clk);
    #10;
    $display("Input: %h, Output: %h", in_fp16, out_fp16);

    // Subnormal number
    in_fp16 = 16'h03FF; // Largest subnormal
    @(posedge clk);
    #10;
    $display("Input: %h, Output: %h", in_fp16, out_fp16);
	 
	 in_fp16 = 16'h33FF; 
    @(posedge clk);
    #10;
    $display("Input: %h, Output: %h", in_fp16, out_fp16);

    // End simulation
    #300;
    $stop;
  end

endmodule
