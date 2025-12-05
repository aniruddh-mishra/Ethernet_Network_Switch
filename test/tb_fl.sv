// mostly AI generated
module tb_fl;

    import mem_pkg::*;

    localparam int NBITS = ADDR_W;

    // DUT interface
    logic clk;
    logic rst_n;

    logic              alloc_req_i;
    logic              alloc_gnt_o;
    logic [NBITS-1:0]  alloc_block_idx_o;

    logic              free_req_i;
    logic [NBITS-1:0]  free_block_idx_i;

    // For tests
    logic [NBITS-1:0]  idx;
    logic [NBITS-1:0]  freed_idx;
    logic [NBITS-1:0]  bypass_free_idx;
    logic [NBITS-1:0]  bypass_alloc_idx;

    // Instantiate DUT
    fl dut (
        .clk               (clk),
        .rst_n             (rst_n),
        .alloc_req_i       (alloc_req_i),
        .alloc_gnt_o       (alloc_gnt_o),
        .alloc_block_idx_o (alloc_block_idx_o),
        .free_req_i        (free_req_i),
        .free_block_idx_i  (free_block_idx_i)
    );

    // Clock: 10 ns period
    initial clk = 0;
    always #5 clk = ~clk;

    // Optional waveform dump
    initial begin
        $dumpfile("fl_tb.vcd");
        $dumpvars(0, tb_fl);
    end

    // ----------------------------
    // Helper tasks
    // ----------------------------

    task automatic do_reset;
        rst_n            = 0;
        alloc_req_i      = 0;
        free_req_i       = 0;
        free_block_idx_i = '0;

        repeat (5) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
        $display("[%0t] Reset deasserted", $time);
    endtask

    // Single allocation attempt
    task automatic do_alloc(
        output [NBITS-1:0] idx_o,
        input  bit         expect_gnt,
        input  string      tag
    );
        alloc_req_i = 1'b1;
        free_req_i  = 1'b0;

        @(posedge clk);

        idx_o = alloc_block_idx_o;

        if (alloc_gnt_o !== expect_gnt) begin
            $error("[%0t] %s: expected grant=%0b, got %0b",
                   $time, tag, expect_gnt, alloc_gnt_o);
        end else begin
            $display("[%0t] %s: alloc_gnt_o=%0b, idx=%0d",
                     $time, tag, alloc_gnt_o, idx_o);
        end

        alloc_req_i = 1'b0;
        @(posedge clk);
    endtask

    // Single free
    task automatic do_free(
        input [NBITS-1:0] idx_i,
        input string      tag
    );
        free_block_idx_i = idx_i;
        free_req_i       = 1'b1;
        alloc_req_i      = 1'b0;

        @(posedge clk);

        $display("[%0t] %s: freed idx=%0d", $time, tag, idx_i);

        free_req_i = 1'b0;
        @(posedge clk);
    endtask

    // Simultaneous alloc + free
    task automatic do_alloc_free_same_cycle(
        input  [NBITS-1:0] free_idx_i,
        output [NBITS-1:0] alloc_idx_o
    );
        free_block_idx_i = free_idx_i;
        free_req_i       = 1'b1;
        alloc_req_i      = 1'b1;

        @(posedge clk);

        alloc_idx_o = alloc_block_idx_o;

        if (!alloc_gnt_o) begin
            $error("[%0t] alloc_free_same_cycle: expected grant=1, got 0", $time);
        end else begin
            $display("[%0t] alloc_free_same_cycle: freed=%0d, allocated=%0d",
                     $time, free_idx_i, alloc_idx_o);
        end

        free_req_i  = 1'b0;
        alloc_req_i = 1'b0;
        @(posedge clk);
    endtask

    // ----------------------------
    // Main stimulus
    // ----------------------------
    initial begin
        int i;

        do_reset();

        // 1) Allocate NUM_BLOCKS entries
        $display("=== TEST 1: allocate until empty ===");
        for (i = 0; i < NUM_BLOCKS; i++) begin
            do_alloc(idx, 1'b1, $sformatf("alloc %0d", i));
        end

        // 2) Extra alloc when empty: expect no grant
        $display("=== TEST 2: allocation when empty (expect no grant) ===");
        do_alloc(idx, 1'b0, "alloc when empty");

        // 3) Free one index and ensure it comes back
        $display("=== TEST 3: free one, then allocate it back ===");
        freed_idx = 2048;  // arbitrary valid index
        do_free(freed_idx, "free mid index");

        do_alloc(idx, 1'b1, "alloc after single free");
        if (idx !== freed_idx) begin
            $error("[%0t] Expected to re-allocate freed_idx=%0d, got %0d",
                   $time, freed_idx, idx);
        end else begin
            $display("[%0t] Re-allocated freed_idx correctly (%0d)",
                     $time, idx);
        end

        // 4) Simultaneous alloc + free (bypass)
        $display("=== TEST 4: simultaneous alloc + free bypass ===");
        bypass_free_idx = 1200;
        do_alloc_free_same_cycle(bypass_free_idx, bypass_alloc_idx);
        if (bypass_alloc_idx !== bypass_free_idx) begin
            $error("[%0t] Expected alloc_idx == free_idx in bypass path, got %0d vs %0d",
                   $time, bypass_alloc_idx, bypass_free_idx);
        end else begin
            $display("[%0t] Bypass OK: alloc_idx==free_idx==%0d",
                     $time, bypass_alloc_idx);
        end

        $display("=== TESTBENCH DONE ===");
        #50;
        $finish;
    end

endmodule
