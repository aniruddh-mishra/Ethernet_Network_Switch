package mem_pkg;
    parameter int unsigned BLOCK_BYTES = 64; // cell size bytes
    parameter int unsigned NUM_BLOCKS = 64; // number of memory cells
    /* verilator lint_off UNUSEDPARAM */
    parameter int unsigned DATA_WIDTH = 8;
    localparam int unsigned ADDR_W = $clog2(NUM_BLOCKS); // ptr size
    localparam int unsigned FOOTER_BYTES = 1; // last 8 B of cell used to point to next cell
    localparam int unsigned PAYLOAD_BYTES= BLOCK_BYTES-FOOTER_BYTES;
    localparam int unsigned BLOCK_BITS = BLOCK_BYTES*8;

    // footer layout: | next_idx | rsvd | valid | eop |
    typedef struct packed { 
    logic [ADDR_W-1:0] next_idx; // 6 bits
    logic eop; // end of packet
    logic rsvd; // 1 bit rsvd
    } footer_t; // total width = 6 + 1 + 1 = 8 bits = 1 byte
endpackage : mem_pkg
