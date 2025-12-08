// memory write controller
module memory_write_ctrl (
    input logic clk,
    input logic rst_n,

    // memory write data, 1 byte / 8 bit beats
    input logic [7:0] data_i,
    input logic data_valid_i,
    input logic data_begin_i,
    input logic data_end_i,
    output logic data_ready_o,

    // iterface with free list
    output logic fl_alloc_req_o,
    input logic fl_alloc_gnt_i,
    input logic [ADDR_W-1:0] fl_alloc_block_idx_i,

    // to memory
    input logic mem_ready_i, // memory controller ready
    output logic mem_we_o,
    output logic [ADDR_W-1:0] mem_addr_o,
    output logic [BLOCK_BITS-1:0] mem_wdata_o,

    // to arb
    output logic [ADDR_W-1:0] start_addr_o
);
    import mem_pkg::*;
    // block size is 64 bytes, beat size is 1 byte
    // 62 bytes reserved for packet payload, 2 bytes for footer
    localparam int PAYLOAD_BITS = 8 * PAYLOAD_BYTES;

    typedef enum logic [1:0] {IDLE, WRITE_PAYLOAD, WAIT, WRITE_FOOTER} state_t;

    logic frame_allocated;
    logic next_frame_allocated;

    // locals
    state_t state, state_n;
    footer_t footer;

    logic [PAYLOAD_BITS-1:0] payload_reg;
    logic [$clog2(BLOCK_BYTES)-1:0] beat_cnt;
    logic [ADDR_W-1:0] curr_idx; // current block idx
    logic [ADDR_W-1:0] next_idx; // used for footer

    logic [ADDR_W-1:0] start_addr;
    logic [ADDR_W-1:0] frame_cnt;

    // not ready if waiting for frame allocation
    assign data_ready_o = state != WAIT && !(state == WRITE_FOOTER && !mem_ready_i);
    assign start_addr_o = start_addr;

    always_comb begin
        fl_alloc_req_o = 1'b0;

        if (state != IDLE) begin
            fl_alloc_req_o = (!frame_allocated && !fl_alloc_gnt_i)   ||
                        (!frame_allocated && !next_frame_allocated) ||
                        (!fl_alloc_gnt_i && !next_frame_allocated);
        end
    end

    logic payload_data_end;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            payload_reg <= 0;
            beat_cnt <= 0;
            curr_idx <= 0;
            next_idx <= 0;
            frame_allocated <= 0;
            next_frame_allocated <= 0;
            start_addr <= 0;
            frame_cnt <= 0;
            payload_data_end <= 0;
        end
        else begin
            state <= state_n;
            mem_we_o <= 0;
            mem_addr_o <= 0;
            mem_wdata_o <= 0;

            if (state != IDLE) begin                
                if (!frame_allocated && fl_alloc_gnt_i) begin
                    curr_idx <= fl_alloc_block_idx_i;
                    frame_allocated <= 1;
                    if (frame_cnt == 0)
                        start_addr <= fl_alloc_block_idx_i;
                end
                if (frame_allocated && !next_frame_allocated && fl_alloc_gnt_i) begin
                    next_idx <= fl_alloc_block_idx_i;
                    next_frame_allocated <= 1;
                end
            end

            case (state)
                IDLE: begin
                    frame_allocated <= 0;
                    next_frame_allocated <= 0;
                    beat_cnt <= 0;
                    frame_cnt <= 0;
                    payload_data_end <= 0;

                    if (data_valid_i && data_begin_i) begin
                        beat_cnt <= 1;
                        payload_reg <= {496'b0, data_i}; // 496 + 8 = 504 = PAYLOAD_BITS
                    end
                end

                WRITE_PAYLOAD: begin         
                    payload_data_end <= data_end_i;             
                    if (data_valid_i) begin
                        payload_reg <= {payload_reg[PAYLOAD_BITS-8-1:0], data_i};
                        beat_cnt <= beat_cnt + 1;
                    end
                end

                WAIT: begin
                    // idle
                end

                WRITE_FOOTER: begin
                    if (data_valid_i || data_end_i || payload_data_end) begin
                        if (mem_ready_i) begin
                            footer.next_idx <= next_idx;
                            footer.eop <= data_end_i;
                            footer.rsvd <= 0;
                            payload_data_end <= 0;

                            if (!data_end_i && !payload_data_end) begin
                                beat_cnt <= 0;
                                frame_allocated <= 1; // next_idx already allocated;
                                next_frame_allocated <= 0;
                                curr_idx <= next_idx;

                                if (data_valid_i) begin
                                    beat_cnt <= 1;
                                    payload_reg <= {496'b0, data_i};
                                end
                            end

                            mem_addr_o <= curr_idx;
                            mem_wdata_o <= { payload_reg , footer };
                            mem_we_o <= 1'b1;
                            frame_cnt <= frame_cnt + 1;
                        end
                    end
                end
            endcase
        end
    end
    
    // next state logic
    always_comb begin
        state_n = state;

        case (state)
            IDLE: begin
                if (data_valid_i && data_begin_i)
                    state_n = WRITE_PAYLOAD;
            end

            WRITE_PAYLOAD: begin
                if ((data_valid_i && (({26'b0, beat_cnt} == PAYLOAD_BYTES - 1))) || data_end_i)
                    state_n = (frame_allocated && next_frame_allocated) ? WRITE_FOOTER : WAIT;
            end

            WAIT: begin
                if (frame_allocated && next_frame_allocated)
                    state_n = WRITE_FOOTER;
            end

            WRITE_FOOTER: begin
                if ((data_valid_i || data_end_i || payload_data_end) && mem_ready_i) // mem transaction success
                    state_n = (data_end_i || payload_data_end) ? IDLE : WRITE_PAYLOAD;
                // TODO: FIX SINGLE FRAME LEAK IF WE GO TO IDLE STATE (LOW PRIORITY)
            end
        endcase
    end
endmodule
