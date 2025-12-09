module outputs #(
    parameter ADDR_W = mem_pkg::ADDR_W,
    parameter BLOCK_BYTES = mem_pkg::BLOCK_BYTES,
    parameter BLOCK_BITS = mem_pkg::BLOCK_BITS,
    parameter NUM_PORTS = switch_pkg::NUM_PORTS
) (
    // Switch Clock Domain
    input logic switch_clk, switch_rst_n,

    // Memory read arbiter connections
    input logic arbiter_mem_rvalid [NUM_PORTS-1:0],
    input logic [BLOCK_BYTES-1:0][DATA_WIDTH-1:0] arbiter_mem_rdata [NUM_PORTS-1:0],
    output logic [ADDR_W-1:0] memory_read_ctrl_addr [NUM_PORTS-1:0],
    output logic memory_read_ctrl_re [NUM_PORTS-1:0],

    // Free list connections
    output logic memory_read_ctrl_free_req [NUM_PORTS-1:0],
    output logic [ADDR_W-1:0] memory_read_ctrl_free_block_idx [NUM_PORTS-1:0],

    // Inputs from crossbar
    input logic [NUM_PORTS-1:0] crossbar_voq_write_reqs,
    input logic [ADDR_W-1:0] crossbar_voq_start_ptrs [NUM_PORTS-1:0],

    // GMII Outputs
    output logic gmii_tx_clk_o [NUM_PORTS-1:0],
    output logic [DATA_WIDTH-1:0] gmii_tx_data_o [NUM_PORTS-1:0],
    output logic gmii_tx_en_o [NUM_PORTS-1:0],
    output logic gmii_tx_er_o [NUM_PORTS-1:0]
);

import rx_tx_pkg::*;

// Wires from egress
logic egress_re [NUM_PORTS-1:0];
logic egress_start [NUM_PORTS-1:0];
logic [ADDR_W-1:0] egress_addr [NUM_PORTS-1:0];

// Wires from memory_read_ctrl
logic [BLOCK_BITS-1:0] memory_read_ctrl_data [NUM_PORTS-1:0];
logic memory_read_ctrl_data_valid [NUM_PORTS-1:0];
logic memory_read_ctrl_data_end [NUM_PORTS-1:0];

genvar p;

// NUM_PORTS x memory_read_ctrl
generate
    for (p = 0; p < NUM_PORTS; p++) begin : GEN_MEM_R
        memory_read_ctrl memory_read_ctrl_u (
            .clk(switch_clk),
            .rst_n(switch_rst_n),

            // memory write data, 1 byte / 8 bit beats
            .re_i(egress_re[p]),
            .start(egress_start[p]),
            .start_addr_i(egress_addr[p]),
            
            // to memory
            .mem_re_o(memory_read_ctrl_re[p]),
            .mem_raddr_o(memory_read_ctrl_addr[p]),

            // from memory (1 cycle later)
            .mem_rvalid_i(arbiter_mem_rvalid[p]),
            .mem_rdata_i(arbiter_mem_rdata[p]),

            // interface with consumer
            .data_o(memory_read_ctrl_data[p]), // unused
            .data_valid_o(memory_read_ctrl_data_valid[p]), // unused
            .data_end_o(memory_read_ctrl_data_end[p]), // unused

            // interface with free list to free
            .free_req_o(memory_read_ctrl_free_req[p]),
            .free_block_idx_o(memory_read_ctrl_free_block_idx[p])
        );
    end
endgenerate  

// NUM_PORTS x egress
generate
    for (p = 0; p < NUM_PORTS; p++) begin : GEN_EGRESS
        egress #(.ADDR_W(ADDR_W)) egress_u (
            .gmii_tx_clk_o(gmii_tx_clk_o[p]),
            .gmii_tx_data_o(gmii_tx_data_o[p]),
            .gmii_tx_en_o(gmii_tx_en_o[p]),
            .gmii_tx_er_o(gmii_tx_er_o[p]),
            .switch_clk(switch_clk),
            .switch_rst_n(switch_rst_n),
            .voq_write_req_i(crossbar_voq_write_reqs[p]),
            .voq_ptr_i(crossbar_voq_start_ptrs[p]),
            .mem_re_o(egress_re[p]),
            .mem_start_o(egress_start[p]),
            .mem_start_addr_o(egress_addr[p]),
            .frame_data_i(memory_read_ctrl_data[p]),
            .frame_valid_i(memory_read_ctrl_data_valid[p]),
            .frame_end_i(memory_read_ctrl_data_end[p])
        );
    end
endgenerate  
    
endmodule
