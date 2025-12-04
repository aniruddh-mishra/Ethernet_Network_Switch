// arbiter

module arbiter #(
    parameter int N=4
) (
    input clk,
    input logic rst_n,

    //// Memory write port arbitration ////
    input logic [N-1:0] mem_we_i,
    input logic [ADDR_W-1:0] mem_addr_i [N-1:0],
    input logic [BLOCK_BITS-1:0] mem_wdata_i [N-1:0],

    // output to memory write controller
    output logic [N-1:0] mem_gnt_o, 

    // output to memory
    output logic mem_we_o,
    output logic [ADDR_W-1:0] mem_addr_o,
    output logic [BLOCK_BITS-1:0] mem_wdata_o,
    //// Memory write port arbitration ////

    //// Free list allocation arbitration ////
    // from memory write controller
    input logic [N-1:0] fl_alloc_req_i,
    
    // to memory write controller
    output logic [N-1:0] fl_alloc_gnt_o,
    output logic [ADDR_W-1:0] fl_alloc_block_idx_o [N-1:0],

    // to fl
    output logic fl_alloc_req_o,

    // from fl
    input logic fl_alloc_gnt_i,
    input logic [ADDR_W-1:0] fl_alloc_block_idx_i,
    //// Free list allocation arbitration ////

    //// Address learn table arbitration ////
    // From rx mac control
    input logic [47:0] rx_mac_src_addr_i [N-1:0],
    input logic [47:0] rx_mac_dst_addr_i [N-1:0],
    input logic [ADDR_W-1:0] data_start_addr_i [N-1:0],
    input logic [N-1:0] eop_i,

    // to address learn table
    output logic [$clog2(N)-1:0] port_o,
    output logic [47:0] rx_mac_src_addr_o,
    output logic [47:0] rx_mac_dst_addr_o,
    output logic [ADDR_W-1:0] data_start_addr_o,
    output logic eop_o, 
    //// Address learn table arbitration ////

    //// memory read control arbitration ////
    // from memory read ctrl
    input logic [N-1:0] mem_re_i,
    input logic [ADDR_W-1:0] mem_raddr_i [N-1:0],
    
    // to memory
    output logic mem_re_o,
    output logic [ADDR_W-1:0] mem_raddr_o,

    // from memory
    input logic mem_rvalid_i,
    input logic [BLOCK_BITS-1:0] mem_rdata_i, // 

    // to memory read ctrl
    output logic [N-1:0] mem_rvalid_o,
    output logic [BLOCK_BITS-1:0] mem_rdata_o [N-1:0]
);
    import mem_pkg::*;
    logic [$clog2(N)-1:0] cur;

     //// Memory write port arbitration ////
    assign mem_we_o = mem_we_i[cur];
    assign mem_addr_o = mem_addr_i[cur];
    assign mem_wdata_o = mem_wdata_i[cur];
    
    always_comb begin
        mem_gnt_o = 0;
        mem_gnt_o[cur+1] = 1;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cur <= 0;
        end
        else begin
            cur <= cur + 1;
        end
    end
    //// Memory write port arbitration ////

    //// Free list allocation arbitration ////
    logic [$clog2(N)-1:0] cur_fl_alloc_port; // allocations must happen in order
    logic [N-1:0] fl_alloc_req_latched;

    assign fl_alloc_req_o = fl_alloc_req_i[cur_fl_alloc_port];
    assign fl_alloc_block_idx_o[cur_fl_alloc_port] = fl_alloc_block_idx_i;
    
    always_comb begin
        fl_alloc_gnt_o = 0;
        fl_alloc_gnt_o[cur_fl_alloc_port] = fl_alloc_gnt_i;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cur_fl_alloc_port <= 0;
            fl_alloc_req_latched <= 0;
        end
        else begin
            fl_alloc_req_latched <= fl_alloc_req_i;

            if (fl_alloc_req_latched[cur_fl_alloc_port] && fl_alloc_gnt_i)
                cur_fl_alloc_port <= cur_fl_alloc_port + 1;
        end
    end
    //// Free list allocation arbitration ////

    //// Address learn table arbitration ////
    assign port_o = cur;
    assign rx_mac_src_addr_o = rx_mac_src_addr_i[cur];
    assign rx_mac_dst_addr_o = rx_mac_dst_addr_i[cur];
    assign data_start_addr_o = data_start_addr_i[cur];
    assign eop_o = eop_i[cur];

    //// memory read control arbitration ////
    logic [N-1:0] local_mem_re;

    assign mem_re_o = mem_re_i[cur];
    assign mem_raddr_o = mem_raddr_i[cur];

    always_comb begin
        mem_rvalid_o = 0; 
        mem_rdata_o = 0;

        if (local_mem_re[cur]) begin
            mem_rvalid_o[cur] = mem_rvalid_i;
            mem_rdata_o[cur] = mem_rdata_i;
        end
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            local_mem_re <= 0;
        end
        else begin
            local_mem_re <= mem_re_i;
        end
    end
endmodule
