`timescale 1ns/1ps

module tb_voq;

  // Import depth/width if defined in your packages

    import switch_pkg::*; 
    import mem_pkg::*;    // provides ADDR_W

    logic clk, rst_n;
    logic write_req_i, read_req_i;
    logic [ADDR_W-1:0] ptr_i;
    logic [ADDR_W-1:0] ptr_o;
    logic ptr_valid_o;

    localparam int DEPTH = voq_pkg::VOQ_DEPTH;

    voq #(.ADDR_W(ADDR_W)) dut (
        .clk(clk), .rst_n(rst_n),
        .write_req_i(write_req_i),
        .ptr_i(ptr_i),
        .read_req_i(read_req_i),
        .ptr_o(ptr_o),
        .ptr_valid_o(ptr_valid_o)
    );

  // Clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz
    end

  task automatic apply_reset();
    begin
        rst_n = 0;
        write_req_i = 0;
        read_req_i  = 0;
        ptr_i = '0;
        repeat (3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
    end
  endtask

  task automatic push(input [ADDR_W-1:0] val);
    begin
        @(posedge clk);
        write_req_i = 1;
        ptr_i       = val;
        @(posedge clk);
        write_req_i = 0;
        ptr_i       = '0;
    end
  endtask

  task automatic pop_expect(input [ADDR_W-1:0] exp, input bit must_be_valid = 1);
    begin
        @(posedge clk);
        read_req_i = 1;
        @(posedge clk);
        read_req_i = 0;
        if (must_be_valid && !ptr_valid_o)
        $fatal(1, "Expected valid pop, got invalid");
        if (must_be_valid && ptr_o !== exp)
        $fatal(1, "Pop mismatch: got 0x%0h exp 0x%0h", ptr_o, exp);
    end
  endtask

  task automatic push_pop_same_cycle(input [ADDR_W-1:0] in_val,
                                     input [ADDR_W-1:0] exp_out,
                                     input bit must_be_valid = 1);
    begin
        @(posedge clk);
        write_req_i = 1;
        ptr_i       = in_val;
        read_req_i  = 1;
        @(posedge clk);
        write_req_i = 0;
        read_req_i  = 0;
        ptr_i       = '0;
        if (must_be_valid && !ptr_valid_o)
        $fatal(1, "Expected valid pop (simul), got invalid");
        if (must_be_valid && ptr_o !== exp_out)
        $fatal(1, "Pop mismatch (simul): got 0x%0h exp 0x%0h", ptr_o, exp_out);
    end
  endtask

  initial begin
    $dumpfile("tb_voq.vcd");
    $dumpvars(0, tb_voq);

    apply_reset();

    // Fill partially and drain in order
    push(12'h10);
    push(12'h11);
    push(12'h12);
    pop_expect(12'h10);
    pop_expect(12'h11);
    pop_expect(12'h12);

    // Check empty -> pop should be invalid
    pop_expect('h00, /*must_be_valid=*/0);

    // Fill to (DEPTH-1) then hit FULL transition
    for (int i = 0; i < DEPTH-1; i++) begin
      push(12'h200 + i[11:0]);
    end
    // This push should move to FULL
    push(12'h2FF);
    push_pop_same_cycle(12'h300, 12'h200);

    // While FULL, an extra write (without read) should be ignored (or safely handled)
    @(posedge clk);
    write_req_i = 1;
    ptr_i       = 12'hBAD;
    @(posedge clk);
    write_req_i = 0;
    ptr_i       = '0;

    // Drain all and check order (the extra write should not appear)
    for (int i = 1; i < DEPTH-1; i++) begin
      pop_expect(12'h200 + i[11:0]);
    end
    pop_expect(12'h2FF);
    pop_expect(12'h300);

    // Back to EMPTY
    pop_expect(12'h00, /*must_be_valid=*/0);

    // Test simultaneous read/write in STATE_NORMAL
    push_pop_same_cycle(12'hA0, 12'hA0);
    push(12'hA0);
    push(12'hA1);
    push_pop_same_cycle(12'hB0, 12'hA0); // should read oldest while writing new
    pop_expect(12'hA1);
    pop_expect(12'hB0);

    // Additional simultaneous read/write stress
    push(12'hC0);
    push(12'hC1);
    push(12'hC2);
    push_pop_same_cycle(12'hD0, 12'hC0);
    pop_expect(12'hC1);
    push_pop_same_cycle(12'hD1, 12'hC2);
    pop_expect(12'hD0);
    pop_expect(12'hD1);

    $display("All VOQ tests passed.");
    $finish;
  end

endmodule