// simple 2 port sram cell, 1 clk latency
module sram (
    input logic clk,

    // Port Write
    input logic we,
    input logic [ADDR_W-1:0] w_addr,
    input logic [BLOCK_BITS-1:0] w_data,

    // Port Read
    input logic [ADDR_W-1:0] r_addr,
    output logic [BLOCK_BITS-1:0] r_data
);
    import mem_pkg::*;

    logic [BLOCK_BITS-1:0] mem [NUM_BLOCKS-1:0];

    always_ff @(posedge clk) begin
        if (we) mem[w_addr] <= w_data;
        r_data <= mem[r_addr];
    end
endmodule
