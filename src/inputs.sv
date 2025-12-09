module inputs #(
    parameter NUM_PORTS = switch_pkg::NUM_PORTS,
    parameter ADDR_W = mem_pkg::ADDR_W,
    parameter BLOCK_BITS = mem_pkg::BLOCK_BITS
) (
    // GMII RX interface
    input logic gmii_rx_clk_i [NUM_PORTS-1:0],
    input logic [7:0] gmii_rx_data_i [NUM_PORTS-1:0],
    input logic gmii_rx_dv_i [NUM_PORTS-1:0],
    input logic gmii_rx_er_i [NUM_PORTS-1:0],

    // switch clk domain
    input logic switch_clk, switch_rst_n,

    // Output to arbiter
    output logic [47:0] mac_dst_addr_o [NUM_PORTS-1:0],
    output logic [47:0] mac_src_addr_o [NUM_PORTS-1:0],
    output logic frame_sof_o [NUM_PORTS-1:0],
    output logic frame_eof_o [NUM_PORTS-1:0],
    output logic frame_error_o [NUM_PORTS-1:0],
    output logic [ADDR_W-1:0] start_addr_o [NUM_PORTS-1:0],

    // Inputs from arbiter
    input logic arbiter_fl_alloc_gnt [NUM_PORTS-1:0],
    input logic [mem_pkg::ADDR_W-1:0] arbiter_fl_alloc_block_idx [NUM_PORTS-1:0],
    input logic arbiter_mem_gnt [NUM_PORTS-1:0],

    // Outputs to memory
    output logic mem_we_o [NUM_PORTS-1:0],
    output logic [mem_pkg::ADDR_W-1:0] mem_addr_o [NUM_PORTS-1:0],
    output logic [mem_pkg::BLOCK_BITS-1:0] mem_wdata_o [NUM_PORTS-1:0],

    // Outputs to memory and free list
    output logic fl_alloc_req_o [NUM_PORTS-1:0]
);

    import rx_tx_pkg::*;

    // Wires from rx_mac_control
    logic [DATA_WIDTH-1:0] rx_mac_control_frame_data     [NUM_PORTS-1:0];
    logic                  rx_mac_control_frame_valid    [NUM_PORTS-1:0];

    // Wires from memory_write_ctrl
    logic                  memory_write_ctrl_data_ready  [NUM_PORTS-1:0];
    logic                  memory_write_ctrl_mem_we      [NUM_PORTS-1:0];
    logic [ADDR_W-1:0]     memory_write_ctrl_mem_addr    [NUM_PORTS-1:0];
    logic [BLOCK_BITS-1:0] memory_write_ctrl_mem_wdata   [NUM_PORTS-1:0];

    genvar p;

    // NUM_PORTS x rx_mac_control
    generate
        for (p = 0; p < NUM_PORTS; p++) begin : GEN_RX_MAC
            rx_mac_control rx_mac_control_u (
                // GMII interface
                .gmii_rx_clk_i(gmii_rx_clk_i[p]),
                .gmii_rx_data_i(gmii_rx_data_i[p]),
                .gmii_rx_dv_i(gmii_rx_dv_i[p]),
                .gmii_rx_er_i(gmii_rx_er_i[p]),

                // switch's clk domain
                .switch_clk(switch_clk),
                .switch_rst_n(switch_rst_n),

                // outputs to MAC learning/lookup - specific to bytes
                .mac_dst_addr_o (mac_dst_addr_o[p]),
                .mac_src_addr_o (mac_src_addr_o[p]),

                // outputs to learning/lookup and memory
                .frame_data_o   (rx_mac_control_frame_data[p]),
                .frame_valid_o  (rx_mac_control_frame_valid[p]),
                .frame_grant_i  (memory_write_ctrl_data_ready[p]),
                .frame_sof_o    (frame_sof_o[p]),
                .frame_eof_o    (frame_eof_o[p]),
                .frame_error_o  (frame_error_o[p])
            );
        end
    endgenerate

    // NUM_PORTS x memory_write_ctrl
    generate
        for (p = 0; p < NUM_PORTS; p++) begin : GEN_MEM_WR
            memory_write_ctrl memory_write_ctrl_u (
                .clk(switch_clk),
                .rst_n(switch_rst_n),

                // memory write data, 1 byte / 8 bit beats
                .data_i(rx_mac_control_frame_data[p]),
                .data_valid_i(rx_mac_control_frame_valid[p]),
                .data_begin_i(frame_sof_o[p]),
                .data_end_i(frame_eof_o[p]),
                .data_ready_o     (memory_write_ctrl_data_ready[p]),

                // interface with free list
                .fl_alloc_req_o   (fl_alloc_req_o[p]),
                .fl_alloc_gnt_i   (arbiter_fl_alloc_gnt[p]),
                .fl_alloc_block_idx_i(arbiter_fl_alloc_block_idx[p]),

                // to memory
                .mem_ready_i      (arbiter_mem_gnt[p]),
                .mem_we_o         (mem_we_o[p]),
                .mem_addr_o       (mem_addr_o[p]),
                .mem_wdata_o      (mem_wdata_o[p]),

                // to arb
                .start_addr_o     (start_addr_o[p])
            );
        end
    endgenerate
    
endmodule
