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
    input logic [ADDR_W-1:0] fl_alloc_idx_i,

    // dual port memory, write will use port a
    output logic mem_we_o,
    output logic mem_addr_o,
    output logic [BLOCK_BITS-1:0] mem_wdata

    // TODO: return allocation metadata
);
    localparam int CELL_PAYLOAD_LAST_BEAT = 6; // (n + 1) * 8, 56 bytes for now

    typedef enum logic [1:0] {IDLE, WAIT_FIRST, WRITE_PAYLOAD, WAIT_SECOND, WRITE_FOOTER} state_t;

    // locals
    state_t state, state_n;
    footer_t footer;

    logic [PAYLOAD_BITS-1:0] payload_reg;
    logic [2:0] beat_cnt; // 7 beats per payload, last beat is for footer
    logic [ADDR_W-1:0] curr_idx; // current block idx
    logic [ADDR_W-1:0] next_idx; // used for footer

    assign fl_alloc_req_o = 
        (state == IDLE && data_valid_i && data_begin_i) || 
        (state == WRITE_PAYLOAD && (beat_cnt == CELL_PAYLOAD_LAST_BEAT) && !data_end_i);
    
    assign data_ready_o = state == IDLE; // TODO: fix this

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
        end
        else begin
            state <= state_n;

            mem_we_o <= 0;
            mem_addr_o <= 0;

            case (state)
                IDLE: begin
                    beat_cnt <= 0;
                end

                WAIT_FIRST: begin
                    if (fl_alloc_gnt)
                        curr_idx   <= fl_alloc_idx;
                end

                WRITE_PAYLOAD: begin
                    if (data_valid_i) begin
                        payload_reg <= {payload_reg[PAYLOAD_BITS-64-1:0], data_i};
                        beat_cnt <= beat_cnt + 1;

                        if (fl_alloc_gnt) 
                            next_idx <= fl_alloc_idx; // early capture
                    end
                end

                WAIT_SECOND: begin
                    if (fl_alloc_gnt) 
                        next_idx <= fl_alloc_idx;
                end

                WRITE_FOOTER: begin
                    footer.next_idx <= next_idx;
                    footer.eop      <= s_eop;
                    footer.valid    <= 1;
                    footer.rsvd     <= 0;

                    if (!data_end_i) begin
                        curr_idx <= next_idx; // hand over to next cell
                        beat_cnt <= 3'd0;
                    end

                    mem_addr  <= curr_idx;
                    mem_wdata <= { payload_reg , link_word };
                    mem_we    <= 1'b1;
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
                    state_n = WAIT_FIRST;
            end

            WAIT_FIRST: begin
                if (fl_alloc_gnt)
                    state_n = WRITE_PAYLOAD;
            end

            WRITE_PAYLOAD: begin
                if (data_valid_i && (beat_cnt == CELL_PAYLOAD_LAST_BEAT)) begin
                    if (data_end_i || fl_alloc_gnt)                     
                        state_n = WRITE_FOOTER;                 
                    else                           
                        state_n = WAIT_SECOND;   // need to wait
                end
            end

            WAIT_SECOND: begin
                if (fl_alloc_gnt)
                    state_n = WRITE_FOOTER;
            end

            WRITE_FOOTER: begin
                state_n = s_eop ? IDLE : FILL;
            end
        endcase
    end
endmodule
