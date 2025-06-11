module fp16_recip (
	 input logic clk,
    input  logic [15:0] in_fp16,    // 16-bit input
    output logic [15:0] out_fp16    // 16-bit reciprocal output
);

    logic sign;
    logic [4:0] exponent;
    logic [9:0] mantissa;
    logic [9:0] recip_mantissa_approx;
    logic [4:0] recip_exponent;
    logic [6:0] lut_addr;

    // Break input
    always_ff@(posedge clk)begin
        sign     = in_fp16[15];
        exponent = in_fp16[14:10];
        mantissa = in_fp16[9:0];

        if (exponent == 5'd0) begin
            // Zero / subnormal input
            recip_exponent = 5'b11111;
            recip_mantissa_approx = 10'b1111_1111_11;
        end else if (exponent == 5'd31) begin
            // Inf or NaN input
            recip_exponent = 5'b0;
            recip_mantissa_approx = 10'b0;
        end else begin
            // Normal number
            lut_addr = mantissa[9:3]; // top 7 bits
				
				recip_exponent = (5'd29) - exponent;
            // Lookup reciprocal mantissa
				case (lut_addr)
				7'd0:   begin 
						recip_mantissa_approx = 10'd0;
						recip_exponent = (5'd30)-exponent;
				end
            7'd1:   recip_mantissa_approx = 10'd1008;
             7'd2: recip_mantissa_approx = 10'd992;
					 7'd3: recip_mantissa_approx = 10'd977;
					 7'd4: recip_mantissa_approx = 10'd962;
					 7'd5: recip_mantissa_approx = 10'd947;
					 7'd6: recip_mantissa_approx = 10'd932;
					 7'd7: recip_mantissa_approx = 10'd918;
					 7'd8: recip_mantissa_approx = 10'd904;
					 7'd9: recip_mantissa_approx = 10'd889;
					 7'd10: recip_mantissa_approx = 10'd876;
					 7'd11: recip_mantissa_approx = 10'd862;
					 7'd12: recip_mantissa_approx = 10'd848;
					 7'd13: recip_mantissa_approx = 10'd835;
					 7'd14: recip_mantissa_approx = 10'd822;
					 7'd15: recip_mantissa_approx = 10'd809;
					 7'd16: recip_mantissa_approx = 10'd796;
					 7'd17: recip_mantissa_approx = 10'd784;
					 7'd18: recip_mantissa_approx = 10'd772;
					 7'd19: recip_mantissa_approx = 10'd759;
					 7'd20: recip_mantissa_approx = 10'd747;
					 7'd21: recip_mantissa_approx = 10'd735;
					 7'd22: recip_mantissa_approx = 10'd724;
					 7'd23: recip_mantissa_approx = 10'd712;
					 7'd24: recip_mantissa_approx = 10'd701;
					 7'd25: recip_mantissa_approx = 10'd689;
					 7'd26: recip_mantissa_approx = 10'd678;
					 7'd27: recip_mantissa_approx = 10'd667;
					 7'd28: recip_mantissa_approx = 10'd656;
					 7'd29: recip_mantissa_approx = 10'd646;
					 7'd30: recip_mantissa_approx = 10'd635;
					 7'd31: recip_mantissa_approx = 10'd625;
					 7'd32: recip_mantissa_approx = 10'd614;
					 7'd33: recip_mantissa_approx = 10'd604;
					 7'd34: recip_mantissa_approx = 10'd594;
					 7'd35: recip_mantissa_approx = 10'd584;
					 7'd36: recip_mantissa_approx = 10'd574;
					 7'd37: recip_mantissa_approx = 10'd565;
					 7'd38: recip_mantissa_approx = 10'd555;
					 7'd39: recip_mantissa_approx = 10'd546;
					 7'd40: recip_mantissa_approx = 10'd536;
					 7'd41: recip_mantissa_approx = 10'd527;
					 7'd42: recip_mantissa_approx = 10'd518;
					 7'd43: recip_mantissa_approx = 10'd509;
					 7'd44: recip_mantissa_approx = 10'd500;
					 7'd45: recip_mantissa_approx = 10'd491;
					 7'd46: recip_mantissa_approx = 10'd483;
					 7'd47: recip_mantissa_approx = 10'd474;
					 7'd48: recip_mantissa_approx = 10'd465;
					 7'd49: recip_mantissa_approx = 10'd457;
					 7'd50: recip_mantissa_approx = 10'd449;
					 7'd51: recip_mantissa_approx = 10'd440;
					 7'd52: recip_mantissa_approx = 10'd432;
					 7'd53: recip_mantissa_approx = 10'd424;
					 7'd54: recip_mantissa_approx = 10'd416;
					 7'd55: recip_mantissa_approx = 10'd408;
					 7'd56: recip_mantissa_approx = 10'd401;
					 7'd57: recip_mantissa_approx = 10'd393;
					 7'd58: recip_mantissa_approx = 10'd385;
					 7'd59: recip_mantissa_approx = 10'd378;
					 7'd60: recip_mantissa_approx = 10'd370;
					 7'd61: recip_mantissa_approx = 10'd363;
					 7'd62: recip_mantissa_approx = 10'd356;
					 7'd63: recip_mantissa_approx = 10'd348;
					 7'd64: recip_mantissa_approx = 10'd341;
					 7'd65: recip_mantissa_approx = 10'd334;
					 7'd66: recip_mantissa_approx = 10'd327;
					 7'd67: recip_mantissa_approx = 10'd320;
					 7'd68: recip_mantissa_approx = 10'd313;
					 7'd69: recip_mantissa_approx = 10'd307;
					 7'd70: recip_mantissa_approx = 10'd300;
					 7'd71: recip_mantissa_approx = 10'd293;
					 7'd72: recip_mantissa_approx = 10'd287;
					 7'd73: recip_mantissa_approx = 10'd280;
					 7'd74: recip_mantissa_approx = 10'd274;
					 7'd75: recip_mantissa_approx = 10'd267;
					 7'd76: recip_mantissa_approx = 10'd261;
					 7'd77: recip_mantissa_approx = 10'd255;
					 7'd78: recip_mantissa_approx = 10'd249;
					 7'd79: recip_mantissa_approx = 10'd242;
					 7'd80: recip_mantissa_approx = 10'd236;
					 7'd81: recip_mantissa_approx = 10'd230;
					 7'd82: recip_mantissa_approx = 10'd224;
					 7'd83: recip_mantissa_approx = 10'd218;
					 7'd84: recip_mantissa_approx = 10'd213;
					 7'd85: recip_mantissa_approx = 10'd207;
					 7'd86: recip_mantissa_approx = 10'd201;
					 7'd87: recip_mantissa_approx = 10'd195;
					 7'd88: recip_mantissa_approx = 10'd190;
					 7'd89: recip_mantissa_approx = 10'd184;
					 7'd90: recip_mantissa_approx = 10'd178;
					 7'd91: recip_mantissa_approx = 10'd173;
					 7'd92: recip_mantissa_approx = 10'd168;
					 7'd93: recip_mantissa_approx = 10'd162;
					 7'd94: recip_mantissa_approx = 10'd157;
					 7'd95: recip_mantissa_approx = 10'd152;
					 7'd96: recip_mantissa_approx = 10'd146;
					 7'd97: recip_mantissa_approx = 10'd141;
					 7'd98: recip_mantissa_approx = 10'd136;
					 7'd99: recip_mantissa_approx = 10'd131;
					 7'd100: recip_mantissa_approx = 10'd126;
					 7'd101: recip_mantissa_approx = 10'd121;
					 7'd102: recip_mantissa_approx = 10'd116;
					 7'd103: recip_mantissa_approx = 10'd111;
					 7'd104: recip_mantissa_approx = 10'd106;
					 7'd105: recip_mantissa_approx = 10'd101;
					 7'd106: recip_mantissa_approx = 10'd96;
					 7'd107: recip_mantissa_approx = 10'd92;
					 7'd108: recip_mantissa_approx = 10'd87;
					 7'd109: recip_mantissa_approx = 10'd82;
					 7'd110: recip_mantissa_approx = 10'd77;
					 7'd111: recip_mantissa_approx = 10'd73;
					 7'd112: recip_mantissa_approx = 10'd68;
					 7'd113: recip_mantissa_approx = 10'd64;
					 7'd114: recip_mantissa_approx = 10'd59;
					 7'd115: recip_mantissa_approx = 10'd55;
					 7'd116: recip_mantissa_approx = 10'd50;
					 7'd117: recip_mantissa_approx = 10'd46;
					 7'd118: recip_mantissa_approx = 10'd42;
					 7'd119: recip_mantissa_approx = 10'd37;
					 7'd120: recip_mantissa_approx = 10'd33;
					 7'd121: recip_mantissa_approx = 10'd29;
					 7'd122: recip_mantissa_approx = 10'd25;
					 7'd123: recip_mantissa_approx = 10'd20;
					 7'd124: recip_mantissa_approx = 10'd16;
					 7'd125: recip_mantissa_approx = 10'd12;
					 7'd126: recip_mantissa_approx = 10'd8;
					 7'd127: recip_mantissa_approx = 10'd4;
					

				default: recip_mantissa_approx = 10'd0;
				endcase


            // Fix exponent:
            // recip_exp = (2 * Bias - 1) - orig_exp
            
        end
    end

    // Assemble output
    assign out_fp16 = {sign, recip_exponent, recip_mantissa_approx};

endmodule
