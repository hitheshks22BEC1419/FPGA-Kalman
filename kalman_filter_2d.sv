
module kalman_filter_2d (
    input logic clk,
    input logic reset,

    // Measurement input (y)
    input logic  [15:0] y[0:1][0:1],

    // Output estimated state (x)
    output logic  [15:0] x[0:1][0:1],
    output logic  [15:0] p[0:1][0:1]
);

	logic [15:0] y_in [0:78][0:1][0:1];
	
	always_ff@(posedge clk)begin
		for(int i = 0;i<78;i++)begin
			y_in[i+1] <= y_in[i];
		end
		y_in[0] <= y;
	end

															 
	
	//
	//PREDICTION STEP
	//
	
	//	X(0) = A*X(-1)+B           Latency (9+5 = 14)		Predict Next State
	
	logic [15:0] A[0:1][0:1];
	logic [15:0] B[0:1][0:1];
	logic [15:0] A_tran[0:1][0:1];
	logic [15:0] prediction_x[0:1][0:1];
	logic [15:0] prediction_u[0:1][0:1];
	logic [15:0] prediction_predict_x[0:1][0:1];
	logic [15:0] prediction_predict_x_stage1[0:1][0:1];
	logic [15:0] prediction_predict_x_stage2[0:1][0:1];
	logic [15:0] prediction_predict_x_stage3[0:8][0:1][0:1];
	logic [15:0] prediction_predict_x_stage4[0:1][0:1];
	
	mat_mult_2x2_simple prediction_m0(.clk(clk), .reset(reset),.a(A), .b(prediction_x),.out(prediction_predict_x_stage1)); 
	mat_mult_2x2_simple prediction_m1(.clk(clk), .reset(reset),.a(B), .b(prediction_u),.out(prediction_predict_x_stage2));
	mat_sum_2x2 prediction_s0(clk,reset, prediction_predict_x_stage1,prediction_predict_x_stage2,prediction_predict_x_stage4);
	
	always@(posedge clk)begin
		prediction_predict_x_stage3[0] <= prediction_predict_x_stage4;
		for(int i = 0;i<8;i++)begin
			prediction_predict_x_stage3[i+1] <= prediction_predict_x_stage3[i];
		end
		prediction_predict_x <= prediction_predict_x_stage3[8];
		
	end

	// P(0) = A*P(-1)*A' + Q		Latency (9+9+5 = 23)		Predict Error Covariance
	
	logic [15:0] Q [0:1][0:1];
	logic [15:0] prediction_p[0:1][0:1];
	logic [15:0] prediction_predict_p[0:1][0:1];
	logic [15:0] prediction_predict_p_stage1[0:1][0:1];
	logic [15:0] prediction_predict_p_stage2[0:1][0:1];
	logic [15:0] prediction_predict_p_stage3[0:1][0:1];
	
	
	mat_mult_2x2_simple prediction_m2(.clk(clk), .reset(reset),.a(A), .b(prediction_p),.out(prediction_predict_p_stage1)); 
	mat_tran_2x2 prediction_t0(A,A_tran);
	mat_mult_2x2_simple prediction_m3(.clk(clk), .reset(reset),.a(prediction_predict_p_stage1), .b(A_tran),.out(prediction_predict_p_stage2)); 
	mat_sum_2x2 prediction_s1(clk,reset, prediction_predict_p_stage2,Q,prediction_predict_p);

	//
	// Kalman Gain
	//
	
	// K = P(0)*H'*( H*P(0)*H' + R)^-1	Latency (46)		Kalman Gain
	
	logic[15:0] K [0:1][0:1];
	logic[15:0] H [0:1][0:1];
	logic [15:0] R [0:1][0:1];
	logic [15:0] H_tran [0:1][0:1];
	logic [15:0] kalman_stage1 [0:1][0:1];
	logic [15:0] kalman_stage2 [0:1][0:1];
	logic [15:0] kalman_stage3 [0:1][0:1];
	logic [15:0] kalman_stage4 [0:1][0:1];
	logic [15:0] kalman_stage5 [0:1][0:1];
	

	mat_mult_2x2_simple kalman_m0(.clk(clk), .reset(reset),.a(H), .b(prediction_predict_p),.out(kalman_stage1));
	mat_tran_2x2 kalman_t0(H,H_tran);	
	mat_mult_2x2_simple kalman_m1(.clk(clk), .reset(reset),.a(kalman_stage1), .b(H_tran),.out(kalman_stage2));
	mat_mult_2x2_simple kalman_m2(.clk(clk), .reset(reset),.a(prediction_predict_p), .b(H_tran),.out(kalman_stage3));
	
	mat_sum_2x2 kalman_s0(clk,reset, kalman_stage2,R,kalman_stage4);
	
	mat_inv_2x2 kalman_inv0(.clk(clk),.reset(reset),.a(kalman_stage3),.o(kalman_stage5));
	mat_mult_2x2_simple kalman_m3(.clk(clk), .reset(reset),.a(kalman_stage4), .b(kalman_stage5),.out(K));
	
	//
	// Update Step
	//
	
	
	logic [15:0] predict_x_in [0:23][0:1][0:1];
	logic [15:0] predict_p_in [0:27][0:1][0:1];
	logic [15:0] k_in [0:18][0:1][0:1];
	
	always_ff @(posedge clk)begin
		
		for(int i = 0;i<23;i++)begin
			predict_x_in [i+1] <= predict_x_in[i];
		end
		predict_x_in[0] <= prediction_predict_x;
		
		for(int i = 0;i <27;i++)begin
			predict_p_in[i+1] <= predict_p_in[i];
		end
		predict_p_in[0] <= prediction_predict_p;
		
		for(int i = 0;i <18;i++)begin
			k_in[i+1] <= k_in[i];
		end
		k_in[0] <= K;
		
	end
	
	// x = x(0) + K*(y - H*x(0))		Latency = 28	Update State Estimate
	logic [15:0] update_x [0:1][0:1];
	logic [15:0] update_x_stage1 [0:1][0:1];
	logic [15:0] update_x_stage2 [0:1][0:1];
	logic [15:0] update_x_stage3 [0:1][0:1];
	
	mat_mult_2x2_simple update_m0(.clk(clk), .reset(reset),.a(H), .b(prediction_predict_x),.out(update_x_stage1));
	mat_sub_2x2 update_sb0(clk,reset, y_in[78],update_x_stage1,update_x_stage2);
	mat_mult_2x2_simple update_m1(.clk(clk), .reset(reset),.a(k_in[14]), .b(update_x_stage2),.out(update_x_stage3));
	mat_sum_2x2 update_s0(clk,reset, predict_x_in[23],update_x_stage3,update_x);
	
	logic [15:0] update_x_stage4 [0:4][0:1][0:1];
	
	always@(posedge clk)begin
		for(int i = 0;i <4;i++)begin
			update_x_stage4[i+1] <= update_x_stage4[i];
		end
		update_x_stage4[0] <= update_x;
		x <= update_x_stage4[4];
	end
	
	// p = p(0) - K*H*p(0)				Latency = 23	Update Error Covariance
	
	logic [15:0] update_p_stage1 [0:1][0:1];
	logic [15:0] update_p_stage2 [0:1][0:1];
	
	
	mat_mult_2x2_simple update_m2(.clk(clk), .reset(reset),.a(H),.b(predict_p_in[27]),.out(update_p_stage1));
	mat_mult_2x2_simple update_m3(.clk(clk), .reset(reset),.a(k_in[18]),.b(update_p_stage1),.out(update_p_stage2));
	mat_sub_2x2 update_sb1(clk,reset, predict_p_in[18],update_p_stage2,p);
	

 
	
	
	always_comb begin
        // Identity matrix A
        A[0][0] = 16'h3c00;
        A[0][1] = 16'h0000;
        A[1][0] = 16'h0000;
        A[1][1] = 16'h3c00;

        // Control matrix B (same as A in this case)
        B[0][0] = 16'h3c00;
        B[0][1] = 16'h0000;
        B[1][0] = 16'h0000;
        B[1][1] = 16'h3c00;

        // Measurement matrix H (same as A in this case)
        H[0][0] = 16'h3c00;
        H[0][1] = 16'h0000;
        H[1][0] = 16'h0000;
        H[1][1] = 16'h3c00;

        // Process noise covariance Q (small noise)
        Q[0][0] = 16'd1;
        Q[0][1] = 16'd0;
        Q[1][0] = 16'd0;
        Q[1][1] = 16'd1;

        // Measurement noise covariance R (larger noise, GPS error)
        R[0][0] = 16'd10;
        R[0][1] = 16'd0;
        R[1][0] = 16'd0;
        R[1][1] = 16'd10;
    end

  
endmodule
