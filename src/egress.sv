module egress #(
    parameter ADDR_W = 6,
    parameter BLOCK_BYTES = 64
)(
    // GMII interface
    output logic gmii_tx_clk_o,
    output logic [DATA_WIDTH-1:0] gmii_tx_data_o,
    output logic gmii_tx_en_o,
    output logic gmii_tx_er_o,
    
    // switch's clk domain
    input logic switch_clk,
    input logic switch_rst_n,
    
    // VOQ write interface
    input logic voq_write_req_i,
    input logic [ADDR_W-1:0] voq_ptr_i,
    
    // mem read interface
    output logic mem_re_o,
    output logic mem_start_o,
    output logic [ADDR_W-1:0] mem_start_addr_o,
    input logic [BLOCK_BYTES-1:0][DATA_WIDTH-1:0] frame_data_i,
    input logic frame_valid_i,
    input logic frame_end_i
);

import rx_tx_pkg::*;

// signals between VOQ and TX MAC control
logic tx_mac_control_voq_read_req;
logic [ADDR_W-1:0] voq_ptr_out;
logic voq_ptr_valid;

voq #(.ADDR_W(ADDR_W)) voq_u (
    .clk(switch_clk),
    .rst_n(switch_rst_n),
    .write_req_i(voq_write_req_i),
    .ptr_i(voq_ptr_i),
    .read_req_i(tx_mac_control_voq_read_req),
    .ptr_o(voq_ptr_out),
    .ptr_valid_o(voq_ptr_valid)
);

tx_mac_control #(.BLOCK_BYTES(BLOCK_BYTES)) tx_mac_control_u (
    // GMII interface
    .gmii_tx_clk_o(gmii_tx_clk_o),
    .gmii_tx_data_o(gmii_tx_data_o),
    .gmii_tx_en_o(gmii_tx_en_o),
    .gmii_tx_er_o(gmii_tx_er_o),
    
    // switch's clk domain
    .switch_clk(switch_clk),
    .switch_rst_n(switch_rst_n),
    
    // mem read ctrl interface
    .mem_re_o(mem_re_o),
    .mem_start_o(mem_start_o),
    .mem_start_addr_o(mem_start_addr_o),
    .frame_data_i(frame_data_i),
    .frame_valid_i(frame_valid_i),
    .frame_end_i(frame_end_i),
    
    // VOQ signals
    .voq_valid_i(voq_ptr_valid),
    .voq_ptr_i(voq_ptr_out),
    .voq_ready_o(tx_mac_control_voq_read_req)
);

endmodule
