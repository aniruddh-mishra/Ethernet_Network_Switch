// memory write controller
import mem_pkg::*;

module memory_write_ctrl (
    input logic clk,
    input logic rst_n,

    // memory write data, 64 bit beats
    input logic [63:0] data_i;
    input logic data_valid_i,
    input logic data_begin_i,
    input logic data_end_i,
    output logic data_ready_o,

    // iterface with free list
    output logic fl_alloc_req_o,
    input logic fl_alloc_gnt,
    input logic [ADDR_W-1:0] fl_alloc_block_idx_i,

    // dual port memory, write will use port a
    output logic mem_we_o,
    output logic mem_addr_o,
    output logic [BLOCK_BITS-1:0] mem_wdata
);
    localparam int CELL_PAYLOAD_LAST_BEAT = 6; // (n + 1) * 8, 56 bytes for now

    typedef enum logic [1:0] {IDLE, WRITE_PAYLOAD, WRITE_FOOTER} state_t;

    logic frame_allocated;
    logic next_frame_allocated;

    assign fl_alloc_req_o = !frame_allocated || !next_frame_allocated;

    // locals
    state_t state, state_n;
    footer_t footer;

    logic [PAYLOAD_BITS-1:0] payload_reg;
    logic [2:0] beat_cnt; // 7 beats per payload, last beat is for footer
    logic [ADDR_W-1:0] curr_idx; // current block idx
    logic [ADDR_W-1:0] next_idx; // used for footer

    // not ready if waiting for frame allocation or actively writing to memory. 
    assign data_ready_o = state == IDLE || state == WRITE_PAYLOAD;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
            payload_reg <= 0;
            beat_cnt <= 0;
            curr_idx <= 0;
            next_idx <= 0;
            frame_allocated <= 0;
        end
        else begin
            state <= state_n;

            mem_we_o <= 0;
            mem_addr_o <= 0;

            if (state != IDLE) begin                
                if (!frame_allocated && fl_alloc_gnt) begin
                    curr_idx <= fl_alloc_idx;
                    frame_allocated <= 1;
                end
                if (frame_allocated && !next_frame_allocated && fl_alloc_gnt) begin
                    next_idx <= fl_alloc_idx;
                    next_frame_allocated <= 1;
                end
            end

            case (state)
                IDLE: begin
                    frame_allocated <= 0;
                    next_frame_allocated <= 0;
                    beat_cnt <= 0;

                    if (data_valid_i)
                        payload_reg <= data_i;
                end

                WRITE_PAYLOAD: begin                        
                    if (data_valid_i) begin
                        payload_reg <= {payload_reg[PAYLOAD_BITS-64-1:0], data_i};
                        beat_cnt <= beat_cnt + 1;
                    end
                end

                WRITE_FOOTER: begin
                    footer.next_idx <= next_idx;
                    footer.eop <= s_eop;
                    footer.valid <= 1;
                    footer.rsvd <= 0;

                    if (!data_end_i) begin
                        beat_cnt <= 3'd0;
                    end

                    mem_addr <= curr_idx;
                    mem_wdata <= { payload_reg , footer };
                    mem_we <= 1'b1;
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
                if (data_valid_i && (beat_cnt == CELL_PAYLOAD_LAST_BEAT))
                    state_n = (frame_allocated && next_frame_allocated) ? WRITE_FOOTER : WAIT;
            end

            WAIT: begin
                if (frame_allocated && next_frame_allocated)
                    state_n = WRITE_FOOTER;
            end

            WRITE_FOOTER: begin
                state_n = data_end_i ? IDLE : WRITE_PAYLOAD;
                // TODO: FIX SINGLE FRAME LEAK IF WE GO TO IDLE STATE (LOW PRIORITY)
            end
        endcase
    end
endmodule
