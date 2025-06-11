
module mat_tran_2x2(
	input logic [15:0] a[0:1][0:1],
	output logic [15:0] o[0:1][0:1]
	);
	
	always_comb begin
		o[0][0] = a[0][0];
		o[0][1] = o[1][0];
		o[1][0] = o[0][1];
		o[1][1] = a[1][1];
	end
	
endmodule 