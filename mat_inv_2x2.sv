
//total latency of 14

module mat_inv_2x2 (
    input  logic clk, reset,
    input  logic [15:0] a [0:1][0:1],    // matrix A = [a b; c d]

    output logic [15:0] o [0:1][0:1] // A_inv = [out_a out_b; out_c out_d]
);

    // Internal signals
	logic [15:0] ad, bc, det, det_inv;
   logic [15:0] adj_a, adj_b, adj_c, adj_d;



	
	logic [15:0] pa [0:8];
	logic [15:0] pb [0:8];
	logic [15:0] pc [0:8];
	logic [15:0] pd [0:8];

	fp16_mult m0(.clk(clk), .reset(reset),.a(a[0][0]), .b(a[1][1]),.result(ad)); //ad 	
	fp16_mult m1(.clk(clk), .reset(reset),.a(a[0][1]), .b(a[1][0]),.result(bc)); //bc		//4 total
	
	fp16_sum s0(.clk(clk),.reset(reset),.num1(ad),.num2({~bc[15],bc[14:0]}),.out(det));		//5
	
	fp16_recip r0(clk,det,det_inv); //1 combinational
	
	fp16_mult m2(.clk(clk), .reset(reset),.a(pa[8]), .b(det_inv),.result(o[0][0])); 	      //4 total
	fp16_mult m3(.clk(clk), .reset(reset),.a(pb[8]), .b(det_inv),.result(o[0][1]));
	fp16_mult m4(.clk(clk), .reset(reset),.a(pc[8]), .b(det_inv),.result(o[1][0])); 	
	fp16_mult m5(.clk(clk), .reset(reset),.a(pd[8]), .b(det_inv),.result(o[1][1]));
	
	
	//stage 0 inputs given
	always_comb begin
		adj_a = a[1][1];
		adj_b = {~a[0][1][15],a[0][1][14:0]};
		adj_c = {~a[1][0][15],a[1][0][14:0]};
		adj_d = a[0][0];
	end
	
	//stage 1 waiting for the determinant value and the inverse
	always_ff @(posedge clk or posedge reset) begin
		 if (reset) begin
			  for (int i = 0; i <= 8; i++) begin
					pa[i] <= 16'h0000;
					pb[i] <= 16'h0000;
					pc[i] <= 16'h0000;
					pd[i] <= 16'h0000;
			  end
		 end else begin
			  for (int i = 7; i >= 0; i--) begin
					pa[i+1] <= pa[i];
					pb[i+1] <= pb[i];
					pc[i+1] <= pc[i];
					pd[i+1] <= pd[i];
			  end
			  pa[0] <= adj_a;
			  pb[0] <= adj_b;
			  pc[0] <= adj_c;
			  pd[0] <= adj_d;
		 end
	end

	
	//stage 2 - passing the inv det and matrix into mult m2 to m5
	
	
endmodule
