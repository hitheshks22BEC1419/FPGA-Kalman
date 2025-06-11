`default_nettype none
module fp16_sum_gpt(
    input wire clk,
    input wire [15:0] num1, num2,
    output reg [15:0] out,
    output wire f_z
);

    reg [15:0] big, sma;
    reg big_sign, sma_sign, res_sign;
    reg [4:0] big_exp, sma_exp, res_exp;
    reg [9:0] big_mant, sma_mant, res_mant;
    //reg [10:0] big_norm, sma_norm;

    // Intermediate flags
    wire add_sub;
    reg ov;

    // Intermediate result
    assign add_sub = (num1[15] == num2[15]); // 1 for addition, 0 for subtraction
    reg [10:0] sma_norm_mant, big_norm_mant;
	 reg pre_sign;
    reg [4:0] pre_exp;
    reg [10:0] pre_mant;  // Addition overflow bit

    // Zero flag correction
    assign f_z = ((num1[14:0] == num2[14:0]) && (num1[15] != num2[15])) || ((num1 == 16'b0) && (num2 == 16'b0));

    // Decode floating-point values
    always @(posedge clk) begin
        {big_sign, big_exp, big_mant} <= big;
        {sma_sign, sma_exp, sma_mant} <= sma;
    end

    // Determine larger number (by exponent & mantissa)
    always @(posedge clk) begin
        if (num2[14:10] > num1[14:10]) begin
            big <= num2;
            sma <= num1;
        end
        else if (num2[14:10] == num1[14:10]) begin
            if (num2[9:0] > num1[9:0]) begin
                big <= num2;
                sma <= num1;
            end
            else begin
                big <= num1;
                sma <= num2;
            end
        end
        else begin
            big <= num1;
            sma <= num2;
        end
    end

    // Normalize smaller mantissa
    always @(posedge clk) begin
        sma_norm_mant <= sma_mant >> (big_exp - sma_exp);
    end

    // Compute sum or difference
    always @(posedge clk) begin
        if (add_sub) begin // If adding
            pre_mant <= big_mant + sma_norm_mant;
            pre_exp  <= big_exp + 1;
            pre_sign <= big_sign;
        end
        else begin // If subtracting
            pre_mant <= big_mant - sma_norm_mant;
            pre_sign <= big_sign;

            casez (pre_mant[9:0])
                10'b1?_????_????: res_mant <= pre_mant;
                10'b01_????_????: begin res_mant <= pre_mant << 1; pre_exp <= big_exp - 1; end
                10'b00_1???_????: begin res_mant <= pre_mant << 2; pre_exp <= big_exp - 2; end
                10'b00_01??_????: begin res_mant <= pre_mant << 3; pre_exp <= big_exp - 3; end
                10'b00_001?_????: begin res_mant <= pre_mant << 4; pre_exp <= big_exp - 4; end
                10'b00_0001_????: begin res_mant <= pre_mant << 5; pre_exp <= big_exp - 5; end
                10'b00_0000_1???: begin res_mant <= pre_mant << 6; pre_exp <= big_exp - 6; end
                10'b00_0000_01??: begin res_mant <= pre_mant << 7; pre_exp <= big_exp - 7; end
                10'b00_0000_001?: begin res_mant <= pre_mant << 8; pre_exp <= big_exp - 8; end
                10'b00_0000_0001: begin res_mant <= pre_mant << 9; pre_exp <= big_exp - 9; end
                default: begin res_mant <= pre_mant; pre_exp <= big_exp; end
            endcase
        end
    end

    // Output result
    always @(posedge clk) begin
        out <= {res_sign, pre_exp, res_mant};
    end

endmodule
