// memory read controller
import mem_pkg::*;

module memory_read_ctrl (
    input logic clk,
    input logic rst_n,

    input logic re_i,
    input logic [ADDR_W-1:0] start_addr_i,
    input logic [$clog2(NUM_BLOCKS)-1:0] fetch_size_i, // num blocks
    
    // interface with memory
    output logic mem_re_o,
    output logic mem_raddr_o,
    input logic mem_rvalid_i,
    input logic [BLOCK_BITS-1:0] mem_rdata_i,

    // interface with consumer
    output logic [BLOCK_BITS-1:0] data_o, // 1 block out every cycle
    output logic data_valid_o,
    output logic busy_o
);    
    typedef enum logic [1:0] {IDLE, ACTIVE} state_t;
    state_n state, state_n;

    logic [$clog2(NUM_BLOCKS)-1:0] i;

    assign data_valid_o = mem_rvalid_i;
    assign data_o = mem_rdata_i;

    assign mem_re_o = (state == IDLE && re_i) || (state == ACTIVE && i < fetch_size_i);
    assign mem_raddr_o = start_addr_i + i;

    assign busy_o = state == ACTIVE;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            i <= 0;
            state <= IDLE;
        end 
        else begin
            state <= state_n;
            unique case (state)
                IDLE: begin
                    i <= 0;
                end
                ACTIVE: begin
                    if (r_valid_i)
                        i <= i + 1;
                end
            endcase
        end
    end

    always_comb begin
        state_n = state;
        re_o = 0;

        unique case (state)
            IDLE: begin
                if (re_i)
                    state_n = ACTIVE;
            end
            ACTIVE: begin
                if (i == fetch_size)
                    state_n = IDLE;
            end
        endcase
    end


endmodule

