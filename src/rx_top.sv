`timescale 1ns/1ps
`default_nettype none

module top #(
    parameter int NUM_PORTS = 4
) ();

    import mem_pkg::*;

    // =========================================================
    // rx_mac_control _o signals (per-port)
    // Prefix: rx_mac_control_
    // Note: naming drops trailing "_o" per your example.
    // =========================================================
    logic [5:0][7:0]        rx_mac_control_mac_dst_addr   [NUM_PORTS];
    logic [5:0][7:0]        rx_mac_control_mac_src_addr   [NUM_PORTS];

    logic [DATA_WIDTH-1:0] rx_mac_control_frame_data     [NUM_PORTS];
    logic                  rx_mac_control_frame_valid    [NUM_PORTS];
    logic                  rx_mac_control_frame_sof      [NUM_PORTS];
    logic                  rx_mac_control_frame_eof      [NUM_PORTS];
    logic                  rx_mac_control_frame_error    [NUM_PORTS];

    // =========================================================
    // memory_write_ctrl _o signals (per-port)
    // Prefix: memory_write_ctrl_
    // =========================================================
    logic                  memory_write_ctrl_data_ready  [NUM_PORTS];

    logic                  memory_write_ctrl_fl_alloc_req[NUM_PORTS];

    logic                  memory_write_ctrl_mem_we      [NUM_PORTS];
    logic [ADDR_W-1:0]     memory_write_ctrl_mem_addr    [NUM_PORTS];
    logic [BLOCK_BITS-1:0] memory_write_ctrl_mem_wdata   [NUM_PORTS];

    logic [ADDR_W-1:0]     memory_write_ctrl_start_addr  [NUM_PORTS];

    // =========================================================
    // arbiter _o signals (single instance, N=NUM_PORTS)
    // Prefix: arbiter_
    // =========================================================
    logic [NUM_PORTS-1:0]  arbiter_mem_gnt;

    logic                  arbiter_mem_we;
    logic [ADDR_W-1:0]     arbiter_mem_waddr;
    logic [BLOCK_BITS-1:0] arbiter_mem_wdata;

    logic [NUM_PORTS-1:0]  arbiter_fl_alloc_gnt;
    logic [ADDR_W-1:0]     arbiter_fl_alloc_block_idx [NUM_PORTS];

    logic                  arbiter_fl_alloc_req;

    logic [$clog2(NUM_PORTS)-1:0] arbiter_port;
    logic [47:0]           arbiter_rx_mac_src_addr;
    logic [47:0]           arbiter_rx_mac_dst_addr;
    logic [ADDR_W-1:0]     arbiter_data_start_addr;
    logic                  arbiter_eop;

    logic                  arbiter_mem_re;
    logic [ADDR_W-1:0]     arbiter_mem_raddr;

    logic [NUM_PORTS-1:0]  arbiter_mem_rvalid;
    logic [BLOCK_BITS-1:0] arbiter_mem_rdata [NUM_PORTS];

    logic                  arbiter_free_req;
    logic [ADDR_W-1:0]     arbiter_free_block_idx;

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

    // =========================================================
    // Instances
    // =========================================================
    genvar p;

    // NUM_PORTS x rx_mac_control
    generate
        for (p = 0; p < NUM_PORTS; p++) begin : GEN_RX_MAC
            rx_mac_control rx_mac_control_u (
                // GMII interface
                .gmii_rx_clk_i(),
                .gmii_rx_data_i(),
                .gmii_rx_dv_i(),
                .gmii_rx_er_i(),

                // switch's clk domain
                .switch_clk(),
                .switch_rst_n(),

                // outputs to MAC learning/lookup - specific to bytes
                .mac_dst_addr_o (rx_mac_control_mac_dst_addr[p]),
                .mac_src_addr_o (rx_mac_control_mac_src_addr[p]),

                // outputs to learning/lookup and memory
                .frame_data_o   (rx_mac_control_frame_data[p]),
                .frame_valid_o  (rx_mac_control_frame_valid[p]),
                .frame_grant_i  (memory_write_ctrl_data_ready[p]),
                .frame_sof_o    (rx_mac_control_frame_sof[p]),
                .frame_eof_o    (rx_mac_control_frame_eof[p]),
                .frame_error_o  (rx_mac_control_frame_error[p])
            );
        end
    endgenerate

    // NUM_PORTS x memory_write_ctrl
    generate
        for (p = 0; p < NUM_PORTS; p++) begin : GEN_MEM_WR
            memory_write_ctrl memory_write_ctrl_u (
                .clk(),
                .rst_n(),

                // memory write data, 1 byte / 8 bit beats
                .data_i(rx_mac_control_frame_data[p]),
                .data_valid_i(rx_mac_control_frame_valid[p]),
                .data_begin_i(rx_mac_control_frame_sof[p]),
                .data_end_i(rx_mac_control_frame_eof[p]),
                .data_ready_o     (memory_write_ctrl_data_ready[p]),

                // interface with free list
                .fl_alloc_req_o   (memory_write_ctrl_fl_alloc_req[p]),
                .fl_alloc_gnt_i   (arbiter_fl_alloc_gnt[p]),
                .fl_alloc_block_idx_i(arbiter_fl_alloc_block_idx[p]),

                // to memory
                .mem_ready_i      (arbiter_mem_gnt[p]),
                .mem_we_o         (memory_write_ctrl_mem_we[p]),
                .mem_addr_o       (memory_write_ctrl_mem_addr[p]),
                .mem_wdata_o      (memory_write_ctrl_mem_wdata[p]),

                // to arb
                .start_addr_o     (memory_write_ctrl_start_addr[p])
            );
        end
    endgenerate

    // 1 x arbiter
    arbiter #(
        .N(NUM_PORTS)
    ) arbiter_u (
        .clk(),
        .rst_n(),

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
        .rx_mac_src_addr_i(),
        .rx_mac_dst_addr_i(),
        .data_start_addr_i(),
        .eop_i(),

        .port_o           (arbiter_port),
        .rx_mac_src_addr_o(arbiter_rx_mac_src_addr),
        .rx_mac_dst_addr_o(arbiter_rx_mac_dst_addr),
        .data_start_addr_o(arbiter_data_start_addr),
        .eop_o            (arbiter_eop),
        //// Address learn table arbitration ////

        //// memory read control arbitration ////
        .mem_re_i(),
        .mem_raddr_i(),

        .mem_re_o         (arbiter_mem_re),
        .mem_raddr_o      (arbiter_mem_raddr),

        .mem_rvalid_i(),
        .mem_rdata_i(),

        .mem_rvalid_o     (arbiter_mem_rvalid),
        .mem_rdata_o      (arbiter_mem_rdata),

        .free_req_i(),
        .free_block_idx_i(),

        .free_req_o       (arbiter_free_req),
        .free_block_idx_o (arbiter_free_block_idx)
    );

    // 1 x fl
    fl fl_u (
        .clk(),
        .rst_n(),

        // alloc
        .alloc_req_i(arbiter_fl_alloc_req),
        .alloc_gnt_o        (fl_alloc_gnt),
        .alloc_block_idx_o  (fl_alloc_block_idx),

        // free
        .free_req_i(arbiter_free_req),
        .free_block_idx_i(arbiter_free_block_idx)
    );

    // 1 x sram
    sram sram_u (
        .clk(),
        .we(arbiter_mem_we),
        .re(arbiter_mem_re),
        .r_addr(arbiter_mem_raddr),
        .w_addr(arbiter_mem_waddr),
        .wdata(arbiter_mem_wdata),
        .rdata   (sram_rdata)
    );

endmodule

`default_nettype wire
