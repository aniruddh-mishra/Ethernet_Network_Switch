import mem_pkg::*;

module translator #(
    parameter int NUM_PORTS = 4
) (
    input logic clk, rst_n,
    input logic [ADDR_W-1:0] start_ptr_i,
    input logic [47:0] dest_addr_i,
    input logic input_valid_i,
    input logic [$clog2(NUM_PORTS)-1:0] address_port_i,
    input logic address_port_valid_i,
    output logic address_learn_enable_o,
    output logic address_learn_address_o,
    output logic [NUM_PORTS-1:0] write_reqs_o,
    output logic [NUM_PORTS-1:0][ADDR_W-1:0] start_ptrs_o
);

logic [ADDR_W-1:0] start_ptr_o;
logic next_valid;

always_ff @(posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        next_valid <= 1'b0;
        write_reqs_o <= 0;
        address_learn_enable_o <= 1'b0;
    end else begin
        if (next_valid) begin
            if (address_port_valid_i) begin
                write_reqs_o[address_port_i] <= 1'b1;
                start_ptrs_o[address_port_i] <= start_ptr_o;
            end else begin
                for (i; i < NUM_PORTS; i = i+1) begin // Flooding
                    write_reqs_o[i] <= 1'b1;
                    start_ptrs_o[i] <= start_ptr_o;
                end
            end
        end
        if (input_valid_i) begin
            next_valid <= 1'b1;
            address_learn_address_o <= dest_addr_i;
            address_learn_enable_o <= 1'b1;
        end else begin
            next_valid <= 1'b0;
            address_learn_enable_o <= 1'b0;
        end
    end
end
    
endmodule