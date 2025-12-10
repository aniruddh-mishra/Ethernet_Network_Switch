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
    input logic [ADDR_W-1:0] free_block_idx_i,
    input logic flood
);
    import mem_pkg::*;

    logic [ADDR_W-1:0] stack [NUM_BLOCKS+1];
    logic [ADDR_W:0]   sp; // stack index is 1 wider
    // sp points to top of stack

    // Per-block flood counters
    logic [2:0] free_cnt [NUM_BLOCKS-1:0];

    logic empty, full;
    assign empty = (sp == 0);
    assign full  = (sp == NUM_BLOCKS[ADDR_W:0]);

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            sp <= NUM_BLOCKS[ADDR_W:0];

            // 0th entry unused
            for (int i = 0; i < NUM_BLOCKS; i++) begin
                stack[i+1] <= i[ADDR_W-1:0];
            end

            for (int i = 0; i < NUM_BLOCKS; i++) begin
                free_cnt[i] <= 0;
            end

            alloc_gnt_o <= 0;
            alloc_block_idx_o <= 0;
        end
        else begin
            alloc_gnt_o <= 0;

            // alloc and free
            if (alloc_req_i && free_req_i) begin
                if (!flood) begin
                    alloc_block_idx_o <= free_block_idx_i;
                    alloc_gnt_o <= 1;

                    free_cnt[free_block_idx_i] <= 0;
                end
                else begin
                    if (free_cnt[free_block_idx_i] == 3) begin
                        // on 4th free , ungate
                        alloc_block_idx_o <= free_block_idx_i;
                        alloc_gnt_o <= 1;

                        free_cnt[free_block_idx_i] <= 0;
                    end
                    else begin
                        // not enough frees yet
                        free_cnt[free_block_idx_i] <= free_cnt[free_block_idx_i] + 1;

                        if (!empty) begin
                            alloc_block_idx_o <= stack[sp];
                            sp <= sp - 1;
                            alloc_gnt_o <= 1;
                        end
                    end
                end
            end

            // alloc only
            else if (alloc_req_i && !empty) begin
                alloc_block_idx_o <= stack[sp];
                sp <= sp - 1;
                alloc_gnt_o <= 1;
            end
            
            // free only
            else if (free_req_i && !full) begin
                if (!flood) begin
                    stack[sp + 1] <= free_block_idx_i;
                    sp <= sp + 1;

                    free_cnt[free_block_idx_i] <= 0;
                end
                else begin
                    if (free_cnt[free_block_idx_i] == 3) begin
                        stack[sp + 1] <= free_block_idx_i;
                        sp <= sp + 1;

                        free_cnt[free_block_idx_i] <= 0;
                    end
                    else begin
                        free_cnt[free_block_idx_i] <= free_cnt[free_block_idx_i] + 1;
                    end
                end
            end
        end
    end
endmodule
