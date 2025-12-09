`timescale 1ns/1ps

module tb_egress;
  import switch_pkg::*;

  logic switch_clk = 0;
  logic switch_rst_n = 0;

  // VOQ write side
  logic voq_write_req_i;
  logic [ADDR_W-1:0] voq_ptr_i;

  // DUT outputs
  logic gmii_tx_clk_o;
  logic [DATA_WIDTH-1:0] gmii_tx_data_o;
  logic gmii_tx_en_o, gmii_tx_er_o;
  logic mem_re_o, mem_start_o;
  logic [ADDR_W-1:0] mem_start_addr_o;

  // Frame return path to DUT
  logic [BLOCK_BYTES-1:0][DATA_WIDTH-1:0] frame_data_i;
  logic frame_valid_i, frame_end_i;

  // Expected VOQ pointers
  logic [ADDR_W-1:0] expected_ptrs[$];
  int frame_id = 0;

  // Clock
  always #5 switch_clk = ~switch_clk;

  // DUT instantiation
  egress dut (
    .gmii_tx_clk_o(gmii_tx_clk_o),
    .gmii_tx_data_o(gmii_tx_data_o),
    .gmii_tx_en_o(gmii_tx_en_o),
    .gmii_tx_er_o(gmii_tx_er_o),
    .switch_clk(switch_clk),
    .switch_rst_n(switch_rst_n),
    .voq_write_req_i(voq_write_req_i),
    .voq_ptr_i(voq_ptr_i),
    .mem_re_o(mem_re_o),
    .mem_start_o(mem_start_o),
    .mem_start_addr_o(mem_start_addr_o),
    .frame_data_i(frame_data_i),
    .frame_valid_i(frame_valid_i),
    .frame_end_i(frame_end_i)
  );

  // Helpers
  task automatic push_ptr(input [ADDR_W-1:0] ptr);
    begin
      expected_ptrs.push_back(ptr);
      @(posedge switch_clk);
      voq_write_req_i = 1'b1;
      voq_ptr_i       = ptr;
      @(posedge switch_clk);
      voq_write_req_i = 1'b0;
      voq_ptr_i       = '0;
    end
  endtask

  task automatic drive_frame(input int beats);
    int beat;
    for (beat = 0; beat < beats; ) begin
      @(posedge switch_clk);
      if (mem_re_o) begin
        frame_valid_i = 1'b1;
        frame_end_i   = (beat == beats-1);
        for (int b = 0; b < BLOCK_BYTES; b++) begin
          frame_data_i[b] = beat + b + frame_id*16;
        end
        beat++;
      end else begin
        frame_valid_i = 1'b0;
        frame_end_i   = 1'b0;
      end
    end
    @(posedge switch_clk);
    frame_valid_i = 1'b0;
    frame_end_i   = 1'b0;
    frame_data_i  = '0;
    frame_id++;
  endtask

  // Reset and stimulus
  initial begin
    voq_write_req_i = 0;
    voq_ptr_i       = '0;
    frame_valid_i   = 0;
    frame_end_i     = 0;
    frame_data_i    = '0;

    repeat (5) @(posedge switch_clk);
    switch_rst_n = 1;

    push_ptr('h010);
    push_ptr('h020);

    // wait for two frames to complete
    repeat (100) @(posedge switch_clk);
    $display("[%0t] tb_egress finished", $time);
    $finish;
  end

  // Monitor mem_start_o and serve frames
  always @(posedge switch_clk) begin
    if (!switch_rst_n) begin
      expected_ptrs   = {};
      frame_valid_i   = 1'b0;
      frame_end_i     = 1'b0;
      frame_data_i    = '0;
    end else if (mem_start_o) begin
      if (expected_ptrs.size() == 0)
        $fatal(1, "[%0t] Unexpected mem_start", $time);
      else if (mem_start_addr_o !== expected_ptrs[0])
        $fatal(1, "[%0t] mem_start addr mismatch got 0x%0h exp 0x%0h", $time, mem_start_addr_o, expected_ptrs[0]);
      else
        $display("[%0t] mem_start for addr 0x%0h", $time, mem_start_addr_o);

      if (expected_ptrs.size() > 0) expected_ptrs.pop_front();
      fork
        drive_frame(3);
      join_none
    end
  end
endmodule
