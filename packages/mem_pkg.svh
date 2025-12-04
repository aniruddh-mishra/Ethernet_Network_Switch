package mem_pkg;
    parameter int unsigned BLOCK_BYTES = 64; // cell size bytes
    parameter int unsigned NUM_BLOCKS = 4096; // number of memory cells
    /* verilator lint_off UNUSEDPARAM */
    parameter int unsigned DATA_WIDTH = 8;
    localparam int unsigned ADDR_W = $clog2(NUM_BLOCKS); // ptr size
    localparam int unsigned FOOTER_BYTES = 2; // last 8 B of cell used to point to next cell
    localparam int unsigned PAYLOAD_BYTES= BLOCK_BYTES-FOOTER_BYTES; // 56 B
    localparam int unsigned BLOCK_BITS = BLOCK_BYTES*8;

    // footer layout: | next_idx | rsvd | valid | eop |
    typedef struct packed { 
    logic [ADDR_W-1:0] next_idx; // 12 bits
    logic eop; // end of packet
    logic [2:0] rsvd; // 3 bits of empty
    } footer_t; // total width = 12 + 1 + 3 = 16 bits = 2 bytes
endpackage : mem_pkg
