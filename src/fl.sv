// free list

module fl (
    input logic clk,
    input logic rst_n,

    // alloc
    input logic alloc_req_i,
    output logic alloc_gnt_o,
    output logic [ADDR_W-1:0] alloc_block_idx_o,
   
    // free
    input logic free_req_i,
    input logic [ADDR_W-1:0] free_block_idx_i
);
    import mem_pkg::*;
    logic [ADDR_W-1:0] stack [NUM_BLOCKS+1];
    logic [ADDR_W:0] sp; // stack index is 1 wider
    // sp points to top of stack

    logic empty, full;
    assign empty = sp == 0;
    assign full = {25'b0, sp} == NUM_BLOCKS;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sp <= NUM_BLOCKS[ADDR_W:0];
            // 0th entry unused
            for (int i = 0; i < NUM_BLOCKS; i++) begin
                stack[i+1] <= i[ADDR_W-1:0];
            end
        end
        else begin
            alloc_gnt_o <= 0;
            if (alloc_req_i && free_req_i) begin
                // sp not updated
                alloc_block_idx_o <= free_block_idx_i;
                alloc_gnt_o <= 1;
            end
            else if (alloc_req_i && !empty) begin
                // pop from stack
                alloc_block_idx_o <= stack[sp];
                sp <= sp - 1;
                alloc_gnt_o <= 1;
            end
            else if (free_req_i && !full) begin
                // push to stack
                stack[sp + 1] <= free_block_idx_i;
                sp <= sp + 1;
            end
        end
    end
endmodule
