// simple 2 port sram cell, 1 clk latency
module sram (
    input logic clk,

    // Port A
    input logic a_we,
    input logic [ADDR_W-1:0] a_addr,
    input logic [BLOCK_BITS-1:0] a_wdata,
    output logic [BLOCK_BITS-1:0] a_rdata,

    // Port B
    input logic b_we,
    input logic [ADDR_W-1:0] b_addr,
    input logic [BLOCK_BITS-1:0] b_wdata,
    output logic [BLOCK_BITS-1:0] b_rdata
);
    import mem_pkg::*;

    logic [BLOCK_BITS-1:0] mem [NUM_BLOCKS];

    // Port A
    always_ff @(posedge clk) begin
        if (a_we) mem[a_addr] <= a_wdata;
        a_rdata <= mem[a_addr];
    end

    // Port B
    always_ff @(posedge clk) begin
        if (b_we) mem[b_addr] <= b_wdata;
            b_rdata <= mem[b_addr];
    end
endmodule
