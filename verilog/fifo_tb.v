`timescale 1ns / 1ps

module fifo_tb;

  // clocks
  reg write_clk = 0;
  reg read_clk  = 0;
  always #5 write_clk = ~write_clk;   // 100 MHz
  always #7 read_clk  = ~read_clk;    // ~71 MHz

  // DUT I/O
  reg         reset;
  reg         write_en, read_en;
  reg  [7:0]  data_in;
  wire        mem_full, mem_empty;
  wire [7:0]  out;

  fifo dut (
    .write_clk(write_clk),
    .read_clk(read_clk),
    .reset(reset),
    .write_en(write_en),
    .read_en(read_en),
    .data_in(data_in),
    .mem_full(mem_full),
    .mem_empty(mem_empty),
    .out(out)
  );

  integer i;

  // stimulus
  initial begin
    // initialize
    reset    = 0;
    write_en = 0;
    read_en  = 0;
    data_in  = 8'h00;

    // apply reset
    $display("[%0t] Applying reset", $time);
    #20 reset = 1;
    $display("[%0t] Releasing reset", $time);

    // --------------------
    // Write 8 values
    // --------------------
    for (i = 1; i <= 8; i = i + 1) begin
      @(posedge write_clk);
      if (!mem_full) begin
        data_in  <= i*8'h11; // 0x11, 0x22, ...
        write_en <= 1;
        $display("[%0t] Writing data = 0x%0h", $time, data_in);
      end
      @(posedge write_clk);
      write_en <= 0;
    end

    // small delay
    #50;

    // --------------------
    // Read 8 values
    // --------------------
    for (i = 0; i < 8; i = i + 1) begin
      @(posedge read_clk);
      if (!mem_empty) begin
        read_en <= 1;
      end
      @(posedge read_clk);
      if (read_en) begin
        $display("[%0t] Read data = 0x%0h", $time, out);
        read_en <= 0;
      end
    end

    // finish
    #100;
    $display("[%0t] Simulation finished", $time);
    $finish;
  end

endmodule
