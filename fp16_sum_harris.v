/*
module fpAddHalf ( input sdi_a , sdi_b ,
input scka , sckb ,
output [15:0] y );
reg a_buf , b_buf ; // Buffers in between the two shift latches
reg [15:0] a , b ; // Shifted in inputs
wire [5:0] expDiff ; // Difference between exponents for inputs a and b
wire [10:0] manDiff ; // Difference between mantissas for inputs a and b
wire expDiffIsZero ;// Is expDiff equal to 0?
wire manDiffIsZero ;// Is manDiff equal to 0?
wire bigSel ; // If 1 , b is bigger . If 0 , a is bigger / equal to b
wire [4:0] rawShiftRt ; // How much to shift smaller mantissa right by
wire [3:0] shiftRtAmt ; // Same as rawShiftRt , but less than or equal to 11
wire operation ; // 1 means subtraction , 0 means addition
wire [4:0] rawExp ; // Unnormalized exponent
wire signOut ; // Sign of calculated output
wire [10:0] bigMan ; // Larger input mantissa
wire [10:0] lilMan ; // Smaller input mantissa
wire [10:0] shiftedMan ; // Shifted version of smaller input mantissa
wire guard ; // Guard bit
reg [10:0] mask ; // Mask to acquire sticky bit
wire sticky ; // Sticky bit
wire [12:0] alignedMan ; // Smaller mantissa prepared for addition
wire [13:0] rawMan ; // Mantissa output from big ALU
wire [13:0] signedMan ; // Mantissa output with correct leading bit
wire [3:0] rawNormAmt ; // Output from leading zero detector
wire valid ; // Bit indicating whether signedMan is all 0 ’ s
wire [3:0] normAmt ; // How much to adjust mantissa / exponent by
wire [5:0] biasExp ; // Biased exponent ready for normalization
wire [14:0] biasMan ; // Biased mantissa ready for normalization
wire [5:0] normExp ; // Normalized exponent
wire [4:0] expOut ; // Final exponent
wire [14:0] normMan ; // Normalized mantissa
wire [9:0] manOut ; // Final mantissa
wire [14:0] numOut ; // Calculated output
wire expAIsOne ;
wire expBIsOne ;
wire expAIsZero ;
wire expBIsZero ;
wire manAIsZero ;
wire manBIsZero ;
wire AIsNaN ;
wire BIsNaN ;
wire AIsInf ;
wire BIsInf ;
wire inIsNaN ;
wire inIsInf ;
wire inIsDenorm ;
wire expOutIsOne ;
wire expOutIsZero ;
wire manOutIsZero ;
wire outIsNaN ;
wire outIsInf ;
wire outIsDenorm ;
wire overflow ;
wire NaN ;
wire underflow ;
// ////////////////////////////////////////////////////////////////////////////
// Shift in Inputs
// ////////////////////////////////////////////////////////////////////////////
always @ ( sckb , sdi_a , sdi_b ) begin
if ( sckb ) begin
a_buf <= sdi_a ;
b_buf <= sdi_b ;
end
end
always @ ( scka , a_buf , b_buf ) begin
if ( scka ) begin
a <= { a [14:0] , a_buf };
b <= { b [14:0] , b_buf };
end
end
// ////////////////////////////////////////////////////////////////////////////
// Compare Exponents
// ////////////////////////////////////////////////////////////////////////////
assign expDiff = {1 ’ b0 , a [14:10]} + {1 ’ b1 , ~ b [14:10]} + 1;
assign manDiff = {1 ’ b0 , a [9:0]} + {1 ’ b1 , ~ b [9:0] } + 1;
// Before deciding which input is larger , we need to check if they have the
// same exponents . If so , then we need to compare the mantissas as well .
assign expDiffIsZero = ~| expDiff ;
assign manDiffIsZero = ~| manDiff ;
// If the exponents are the same , then we must check the sign of the
// mantissa comparison . If the exponents aren ’ t the same , then we can just
// go off of the expDiff .
assign bigSel = expDiffIsZero ? manDiff [10] : expDiff [5];
// We want the shift amount to be the absolute value of expDiff .
assign rawShiftRt = expDiff [5] ? ~ expDiff [4:0] + 1 : expDiff [4:0];
assign shiftRtAmt = ( rawShiftRt > 11) ? 4 ’ b1011 : rawShiftRt [3:0];
// If both signs of the inputs are the same , then the ALU does addition . If
// they ’ re different , then the ALU does subtraction . The smaller number
// always is two ’ s complemented .
assign operation = a [15] ^ b [15];
// Use the bigSel and operation control signals to choose which input is
// larger and whether or not the smaller one should be two ’ s complemented
assign rawExp = bigSel ? b [14:10] : a [14:10];
assign signOut = bigSel ? b [15] : a [15];
assign bigMan = {1 ’ b1 , bigSel ? b [9:0] : a [9:0]};
assign lilMan = {1 ’ b1 , bigSel ? a [9:0] : b [9:0]};
// Align mantissas , create guard / sticky bits , and selectively complement
assign shiftedMan = lilMan >> shiftRtAmt ;
assign guard = (( shiftRtAmt == 0) || ( rawShiftRt > 11)) ?
1 ’ b0 :
lilMan [ shiftRtAmt -1];
// mask will tell us which bits have been shifted out . We can then bitwise
// AND it with lilMan to get the exact bits that were shifted out , and then
// OR that outcome to get the sticky bit
always @ (*) begin
casez ({ shiftRtAmt , ( rawShiftRt > 11)})
5 ’ b00000 : mask = 11 ’ b000_0000_0000 ;
5 ’ b00010 : mask = 11 ’ b000_0000_0000 ;
5 ’ b00100 : mask = 11 ’ b000_0000_0001 ;
5 ’ b00110 : mask = 11 ’ b000_0000_0011 ;
5 ’ b01000 : mask = 11 ’ b000_0000_0111 ;
5 ’ b01010 : mask = 11 ’ b000_0000_1111 ;
5 ’ b01100 : mask = 11 ’ b000_0001_1111 ;
5 ’ b01110 : mask = 11 ’ b000_0011_1111 ;
5 ’ b10000 : mask = 11 ’ b000_0111_1111 ;
5 ’ b10010 : mask = 11 ’ b000_1111_1111 ;
5 ’ b10100 : mask = 11 ’ b001_1111_1111 ;
5 ’ b10110 : mask = 11 ’ b011_1111_1111 ;
5 ’ b ????1: mask = 11 ’ b111_1111_1111 ;
default : mask = 11 ’ b000_0000_0000 ;
endcase
end
assign sticky = |( lilMan [10:0] & mask [10:0]);
assign alignedMan = operation ? ~{ shiftedMan , guard , sticky } :
{ shiftedMan , guard , sticky };

// ////////////////////////////////////////////////////////////////////////////
// Add Mantissas
// ////////////////////////////////////////////////////////////////////////////
assign rawMan = alignedMan + { bigMan , 2 ’ b0 } + operation ;
// In subtraction , we don ’ t want the carry - out , so we replace it with a zero .
assign signedMan = { rawMan [13] & ~ operation , rawMan [12:0]};
// ////////////////////////////////////////////////////////////////////////////
// Normalize / Package
// ////////////////////////////////////////////////////////////////////////////
// In normalization , we will either right - shift by 1 , do nothing , or
// left - shift by some variable amount . By biasing the normalization , we
// either do nothing or we only left - shift .

lzd14 lzd ( signedMan , rawNormAmt , valid );
assign normAmt = valid ? rawNormAmt : 4 ’ b0 ;
assign biasExp = rawExp + 1;
assign biasMan = {1 ’ b0 , signedMan };
assign normExp = biasExp + ~{2 ’ b0 , normAmt } + 1;
assign expOut = normExp [4:0];
assign normMan = biasMan << normAmt ;
assign manOut = normMan [12:3];
// Discard the guard / sticky bits ( since we ’ re rounding down ) , discard
// the two upper bits ( which are the overflow bit and the hidden 1) , and
// discard the bit just above the guard / sticky bits , which was added in when
// we biased the mantissa .
// Calculated output
assign numOut = { expOut , manOut };
// Input exception signals
assign expAIsOne = & a [14:10];
assign expBIsOne = & b [14:10];
assign expAIsZero = ~| a [14:10];
assign expBIsZero = ~| b [14:10];
assign manAIsZero = ~| a [9:0];
assign manBIsZero = ~| b [9:0];
assign AIsNaN = expAIsOne & ~ manAIsZero ;
assign BIsNaN = expBIsOne & ~ manBIsZero ;
assign AIsInf = expAIsOne & manAIsZero ;
assign BIsInf = expBIsOne & manBIsZero ;
assign inIsNaN = AIsNaN | BIsNaN | ( AIsInf & BIsInf & operation );
assign inIsInf = AIsInf | BIsInf ;
assign inIsDenorm = expAIsZero | expBIsZero ;
assign zero = expDiffIsZero & manDiffIsZero & operation ;
// Output exception signals
assign expOutIsOne = & expOut ;
assign expOutIsZero = ~| expOut ;
assign manOutIsZero = ~| manOut ;
assign outIsInf = expOutIsOne & ~ normExp [5];
assign outIsDenorm = expOutIsZero | normExp [5];
// Final exception signals
assign overflow = ( inIsInf | outIsInf ) & ~ zero ;
assign NaN = inIsNaN ;
assign underflow = inIsDenorm | outIsDenorm | zero ;
// Choose output from exception signals
assign y = NaN ? 16 ’ b0111_1111_1111_1111 :
overflow ? { signOut , 15 ’ b111_1100_0000_0000 } :
underflow ? 16 ’ b0000_0000_0000_0000 :
{ signOut , numOut };
endmodule
*/