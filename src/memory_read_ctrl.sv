module memory_read_ctrl (
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
    output logic data_end_o
);  

    logic [BLOCK_BITS-1:0] mem_rdata;
    logic mem_rvalid;

    footer_t footer; 

    logic [2:0] rsvd_unused;
    assign rsvd_unused = footer.rsvd;

    assign footer = footer_t'(mem_rdata[15:0]);

    assign mem_re_o = re_i;
    assign mem_raddr_o = start ? start_addr_i : footer.next_idx;

    assign data_o = mem_rdata;
    assign data_valid_o = mem_rvalid;
    assign data_end_o = footer.eop;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
        end
        else begin
            mem_rvalid <= mem_rvalid_i;

            if (mem_rvalid_i) 
                mem_rdata <= mem_rdata_i;
        end
    end

endmodule

