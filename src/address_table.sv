module address_table #(
    parameter int NUM_PORTS = 4
)(
    input logic clk, rst_n,

    input logic learn_req_i,
    input logic [47:0] learn_address_i, // ingress sender address
    input logic [$clog2(NUM_PORTS)-1:0] learn_port_i,

    input logic read_req_i,
    input logic [47:0] read_address_i,

    output logic [$clog2(NUM_PORTS)-1:0] read_port_o,
    output logic read_port_valid_o
);

import address_table_pkg::*;

logic [$clog2(MAX_HIT)-1:0] table_hits [NUM_ENTRIES-1:0];
logic [47:0] table_addresses [NUM_ENTRIES-1:0];
logic [$clog2(NUM_PORTS)-1:0] table_ports [NUM_ENTRIES-1:0];
logic table_usage [NUM_ENTRIES-1:0];

logic [$clog2(NUM_ENTRIES)-1:0] next_index;
logic address_learn_exists;

always_comb begin // Priority encoder for port select
    next_index = free_index(table_usage, table_hits);

    address_learn_exists = 0;
    for (int i=0; i<NUM_ENTRIES; i=i+1) begin
        if (table_addresses[i] == learn_address_i && table_ports[i] == learn_port_i) begin
            address_learn_exists = 1;
        end
    end
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        read_port_valid_o <= 1'b0;
        table_usage <= '{default: '0};
        table_hits <= '{default: '0};
    end 
    else begin
        read_port_valid_o <= 1'b0;
        if (learn_req_i) begin
            for (int i=0; i<NUM_ENTRIES; i=i+1) begin
                if (table_addresses[i] == learn_address_i && table_ports[i] != learn_port_i) begin
                    table_usage[i] <= 0; // Address port information has changed
                end
            end
            if (!address_learn_exists) begin
                table_addresses[next_index] <= learn_address_i;
                table_usage[next_index] <= 1'b1;
                table_ports[next_index] <= learn_port_i; // Port # is stored in the table.
                table_hits[next_index] <= 1; // Initialize hit count on new learn
            end
        end
        if (read_req_i) begin
            for (int i=0; i<(NUM_ENTRIES); i=i+1) begin
                if (table_addresses[i] == read_address_i) begin
                    read_port_o <= table_ports[i];
                    read_port_valid_o <= 1'b1;
                    if (!(i[$clog2(NUM_ENTRIES)-1:0] == next_index && !address_learn_exists && learn_req_i)) begin // Saturation Counter
                        if (table_hits[i] != {$clog2(MAX_HIT){1'b1}}) table_hits[i] <= table_hits[i] + 1;
                        else table_hits[i] <= (MAX_HIT[$clog2(MAX_HIT)-1:0] - 1);
                    end
                end
                else if (!(i[$clog2(NUM_ENTRIES)-1:0] == next_index && !address_learn_exists && learn_req_i)) begin
                    if (table_hits[i] != 0) table_hits[i] <= table_hits[i] - 1;
                    else table_hits[i] <= 0;
                end
            end
        end
    end
end

endmodule
