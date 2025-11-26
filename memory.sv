package mem_pkg;
    parameter int unsigned BLOCK_BYTES = 64; // cell size bytes
    parameter int unsigned NUM_BLOCKS = 4096; // number of memory cells
    localparam int unsigned ADDR_W = $clog2(NUM_BLOCKS); // ptr size
    localparam int unsigned FOOTER_BYTES = 8; // last 8 B of cell used to point to next cell
    localparam int unsigned PAYLOAD_BYTES= BLOCK_BYTES-LINK_BYTES; // 56 B
    localparam int unsigned BLOCK_BITS = BLOCK_BYTES*8;

    // footer layout: | next_idx | rsvd | valid | eop |
    typedef struct packed {
    logic [ADDR_W-1:0] next_idx;
    logic [5:0] rsvd;
    logic valid;
    logic eop; // end of packet
    } footer_t; // total width = ADDR_W+8 bits (<=64)
endpackage : mem_pkg

import mem_pkg::*;

// simple 2 port sram cell, 1 clk latency
module sram #(
    parameter int unsigned BLOCK_BYTES = BLOCK_BYTES,
    parameter int unsigned NUM_BLOCKS = NUM_BLOCKS
) (
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
