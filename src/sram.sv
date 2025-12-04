// simple 1 cycle blocked sram
module sram (
    input logic clk,

    input logic we,
    input logic re,
    input logic [ADDR_W-1:0] addr,
    input logic [BLOCK_BITS-1:0] wdata,
    output logic [BLOCK_BITS-1:0] rdata
);
    import mem_pkg::*;

    logic [BLOCK_BITS-1:0] mem [NUM_BLOCKS];

    always_ff @(posedge clk) begin
        if (we) mem[addr] <= wdata;
        if (re) rdata <= mem[addr];
    end
endmodule
