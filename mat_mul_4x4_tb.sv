
/*
`timescale 1ns/1ps
`default_nettype none

module mat_mul_4x4_tb();

  // Parameters
  localparam CLK_PERIOD = 10; // 100 MHz clock

  // Signals
  reg clk, reset, start;
  reg [15:0] a [0:3][0:3];
  reg [15:0] b [0:3][0:3];
  wire [15:0] out [0:3][0:3];
  wire done;

  // Instantiate DUT
  fp16_matmul_4x4 dut (
    .clk(clk),
    .reset(reset),
    .start(start),
    .a(a),
    .b(b),
    .out(out),
    .done(done)
  );

  // Clock generation
  initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
  end

  // Main test sequence
  initial begin
    // Initialize
    reset = 1;
    start = 0;
    initialize_matrices();

    // Reset release
    #(CLK_PERIOD*2);
    reset = 0;

    // Test case 1: Identity * 2.0
    $display("\nTest Case 1: Identity * 2.0");
    load_matrices(
      '{'{16'h3C00, 16'h0000, 16'h0000, 16'h0000},  // 1 0 0 0
        '{16'h0000, 16'h3C00, 16'h0000, 16'h0000},  // 0 1 0 0
        '{16'h0000, 16'h0000, 16'h3C00, 16'h0000},  // 0 0 1 0
        '{16'h0000, 16'h0000, 16'h0000, 16'h3C00}}, // 0 0 0 1
      '{'{16'h4000, 16'h4000, 16'h4000, 16'h4000},  // 2 2 2 2
        '{16'h4000, 16'h4000, 16'h4000, 16'h4000},
        '{16'h4000, 16'h4000, 16'h4000, 16'h4000},
        '{16'h4000, 16'h4000, 16'h4000, 16'h4000}}
    );
    run_test();
    verify_result(
      '{'{16'h4000, 16'h4000, 16'h4000, 16'h4000},
        '{16'h4000, 16'h4000, 16'h4000, 16'h4000},
        '{16'h4000, 16'h4000, 16'h4000, 16'h4000},
        '{16'h4000, 16'h4000, 16'h4000, 16'h4000}}
    );

    // Test case 2: Random matrices
    $display("\nTest Case 2: Random matrices");
    load_matrices(
      '{'{16'h3C00, 16'h4200, 16'h4500, 16'h4800},  // 1, 2.5, 5, 8
        '{16'h4900, 16'h4B00, 16'h4D00, 16'h4F00},  // 10, 12, 14, 16
        '{16'h5000, 16'h5100, 16'h5200, 16'h5300},  // 32, 64, 128, 256
        '{16'h5400, 16'h5500, 16'h5600, 16'h5700}}, // 512, 1024, 2048, 4096
      '{'{16'h3C00, 16'h0000, 16'h0000, 16'h0000},
        '{16'h0000, 16'h3C00, 16'h0000, 16'h0000},
        '{16'h0000, 16'h0000, 16'h3C00, 16'h0000},
        '{16'h0000, 16'h0000, 16'h0000, 16'h3C00}}
    );
    run_test();
    // Expected result same as matrix A (multiplied by identity)

    // Test case 3: Zero matrix
    $display("\nTest Case 3: Zero matrix");
    load_matrices(
      '{'{16'h0000, 16'h0000, 16'h0000, 16'h0000},
        '{16'h0000, 16'h0000, 16'h0000, 16'h0000},
        '{16'h0000, 16'h0000, 16'h0000, 16'h0000},
        '{16'h0000, 16'h0000, 16'h0000, 16'h0000}},
      '{'{16'h4000, 16'h4000, 16'h4000, 16'h4000},
        '{16'h4000, 16'h4000, 16'h4000, 16'h4000},
        '{16'h4000, 16'h4000, 16'h4000, 16'h4000},
        '{16'h4000, 16'h4000, 16'h4000, 16'h4000}}
    );
    run_test();
    verify_result(
      '{'{16'h0000, 16'h0000, 16'h0000, 16'h0000},
        '{16'h0000, 16'h0000, 16'h0000, 16'h0000},
        '{16'h0000, 16'h0000, 16'h0000, 16'h0000},
        '{16'h0000, 16'h0000, 16'h0000, 16'h0000}}
    );

    // Finish simulation
    #100;
    $display("\nAll tests completed!");
    $finish;
  end

  // Helper tasks
  task initialize_matrices();
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 4; j++) begin
        a[i][j] = 0;
        b[i][j] = 0;
      end
    end
  endtask

  task load_matrices(
    input [15:0] a_matrix [0:3][0:3],
    input [15:0] b_matrix [0:3][0:3]
  );
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 4; j++) begin
        a[i][j] = a_matrix[i][j];
        b[i][j] = b_matrix[i][j];
      end
    end
  endtask

  task run_test();
    start = 1;
    #(CLK_PERIOD);
    start = 0;
    wait(done);
    #(CLK_PERIOD);
  endtask

  task verify_result(
    input [15:0] expected [0:3][0:3]
  );
    int errors = 0;
    $display("Result Matrix:");
    for (int i = 0; i < 4; i++) begin
      for (int j = 0; j < 4; j++) begin
        $write("%4h ", out[i][j]);
        if (out[i][j] !== expected[i][j]) begin
          $write("(Expected: %4h)", expected[i][j]);
          errors++;
        end
      end
      $display("");
    end
    
    if (errors == 0) begin
      $display("SUCCESS: All values match!");
    end else begin
      $display("FAILED: %0d mismatches found", errors);
    end
  endtask

  // Monitor
  initial begin
    $timeformat(-9, 2, " ns", 10);
    $monitor("At %t: %s", $time, 
      done ? "Calculation done" : 
      start ? "Calculation started" : "");
  end

endmodule
*/