// include sync + clk_div modules
`include "rx_tx_pkg.svh"
// import params and crc32 function
import rx_tx_pkg::*;

module tx_mac_control #(
    parameter DATA_WIDTH = 8,
    parameter VOQ_DEPTH = 8
)(
    // GMII interface
    output logic gmii_tx_clk_o,
    output logic [DATA_WIDTH-1:0] gmii_tx_data_o,
    output logic gmii_tx_en_o,
    output logic gmii_tx_er_o,
    
    // switch's clk domain
    input logic switch_clk, switch_rst_n,
    
    // inputs from memory
    input logic [DATA_WIDTH-1:0] frame_data_i, // input data one byte at a time
    input logic frame_valid_i, // high for every cycle data is valid
    input logic frame_eof_i, // high on last data/FCS byte
    output logic [$clog2(VOQ_DEPTH)-1:0] mem_ptr_o, // ptr given to mem

    // VOQ signals
    output logic voq_ready_o, // always high when ready to start frame
    input logic voq_valid_i, // indicates VOQ has valid start ptr
    input logic [$clog2(VOQ_DEPTH)-1:0] voq_ptr_i
);

// status and debug signals (simulation only)
logic [31:0] tx_frame_count; // # of frames transmitted
logic [31:0] fifo_overflow_count; // # of times FIFO full - switch clk domain
logic [31:0] fifo_underflow_count; // # of times FIFO empty - gmii clk domain

// generate gmii clk
clk_div #(
    .DIVIDE(4) // 125MHz from 500MHz switch clk
) gmii_clk_gen (
    .clk_in(switch_clk),
    .rst_n(switch_rst_n),
    .clk_out(gmii_tx_clk_o)
);

// FIFO signals for CDC (switch clk -> GMII)
logic [DATA_WIDTH-1:0] fifo_din; // continous only 
logic [DATA_WIDTH-1:0] fifo_dout;
logic fifo_wr_en;
logic fifo_full; logic fifo_empty;
logic fifo_rd_en; assign fifo_rd_en = !fifo_empty; // constantly read in gmii domain

// sync switch clk reset to gmii/PHY clk
logic sync_switch_rst_n;
synchronizer sync_rst(gmii_tx_clk_o, switch_rst_n, sync_switch_rst_n);

// CDC FIFO instance (async FIFO)
async_fifo #(
    .DATA_WIDTH(DATA_WIDTH) // just data
    // default addr_width 4 = 16 depth
    // default 2 sync stages
) cdc_fifo (
    .wclk(switch_clk),
    .wrst_n(switch_rst_n),
    .w_en(fifo_wr_en),
    .w_data(fifo_din),
    .w_full(fifo_full),
    
    .rclk(gmii_tx_clk_o),
    .rrst_n(sync_switch_rst_n),
    .r_en(fifo_rd_en),
    .r_data(gmii_tx_data_o),
    .r_empty(fifo_empty)
);

// state machine (switch clk domain) - handles all frame processing
typedef enum logic [1:0] {IDLE, PREAMBLE, DATA, IFG} state_t;

state_t current_state, next_state;

logic [2:0] preamble_ctr, next_preamble_ctr; // 8 bytes
logic [3:0] IFG_ctr, next_IFG_ctr; // 12 bytes
logic next_voq_ready_o;

// status and debug signals
logic [31:0] next_tx_frame_count;

always_comb begin
    // default values
    next_state = current_state;
    next_preamble_ctr = preamble_ctr;
    next_IFG_ctr = IFG_ctr;
    fifo_wr_en = 1'b0;
    next_voq_ready_o = 1'b0;
    next_tx_frame_count = tx_frame_count;

    case (current_state)
        IDLE: begin
            next_preamble_ctr = 0;
            next_IFG_ctr = 0;
            if (!voq_ready_o) next_voq_ready_o = 1'b1;
            else begin
                mem_ptr_o = voq_ptr_i;
                next_state = PREAMBLE;
            end
        end
        PREAMBLE: begin // write 7 preamble bytes + 1 SFD byte
            if (!fifo_full) begin
                if (preamble_ctr < 7) begin 
                    fifo_din = PREAMBLE_BYTE;
                end else begin
                    fifo_din = SFD_BYTE;
                    next_state = DATA;
                end
                fifo_wr_en = 1'b1;
                next_preamble_ctr = preamble_ctr + 1;
            end
        end
        DATA: begin
            if (frame_valid_i && !fifo_full) begin
                fifo_din = frame_data_i;
                fifo_wr_en = 1'b1;
                
                if (frame_eof_i) begin
                    next_tx_frame_count = tx_frame_count + 1;
                    next_state = IFG;
                end
            end
        end
        IFG: begin // maintain 12-byte IFG
            next_IFG_ctr = IFG_ctr + 1;
            if (IFG_ctr == 11) begin
                next_state = IDLE;
            end
        end
        default: next_state = IDLE;
    endcase
end

// state machine (switch clk domain) - seq logic
always_ff @(posedge switch_clk or negedge switch_rst_n) begin
    if (!switch_rst_n) begin
        current_state <= IDLE;
        voq_ready_o <= 0;
        preamble_ctr <= 0;
        IFG_ctr <= 0;
        tx_frame_count <= 0;
        fifo_overflow_count <= 0;
    end else begin
        current_state <= next_state;
        voq_ready_o <= next_voq_ready_o;
        preamble_ctr <= next_preamble_ctr;
        IFG_ctr <= next_IFG_ctr;
        tx_frame_count <= next_tx_frame_count;
        
        // debug counter
        if (fifo_full) fifo_overflow_count <= fifo_overflow_count + 1;
    end
end

// simple output logic (gmii clk domain) - just read from FIFO and output
logic prev_fifo_rd_en;
assign fifo_rd_en = !fifo_empty; // continuous read when data available
assign gmii_tx_en_o = prev_fifo_rd_en; // tx_en follows
assign gmii_tx_er_o = 1'b0; // no errors generated

// simple gmii
always_ff @(posedge gmii_tx_clk_o or negedge sync_switch_rst_n) begin
    if (!sync_switch_rst_n) begin
        fifo_underflow_count <= 0;
    end else begin
        prev_fifo_rd_en <= fifo_rd_en;
        // debug
        if (fifo_empty) fifo_underflow_count <= fifo_underflow_count + 1;
    end
end

endmodule