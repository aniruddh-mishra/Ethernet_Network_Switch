module tb_memory_read_ctrl;

    import mem_pkg::*;

    localparam int NUM_CHAIN_BLOCKS = 10;
    localparam int FOOTER_BITS      = $bits(footer_t);

    // Clock / reset
    logic clk;
    logic rst_n;

    // Read controller interface
    logic                  re_i;
    logic                  start;
    logic [ADDR_W-1:0]     start_addr_i;

    logic                  mem_re_o;
    logic [ADDR_W-1:0]     mem_raddr_o;

    logic                  mem_rvalid_i;
    logic [BLOCK_BITS-1:0] mem_rdata_i;

    logic [BLOCK_BITS-1:0] data_o;
    logic                  data_valid_o;
    logic                  data_end_o;

    // SRAM interface (muxed between programming phase and read_ctrl)
    logic                  mem_we_prog;
    logic                  mem_re_prog;
    logic [ADDR_W-1:0]     mem_addr_prog;
    logic [BLOCK_BITS-1:0] mem_wdata_prog;

    logic                  mem_we_mux;
    logic                  mem_re_mux;
    logic [ADDR_W-1:0]     mem_addr_mux;
    logic [BLOCK_BITS-1:0] mem_wdata_mux;
    logic [BLOCK_BITS-1:0] mem_rdata;

    // One-cycle valid pipeline from memory
    logic mem_rvalid_pipe;

    // Chain of block indices (now contiguous)
    logic [ADDR_W-1:0] chain [0:NUM_CHAIN_BLOCKS-1];

    // Phase control: 1 = programming SRAM, 0 = running read controller
    logic program_mode;

    // --------------------------
    // DUTs
    // --------------------------
    sram u_mem (
        .clk   (clk),
        .we    (mem_we_mux),
        .re    (mem_re_mux),
        .addr  (mem_addr_mux),
        .wdata (mem_wdata_mux),
        .rdata (mem_rdata)
    );

    memory_read_ctrl dut (
        .clk          (clk),
        .rst_n        (rst_n),
        .re_i         (re_i),
        .start        (start),
        .start_addr_i (start_addr_i),

        .mem_re_o     (mem_re_o),
        .mem_raddr_o  (mem_raddr_o),

        .mem_rvalid_i (mem_rvalid_i),
        .mem_rdata_i  (mem_rdata_i),

        .data_o       (data_o),
        .data_valid_o (data_valid_o),
        .data_end_o   (data_end_o)
    );

    // --------------------------
    // Clock / waves
    // --------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("memory_read_ctrl_tb.vcd");
        $dumpvars(0, tb_memory_read_ctrl);
    end

    // --------------------------
    // SRAM muxing and valid pipeline
    // --------------------------
    assign mem_we_mux   = program_mode ? mem_we_prog   : 1'b0;
    assign mem_re_mux   = program_mode ? mem_re_prog   : mem_re_o;
    assign mem_addr_mux = program_mode ? mem_addr_prog : mem_raddr_o;
    assign mem_wdata_mux= mem_wdata_prog;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_rvalid_pipe <= 1'b0;
        end else begin
            mem_rvalid_pipe <= mem_re_mux;
        end
    end

    assign mem_rvalid_i = mem_rvalid_pipe;
    assign mem_rdata_i  = mem_rdata;

    // --------------------------
    // Monitor: check data_o footers
    // --------------------------
    int blocks_seen;
    /*
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            blocks_seen <= 0;
        end else begin
            if (data_valid_o) begin
                footer_t f;
                f = footer_t'(data_o[15:0]);

                $display("[%0t] READ block #%0d: footer.next_idx=%0d eop=%0b data_end_o=%0b",
                         $time, blocks_seen, f.next_idx, f.eop, data_end_o);

                if (blocks_seen < NUM_CHAIN_BLOCKS-1) begin
                    // For non-last blocks, eop must be 0 and next_idx must match next link in chain
                    if (f.eop !== 1'b0)
                       // $error("Block %0d: expected eop=0", blocks_seen);
                    if (f.next_idx !== chain[blocks_seen+1])
                        $error("Block %0d: expected next_idx=%0d, got %0d",
                               blocks_seen, chain[blocks_seen+1], f.next_idx);
                end else begin
                    // Last block: eop must be 1
                    if (f.eop !== 1'b1)
                        $error("Last block: expected eop=1");
                end

                blocks_seen++;
            end
        end
    end
    */

    // --------------------------
    // Main stimulus
    // --------------------------
    initial begin
        int i;
        int max_cycles;
        int cycle_count;

        // Contiguous block indices: 0,1,2,...,9
        chain[0] = 12'd37;
        chain[1] = 12'd905;
        chain[2] = 12'd128;
        chain[3] = 12'd2047;
        chain[4] = 12'd319;
        chain[5] = 12'd4093;
        chain[6] = 12'd777;
        chain[7] = 12'd2560;
        chain[8] = 12'd1234;
        chain[9] = 12'd3001;

        // Initial values
        rst_n         = 1'b0;
        program_mode  = 1'b1;

        re_i          = 1'b0;
        start         = 1'b0;
        start_addr_i  = '0;

        mem_we_prog   = 1'b0;
        mem_re_prog   = 1'b0;
        mem_addr_prog = '0;
        mem_wdata_prog= '0;

        blocks_seen   = 0;

        // Reset
        repeat (5) @(posedge clk);
        rst_n = 1'b1;
        @(posedge clk);

        // ----------------------
        // Program SRAM with a linked list of blocks
        // ----------------------
        $display("=== Programming memory blocks (linked list) ===");
        mem_we_prog = 1'b1;

        for (i = 0; i < NUM_CHAIN_BLOCKS; i++) begin
            footer_t f;
            logic [15:0] footer_bits;

            f.next_idx = (i == NUM_CHAIN_BLOCKS-1) ? '0 : chain[i+1];
            f.eop      = (i == NUM_CHAIN_BLOCKS-1);
            f.rsvd     = 3'b000;

            footer_bits    = f;
            mem_addr_prog  = chain[i];
            mem_wdata_prog = { {(BLOCK_BITS-FOOTER_BITS){1'b0}}, footer_bits };

            @(posedge clk);
            $display("[%0t] WROTE block %0d at addr=%0d: next_idx=%0d eop=%0b",
                     $time, i, chain[i], f.next_idx, f.eop);
        end

        mem_we_prog   = 1'b0;
        mem_addr_prog = '0;
        mem_wdata_prog= '0;

        repeat (3) @(posedge clk);

        // ----------------------
        // Run read controller
        // ----------------------
        program_mode  = 1'b0;          // give control of SRAM to read_ctrl
        start_addr_i  = chain[0];
        re_i          = 1'b1;          // continuous read enable
        start         = 1'b1;          // start on first block

        $display("=== Starting read controller from addr %0d ===", chain[0]);

        @(posedge clk);
        start = 1'b0;                 // only first cycle

        // Let it run for a fixed number of cycles
        max_cycles  = 200;
        cycle_count = 0;

        while (cycle_count < max_cycles) begin
            @(posedge clk);
            cycle_count++;
        end

        if (blocks_seen != NUM_CHAIN_BLOCKS) begin
            $error("Expected to see %0d blocks, but saw %0d", NUM_CHAIN_BLOCKS, blocks_seen);
        end else begin
            $display("=== Read controller walked the chain of %0d blocks ===", NUM_CHAIN_BLOCKS);
        end

        re_i = 1'b0;
        repeat (5) @(posedge clk);
        $finish;
    end

endmodule
