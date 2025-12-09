module crossbar #(
    parameter int NUM_PORTS = 4,
    parameter int ADDR_W = 12
) (
    input logic clk, rst_n,
    input eof_i,
    input logic [$clog2(NUM_PORTS)-1:0] ingress_port_i,
    input logic [47:0] rx_mac_src_addr_i,
    input logic [47:0] rx_mac_dst_addr_i,
    input logic [ADDR_W-1:0] data_start_ptr_i,
    output logic [NUM_PORTS-1:0] voq_write_reqs_o,
    output logic [ADDR_W-1:0] voq_start_ptrs_o [NUM_PORTS-1:0]
);

    // Wires between translator and address table
    logic address_table_read_req;
    logic address_table_read_address_valid;
    logic [47:0] address_table_read_address;
    logic [$clog2(NUM_PORTS)-1:0] address_table_read_port;

    // DUTs
    address_table #(.NUM_PORTS(NUM_PORTS)) addr_table (
        .clk(clk), .rst_n(rst_n),
        .learn_req_i(eof_i),
        .learn_address_i(rx_mac_src_addr_i),
        .learn_port_i(ingress_port_i),
        .read_req_i(address_table_read_req),
        .read_address_i(address_table_read_address),
        .read_port_o(address_table_read_port),
        .read_port_valid_o(address_table_read_address_valid)
    );

    translator #(.NUM_PORTS(NUM_PORTS), .ADDR_W(ADDR_W)) translator_inst (
        .clk(clk), .rst_n(rst_n),
        .start_ptr_i(data_start_ptr_i),
        .dest_addr_i(rx_mac_dst_addr_i),
        .input_valid_i(eof_i),
        .address_port_i(address_table_read_port),
        .address_port_valid_i(address_table_read_address_valid),
        .address_learn_enable_o(address_table_read_req),
        .address_learn_address_o(address_table_read_address),
        .write_reqs_o(voq_write_reqs_o),
        .start_ptrs_o(voq_start_ptrs_o)
    );

endmodule
