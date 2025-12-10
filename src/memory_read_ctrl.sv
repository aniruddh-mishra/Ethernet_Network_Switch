// memory read controller

module memory_read_ctrl #(
    parameter int ADDR_W = mem_pkg::ADDR_W,
    parameter int BLOCK_BITS = mem_pkg::BLOCK_BITS
)(
    input logic clk,
    input logic rst_n,

    input logic re_i,
    input logic start,
    input logic [ADDR_W-1:0] start_addr_i,
    
    // to memory
    output logic mem_re_o,
    output logic [ADDR_W-1:0] mem_raddr_o,
    
    // from memory (1 cycle later)
    input logic mem_rvalid_i,
    input logic [BLOCK_BITS-1:0] mem_rdata_i,

    // interface with consumer
    output logic [BLOCK_BITS-1:0] data_o, // 1 block out every cycle
    output logic data_valid_o,
    output logic data_end_o,

    // interface with free list to free
    output logic free_req_o,
    output logic [ADDR_W-1:0] free_block_idx_o
);    
    import mem_pkg::*;
    footer_t footer; 

    logic [BLOCK_BITS-1:0] mem_rdata;
    logic mem_rvalid;

    logic free_req;
    logic [ADDR_W-1:0] free_addr;

    logic rsvd_unused;
    assign rsvd_unused = footer.rsvd;

    assign footer = footer_t'(mem_rdata[15:0]);

    assign mem_re_o = re_i & !mem_rvalid_i;

    logic [ADDR_W-1:0] mem_raddr;

    assign mem_raddr = start ? start_addr_i : footer.next_idx;

    assign mem_raddr_o = mem_raddr;

    assign data_o = mem_rdata;
    assign data_valid_o = mem_rvalid;
    assign data_end_o = footer.eop;

    assign free_block_idx_o = free_addr;
    assign free_req_o = free_req;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            mem_rdata <= 0;
            mem_rvalid <= 0;
            free_req <= 0;
            free_addr <= 0;
        end
        else begin
            mem_rvalid <= mem_rvalid_i;
            free_req <= 0;
            if (mem_re_o)
                free_addr <= mem_raddr;
                
            if (mem_rvalid_i) begin
                mem_rdata <= mem_rdata_i;
                free_req <= 1;
            end
        end
    end

endmodule

