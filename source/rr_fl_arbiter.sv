module rr_fl_arbiter #(
     parameter int N=4
) (
    input logic clk,
    input logic rst_n,

    // from memory write controller
    input logic [N-1:0] fl_alloc_req_i,
    
    // to memory write controller
    output logic [N-1:0] fl_alloc_gnt_o,
    output logic [ADDR_W-1:0] fl_alloc_block_idx_o [N-1:0],

    // to fl
    output logic fl_alloc_req_o,

    // from fl
    input logic fl_alloc_gnt_i,
    input logic [ADDR_W-1:0] fl_alloc_block_idx_i
);
    import mem_pkg::*;

    logic [$clog2(N)-1:0] cur;
    logic [N-1:0] local_fl_alloc_req;

    assign fl_alloc_req_o = fl_alloc_req_i[cur];
    assign fl_alloc_block_idx_o[cur] = fl_alloc_block_idx_i;
    
    always_comb begin
        fl_alloc_gnt_o = 0; 

        if (local_fl_alloc_req[cur])
            fl_alloc_gnt_o[cur] = fl_alloc_gnt_i;
        
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cur <= 0;
            local_fl_alloc_req <= 0;
        end
        else begin
            local_fl_alloc_req <= fl_alloc_req_i;
            cur <= cur + 1;
        end
    end
endmodule
