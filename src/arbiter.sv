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

    //// Free list arbitration ////
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
    //// Free list arbitration ////

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
    output logic eop_o
    //// Address learn table arbitration ////
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

    //// Free list arbitration ////
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
            local_fl_alloc_req <= 0;
        end
        else begin
            local_fl_alloc_req <= fl_alloc_req_i;
        end
    end
    //// Free list arbitration ////

    //// Address learn table arbitration ////
    assign port_o = cur;
    assign rx_mac_src_addr_o = rx_mac_src_addr_i[cur];
    assign rx_mac_dst_addr_o = rx_mac_dst_addr_i[cur];
    assign data_start_addr_o = data_start_addr_i[cur];
    assign eop_o = eop_i[cur];
endmodule
