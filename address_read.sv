module address_learn (
    parameter integer NUM_PORTS = 8, // Assumes a maximum number of ports
    parameter integer NUM_ENTRIES = 1024;
)

parameter STATE_IDLE = 1'b0;
parameter STATE_READ = 1'b1;

input logic clk;
input logic reset;

input logic read_en;
input logic read_address;
output logic read_out;
output logic read_out_valid;

input logic [48:0] table_addresses [NUM_ENTRIES-1:0];
input logic [$clog2(NUM_PORTS)-1:0] table_ports [NUM_ENTRIES-1:0];
input logic [$clog2(NUM_ENTRIES)-1:0] table_hits [NUM_ENTRIES-1:0];

logic state;

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        state <= STATE_IDLE;
        table_hits <= '{default: '0};
        read_out_valid = 1'b0;
    end
    else begin
        case (state)
            STATE_IDLE: begin
                if (read_en) state <= STATE_READ;
            end
            STATE_READ: begin
                for (i=0; i<(NUM_ENTRIES); i=i+1) begin
                    if (table_addresses[i] == read_address) begin
                        read_out <= table_ports[i];
                        read_out_valid <= 1'b1;
                        table_hits[i] <= (table_hits[i] + 1 < NUM_ENTRIES) ? table_hits[i] + 1 : table_hits[i] - 5; // Keeps cycling between 5 highest numbers for pseudo random eviction when all entries are max utilized
                    end
                end
                if (!read_en) state <= STATE_IDLE;
            end
        endcase
    end
end

endmodule