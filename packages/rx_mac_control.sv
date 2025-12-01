// import params and crc32 function
import rx_tx_pkg::*;

module rx_mac_control (
    // GMII interface
    input logic gmii_rx_clk,
    input logic [DATA_WIDTH-1:0] gmii_rx_data,
    input logic gmii_rx_dv,
    input logic gmii_rx_er,
    
    // switch's clk domain
    input logic switch_clk, switch_rst_n,

    // outputs to MAC learning/lookup - specific to bytes
    output logic [5:0][7:0] mac_dst_addr, mac_src_addr,

    // outputs to learning/lookup and memory
    output logic [DATA_WIDTH-1:0] frame_data, // outputs data one byte at a time
    output logic frame_valid, // high for every cycle data is valid
    input logic frame_grant, // from mem
    output logic frame_sof, // single high start of frame - set on first valid data outputted
    output logic frame_eof, // single high end of frame - follows after last data/FCS byte
    output logic frame_error, // high at eof if CRC or other error
);

// status and debug signals
logic [31:0] crc_error_count, // # of frames with CRC errors
logic [31:0] rx_error_count, // # of frames with any errors
logic [31:0] rx_frame_count, // # of frames received (valid or invalid)
logic [31:0] fifo_overflow_count, // # of times FIFO was full when trying to write - gmii clk domain
logic [31:0] fifo_underflow_count // # of times FIFO was empty when trying to read in eof metadata state - switch clk domain

// FIFO signals for CDC (GMII -> switch clk)
logic [DATA_WIDTH-1:0] fifo_din, next_fifo_din; // only data, no eof/sof
logic [DATA_WIDTH-1:0] fifo_dout;
logic fifo_rd_en; // continuous signal, no reg
logic fifo_full;
logic fifo_empty;

// sync switch clk reset to gmii/PHY clk
logic sync_switch_rst_n;
synchronizer(gmii_rx_clk, switch_rst_n, sync_switch_rst_n);

// CDC FIFO instance (async FIFO)
async_fifo cdc_fifo (
    .wclk(gmii_rx_clk),
    .wrst_n(sync_switch_rst_n),
    .w_en(gmii_rx_dv && !gmii_rx_er),
    .w_data(gmii_rx_data),
    .w_full(fifo_full),
    
    .rclk(switch_clk),
    .rrst_n(switch_rst_n),
    .r_en(fifo_rd_en),
    .r_data(fifo_dout),
    .r_empty(fifo_empty)
);

// output state machine (switch clk domain) - comb logic 
typedef enum logic [1:0] {OUT_IDLE, OUT_PREAMBLE, OUT_HEADER, OUT_PAYLOAD} out_state_t;

out_state_t out_current_state, out_next_state;

logic [31:0] crc_reg, next_crc_reg;
logic [4:0] preamble_header_ctr, next_preamble_header_ctr; // preamble = 8 bytes, header = 6 + 6 + 2 bytes, total = 22 bytes
logic prev_fifo_rd_en; // needed b/c 1st cycle: req read, 2nd cycle: check data
logic [5:0][7:0] next_mac_dst_addr, next_mac_src_addr;
logic [DATA_WIDTH-1:0] next_frame_data;
logic next_frame_valid;
logic next_frame_sof; logic next_frame_eof; logic next_frame_error;

// output status and debug signals
logic [31:0] next_crc_error_count; 
logic [31:0] next_rx_error_count; 
logic [31:0] next_rx_frame_count; 

// data valid and error logic
logic rx_dv, rx_er; 
assign rx_dv = gmii_rx_dv_sync[1]; 
assign rx_er = gmii_rx_er_sync[1];

logic [1:0] gmii_rx_dv_sync, gmii_rx_er_sync;
always_ff @(posedge switch_clk or negedge switch_rst_n) begin
    if (!switch_rst_n) begin
        gmii_rx_dv_sync <= 0;
        gmii_rx_er_sync <= 0;
    end else begin
        gmii_rx_dv_sync <= {gmii_rx_dv_sync[0], gmii_rx_dv};
        gmii_rx_er_sync <= {gmii_rx_er_sync[0], gmii_rx_er};
    end
end
logic rx_dv_flag; // sticky flag for dv during frame

always_comb begin
    // default values
    out_next_state = out_current_state;
    fifo_rd_en = 1'b0; // default false
    next_crc_reg = crc_reg;
    next_preamble_header_ctr = preamble_header_ctr;
    next_mac_dst_addr = mac_dst_addr; next_mac_src_addr = mac_src_addr;
    next_frame_data = frame_data; next_frame_valid = frame_valid;
    next_frame_eof = 1'b0; next_frame_sof = 1'b0; // default false
    next_frame_error = rx_er || frame_error; // sticky error during frame

    case (out_current_state)
        OUT_IDLE: begin // assume IFG is not violated from sender
            next_crc_reg = 32'hFFFFFFFF;
            next_frame_error = 1'b0; // resets frame error which stays high during frame
            rx_dv_flag = 1'b0; // reset sticky flag
            if (!fifo_empty) fifo_rd_en = 1'b1; 
            if (prev_fifo_rd_en) begin
                if (fifo_dout == PREAMBLE_BYTE) begin
                    next_preamble_header_ctr = 1; // resets ctr
                    out_next_state = OUT_PREAMBLE;
                end
            end
        end
        OUT_PREAMBLE: begin
            if (!fifo_empty) fifo_rd_en = 1'b1;
            if (prev_fifo_rd_en) begin
                if (preamble_header_ctr == 7) begin
                    if (fifo_dout == SFD_BYTE) begin 
                        next_preamble_header_ctr = preamble_header_ctr + 1;
                        next_frame_sof = 1'b1;
                        out_next_state = OUT_HEADER;
                    end else begin
                        out_next_state = OUT_IDLE; // invalid SFD byte, go back to IDLE
                    end
                end else begin
                    if (fifo_dout == PREAMBLE_BYTE) next_preamble_header_ctr = preamble_header_ctr + 1;
                    else out_next_state = OUT_IDLE; // invalid preamble byte, go back to IDLE
                end
            end
        end
        OUT_HEADER: begin // parse header bytes for MAC addresses
            if (!fifo_empty && frame_grant) fifo_rd_en = 1'b1;
            if (prev_fifo_rd_en) begin
                next_crc_reg = crc32_next(fifo_dout, crc_reg);

                if (preamble_header_ctr < 14) begin // 8 + 6 = 14
                    next_mac_dst_addr = {mac_dst_addr[4:0], fifo_dout}; // SIPO
                end else if (preamble_header_ctr < 20) begin
                    next_mac_src_addr = {mac_src_addr[4:0], fifo_dout};
                end 
                // else if (preamble_header_ctr < 22) begin // ignore mac_type for now
                //     next_mac_type = {mac_type[0], fifo_dout};
                // end
                next_preamble_header_ctr = preamble_header_ctr + 1;
                next_frame_data = fifo_dout;
                next_frame_valid = 1'b1;
            end
        end
        OUT_PAYLOAD: begin // assume frame fits within max and min bytes + follows IFG
            if (!fifo_empty && frame_grant) fifo_rd_en = 1'b1;
            if (!rx_dv) rx_dv_flag = 1'b1; // set sticky flag when dv goes low
            if (prev_fifo_rd_en) begin
                next_crc_reg = crc32_next(fifo_dout, crc_reg);
                next_frame_data = fifo_dout;
                next_frame_valid = 1'b1;
            end else if (rx_dv_flag) begin // sender has finished sending frame + we have read all data
                if (crc_reg != CRC32_CONSTANT) begin
                    next_frame_error = 1'b1; // allow payload to cut through, perform CRC calculations as data arrives, flag error at end
                    // update debug ctrs
                    next_crc_error_count = crc_error_count + 1;
                    next_rx_error_count = rx_error_count + 1;
                end
                next_frame_eof = 1'b1;
                out_next_state = OUT_IDLE;
                next_rx_frame_count = rx_frame_count + 1; // update debug ctrs
            end
        end
        default: out_next_state = OUT_IDLE;
    endcase
end

// output state machine (switch clk domain) - seq logic 
always_ff @(posedge switch_clk or negedge switch_rst_n) begin
    if (!switch_rst_n) begin
        out_current_state <= OUT_IDLE;
        prev_fifo_rd_en <= 0;
        frame_data <= 0;
        frame_eof <= 0;
        frame_sof <= 0;
        frame_valid <= 0;
        frame_error <= 0;

        // debug
        crc_error_count <= 0;
        rx_error_count <= 0;
        rx_frame_count <= 0;
        fifo_underflow_count <= 0;
    end else begin
        if (frame_grant) begin // freeze current data if mem or addr learning is backed up
            out_current_state <= out_next_state;
            prev_fifo_rd_en <= fifo_rd_en;
            frame_data <= next_frame_data;
            frame_eof <= next_frame_eof;
            frame_sof <= next_frame_sof;
            frame_valid <= next_frame_valid;
            frame_error <= next_frame_error;
            
            // debug
            crc_error_count <= next_crc_error_count;
            rx_error_count <= next_rx_error_count;
            rx_frame_count <= next_rx_frame_count;
            
        end

        if (fifo_empty) fifo_underflow_count <= fifo_underflow_count + 1;
    end
end

// debug for gmii
always_ff @(posedge gmii_rx_clk or negedge sync_switch_rst_n) begin
    if (!sync_switch_rst_n) begin
        fifo_overflow_count <= 0;
    end else begin
        if (fifo_full) fifo_overflow_count <= fifo_overflow_count + 1;
    end
end
endmodule

module synchronizer (input logic clk, input logic rst_n_in, output logic rst_n_out);
    logic sync_ff1, sync_ff2;

    always_ff @(posedge clk or negedge rst_n_in) begin
        if (!rst_n_in) begin
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
        end else begin
            sync_ff1 <= 1'b1;
            sync_ff2 <= sync_ff1;
        end
    end

    assign rst_n_out = sync_ff2;
endmodule