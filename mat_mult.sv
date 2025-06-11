`default_nettype none

module mat_mult #(parameter size = 4)(
    input clk,
    input logic [15:0] a[0:size*size-1],
    input logic [15:0] b[0:size*size-1],
    output logic [15:0] c[0:size*size-1]
);

    logic [15:0] a_uf [0:size-1][0:size-1];  
    logic [15:0] b_uf [0:size-1][0:size-1]; 
	 logic [15:0] c_uf [0:size-1][0:size-1];
    integer i, j;
    

    always_comb begin
        for (i = 0; i < size; i = i + 1) begin
            for (j = 0; j < size; j = j + 1) begin
                a_uf[i][j] = a[i*size + j];
                b_uf[i][j] = b[i*size + j];
            end
        end
    end
	 
	always @(posedge clk) begin
		for(i = 0;i<size;i= i+1)begin
			for(j = 0;j<size;j= j+1)begin
				
			end
		end
		
	end
	 
    
   
    always_comb begin
        for (i = 0; i < size; i = i + 1) begin
            for (j = 0; j < size; j = j + 1) begin
                c[i*size + j] = c_uf[i][j];
            end
        end
    end

endmodule
