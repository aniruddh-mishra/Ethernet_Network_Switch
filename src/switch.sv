module switch (
    input switch_clk, rst_n,
    
    // GMII Input (per-port)
    input logic gmii_rx_clk_i [NUM_PORTS-1:0],
    input logic [DATA_WIDTH-1:0] gmii_rx_data_i [NUM_PORTS-1:0],
    input logic gmii_rx_dv_i [NUM_PORTS-1:0],
    input logic gmii_rx_er_i [NUM_PORTS-1:0],

    // GMII Out (per-port)
    output logic gmii_tx_clk_o [NUM_PORTS-1:0],
    output logic [DATA_WIDTH-1:0] gmii_tx_data_o [NUM_PORTS-1:0],
    output logic gmii_tx_en_o [NUM_PORTS-1:0],
    output logic gmii_tx_er_o [NUM_PORTS-1:0]
);

// Packages
import address_table_pkg::*;
import mem_pkg::*;
import rx_tx_pkg::*;
import switch_pkg::*;
import voq_pkg::*;

// RX Module Signals
logic [47:0] ingress_dst_addrs [NUM_PORTS-1:0];
logic [47:0] ingress_src_addrs [NUM_PORTS-1:0];

logic ingress_grants [NUM_PORTS-1:0];
logic [DATA_WIDTH-1:0] ingress_byte_outs [NUM_PORTS-1:0];
logic ingress_byte_valids [NUM_PORTS-1:0];
logic ingress_sofs [NUM_PORTS-1:0];
logic ingress_eofs [NUM_PORTS-1:0];
logic ingress_errors [NUM_PORTS-1:0];

// TX Module Signals
logic [DATA_WIDTH-1:0] egress_byte_ins [NUM_PORTS-1:0];
logic egress_byte_valids [NUM_PORTS-1:0];
logic egress_eofs [NUM_PORTS-1:0];
logic [$clog2(VOQ_DEPTH)-1:0] egress_mem_ptrs [NUM_PORTS-1:0];
logic egress_idles [NUM_PORTS-1:0];

// VOQ Signals
logic voq_valids [NUM_PORTS-1:0];
logic [$clog2(VOQ_DEPTH)-1:0] voq_ptrs [NUM_PORTS-1:0];

// Memory write/read interconnect (per-port)
logic mem_we_ports [NUM_PORTS-1:0];
logic [ADDR_W-1:0] mem_addr_ports [NUM_PORTS-1:0];
logic [BLOCK_BITS-1:0] mem_wdata_ports [NUM_PORTS-1:0];
logic mem_gnt_ports [NUM_PORTS-1:0];

// Free-list interconnect
logic fl_alloc_req_ports [NUM_PORTS-1:0];
logic fl_alloc_gnt_ports [NUM_PORTS-1:0];
logic [ADDR_W-1:0] fl_alloc_idx_ports [NUM_PORTS-1:0];

// Address learn arbitration inputs (from RXs)
logic [ADDR_W-1:0] data_start_addr_i [NUM_PORTS-1:0];

// Arbiter outputs
logic [$clog2(NUM_PORTS)-1:0] arb_port_o;
logic [47:0] arb_rx_mac_src_addr_o;
logic [47:0] arb_rx_mac_dst_addr_o;
logic [ADDR_W-1:0] arb_data_start_addr_o;
logic arb_eop_o; // Same as eof

// sram read data
logic [BLOCK_BITS-1:0] sram_b_rdata;
// sram A-side signals (driven by arbiter)
logic sram_a_we;
logic [ADDR_W-1:0] sram_a_addr;
logic [BLOCK_BITS-1:0] sram_a_wdata;
logic [BLOCK_BITS-1:0] sram_a_rdata;

// free-list handshake signals to/from fl
logic arb_fl_alloc_req_o;
logic arb_fl_alloc_gnt_i;
logic [ADDR_W-1:0] arb_fl_alloc_block_idx_i;

// Instantiate 4 RX MAC control ports
rx_mac_control port1_ingress (
    .gmii_rx_clk_i(gmii_rx_clk_i[0]), 
    .gmii_rx_data_i(gmii_rx_data_i[0]), 
    .gmii_rx_dv_i(gmii_rx_dv_i[0]), 
    .gmii_rx_er_i(gmii_rx_er_i[0]),
    
    .switch_clk(switch_clk),
    .switch_rst_n(rst_n),
    
    .mac_dst_addr_o(ingress_dst_addrs[0]),
    .mac_src_addr_o(ingress_src_addrs[0]),
    
    .frame_grant_i(ingress_grants[0]),
    .frame_data_o(ingress_byte_outs[0]),
    .frame_valid_o(ingress_byte_valids[0]),
    .frame_sof_o(ingress_sofs[0]),
    .frame_eof_o(ingress_eofs[0]),
    .frame_error_o(ingress_errors[0]));

rx_mac_control port2_ingress (
    .gmii_rx_clk_i(gmii_rx_clk_i[1]), 
    .gmii_rx_data_i(gmii_rx_data_i[1]), 
    .gmii_rx_dv_i(gmii_rx_dv_i[1]), 
    .gmii_rx_er_i(gmii_rx_er_i[1]),
    
    .switch_clk(switch_clk),
    .switch_rst_n(rst_n),
    
    .mac_dst_addr_o(ingress_dst_addrs[1]),
    .mac_src_addr_o(ingress_src_addrs[1]),
    
    .frame_grant_i(ingress_grants[1]),
    .frame_data_o(ingress_byte_outs[1]),
    .frame_valid_o(ingress_byte_valids[1]),
    .frame_sof_o(ingress_sofs[1]),
    .frame_eof_o(ingress_eofs[1]),
    .frame_error_o(ingress_errors[1]));

rx_mac_control port3_ingress (
    .gmii_rx_clk_i(gmii_rx_clk_i[2]), 
    .gmii_rx_data_i(gmii_rx_data_i[2]), 
    .gmii_rx_dv_i(gmii_rx_dv_i[2]), 
    .gmii_rx_er_i(gmii_rx_er_i[2]),
    
    .switch_clk(switch_clk),
    .switch_rst_n(rst_n),
    
    .mac_dst_addr_o(ingress_dst_addrs[2]),
    .mac_src_addr_o(ingress_src_addrs[2]),
    
    .frame_grant_i(ingress_grants[2]),
    .frame_data_o(ingress_byte_outs[2]),
    .frame_valid_o(ingress_byte_valids[2]),
    .frame_sof_o(ingress_sofs[2]),
    .frame_eof_o(ingress_eofs[2]),
    .frame_error_o(ingress_errors[2]));

rx_mac_control port4_ingress (
    .gmii_rx_clk_i(gmii_rx_clk_i[3]), 
    .gmii_rx_data_i(gmii_rx_data_i[3]), 
    .gmii_rx_dv_i(gmii_rx_dv_i[3]), 
    .gmii_rx_er_i(gmii_rx_er_i[3]),
    
    .switch_clk(switch_clk),
    .switch_rst_n(rst_n),
    
    .mac_dst_addr_o(ingress_dst_addrs[3]),
    .mac_src_addr_o(ingress_src_addrs[3]),
    
    .frame_grant_i(ingress_grants[3]),
    .frame_data_o(ingress_byte_outs[3]),
    .frame_valid_o(ingress_byte_valids[3]),
    .frame_sof_o(ingress_sofs[3]),
    .frame_eof_o(ingress_eofs[3]),
    .frame_error_o(ingress_errors[3]));

// Connect RX MAC address outputs into arbiter inputs
assign data_start_addr_i = '{default: '0}; // not wired to write-starts in this simple hookup

// Per-port memory write controllers
memory_write_ctrl mem_wr_p0 (
    .clk(switch_clk),
    .rst_n(rst_n),
    .data_i(ingress_byte_outs[0]),
    .data_valid_i(ingress_byte_valids[0]),
    .data_begin_i(ingress_sofs[0]),
    .data_end_i(ingress_eofs[0]),
    .data_ready_o(),
    .fl_alloc_req_o(fl_alloc_req_ports[0]),
    .fl_alloc_gnt(fl_alloc_gnt_ports[0]),
    .fl_alloc_block_idx_i(fl_alloc_idx_ports[0]),
    .mem_ready_i(mem_gnt_ports[0]),
    .mem_we_o(mem_we_ports[0]),
    .mem_addr_o(mem_addr_ports[0]),
    .mem_wdata_o(mem_wdata_ports[0])
);

memory_write_ctrl mem_wr_p1 (
    .clk(switch_clk),
    .rst_n(rst_n),
    .data_i(ingress_byte_outs[1]),
    .data_valid_i(ingress_byte_valids[1]),
    .data_begin_i(ingress_sofs[1]),
    .data_end_i(ingress_eofs[1]),
    .data_ready_o(),
    .fl_alloc_req_o(fl_alloc_req_ports[1]),
    .fl_alloc_gnt(fl_alloc_gnt_ports[1]),
    .fl_alloc_block_idx_i(fl_alloc_idx_ports[1]),
    .mem_ready_i(mem_gnt_ports[1]),
    .mem_we_o(mem_we_ports[1]),
    .mem_addr_o(mem_addr_ports[1]),
    .mem_wdata_o(mem_wdata_ports[1])
);

memory_write_ctrl mem_wr_p2 (
    .clk(switch_clk),
    .rst_n(rst_n),
    .data_i(ingress_byte_outs[2]),
    .data_valid_i(ingress_byte_valids[2]),
    .data_begin_i(ingress_sofs[2]),
    .data_end_i(ingress_eofs[2]),
    .data_ready_o(),
    .fl_alloc_req_o(fl_alloc_req_ports[2]),
    .fl_alloc_gnt(fl_alloc_gnt_ports[2]),
    .fl_alloc_block_idx_i(fl_alloc_idx_ports[2]),
    .mem_ready_i(mem_gnt_ports[2]),
    .mem_we_o(mem_we_ports[2]),
    .mem_addr_o(mem_addr_ports[2]),
    .mem_wdata_o(mem_wdata_ports[2])
);

memory_write_ctrl mem_wr_p3 (
    .clk(switch_clk),
    .rst_n(rst_n),
    .data_i(ingress_byte_outs[3]),
    .data_valid_i(ingress_byte_valids[3]),
    .data_begin_i(ingress_sofs[3]),
    .data_end_i(ingress_eofs[3]),
    .data_ready_o(),
    .fl_alloc_req_o(fl_alloc_req_ports[3]),
    .fl_alloc_gnt(fl_alloc_gnt_ports[3]),
    .fl_alloc_block_idx_i(fl_alloc_idx_ports[3]),
    .mem_ready_i(mem_gnt_ports[3]),
    .mem_we_o(mem_we_ports[3]),
    .mem_addr_o(mem_addr_ports[3]),
    .mem_wdata_o(mem_wdata_ports[3])
);

// Per-port memory read controllers
memory_read_ctrl mem_rd_p0 (
    .clk(switch_clk),
    .rst_n(rst_n),
    .re_i(egress_idles[0]),
    .start(egress_idles[0] & voq_valids[0]),
    .start_addr_i(egress_mem_ptrs[0]),
    .mem_re_o(),
    .mem_raddr_o(),
    .mem_rvalid_i(1'b1),
    .mem_rdata_i(sram_b_rdata),
    .data_o(egress_byte_ins[0]),
    .data_valid_o(egress_byte_valids[0]),
    .data_end_o(egress_eofs[0])
);

memory_read_ctrl mem_rd_p1 (
    .clk(switch_clk),
    .rst_n(rst_n),
    .re_i(egress_idles[1]),
    .start(egress_idles[1] & voq_valids[1]),
    .start_addr_i(egress_mem_ptrs[1]),
    .mem_re_o(),
    .mem_raddr_o(),
    .mem_rvalid_i(1'b1),
    .mem_rdata_i(sram_b_rdata),
    .data_o(egress_byte_ins[1]),
    .data_valid_o(egress_byte_valids[1]),
    .data_end_o(egress_eofs[1])
);

memory_read_ctrl mem_rd_p2 (
    .clk(switch_clk),
    .rst_n(rst_n),
    .re_i(egress_idles[2]),
    .start(egress_idles[2] & voq_valids[2]),
    .start_addr_i(egress_mem_ptrs[2]),
    .mem_re_o(),
    .mem_raddr_o(),
    .mem_rvalid_i(1'b1),
    .mem_rdata_i(sram_b_rdata),
    .data_o(egress_byte_ins[2]),
    .data_valid_o(egress_byte_valids[2]),
    .data_end_o(egress_eofs[2])
);

memory_read_ctrl mem_rd_p3 (
    .clk(switch_clk),
    .rst_n(rst_n),
    .re_i(egress_idles[3]),
    .start(egress_idles[3] & voq_valids[3]),
    .start_addr_i(egress_mem_ptrs[3]),
    .mem_re_o(),
    .mem_raddr_o(),
    .mem_rvalid_i(1'b1),
    .mem_rdata_i(sram_b_rdata),
    .data_o(egress_byte_ins[3]),
    .data_valid_o(egress_byte_valids[3]),
    .data_end_o(egress_eofs[3])
);

tx_mac_control port1_egress (
    .gmii_tx_clk_o(gmii_tx_clk_o[0]),
    .gmii_tx_data_o(gmii_tx_data_o[0]),
    .gmii_tx_en_o(gmii_tx_en_o[0]),
    .gmii_tx_er_o(gmii_tx_er_o[0]),

    .switch_clk(switch_clk),
    .switch_rst_n(rst_n),

    .frame_data_i(egress_byte_ins[0]),
    .frame_valid_i(egress_byte_valids[0]),
    .frame_eof_i(egress_eofs[0]),
    .mem_ptr_o(egress_mem_ptrs[0]),

    .voq_valid_i(voq_valids[0]),
    .voq_ptr_i(voq_ptrs[0]),
    .voq_ready_o(egress_idles[0]));

tx_mac_control port2_egress (
    .gmii_tx_clk_o(gmii_tx_clk_o[1]),
    .gmii_tx_data_o(gmii_tx_data_o[1]),
    .gmii_tx_en_o(gmii_tx_en_o[1]),
    .gmii_tx_er_o(gmii_tx_er_o[1]),

    .switch_clk(switch_clk),
    .switch_rst_n(rst_n),

    .frame_data_i(egress_byte_ins[1]),
    .frame_valid_i(egress_byte_valids[1]),
    .frame_eof_i(egress_eofs[1]),
    .mem_ptr_o(egress_mem_ptrs[1]),

    .voq_valid_i(voq_valids[1]),
    .voq_ptr_i(voq_ptrs[1]),
    .voq_ready_o(egress_idles[1]));

tx_mac_control port3_egress (
    .gmii_tx_clk_o(gmii_tx_clk_o[2]),
    .gmii_tx_data_o(gmii_tx_data_o[2]),
    .gmii_tx_en_o(gmii_tx_en_o[2]),
    .gmii_tx_er_o(gmii_tx_er_o[2]),

    .switch_clk(switch_clk),
    .switch_rst_n(rst_n),

    .frame_data_i(egress_byte_ins[2]),
    .frame_valid_i(egress_byte_valids[2]),
    .frame_eof_i(egress_eofs[2]),
    .mem_ptr_o(egress_mem_ptrs[2]),

    .voq_valid_i(voq_valids[2]),
    .voq_ptr_i(voq_ptrs[2]),
    .voq_ready_o(egress_idles[2]));

tx_mac_control port4_egress (
    .gmii_tx_clk_o(gmii_tx_clk_o[3]),
    .gmii_tx_data_o(gmii_tx_data_o[3]),
    .gmii_tx_en_o(gmii_tx_en_o[3]),
    .gmii_tx_er_o(gmii_tx_er_o[3]),

    .switch_clk(switch_clk),
    .switch_rst_n(rst_n),

    .frame_data_i(egress_byte_ins[3]),
    .frame_valid_i(egress_byte_valids[3]),
    .frame_eof_i(egress_eofs[3]),
    .mem_ptr_o(egress_mem_ptrs[3]),

    .voq_valid_i(voq_valids[3]),
    .voq_ptr_i(voq_ptrs[3]),
    .voq_ready_o(egress_idles[3]));

// Per-port VOQs
voq voq_p0 (
    .clk(switch_clk), .rst_n(rst_n),
    .write_req_i(1'b0), .ptr_i('0),
    .read_req_i(egress_idles[0]),
    .ptr_o(voq_ptrs[0]), .ptr_valid_o(voq_valids[0])
);
voq voq_p1 (
    .clk(switch_clk), .rst_n(rst_n),
    .write_req_i(1'b0), .ptr_i('0),
    .read_req_i(egress_idles[1]),
    .ptr_o(voq_ptrs[1]), .ptr_valid_o(voq_valids[1])
);
voq voq_p2 (
    .clk(switch_clk), .rst_n(rst_n),
    .write_req_i(1'b0), .ptr_i('0),
    .read_req_i(egress_idles[2]),
    .ptr_o(voq_ptrs[2]), .ptr_valid_o(voq_valids[2])
);
voq voq_p3 (
    .clk(switch_clk), .rst_n(rst_n),
    .write_req_i(1'b0), .ptr_i('0),
    .read_req_i(egress_idles[3]),
    .ptr_o(voq_ptrs[3]), .ptr_valid_o(voq_valids[3])
);

// Single shared SRAM
// Arbiter: pick which port writes to SRAM and arbitrate free-list
arbiter #(.NUM_PORTS(NUM_PORTS)) arb_inst (
    .clk(switch_clk),
    .rst_n(rst_n),

    .mem_we_i(mem_we_ports),
    .mem_addr_i(mem_addr_ports),
    .mem_wdata_i(mem_wdata_ports),
    .mem_gnt_o(mem_gnt_ports),

    .mem_we_o(sram_a_we),
    .mem_addr_o(sram_a_addr),
    .mem_wdata_o(sram_a_wdata),

    .fl_alloc_req_i(fl_alloc_req_ports),
    .fl_alloc_gnt_o(fl_alloc_gnt_ports),
    .fl_alloc_block_idx_o(fl_alloc_idx_ports),

    .fl_alloc_req_o(arb_fl_alloc_req_o),
    .fl_alloc_gnt_i(arb_fl_alloc_gnt_i),
    .fl_alloc_block_idx_i(arb_fl_alloc_block_idx_i),

    .rx_mac_src_addr_i(ingress_src_addrs),
    .rx_mac_dst_addr_i(ingress_dst_addrs),
    .data_start_addr_i(data_start_addr_i),
    .eop_i(ingress_eofs),

    .port_o(arb_port_o),
    .rx_mac_src_addr_o(arb_rx_mac_src_addr_o),
    .rx_mac_dst_addr_o(arb_rx_mac_dst_addr_o),
    .data_start_addr_o(arb_data_start_addr_o),
    .eop_o(arb_eop_o)
);

// Single shared SRAM - A-side driven by arbiter outputs
sram sram_inst (
    .clk(switch_clk),
    .a_we(sram_a_we),
    .a_addr(sram_a_addr),
    .a_wdata(sram_a_wdata),
    .a_rdata(sram_a_rdata),
    .b_we(1'b0),
    .b_addr('0),
    .b_wdata({BLOCK_BITS{1'b0}}),
    .b_rdata(sram_b_rdata)
);

// Free list
// Free list - connect to arbiter free-list handshake
fl fl_inst (
    .clk(switch_clk), .rst_n(rst_n),
    .alloc_req_i(arb_fl_alloc_req_o),
    .alloc_gnt_o(arb_fl_alloc_gnt_i),
    .alloc_block_idx_o(arb_fl_alloc_block_idx_i),
    .free_req_i(1'b0), .free_block_idx_i('0)
);

// Address table (single instance)
address_table #(.NUM_PORTS(NUM_PORTS)) addr_table (
    .clk(switch_clk), .rst_n(rst_n),
    .learn_req_i(1'b0), .learn_address_i(48'd0), .learn_port_i(0),
    .read_req_i(1'b0), .read_address_i(0),
    .read_port_o(), .read_port_valid_o()
);

// Translator (single instance)
translator #(.NUM_PORTS(NUM_PORTS)) translator_inst (
    .clk(switch_clk), .rst_n(rst_n),
    .start_ptr_i('0), .dest_addr_i(48'd0), .input_valid_i(1'b0),
    .address_port_i(0), .address_port_valid_i(1'b0),
    .address_learn_enable_o(), .address_learn_address_o(),
    .write_reqs_o(), .start_ptrs_o()
);

endmodule
