/*
`default_nettype none

module fp16_matmul_4x4_optimized (
  input  wire         clk, reset, start,
  input  wire [15:0]  a [0:3][0:3],  // Row-major
  input  wire [15:0]  b [0:3][0:3],  // Column-major
  output reg  [15:0]  out [0:3][0:3],
  output reg          done
);

  //--------------------------------------------------
  // 1. Multiplier Array (16 multipliers, 4-cycle latency)
  //--------------------------------------------------
  reg [15:0] a_reg [0:3][0:3];  // Registered inputs
  reg [15:0] b_reg [0:3][0:3];
  wire [15:0] mult_out [0:3][0:3][0:3];  // [i][j][k] = A[i][k] * B[k][j]

  generate
    for (genvar i = 0; i < 4; i++) begin : row
      for (genvar j = 0; j < 4; j++) begin : col
        for (genvar k = 0; k < 4; k++) begin : mult
          fp16_mult mult_inst (
            .clk(clk),
            .reset(reset),
            .a(a_reg[i][k]),
            .b(b_reg[k][j]),
            .result(mult_out[i][j][k])
          );
        end
      end
    end
  endgenerate

  //--------------------------------------------------
  // 2. Adder Trees (16 adders, 5-cycle latency)
  //--------------------------------------------------
  wire [15:0] sum_out [0:3][0:3];  // Final sums

  generate
    for (genvar i = 0; i < 4; i++) begin : adder_row
      for (genvar j = 0; j < 4; j++) begin : adder_col
        // 3-level adder tree (4 mults → 2 adds → 1 add)
        wire [15:0] sum_stage1 [0:1];

        fp16_sum add0 (
          .clk(clk),
          .reset(reset),
          .num1(mult_out[i][j][0]),
          .num2(mult_out[i][j][1]),
          .out(sum_stage1[0])
        );

        fp16_sum add1 (
          .clk(clk),
          .reset(reset),
          .num1(mult_out[i][j][2]),
          .num2(mult_out[i][j][3]),
          .out(sum_stage1[1])
        );

        fp16_sum add_final (
          .clk(clk),
          .reset(reset),
          .num1(sum_stage1[0]),
          .num2(sum_stage1[1]),
          .out(sum_out[i][j])
        );
      end
    end
  endgenerate

  //--------------------------------------------------
  // 3. Pipeline Control (Throughput: 1/5 cycles)
  //--------------------------------------------------
  reg [3:0] i,j;
  reg [3:0] cycle_count;
  typedef enum {IDLE, RUNNING} state_t;
  state_t state;

  always @(posedge clk or posedge reset) begin
    if (reset) begin
      state <= IDLE;
      cycle_count <= 0;
      done <= 0;
      out <= '{default:'0};
      a_reg <= '{default:'0};
      b_reg <= '{default:'0};
    end else begin
      case (state)
        IDLE: 
          if (start) begin
            a_reg <= a;
            b_reg <= b;
            state <= RUNNING;
            cycle_count <= 1;
          end

        RUNNING: begin
          if (cycle_count == 9) begin  // 4 mult + 5 add cycles
            for ( i = 0; i < 4; i = i+1)
              for (j = 0; j < 4; j = j+1)
                out[i][j] <= sum_out[i][j];
            done <= 1;
            state <= IDLE;
          end
          cycle_count <= cycle_count + 1;
        end
      endcase
    end
  end
endmodule
*/