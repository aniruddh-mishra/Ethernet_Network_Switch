module tb_arbiter;

    import mem_pkg::*;

    localparam int N = 4;

    // Clock / reset
    logic clk;
    logic rst_n;

    // -----------------------------
    // Inputs to arbiter
    // -----------------------------

    // Memory write arbitration inputs
    logic [N-1:0] mem_we_i;
    logic [ADDR_W-1:0] mem_addr_i [N-1:0];
    logic [BLOCK_BITS-1:0] mem_wdata_i [N-1:0];

    // Free list allocation arbitration inputs
    logic [N-1:0] fl_alloc_req_i;

    // From fl
    logic fl_alloc_gnt_i;
    logic [ADDR_W-1:0] fl_alloc_block_idx_i;

    // Address learn table inputs (ignored)
    logic [47:0] rx_mac_src_addr_i [N-1:0];
    logic [47:0] rx_mac_dst_addr_i [N-1:0];
    logic [ADDR_W-1:0] data_start_addr_i [N-1:0];
    logic [N-1:0] eop_i;

    // Memory read arbitration inputs
    logic [N-1:0] mem_re_i;
    logic [ADDR_W-1:0] mem_raddr_i [N-1:0];

    // From memory
    logic mem_rvalid_i;
    logic [BLOCK_BITS-1:0] mem_rdata_i;

    // -----------------------------
    // Outputs from arbiter
    // -----------------------------

    logic [N-1:0] mem_gnt_o;

    logic mem_we_o;
    logic [ADDR_W-1:0] mem_addr_o;
    logic [BLOCK_BITS-1:0] mem_wdata_o;

    logic [N-1:0] fl_alloc_gnt_o;
    logic [ADDR_W-1:0] fl_alloc_block_idx_o [N-1:0];

    logic fl_alloc_req_o;

    logic [$clog2(N)-1:0] port_o;
    logic [47:0] rx_mac_src_addr_o;
    logic [47:0] rx_mac_dst_addr_o;
    logic [ADDR_W-1:0] data_start_addr_o;
    logic eop_o;

    logic mem_re_o;
    logic [ADDR_W-1:0] mem_raddr_o;

    logic [N-1:0] mem_rvalid_o;
    logic [BLOCK_BITS-1:0] mem_rdata_o [N-1:0];

    // -----------------------------
    // DUT
    // -----------------------------
    arbiter #(.N(N)) dut (
        .clk(clk),
        .rst_n(rst_n),

        .mem_we_i(mem_we_i),
        .mem_addr_i(mem_addr_i),
        .mem_wdata_i(mem_wdata_i),
        .mem_gnt_o(mem_gnt_o),
        .mem_we_o(mem_we_o),
        .mem_addr_o(mem_addr_o),
        .mem_wdata_o(mem_wdata_o),

        .fl_alloc_req_i(fl_alloc_req_i),
        .fl_alloc_gnt_o(fl_alloc_gnt_o),
        .fl_alloc_block_idx_o(fl_alloc_block_idx_o),
        .fl_alloc_req_o(fl_alloc_req_o),
        .fl_alloc_gnt_i(fl_alloc_gnt_i),
        .fl_alloc_block_idx_i(fl_alloc_block_idx_i),

        .rx_mac_src_addr_i(rx_mac_src_addr_i),
        .rx_mac_dst_addr_i(rx_mac_dst_addr_i),
        .data_start_addr_i(data_start_addr_i),
        .eop_i(eop_i),
        .port_o(port_o),
        .rx_mac_src_addr_o(rx_mac_src_addr_o),
        .rx_mac_dst_addr_o(rx_mac_dst_addr_o),
        .data_start_addr_o(data_start_addr_o),
        .eop_o(eop_o),

        .mem_re_i(mem_re_i),
        .mem_raddr_i(mem_raddr_i),
        .mem_re_o(mem_re_o),
        .mem_raddr_o(mem_raddr_o),
        .mem_rvalid_i(mem_rvalid_i),
        .mem_rdata_i(mem_rdata_i),
        .mem_rvalid_o(mem_rvalid_o),
        .mem_rdata_o(mem_rdata_o)
    );

    // -----------------------------
    // Clock + waves
    // -----------------------------
    initial clk = 0;
    always #5 clk = ~clk;

    initial begin
        $dumpfile("arbiter_tb.vcd");
        $dumpvars(0, tb_arbiter);
    end

    // -----------------------------
    // Cycle counter
    // -----------------------------
    int cyc;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) cyc <= 0;
        else        cyc <= cyc + 1;
    end

    // -----------------------------
    // Drive inputs (single driver)
    // -----------------------------
    int p;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_we_i       <= '0;
            fl_alloc_req_i <= '0;
            mem_re_i       <= '0;

            for (p = 0; p < N; p++) begin
                mem_addr_i[p]        <= '0;
                mem_wdata_i[p]       <= '0;
                mem_raddr_i[p]       <= '0;

                rx_mac_src_addr_i[p] <= 48'b0;
                rx_mac_dst_addr_i[p] <= 48'b0;
                data_start_addr_i[p] <= '0;
                eop_i[p]             <= 1'b0;
            end
        end else begin
            // always high for all ports
            mem_we_i       <= '1;
            fl_alloc_req_i <= '1;
            mem_re_i       <= '1;

            for (p = 0; p < N; p++) begin
                // per-port identifiable patterns
                mem_addr_i[p]  <= ADDR_W'(p * 16 + cyc);

                mem_wdata_i[p] <= '0;
                mem_wdata_i[p][7:0]   <= p[7:0];
                mem_wdata_i[p][15:8]  <= cyc[7:0];
                // zero-extend addr safely into 16 bits
                mem_wdata_i[p][31:16] <= {{(16-ADDR_W){1'b0}}, mem_addr_i[p]};

                mem_raddr_i[p] <= ADDR_W'(p * 32 + cyc);

                // ignored address learn inputs
                rx_mac_src_addr_i[p] <= 48'b0;
                rx_mac_dst_addr_i[p] <= 48'b0;
                data_start_addr_i[p] <= '0;
                eop_i[p]             <= 1'b0;
            end
        end
    end

    // -----------------------------
    // Free list model:
    // grant next cycle if request is high
    // -----------------------------
    logic fl_req_q;
    logic [ADDR_W-1:0] fl_idx_cnt;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            fl_req_q             <= 1'b0;
            fl_alloc_gnt_i       <= 1'b0;
            fl_alloc_block_idx_i <= '0;
            fl_idx_cnt           <= '0;
        end else begin
            fl_alloc_gnt_i <= fl_req_q;

            if (fl_req_q) begin
                fl_alloc_block_idx_i <= fl_idx_cnt;
                fl_idx_cnt           <= fl_idx_cnt + 1;
            end

            fl_req_q <= fl_alloc_req_o;
        end
    end

    // -----------------------------
    // Memory read return model:
    // always valid; data encodes raddr_o
    // -----------------------------
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_rvalid_i <= 1'b0;
            mem_rdata_i  <= '0;
        end else begin
            mem_rvalid_i <= 1'b1;
            mem_rdata_i  <= '0;
            mem_rdata_i[ADDR_W-1:0] <= mem_raddr_o;
            mem_rdata_i[31:16]      <= cyc[15:0];
        end
    end

    // -----------------------------
    // Dummy uses to avoid UNUSEDSIGNAL
    // -----------------------------
    logic unused_wdata_reduce;
    logic unused_flidx_reduce;
    logic unused_port_reduce;
    logic unused_rdata_reduce;

    always_comb begin
        unused_wdata_reduce = ^mem_wdata_o;
        unused_port_reduce  = ^port_o;

        unused_flidx_reduce = 1'b0;
        for (int k = 0; k < N; k++) begin
            unused_flidx_reduce ^= ^fl_alloc_block_idx_o[k];
        end

        unused_rdata_reduce = 1'b0;
        for (int k = 0; k < N; k++) begin
            unused_rdata_reduce ^= ^mem_rdata_o[k];
        end
    end

    // -----------------------------
    // Monitor (no mixed reset style)
    // -----------------------------
    logic rst_done;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) rst_done <= 1'b0;
        else        rst_done <= 1'b1;
    end

    always_ff @(posedge clk) begin
        if (rst_done) begin
            $display("---- cycle %0d ----", cyc);
            $display("WRITE: mem_we_o=%0b mem_addr_o=%0d mem_gnt_o=%b",
                     mem_we_o, mem_addr_o, mem_gnt_o);
            $display("FL: fl_alloc_req_o=%0b fl_alloc_gnt_i=%0b fl_alloc_block_idx_i=%0d fl_alloc_gnt_o=%b",
                     fl_alloc_req_o, fl_alloc_gnt_i, fl_alloc_block_idx_i, fl_alloc_gnt_o);
            $display("READ: mem_re_o=%0b mem_raddr_o=%0d mem_rvalid_i=%0b mem_rvalid_o=%b",
                     mem_re_o, mem_raddr_o, mem_rvalid_i, mem_rvalid_o);
        end
    end

    // -----------------------------
    // Reset + run
    // -----------------------------
    initial begin
        rst_n = 1'b0;
        repeat (5) @(posedge clk);
        rst_n = 1'b1;

        repeat (50) @(posedge clk);
        $finish;
    end

endmodule
