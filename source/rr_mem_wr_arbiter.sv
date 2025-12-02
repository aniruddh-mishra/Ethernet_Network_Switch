// round robin memory arbiter

module rr_mem_wr_arbiter #(
     parameter int N=4
) (
    input logic clk,
    input logic rst_n,

    // from per-port memory write ctrl
    input logic [N-1:0] mem_we_i,
    input logic [ADDR_W-1:0] mem_addr_i [N-1:0],
    input logic [BLOCK_BITS-1:0] mem_wdata_i [N-1:0],
    output logic [N-1:0] mem_gnt_o, // access granted to memory port

    // output to memory
    output logic mem_we_o,
    output logic [ADDR_W-1:0] mem_addr_o,
    output logic [BLOCK_BITS-1:0] mem_wdata_o
);
    import mem_pkg::*;

    logic [$clog2(N)-1:0] cur;

    assign mem_we_o = mem_we_i[cur];
    assign mem_addr_o = mem_addr_i[cur];
    assign mem_wdata_o = mem_wdata_i[cur];
    
    always_comb begin
        mem_gnt_o = 0;
        mem_gnt_o[cur] = 1;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cur <= 0;
        end
        else begin
            cur <= cur + 1;
        end
    end

endmodule
