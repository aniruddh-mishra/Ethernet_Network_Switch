module address_learn (
    parameter integer NUM_PORTS = 8, // Assumes a maximum number of ports
    parameter integer NUM_ENTRIES = 1024;
)

parameter STATE_IDLE = 1'b0;
parameter STATE_LEARN = 1'b1;

input logic clk;
input logic reset;

input logic source_address_valid_i [NUM_PORTS-1:0] ; // One learn enable per port
input logic [48:0] source_address_i [NUM_PORTS-1:0]; // ingress sender address

input logic [48:0] table_addresses [NUM_ENTRIES-1:0];
input logic [$clog2(NUM_PORTS)-1:0] table_ports [NUM_ENTRIES-1:0];
input logic table_usage [NUM_ENTRIES-1:0];
input logic [$clog2(NUM_ENTRIES)-1:0] table_hits [NUM_ENTRIES-1:0];

logic state;
logic [$clog2(NUM_PORTS)-1:0] active_learn_port;

// Priority encoder function
function [1:0] priority_encoder(logic in [NUM_ENTRIES-1:0])
    for (i=0; i<(NUM_ENTRIES - 1); i=i+1) begin
        if (in[i]) begin
            return [1, i];
        end
    end
    return [0, 0];
endfunction

function bit min_used(logic in [NUM_ENTRIES-1:0])
    int smallest = in[0];
    int return_address = 0;
    for (i=0; i<(NUM_ENTRIES - 1); i=i+1) begin
        if (in[i] <= smallest) begin
            smallest = in[i];
            return_address = i;
        end
    end
    return return_address;
endfunction

always_comb begin // Priority encoder for port select
    table_space, next_address = priority_encoder(table_usage, NUM_ENTRIES);
    if (!table_space) begin
        next_address = min_used(table_hits, NUM_ENTRIES);
    end
end

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        state <= STATE_IDLE;
        table_usage <= '{default: '0};
    end 
    else begin
        case (state)
            STATE_IDLE: begin
                if (source_address_valid_i != 0) state <= STATE_LEARN;
            end
            STATE_LEARN: begin
                for (i=0; i<($clog2(NUM_PORTS)); i=i+1) begin
                    if (source_address_valid_i[i] && (i > active_learn_port || active_learn_port == (NUM_PORTS - 1))) begin
                        active_learn_port <= i; // Learn port increments to next active learn port unless at max port index
                        logic found = 0;
                        for (j=0; j<NUM_ENTRIES; j=j+1) begin
                            if (table_addresses[j] == source_address_i[i]) begin
                                if (table_ports[j] == i + 1) begin
                                    found = 1;
                                    break;
                                end
                                else begin
                                    table_usage[j] <= 0; // Address port information has changed
                                    break;
                                end
                            end
                        end
                        if (found == 1) begin
                            table_addresses[next_address] <= source_address_i[i];
                            table_usage[next_address] <= 1'b1;
                            table_ports[next_address] <= i + 1; // Port # is stored in the table.
                            table_hits[next_address] <= 0;
                        end
                        break;
                    end
                end
                if (source_address_valid_i == 0) state <= STATE_IDLE;
            end
        endcase
    end
end

endmodule;