module address_table (
    parameter integer NUM_PORTS = 8,
    parameter integer NUM_ENTRIES = 1024;
)

input logic clk;
input logic reset;

input logic [NUM_PORTS-1:0] learn_en_i; // One learn enable per port
input logic [48:0][NUM_PORTS-1:0] mac_addr_learn_i; // ingress sender address
input logic [48:0] mac_addr_read_i;

output logic [$clog2(NUM_PORTS)-1:0] port_num_o;
output logic [NUM_PORTS-1:0] port_valid_o;

logic [48:0] addresses [NUM_ENTRIES-1:0];
logic [$clog2(NUM_PORTS)-1:0] ports [NUM_ENTRIES-1:0];
logic table_usage [NUM_ENTRIES-1:0];
logic learn_port;
logic learn_active;

// Priority encoder function
function [1:0] priority_encoder(logic [NUM_PORTS-1:0] in, integer size) begin
    for (i=0; i<($clog2(size)-1); i=i+1) begin
        if (in[i]) begin
            return [1, i];
        end
    end
    return [0, 0];
endfunction

always_comb begin // Priority encoder for port select
    learn_active, learn_port = priority_encoder(learn_en_i, NUM_PORTS);
end

always_ff @(posedge clk) begin // Priority encoder for port select
    table_space, table_index = priority_encoder(table_usage, NUM_ENTRIES);
    if (!table_space) table_index = evict_entry();
end

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        addresses <= 0;
        ports <= 0;
    end else begin
        if (learn_active) begin
            addresses[table_index] <= mac_addr_i[learn_port];
            ports[table_index] <= table_index;
        end
    end
end

always_ff @(posedge clk) begin // Read table
    port_valid_o = 1'b0;
    if (read_active) begin
        for (i=0; i<NUM_ENTRIES; i=i+1) begin
            if (addresses[i] == mac_addr_read_i) begin
                port_num_o <= ports[i];
                port_valid_o <= 1'b1;
            end
        end
    end
end

// TODO: Add eviction logic

endmodule;