`default_nettype none

module fp16_mult (
    input wire clk, reset,
    input wire [15:0] a, b,
    output reg [15:0] result
);

    // Stage 1 registers
    reg sign_a_s1, sign_b_s1;
    reg [4:0] exp_a_s1, exp_b_s1;
    reg [10:0] mant_a_s1, mant_b_s1;

    // Stage 2 registers
    reg [21:0] mant_res_s2;
    reg [4:0] exp_res_s2;
    reg sign_res_s2;

    // Stage 3 registers
    reg [21:0] mant_res_s3;
    reg [4:0] exp_res_s3;
    reg sign_res_s3;

    // Stage 4 output is directly assigned to result

    // Pipeline Stage 1: Decode
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            sign_a_s1 <= 0; sign_b_s1 <= 0;
            exp_a_s1 <= 0; exp_b_s1 <= 0;
            mant_a_s1 <= 0; mant_b_s1 <= 0;
        end else begin
            sign_a_s1 <= a[15];
            sign_b_s1 <= b[15];
            exp_a_s1  <= a[14:10];
            exp_b_s1  <= b[14:10];
            mant_a_s1 <= {1'b1, a[9:0]}; // implicit 1
            mant_b_s1 <= {1'b1, b[9:0]};
        end
    end

    // Pipeline Stage 2: Multiply mantissas, add exponents
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mant_res_s2 <= 0;
            exp_res_s2  <= 0;
            sign_res_s2 <= 0;
        end else begin
            mant_res_s2 <= mant_a_s1 * mant_b_s1;
            exp_res_s2  <= exp_a_s1 + exp_b_s1 - 5'd15;
            sign_res_s2 <= sign_a_s1 ^ sign_b_s1;
        end
    end

    // Pipeline Stage 3: Normalize
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            mant_res_s3 <= 0;
            exp_res_s3  <= 0;
            sign_res_s3 <= 0;
        end else begin
            if (mant_res_s2[21]) begin
                mant_res_s3 <= mant_res_s2 >> 1;
                exp_res_s3  <= exp_res_s2 + 1;
            end else begin
                mant_res_s3 <= mant_res_s2;
                exp_res_s3  <= exp_res_s2;
            end
            sign_res_s3 <= sign_res_s2;
        end
    end

    // Pipeline Stage 4: Assemble result
    always @(posedge clk or posedge reset) begin
        if (reset)
            result <= 0;
        else
            result <= {sign_res_s3, exp_res_s3, mant_res_s3[19:10]};
    end

endmodule
