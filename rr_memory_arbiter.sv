// round robin memory arbiter
import mem_pkg::*;

// N is num ingress ports
module rr_memory_arbiter #(
    parameter int N
) (
    input logic clk,
    input logic rst_n,

    // from ingress port
    input logic [7:0] all_data_i [N-1:0];
    input logic [N-1:0] all_data_valid_i,
    input logic [N-1:0] all_data_begin_i,
    input logic [N-1:0] all_data_end_i,

    // from memory write controller
    input logic mem_wr_ctrl_ready_i,
    
    // to memory write controller
    output logic [7:0] data_o;
    output logic data_valid_o,
    output logic data_begin_o,
    output logic data_end_o,

    output logic [N-1:0] gnt_o
);
    logic [$clog2(N)-1:0] cur;

    always_comb begin
        data_o = 0;
        data_valid_o = 0;
        data_begin_o = 0;
        data_end_o = 0;
        gnt_o = 0;

        if (mem_wr_ctrl_ready_i) begin
            data_o = all_data_i[cur];
            data_valid_o = all_data_valid_i[cur];
            data_begin_o = all_data_begin_i[cur];
            data_end_o = all_data_end_i[cur];
            gnt_o[cur] = 1;
        end
    end


    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cur <= 0;
        end
        else begin
            if (mem_wr_ctrl_ready_i)
                cur <= cur + 1;
        end
    end

endmodule


