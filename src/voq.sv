module voq #(
    parameter int ADDR_W = mem_pkg::ADDR_W
)(
    input logic clk, rst_n,
    input logic write_req_i,
    input logic [ADDR_W-1:0] ptr_i,
    input logic read_req_i,
    input logic flood_i,
    output logic [ADDR_W-1:0] ptr_o,
    output logic ptr_valid_o,
    output logic flood_o
);

import voq_pkg::*;

typedef enum logic[1:0] {STATE_EMPTY, STATE_NORMAL, STATE_FULL} state_t;

state_t state;
logic [$clog2(VOQ_DEPTH)-1:0] voq_r_ptr;
logic [$clog2(VOQ_DEPTH)-1:0] voq_w_ptr;
logic [ADDR_W-1:0] voq_table [VOQ_DEPTH-1:0];
logic floods [VOQ_DEPTH-1:0];

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        voq_r_ptr <= 0;
        state <= STATE_EMPTY;
        ptr_valid_o <= 1'b0;
    end
    else begin
        case (state)
            STATE_EMPTY: begin
                ptr_valid_o <= 1'b0;
                if (write_req_i) begin
                    if (read_req_i) begin
                        // simultaneous write and read
                        ptr_o <= ptr_i;
                        flood_o <= flood_i;
                        ptr_valid_o <= 1'b1;
                    end
                    else begin
                        voq_table[voq_w_ptr] <= ptr_i;
                        floods[voq_w_ptr] <= flood_i;
                        voq_w_ptr <= voq_w_ptr + 1;
                        state <= STATE_NORMAL;
                    end
                end
            end
            STATE_NORMAL: begin
                if (write_req_i) begin
                    voq_table[voq_w_ptr] <= ptr_i;
                    floods[voq_w_ptr] <= flood_i;
                    if (voq_w_ptr + 1 == voq_r_ptr && !read_req_i) state <= STATE_FULL;
                    voq_w_ptr <= voq_w_ptr + 1;
                end
                if (read_req_i) begin
                    ptr_o <= voq_table[voq_r_ptr];
                    flood_o <= floods[voq_r_ptr];
                    ptr_valid_o <= 1'b1;
                    if (voq_r_ptr + 1 == voq_w_ptr && !write_req_i) state <= STATE_EMPTY;
                    voq_r_ptr <= voq_r_ptr + 1;
                end
                else ptr_valid_o <= 1'b0;
            end
            STATE_FULL: begin
                if (read_req_i) begin
                    ptr_o <= voq_table[voq_r_ptr];
                    flood_o <= floods[voq_r_ptr];
                    ptr_valid_o <= 1'b1;
                    voq_r_ptr <= voq_r_ptr + 1;
                    if (write_req_i) begin
                        voq_table[voq_w_ptr] <= ptr_i;
                        floods[voq_w_ptr] <= flood_i;
                        voq_w_ptr <= voq_w_ptr + 1;
                    end 
                    else state <= STATE_NORMAL;
                end
                else ptr_valid_o <= 1'b0;
            end
            default: state <= STATE_EMPTY;
        endcase
    end
end

endmodule
