// arbiter

module arbiter #(
    parameter int N=switch_pkg::NUM_PORTS,
    parameter int BLOCK_BITS=mem_pkg::BLOCK_BITS,
    parameter int ADDR_W=mem_pkg::ADDR_W
) (
    input clk,
    input logic rst_n,

    //// Memory write port arbitration ////
    input logic mem_we_i [N-1:0],
    input logic [ADDR_W-1:0] mem_waddr_i [N-1:0],
    input logic [BLOCK_BITS-1:0] mem_wdata_i [N-1:0],

    // output to memory write controller
    output logic mem_gnt_o [N-1:0], 

    // output to memory
    output logic mem_we_o,
    output logic [ADDR_W-1:0] mem_waddr_o,
    output logic [BLOCK_BITS-1:0] mem_wdata_o,
    //// Memory write port arbitration ////

    //// Free list allocation arbitration ////
    // from memory write controller
    input logic fl_alloc_req_i [N-1:0],
    
    // to memory write controller
    output logic fl_alloc_gnt_o [N-1:0],
    output logic [ADDR_W-1:0] fl_alloc_block_idx_o [N-1:0],

    // to fl
    output logic fl_alloc_req_o,
    output logic flood_o,

    // from fl
    input logic fl_alloc_gnt_i,
    input logic [ADDR_W-1:0] fl_alloc_block_idx_i,
    //// Free list allocation arbitration ////

    //// Address learn table arbitration ////
    // From rx mac control
    input logic [47:0] rx_mac_src_addr_i [N-1:0],
    input logic [47:0] rx_mac_dst_addr_i [N-1:0],
    input logic [ADDR_W-1:0] data_start_addr_i [N-1:0],
    input logic data_error_i [N-1:0],
    input logic eop_i [N-1:0],
    input logic sof_i [N-1:0],

    // to address learn table
    output logic [$clog2(N)-1:0] port_o,
    output logic [47:0] rx_mac_src_addr_o,
    output logic [47:0] rx_mac_dst_addr_o,
    output logic [ADDR_W-1:0] data_start_addr_o,
    output logic eop_o, 
    //// Address learn table arbitration ////

    //// memory read control arbitration ////
    // from memory read ctrl
    input logic mem_re_i [N-1:0],
    input logic [ADDR_W-1:0] mem_raddr_i [N-1:0],
    input logic flood_i [N-1:0],
    
    // to memory
    output logic mem_re_o,
    output logic [ADDR_W-1:0] mem_raddr_o,

    // from memory
    input logic mem_rvalid_i,
    input logic [BLOCK_BITS-1:0] mem_rdata_i, // 

    // to memory read ctrl
    output logic mem_rvalid_o [N-1:0],
    output logic [BLOCK_BITS-1:0] mem_rdata_o [N-1:0],

    // freeing logic sent read controller
    input logic free_req_i [N-1:0],
    input logic [ADDR_W-1:0] free_block_idx_i [N-1:0],

    // free signal to fl
    output logic free_req_o,
    output logic [ADDR_W-1:0] free_block_idx_o
);  
    import mem_pkg::*;
    logic [$clog2(N)-1:0] cur;

    logic [N-1:0] eop_ack;
    logic latched_mem_re [N-1:0];
    logic latched_fl_alloc_req [N-1:0];

     //// Memory write port arbitration ////
    assign mem_we_o = mem_we_i[cur];
    assign mem_waddr_o = mem_waddr_i[cur];
    assign mem_wdata_o = mem_wdata_i[cur];
    
    always_comb begin
        mem_gnt_o = '{default:0};
        mem_gnt_o[cur+1] = 1;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cur <= 3;
        end
        else begin
            cur <= cur + 1;
        end
    end
    //// Memory write port arbitration ////

    //// Free list allocation arbitration ////
    logic [$clog2(N)-1:0] cur_fl_alloc_port; // allocations must happen in order
    
    always_comb begin
        fl_alloc_block_idx_o[cur_fl_alloc_port] = fl_alloc_block_idx_i;
        fl_alloc_req_o = fl_alloc_gnt_i ? fl_alloc_req_i[cur_fl_alloc_port+1] : fl_alloc_req_i[cur_fl_alloc_port]; 

        fl_alloc_gnt_o = '{default:0}; 
        fl_alloc_gnt_o[cur_fl_alloc_port] = fl_alloc_gnt_i;
    end

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cur_fl_alloc_port <= 0;
            latched_fl_alloc_req[0] <= 0;
            latched_fl_alloc_req[1] <= 0;
            latched_fl_alloc_req[2] <= 0;
            latched_fl_alloc_req[3] <= 0;
        end
        else begin
            latched_fl_alloc_req <= fl_alloc_req_i;
            if (latched_fl_alloc_req[cur_fl_alloc_port]) begin
                if (fl_alloc_gnt_i) 
                    cur_fl_alloc_port <= cur_fl_alloc_port + 1;
            end
            else begin
                if (!fl_alloc_req_i[cur_fl_alloc_port])
                    cur_fl_alloc_port <= cur_fl_alloc_port + 1;
            end
        end
    end
    //// Free list allocation arbitration ////

    //// Address learn table arbitration ////
    assign port_o = cur;
    assign rx_mac_src_addr_o = rx_mac_src_addr_i[cur];
    assign rx_mac_dst_addr_o = rx_mac_dst_addr_i[cur];
    assign data_start_addr_o = data_start_addr_i[cur];
    assign eop_o = eop_i[cur] & ~eop_ack[cur] & ~data_error_i[cur];

    //// memory read control arbitration ////
    logic [$clog2(N)-1:0] cur_mem_read_port;

    assign free_req_o = free_req_i[cur_mem_read_port - 1];
    // assign free_req_o = 0;
    assign free_block_idx_o = free_block_idx_i[cur_mem_read_port - 1];
    assign flood_o = flood_i[cur_mem_read_port - 1];

    always_comb begin
        mem_rvalid_o = '{default:0};
        mem_rvalid_o[cur_mem_read_port] = mem_rvalid_i;

        mem_rdata_o[cur_mem_read_port] = mem_rdata_i;
        mem_raddr_o = mem_rvalid_i ? mem_raddr_i[cur_mem_read_port + 1] : mem_raddr_i[cur_mem_read_port];
        mem_re_o = mem_rvalid_i ? mem_re_i[cur_mem_read_port + 1] : mem_re_i[cur_mem_read_port];
    end 

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            cur_mem_read_port <= 0;
            eop_ack <= 0;
            latched_mem_re[0] <= 0;
            latched_mem_re[1] <= 0;
            latched_mem_re[2] <= 0;
            latched_mem_re[3] <= 0;
        end
        else begin
            latched_mem_re <= mem_re_i;
            if (latched_mem_re[cur_mem_read_port]) begin
                if (mem_rvalid_i)
                    cur_mem_read_port <= cur_mem_read_port + 1;
            end
            else begin
                if (!mem_re_i[cur_mem_read_port])
                    cur_mem_read_port <= cur_mem_read_port + 1;
            end
            if (eop_i[cur]) eop_ack[cur] <= 1;
            else eop_ack[cur] <= 0;
        end
    end
endmodule
