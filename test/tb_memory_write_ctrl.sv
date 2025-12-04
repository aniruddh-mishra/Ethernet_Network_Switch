// mostly ai generated
module tb_memory_write_ctrl;

    import mem_pkg::*;

    // clock / reset
    logic clk;
    logic rst_n;

    // DUT interface
    logic [7:0]           data_i;
    logic                 data_valid_i;
    logic                 data_begin_i;
    logic                 data_end_i;
    logic                 data_ready_o;

    logic                 fl_alloc_req_o;
    logic                 fl_alloc_gnt_i;
    logic [ADDR_W-1:0]    fl_alloc_block_idx_i;

    logic                 mem_ready_i;
    logic                 mem_we_o;
    logic [ADDR_W-1:0]    mem_addr_o;
    logic [BLOCK_BITS-1:0] mem_wdata_o;

    logic [ADDR_W-1:0]    start_addr_o;

    // bookkeeping
    int                   write_count;

    //------------------------
    // DUT
    //------------------------
    memory_write_ctrl dut (
        .clk                 (clk),
        .rst_n               (rst_n),

        .data_i              (data_i),
        .data_valid_i        (data_valid_i),
        .data_begin_i        (data_begin_i),
        .data_end_i          (data_end_i),
        .data_ready_o        (data_ready_o),

        .fl_alloc_req_o      (fl_alloc_req_o),
        .fl_alloc_gnt_i        (fl_alloc_gnt_i),
        .fl_alloc_block_idx_i(fl_alloc_block_idx_i),

        .mem_ready_i         (mem_ready_i),
        .mem_we_o            (mem_we_o),
        .mem_addr_o          (mem_addr_o),
        .mem_wdata_o         (mem_wdata_o),

        .start_addr_o        (start_addr_o)
    );

    initial begin
    $dumpfile("mem_wr.vcd");           // name of the waveform file
        $dumpvars(0, tb_memory_write_ctrl); // dump whole TB hierarchy
    end
    //------------------------
    // Clock
    //------------------------
    localparam real CLK_PERIOD = 10.0; // 10 ns

    initial clk = 0;
    always #(CLK_PERIOD/2.0) clk = ~clk;

    //------------------------
    // Simple free list model
    //------------------------
    logic [ADDR_W-1:0] next_block_idx;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fl_alloc_gnt_i         <= 1'b0;
            fl_alloc_block_idx_i <= '0;
            next_block_idx       <= '0;
        end else begin
            fl_alloc_gnt_i <= fl_alloc_req_o;
            if (fl_alloc_req_o) begin
                fl_alloc_block_idx_i <= next_block_idx;
                next_block_idx       <= next_block_idx + 1;
            end
        end
    end

    //------------------------
    // Memory model: always ready
    //------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_ready_i <= 1'b0;
        end else begin
            mem_ready_i <= 1'b1;
        end
    end

    //------------------------
    // Monitor memory writes
    //------------------------
    localparam int FOOTER_BITS = $bits(footer_t);

    footer_t footer_dec;
    // Dummy reduction to touch upper bits of mem_wdata_o (avoid UNUSEDSIGNAL)
    logic     unused_upper_reduce;

    always_comb begin
        unused_upper_reduce = ^mem_wdata_o[BLOCK_BITS-1:FOOTER_BITS];
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            write_count <= 0;
            footer_dec  <= '0;
        end else begin
            if (mem_we_o) begin
                write_count <= write_count + 1;
                footer_dec  <= footer_t'(mem_wdata_o[FOOTER_BITS-1:0]);

                $display("[%0t] MEM WRITE #%0d: addr=%0d start_addr_o=%0d",
                         $time, write_count, mem_addr_o, start_addr_o);
                $display("           footer: next_idx=%0d eop=%0b rsvd=%0h",
                         footer_dec.next_idx, footer_dec.eop, footer_dec.rsvd);
            end
        end
    end

    //------------------------
    // Stimulus task
    //------------------------
    task automatic send_packet(input int num_bytes);
        int i;
        $display("[%0t] >>> Sending packet with %0d bytes",
                 $time, num_bytes);

        for (i = 0; i < num_bytes; i++) begin
            @(negedge clk);
            while (!data_ready_o) @(negedge clk);

            // blocking assignments in task / initial to avoid INITIALDLY warning
            data_valid_i = 1'b1;
            data_begin_i = (i == 0);
            data_end_i   = (i == num_bytes-1);
            data_i       = i[7:0];
        end

        @(negedge clk);
        data_valid_i = 1'b0;
        data_begin_i = 1'b0;
        data_end_i   = 1'b0;

        // ≥1 cycle gap between packets
        @(negedge clk);
    endtask

    //------------------------
    // Optional VCD
    //------------------------
    initial begin
        $dumpfile("wave.vcd");
        $dumpvars(0, tb_memory_write_ctrl);
    end

    //------------------------
    // Test sequence
    //------------------------
        //------------------------
    // Test sequence
    //------------------------
        //------------------------
    // Test sequence
    //------------------------
    initial begin
        rst_n        = 1'b0;
        data_i       = '0;
        data_valid_i = 1'b0;
        data_begin_i = 1'b0;
        data_end_i   = 1'b0;

        // Reset
        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        repeat (5) @(posedge clk);

        // Large packets: K * PAYLOAD_BYTES so they span many frames

        $display("=== TEST 1: large packet (4 * PAYLOAD_BYTES bytes) ===");
        send_packet(4 * PAYLOAD_BYTES);
        /*
        $display("=== TEST 2: larger packet (8 * PAYLOAD_BYTES bytes) ===");
        send_packet(8 * PAYLOAD_BYTES);

        $display("=== TEST 3: very large packet (16 * PAYLOAD_BYTES bytes) ===");
        send_packet(16 * PAYLOAD_BYTES);

        // Optional mild stress: a few very large packets back-to-back
        $display("=== TEST 4: 4 back-to-back very large packets (16 * PAYLOAD_BYTES each) ===");
        for (int k = 0; k < 4; k++) begin
            send_packet(16 * PAYLOAD_BYTES);
        end
*/
        // Let everything drain
        repeat (200) @(posedge clk);

        $display("=== Simulation done. Total memory writes: %0d ===", write_count);
        $finish;
    end



endmodule
