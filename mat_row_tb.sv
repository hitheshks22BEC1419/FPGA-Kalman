`timescale 1ns/1ps
`default_nettype none

module mat_row_tb;

  // Parameters
  parameter size = 4;

  // Signals
  logic clk, reset;
  logic [15:0] a[0:size-1];
  logic [15:0] b[0:size-1];
  logic [15:0] out;
  
  // Clock generation
  initial clk = 0;
  always #5 clk = ~clk;  // 100MHz clock

  // Instantiate DUT
  mat_row #(size) dut (
    .clk(clk),
    .reset(reset),
    .a(a),
    .b(b),
    .out(out)
  );
  
  /*
  //real fp_out;
	task automatic fp16_to_real(
    input  logic [15:0] fp_in,
    output real real_out
	);
    logic sign;
    logic [4:0] exp;
    logic [9:0] frac;
    int exponent_val;
    real fraction_val;
    real result;

    begin
        sign = fp_in[15];
        exp  = fp_in[14:10];
        frac = fp_in[9:0];

        if (exp == 5'b00000) begin
            // Subnormal number
            exponent_val = -14;
            fraction_val = frac / 1024.0; // 10-bit mantissa
            result = (sign ? -1 : 1) * (fraction_val) * 2.0**exponent_val;
        end
        else if (exp == 5'b11111) begin
            // NaN or Infinity
            if (frac == 0)
                result = (sign ? -1.0 : 1.0) * 1.0 / 0.0; // +/- Infinity
            else
                result = 0.0 / 0.0; // NaN
        end
        else begin
            // Normalized number
            exponent_val = exp - 15; // bias = 15
            fraction_val = 1.0 + (frac / 1024.0); // 1.M
            result = (sign ? -1.0 : 1.0) * fraction_val * (2.0 ** exponent_val);
        end

        real_out = result;
    end
	endtask
	*/
	
  
  initial begin
    reset = 1;
	 #10;
	 reset = 0;
	 a  = '{16'h3C00, 16'h4000, 16'h4200, 16'h4400};
	 b = 	'{4{16'h3C00}};
    
    
    #150;
    $display("Result = %h", out);  // Check final result
	 //fp16_to_real(out, fp_out);
	 //$display("Integer: %d -> FP16: %h", out, fp_out);
    $stop;
  end

endmodule
