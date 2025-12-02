module switch (
    input gmii_clk, switch_clk, rst_n,
    
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
    .voq_ready_o(egress_idles[0])
);

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
    .voq_ready_o(egress_idles[1])
);

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
    .voq_ready_o(egress_idles[2])
);

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
    .voq_ready_o(egress_idles[3])
);

endmodule
