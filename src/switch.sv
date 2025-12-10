module switch #(
    parameter int NUM_PORTS = switch_pkg::NUM_PORTS,
    parameter int DATA_WIDTH = rx_tx_pkg::DATA_WIDTH
) (
    // GMII Inputs
    input logic gmii_rx_clk_i [NUM_PORTS-1:0],
    input logic [DATA_WIDTH-1:0] gmii_rx_data_i [NUM_PORTS-1:0],
    input logic gmii_rx_dv_i [NUM_PORTS-1:0],
    input logic gmii_rx_er_i [NUM_PORTS-1:0],

    // switch's clk domain
    input logic switch_clk,
    input logic switch_rst_n,

    // GMII Outputs
    output logic gmii_tx_clk_o [NUM_PORTS-1:0],
    output logic [DATA_WIDTH-1:0] gmii_tx_data_o [NUM_PORTS-1:0],
    output logic gmii_tx_en_o [NUM_PORTS-1:0],
    output logic gmii_tx_er_o [NUM_PORTS-1:0]
);
    import mem_pkg::*;
    import rx_tx_pkg::*;

    // =========================================================
    // rx_mac_control _o signals (per-port)
    // Prefix: rx_mac_control_
    // Note: naming drops trailing "_o" per your example.
    // =========================================================
    logic [5:0][7:0]        rx_mac_control_mac_dst_addr   [NUM_PORTS-1:0];
    logic [5:0][7:0]        rx_mac_control_mac_src_addr   [NUM_PORTS-1:0];
    logic                  rx_mac_control_frame_sof      [NUM_PORTS-1:0];
    logic                  rx_mac_control_frame_eof      [NUM_PORTS-1:0];
    logic                  rx_mac_control_frame_error    [NUM_PORTS-1:0];

    // =========================================================
    // memory_write_ctrl _o signals (per-port)
    // Prefix: memory_write_ctrl_
    // =========================================================
    logic                  memory_write_ctrl_fl_alloc_req[NUM_PORTS-1:0];

    logic                  memory_write_ctrl_mem_we      [NUM_PORTS-1:0];
    logic [ADDR_W-1:0]     memory_write_ctrl_mem_addr    [NUM_PORTS-1:0];
    logic [BLOCK_BITS-1:0] memory_write_ctrl_mem_wdata   [NUM_PORTS-1:0];

    logic [ADDR_W-1:0]     memory_write_ctrl_start_addr  [NUM_PORTS-1:0];

    // =========================================================
    // arbiter _o signals (single instance, N=NUM_PORTS)
    // Prefix: arbiter_
    // =========================================================
    logic                  arbiter_mem_gnt [NUM_PORTS-1:0];

    logic                  arbiter_mem_we;
    logic [ADDR_W-1:0]     arbiter_mem_waddr;
    logic [BLOCK_BITS-1:0] arbiter_mem_wdata;

    logic                  arbiter_fl_alloc_gnt [NUM_PORTS-1:0];
    logic [ADDR_W-1:0]     arbiter_fl_alloc_block_idx [NUM_PORTS-1:0];

    logic                  arbiter_fl_alloc_req;

    logic [$clog2(NUM_PORTS)-1:0] arbiter_port;
    logic [47:0]           arbiter_rx_mac_src_addr;
    logic [47:0]           arbiter_rx_mac_dst_addr;
    logic [ADDR_W-1:0]     arbiter_data_start_addr;
    logic                  arbiter_eop;

    logic                  arbiter_mem_re;
    logic [ADDR_W-1:0]     arbiter_mem_raddr;

    logic                  arbiter_mem_rvalid [NUM_PORTS-1:0];
    logic [BLOCK_BITS-1:0] arbiter_mem_rdata [NUM_PORTS-1:0];

    logic                  arbiter_free_req;
    logic [ADDR_W-1:0]     arbiter_free_block_idx;
    logic                 abriter_flood;

    // =========================================================
    // fl _o signals (single instance)
    // Prefix: fl_
    // =========================================================
    logic                  fl_alloc_gnt;
    logic [ADDR_W-1:0]     fl_alloc_block_idx;

    // =========================================================
    // sram _o signals (single instance)
    // Prefix: sram_
    // =========================================================
    logic [BLOCK_BITS-1:0] sram_rdata;
    logic                  sram_rvalid;

    //// memory read control arbitration ////
    // from memory read ctrl
    logic [ADDR_W-1:0] memory_read_ctrl_addr [NUM_PORTS-1:0];
    logic memory_read_ctrl_re [NUM_PORTS-1:0];

    logic memory_read_ctrl_free_req [NUM_PORTS-1:0];
    logic [ADDR_W-1:0] memory_read_ctrl_free_block_idx [NUM_PORTS-1:0];
    logic memory_read_ctrl_floods [NUM_PORTS-1:0];

    // Crossbar outputs
    logic [NUM_PORTS-1:0] crossbar_voq_write_reqs;
    logic [ADDR_W-1:0] crossbar_voq_start_ptrs [NUM_PORTS-1:0];
    logic crossbar_voq_flood;

    inputs inputs_u (
        // GMII RX interface
        .gmii_rx_clk_i(gmii_rx_clk_i),
        .gmii_rx_data_i(gmii_rx_data_i),
        .gmii_rx_dv_i(gmii_rx_dv_i),
        .gmii_rx_er_i(gmii_rx_er_i),

        // switch clk domain
        .switch_clk(switch_clk),
        .switch_rst_n(switch_rst_n),

        // Outputs to arbiter
        .mac_dst_addr_o(rx_mac_control_mac_dst_addr),
        .mac_src_addr_o(rx_mac_control_mac_src_addr),
        .frame_sof_o(rx_mac_control_frame_sof),
        .frame_eof_o(rx_mac_control_frame_eof),
        .frame_error_o(rx_mac_control_frame_error),
        .start_addr_o(memory_write_ctrl_start_addr),

        // Inputs from arbiter
        .arbiter_fl_alloc_gnt(arbiter_fl_alloc_gnt),
        .arbiter_fl_alloc_block_idx(arbiter_fl_alloc_block_idx),
        .arbiter_mem_gnt(arbiter_mem_gnt),

        // Outputs to memory
        .mem_we_o(memory_write_ctrl_mem_we),
        .mem_addr_o(memory_write_ctrl_mem_addr),
        .mem_wdata_o(memory_write_ctrl_mem_wdata),

        // Outputs to memory and free list
        .fl_alloc_req_o(memory_write_ctrl_fl_alloc_req)
    );

    // 1 x arbiter
    arbiter arbiter_u (
        .clk(switch_clk),
        .rst_n(switch_rst_n),

        //// Memory write port arbitration ////
        .mem_we_i(memory_write_ctrl_mem_we),
        .mem_waddr_i(memory_write_ctrl_mem_addr),
        .mem_wdata_i(memory_write_ctrl_mem_wdata),

        .mem_gnt_o       (arbiter_mem_gnt),

        .mem_we_o        (arbiter_mem_we),
        .mem_waddr_o      (arbiter_mem_waddr),
        .mem_wdata_o     (arbiter_mem_wdata),
        //// Memory write port arbitration ////

        //// Free list allocation arbitration ////
        .fl_alloc_req_i(memory_write_ctrl_fl_alloc_req),

        .fl_alloc_gnt_o       (arbiter_fl_alloc_gnt),
        .fl_alloc_block_idx_o (arbiter_fl_alloc_block_idx),

        .fl_alloc_req_o       (arbiter_fl_alloc_req),

        .fl_alloc_gnt_i(fl_alloc_gnt),
        .fl_alloc_block_idx_i(fl_alloc_block_idx),
        //// Free list allocation arbitration ////

        //// Address learn table arbitration ////
        .rx_mac_src_addr_i(rx_mac_control_mac_src_addr),
        .rx_mac_dst_addr_i(rx_mac_control_mac_dst_addr),
        .data_start_addr_i(memory_write_ctrl_start_addr),
        .data_error_i(rx_mac_control_frame_error),
        .eop_i(rx_mac_control_frame_eof),
        .sof_i(rx_mac_control_frame_sof),

        .port_o           (arbiter_port),
        .rx_mac_src_addr_o(arbiter_rx_mac_src_addr),
        .rx_mac_dst_addr_o(arbiter_rx_mac_dst_addr),
        .data_start_addr_o(arbiter_data_start_addr),
        .eop_o            (arbiter_eop),
        //// Address learn table arbitration ////

        //// memory read control arbitration ////
        .mem_re_i(memory_read_ctrl_re),
        .mem_raddr_i(memory_read_ctrl_addr),

        .mem_re_o         (arbiter_mem_re),
        .mem_raddr_o      (arbiter_mem_raddr),

        .mem_rvalid_i (sram_rvalid),
        .mem_rdata_i (sram_rdata),

        .mem_rvalid_o     (arbiter_mem_rvalid),
        .mem_rdata_o      (arbiter_mem_rdata),

        .free_req_i (memory_read_ctrl_free_req),
        .free_block_idx_i (memory_read_ctrl_free_block_idx),
        .flood_i(memory_read_ctrl_floods),

        .free_req_o (arbiter_free_req),
        .free_block_idx_o (arbiter_free_block_idx),
        .flood_o(abriter_flood)
    );

    // 1 x fl
    fl fl_u (
        .clk(switch_clk),
        .rst_n(switch_rst_n),

        // alloc
        .alloc_req_i (arbiter_fl_alloc_req),
        .alloc_gnt_o (fl_alloc_gnt),
        .alloc_block_idx_o  (fl_alloc_block_idx),

        // free
        .free_req_i(arbiter_free_req),
        .free_block_idx_i(arbiter_free_block_idx),
        .flood(abriter_flood)
    );

    // 1 x sram
    sram sram_u (
        .clk (switch_clk),
        .rst_n (switch_rst_n),
        .we (arbiter_mem_we),
        .re (arbiter_mem_re),
        .r_addr (arbiter_mem_raddr),
        .w_addr (arbiter_mem_waddr),
        .wdata (arbiter_mem_wdata),
        .rdata (sram_rdata),
        .rvalid (sram_rvalid)
    );

    crossbar crossbar_u (
        .clk(switch_clk),
        .rst_n(switch_rst_n),
        .eof_i(arbiter_eop),
        .ingress_port_i(arbiter_port),
        .rx_mac_src_addr_i(arbiter_rx_mac_src_addr),
        .rx_mac_dst_addr_i(arbiter_rx_mac_dst_addr),
        .data_start_ptr_i(arbiter_data_start_addr),
        .voq_write_reqs_o(crossbar_voq_write_reqs),
        .voq_start_ptrs_o(crossbar_voq_start_ptrs),
        .flood_o(crossbar_voq_flood)
    );

    outputs outputs_u (
        .switch_clk(switch_clk),
        .switch_rst_n(switch_rst_n),

        // Memory read arbiter connections
        .arbiter_mem_rvalid(arbiter_mem_rvalid),
        .arbiter_mem_rdata(arbiter_mem_rdata),
        .memory_read_ctrl_addr(memory_read_ctrl_addr),
        .memory_read_ctrl_re(memory_read_ctrl_re),

        // Free list connections
        .memory_read_ctrl_free_req(memory_read_ctrl_free_req),
        .memory_read_ctrl_free_block_idx(memory_read_ctrl_free_block_idx),
        .memory_read_ctrl_floods(memory_read_ctrl_floods),

        // Inputs from crossbar
        .crossbar_voq_write_reqs(crossbar_voq_write_reqs),
        .crossbar_voq_start_ptrs(crossbar_voq_start_ptrs),
        .crossbar_voq_flood(crossbar_voq_flood),

        // GMII Outputs
        .gmii_tx_clk_o(gmii_tx_clk_o),
        .gmii_tx_data_o(gmii_tx_data_o),
        .gmii_tx_en_o(gmii_tx_en_o),
        .gmii_tx_er_o(gmii_tx_er_o)
    );

endmodule
