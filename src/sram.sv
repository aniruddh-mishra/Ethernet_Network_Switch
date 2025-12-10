// simple 1 cycle blocked sram
module sram #(
    parameter int ADDR_W = mem_pkg::ADDR_W,
    parameter int BLOCK_BITS = mem_pkg::BLOCK_BITS,
    parameter int NUM_BLOCKS = mem_pkg::NUM_BLOCKS
)(
    input logic clk, rst_n,

    input logic we,
    input logic re,
    input logic [ADDR_W-1:0] r_addr,
    input logic [ADDR_W-1:0] w_addr,
    input logic [BLOCK_BITS-1:0] wdata,
    output logic [BLOCK_BITS-1:0] rdata,
    output logic rvalid
);
    logic [BLOCK_BITS-1:0] mem [NUM_BLOCKS];

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) rvalid <= 1'b0;
        else begin
            rvalid <= 1'b0;
            if (we) mem[w_addr] <= wdata;
            if (re) begin
                rdata <= mem[r_addr];
                rvalid <= 1'b1;
            end
        end
    end
endmodule
