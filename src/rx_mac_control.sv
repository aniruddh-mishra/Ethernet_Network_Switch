module rx_mac_control #(
    parameter DATA_WIDTH = 8,
    parameter BLOCK_SIZE = 8, // in bytes
) (
    // GMII interface
    input logic gmii_rx_clk,
    input logic [DATA_WIDTH-1:0] gmii_rx_data,
    input logic gmii_rx_dv,
    input logic gmii_rx_er,
    
    // switch's clk domain
    input logic switch_clk, switch_rst_n

    // outputs to MAC learning/lookup - specific to 8 bytes
    output logic [5:0][7:0] mac_src_addr,
    output logic [5:0][7:0] mac_dst_addr,
    output logic [1:0][7:0] mac_type,
    output logic mac_src_valid,
    output logic mac_dst_valid,
    output logic mac_type_valid,
    

    // outputs to learning/lookup and memory
    output logic [BLOCK_SIZE-1:0][DATA_WIDTH-1:0] frame_data, // outputs data one block size at a time
    output logic frame_valid, // high for every cycle data is valid
    // output logic frame_sof, // single high at beg of frame - frame_valid going high works too
    output logic frame_eof, // single high end of frame - follows after last data/FCS byte
    output logic frame_error, // high at eof if CRC or other error
    output logic [$clog2(MAX_FRAME_SIZE)-1:0] frame_length, // wide enough to cover from MIN to MAX frame size

    // status and debug signals
    output logic [31:0] crc_error_count, // # of frames with CRC errors
    output logic [31:0] rx_error_count, // # of frames with any errors
    output logic [31:0] rx_frame_count, // # of frames received (valid or invalid)
    output logic [31:0] preamble_error_count // # of frames with preamble errors
    output logic [31:0] fifo_overflow_count // # of times FIFO was full when trying to write
    output logic [31:0] fifo_underflow_count // # of times FIFO was empty when trying to read in eof metadata state - switch clk domain
);

// ethernet standards
localparam PREAMBLE_BYTE = 8'h55; // repeated for 7 bytes
localparam SFD_BYTE = 8'hD5; // 1 byte after preamble
/* MIN_FRAME_SIZE includes: 
    6-byte destination addr
    6-byte source addr
    2-byte type
    46 to 1500-byte data
    4-byte FCS 
*/
localparam MIN_FRAME_SIZE = 64;
localparam MAX_FRAME_SIZE = 1518; // 1522 if including VLAN tag
localparam CRC32_POLY_REFLECTED = 32'hEDB88320; // non-reflected polynomial: 32'h04C11DB7
/* 
    when including FCS in the CRC calculation (since it would be difficult to exclude the FCS bytes themselves without sacrificing speed), the CRC of the entire frame (data + FCS) should equal 0xC704DD7B
    this only occurs when there are no errors in the data or FCS transmitted
    this is due to the properties of the polynomial division used in CRC calculations, where after all data is sent, the CRC_reg should equal the FCS, and thus the final CRC (data + FCS) equals a known constant
*/
localparam CRC32_CONSTANT = 32'hC704DD7B; // final XOR value

localparam IFG_LENGTH = 12; // inter-frame gap in bytes

// fsm states
typedef enum logic [2:0] {
    IDLE,
    PREAMBLE,
    HEADER, // dest addr + source addr + type
    PAYLOAD,
    FCS,
    WAIT_IFG // inter-frame gap between frames
} state_t;

// internal signals
state_t rx_current_state, rx_next_state;
logic [2:0] preamble_count, next_preamble_count; // count up to 7 bytes
logic [$clog2(MAX_FRAME_SIZE)-1:0] byte_count, next_byte_count; // 64 to 1518-byte frame
logic [31:0] crc_reg, next_crc_reg;
// logic crc_valid, next_crc_valid;
logic [31:0] received_fcs, next_received_fcs; // frame check sequence sent from ingress
// logic [1:0] fcs_byte_count, next_fcs_byte_count;
logic frame_error, next_frame_error;
logic [$clog2(IFG_LENGTH)-1:0] ifg_count, next_ifg_count;

// FIFO signals for CDC (GMII -> switch clk)
logic [DATA_WIDTH-1+3:0] fifo_din, next_fifo_din; // eof + sof + valid + data
logic [DATA_WIDTH-1+3:0] fifo_dout;
logic fifo_wr_en, next_fifo_wr_en;
logic fifo_rd_en, next_fifo_rd_en;
logic fifo_full;
logic fifo_empty;

// output comb signals
logic [5:0][7:0] next_mac_src_addr, next_mac_dst_addr;
logic next_mac_frame_valid;
logic [BLOCK_SIZE-1:0][DATA_WIDTH-1:0] next_frame_data;
// logic [DATA_WIDTH-1:0] next_frame_byte_data;
logic next_frame_valid;
// logic next_frame_sof;
logic next_frame_eof;
logic next_frame_error;
logic [$clog2(MAX_FRAME_SIZE)-1:0] next_frame_length;

// output status and debug signals (gmii clk domain)
logic [31:0] next_crc_error_count, // # of frames with CRC errors
logic [31:0] next_rx_error_count, // # of frames with any errors
logic [31:0] next_rx_frame_count, // # of frames received (valid or invalid)
logic [31:0] next_preamble_error_count; // # of frames with preamble errors
logic [31:0] next_fifo_overflow_count; // # of times FIFO was full when trying to write
logic [31:0] next_fifo_underflow_count; // # of times FIFO was empty when trying to read in eof metadata state - switch clk domain

// =========================================================================
// CDC FIFO instance (async FIFO)
// =========================================================================

async_fifo #(
    .DATA_WIDTH(DATA_WIDTH + 1), // eof + data
    // default addr_width 4 = 16 depth
    // default 2 sync stages
) cdc_fifo (
    .wclk(gmii_rx_clk),
    .wrst_n(switch_rst_n),
    .w_en(fifo_wr_en),
    .w_data(fifo_din),
    .w_full(fifo_full),
    
    .rclk(switch_clk),
    .rrst_n(switch_rst_n),
    .r_en(fifo_rd_en),
    .r_data(fifo_dout),
    .r_empty(fifo_empty)
);

// =========================================================================
// CRC-32 calculation
//=========================================================================

/* function that computes the next CRC-32 value,
   given current CRC and new data byte lSB first, transmitting MSB first
   1. left shift data up to 32 bits, XOR with current CRC
   2. for each bit in the byte:
      a. if MSB of CRC == 1, << 1 and XOR with polynomial
      b. else just << 1
*/
function automatic [31:0] crc32_next(
    input logic [7:0] data, input logic [31:0] crc_in
);
    integer i;
    logic [31:0] crc;
    logic [7:0] data_reflected;
    // ethernet data comes in lSB first, so reflect byte
    assign data_reflected = {data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]};
    begin
        crc = crc_in ^ (data_reflected << 24);
        // unrolls into 8 shifts/xors
        for (i = 0; i < 8; i = i + 1) begin
            if (crc[31]) begin
                crc = (crc << 1) ^ CRC32_POLY_REFLECTED;
            end else begin
                crc = crc << 1;
            end
        end
        return crc;
    end
endfunction

// =========================================================================
// RX state machine (GMII clk domain) - comb logic 
// =========================================================================

always_comb begin
    // default values
    rx_next_state = rx_current_state;
    next_preamble_count = preamble_count;
    next_byte_count = byte_count;
    next_crc_reg = crc_reg;
    next_received_fcs = received_fcs;
    // next_fcs_byte_count = fcs_byte_count;
    next_fifo_din = fifo_din;
    next_fifo_wr_en = 1'b0;
    next_frame_error = frame_error;
    next_ifg_count = ifg_count;
    // next_crc_valid = crc_valid;
    next_preamble_error_count = preamble_error_count;
    next_rx_frame_count = rx_frame_count;
    next_crc_error_count = crc_error_count;
    next_rx_error_count = rx_error_count;
    next_fifo_overflow_count = fifo_overflow_count;

    case (rx_current_state) 
        IDLE: begin
            next_crc_reg = 32'hFFFFFFFF;
            next_byte_count = 0;
            next_frame_error = 1'b0;
            // next_fcs_byte_count = 0;

            // wait for rx data valid, no error, then check preamble
            if (gmii_rx_dv && !gmii_rx_er) begin
                if (gmii_rx_data == PREAMBLE_BYTE) begin
                    next_preamble_count = 1;
                    rx_next_state = PREAMBLE;
                end 
            end
        end

        PREAMBLE: begin
            // count preamble bytes
            if (gmii_rx_dv && !gmii_rx_er) begin
                if (preamble_count + 1 == 7) begin
                    if (gmii_rx_data == SFD_BYTE) begin
                        // received 7 preamble bytes and SFD --> HEADER
                        rx_next_state = HEADER;
                        next_preamble_count = 0; // reset ctr
                    end else begin
                        // invalid SFD, go to IDLE
                        rx_next_state = IDLE;
                    end
                end else begin
                    if (gmii_rx_data == PREAMBLE_BYTE) begin
                        next_preamble_count = preamble_count + 1;
                    end else begin
                        // invalid preamble byte, go to IDLE
                        rx_next_state = IDLE;
                    end
                end
            end else begin
                // dv deasserted or error, go to IDLE
                if (gmii_rx_er) begin
                    next_preamble_error_count = preamble_error_count + 1; // accumulate until full reset
                end 
                rx_next_state = IDLE;
            end
            // NOTE: no FIFO writes during preamble, just silently return to IDLE on error and raise debug ctr (no real partial frame for an error)
        end

        HEADER: begin
            // capture header bytes into buffer
            if (gmii_rx_dv && !gmii_rx_er) begin
                next_byte_count = byte_count + 1;

                next_crc_reg = crc32_next(gmii_rx_data, crc_reg);
                if (byte_count + 1 == 14) begin
                    // completed header capture
                    rx_next_state = PAYLOAD;
                end

                // now, begin writing to FIFO
                next_fifo_din = {1'b0, gmii_rx_data}; // eof=0 
                // if FIFO ever is full, data is lost
                if (!fifo_full) begin
                    next_fifo_wr_en = 1'b1;
                end else begin
                    next_frame_error = 1'b1;
                    next_fifo_overflow_count = fifo_overflow_count + 1;
                    rx_next_state = WAIT_IFG; 
                end
            end else begin
                // dv deasserted or error, go to WAIT_IFG
                if (gmii_rx_er) begin
                    next_frame_error = 1'b1;
                end
                rx_next_state = WAIT_IFG;
            end
        end

        PAYLOAD: begin
            // allow payload to cut through to frame parser, perform CRC calculations as data arrives, flag error at end
            if (gmii_rx_dv && !gmii_rx_er) begin
                next_byte_count = byte_count + 1;

                next_crc_reg = crc32_next(gmii_rx_data, crc_reg);

                // write to FIFO
                next_fifo_din = {1'b0, gmii_rx_data}; // eof=0 
                if (!fifo_full) begin
                    next_fifo_wr_en = 1'b1;
                end else begin
                    next_frame_error = 1'b1;
                    next_fifo_overflow_count = fifo_overflow_count + 1;
                    rx_next_state = WAIT_IFG; 
                end
            end else if (gmii_rx_er || (!gmii_rx_dv && byte_count < MIN_FRAME_SIZE) || (byte_count + 1 > MAX_FRAME_SIZE)) begin
                // error during payload, dv deasserted early before min frame size, or exceeded max frame size
                next_frame_error = 1'b1;
                rx_next_state = WAIT_IFG;
            end else begin
                // dv deasserted normally, move to FCS check
                // next_fcs_byte_count = 0;
                rx_next_state = WAIT_IFG;
            end
        end

        // FCS: begin
        //     if (gmii_rx_dv) begin
        //         // capture received FCS bytes
        //         case (fcs_byte_count)
        //             0: next_received_fcs[7:0] = gmii_rx_data;
        //             1: next_received_fcs[15:8] = gmii_rx_data;
        //             2: next_received_fcs[23:16] = gmii_rx_data;
        //             3: begin
        //                 next_received_fcs[31:24] = gmii_rx_data;
        //                 // completed FCS capture, check CRC
        //                 if (crc_reg != CRC32_CONSTANT) begin
        //                     // CRC mismatch
        //                     next_frame_error = 1'b1;
        //                     next_crc_valid = 1'b0;
        //                 end else begin
        //                     next_crc_valid = 1'b1;
        //                 end
        //                 // frame done, go to WAIT_IFG
        //                 rx_next_state = WAIT_IFG;
        //             end
        //         endcase
        //         next_fcs_byte_count = fcs_byte_count + 1;
        //     end else begin
        //         // dv deasserted early during FCS
        //         next_frame_error = 1'b1;
        //         rx_next_state = WAIT_IFG;
        //     end
        // end

        WAIT_IFG: begin
            // wait for inter-frame gap to finish
            if (ifg_count + 1 == (IFG_LENGTH - 1)) begin // last IFG cycle
                // reset errors
                next_frame_error = 1'b0;
                // next_crc_valid = 1'b1;
                // reset ctrs
                next_fcs_byte_count = 0;
                next_ifg_count = 0;

                rx_next_state = IDLE;
            end else if (ifg_count == 0) begin // first IFG cycle
                // completed FCS capture, check CRC
                if (crc_reg != CRC32_CONSTANT) begin
                    // CRC mismatch
                    next_frame_error = 1'b1;
                    // next_crc_valid = 1'b0;
                    next_crc_error_count = crc_error_count + 1;
                end 
                // update debug ctrs - accumulate until full reset
                next_rx_frame_count = rx_frame_count + 1;
                if (next_frame_error) begin
                    next_rx_error_count = rx_error_count + 1;
                end
                // else begin
                //      next_crc_valid = 1'b1;
                // end
                /* 
                    send metadata (error and length) to frame parser via FIFO
                    NOTE: length needs up to 11 bits to cover 64 to 1518 bytes, so we must send over two cycles:
                        cycle 1: send error + lower 7 bits of length
                        cycle 2: send upper 4 bits of length, padded with zeros
                    use eof as flag in FIFO to indicate metadata, eof=1, sof=0, valid=1
                    NOTE: at this point, frame error is too late to be raised for fifo full errors
                */
                if (!fifo_full) begin
                    next_fifo_wr_en = 1'b1;
                    next_fifo_din = {1'b1, frame_error, byte_count[6:0]}; // eof=1, error, data = byte_count[6:0]
                end else begin
                    // next_frame_error = 1'b1;
                    next_fifo_overflow_count = fifo_overflow_count + 1;
                end
                next_ifg_count = ifg_count + 1;
            end else if (ifg_count == 1) begin // second IFG cycle
                if (!fifo_full) begin
                    next_fifo_wr_en = 1'b1;
                    next_fifo_din = {1'b1, {(8-($clog2(MAX_FRAME_SIZE)-7)){1'b0}}, byte_count[$clog2(MAX_FRAME_SIZE)-1:7]}; // eof=1, data = {4{1'b0}, byte_count[10:7]}
                end else begin
                    // next_frame_error = 1'b1;
                    next_fifo_overflow_count = fifo_overflow_count + 1;
                end
                next_ifg_count = ifg_count + 1;
            end else begin
                next_ifg_count = ifg_count + 1;
            end
        end

        default: rx_next_state = IDLE;
    endcase
end

// =========================================================================
// RX state machine (GMII clk domain) - seq logic 
// =========================================================================

// reset async assert sync deassert
logic sync_switch_rst_n;
synchronizer switch_rst_sync_inst (
    .clk(gmii_rx_clk),
    .rst_n_in(switch_rst_n),
    .rst_n_out(sync_switch_rst_n)
);

always_ff @(posedge gmii_rx_clk or negedge sync_switch_rst_n) begin
    if (!sync_switch_rst_n) begin
        rx_current_state <= IDLE;
        preamble_count <= 0;
        byte_count <= 0;
        crc_reg <= 32'hFFFFFFFF; // initial ethernet seed value
        received_fcs <= 0;
        crc_valid <= 0;
        fcs_byte_count <= 0;
        preamble_error_count <= 0;
        rx_frame_count <= 0;
        crc_error_count <= 0;
        rx_error_count <= 0;
        fifo_overflow_count <= 0;
        ifg_count <= 0;
        fifo_wr_en <= 0;
        fifo_din <= 0;
        frame_error <= 0;
    end else begin
        rx_current_state <= rx_next_state;
        preamble_count <= next_preamble_count;
        byte_count <= next_byte_count;
        crc_reg <= next_crc_reg;
        received_fcs <= next_received_fcs;
        // crc_valid <= next_crc_valid;
        // fcs_byte_count <= next_fcs_byte_count;
        preamble_error_count <= next_preamble_error_count;
        rx_frame_count <= next_rx_frame_count;
        crc_error_count <= next_crc_error_count;
        rx_error_count <= next_rx_error_count;
        fifo_overflow_count <= next_fifo_overflow_count;
        ifg_count <= next_ifg_count;
        fifo_wr_en <= next_fifo_wr_en;
        fifo_din <= next_fifo_din;
        frame_error <= next_frame_error;
    end
end


// =========================================================================
// output state machine (switch clk domain) - comb logic 
// =========================================================================

typedef enum [2:0] logic {
    OUT_IDLE,
    OUT_HEADER,
    OUT_READ,
    OUT_EOF,
    OUT_APPEND
} out_state_t;

out_state_t out_current_state, out_next_state;
logic [$clog2(BLOCK_SIZE)-1:0] block_size_ctr, next_block_size_ctr;
logic byte_eof; assign byte_eof = fifo_dout[DATA_WIDTH]; // eof byte from fifo

always_comb begin
    // default values
    out_next_state = out_current_state;
    next_fifo_rd_en = 1'b0;
    next_mac_src_addr = mac_src_addr;
    next_mac_dst_addr = mac_dst_addr;
    next_mac_type = mac_type;
    next_mac_src_valid = 1'b0;
    next_mac_dst_valid = 1'b0;
    next_mac_type_valid = 1'b0;
    next_frame_data = frame_data;
    // next_frame_byte_data = fifo_dout[DATA_WIDTH-1:0];
    next_block_size_ctr = block_size_ctr;
    next_frame_eof = 1'b0;
    // next_frame_sof = fifo_dout[DATA_WIDTH+1];
    // next_frame_valid = fifo_dout[DATA_WIDTH+2]; // past: eof, sof, valid, data[7:0]
    next_frame_valid = 1'b0;
    next_frame_length = frame_length;
    next_frame_error = frame_error;
    next_fifo_underflow_count = fifo_underflow_count;

    case (out_current_state)
        OUT_IDLE: begin
            if (!fifo_empty) begin // start reading 
                // eof=0, error, data
                next_fifo_rd_en = 1'b1;
                next_frame_data = {frame_data[BLOCK_SIZE-1:1], fifo_dout[DATA_WIDTH-1:0]}; // shift in new byte
                next_block_size_ctr = block_size_ctr + 1;
                out_next_state = OUT_HEADER;
            end
        end
        OUT_HEADER: begin
            // parse header bytes for MAC addresses
            if (block_size_ctr == 5) begin
                next_mac_dst_addr = {frame_data[4:0][7:0], fifo_dout[DATA_WIDTH-1:0]};
                next_mac_dst_valid = 1'b1;
            end else if (block_size_ctr == 11) begin
                next_mac_src_addr = {frame_data[10:6][7:0], fifo_dout[DATA_WIDTH-1:0]};
                next_mac_src_valid = 1'b1;
            end else if (block_size_ctr == 13) begin
                next_mac_type = {frame_data[12:12][7:0], fifo_dout[DATA_WIDTH-1:0]};
                next_mac_type_valid = 1'b1;
            end
            if (block_size_ctr == BLOCK_SIZE-1) begin
                // completed block, set valid high
                next_frame_valid = 1'b1;
                // next_block_size_ctr = 0; // done below
            end 
            if (!fifo_empty) begin // continue reading 
                // eof=0, error, data
                next_fifo_rd_en = 1'b1;
                next_frame_data = {frame_data[BLOCK_SIZE-1:1], fifo_dout[DATA_WIDTH-1:0]}; 
                next_block_size_ctr = block_size_ctr + 1;
            end else begin
                next_fifo_underflow_count = fifo_underflow_count + 1;
                next_frame_valid = 1'b0; // otherwise could be stuck high
                // assume we stay in this state until we can read more data
            end
        end
        OUT_READ: begin
            if (block_size_ctr == BLOCK_SIZE-1) begin
                // completed block, set valid high
                next_frame_valid = 1'b1;
                // next_block_size_ctr = 0; // done below
            end 
            if (!fifo_empty) begin // continue reading 
                // eof=1, error, data = byte_count[6:0]
                next_fifo_rd_en = 1'b1;
                next_frame_data = {frame_data[BLOCK_SIZE-1:1], fifo_dout[DATA_WIDTH-1:0]}; 
                next_block_size_ctr = block_size_ctr + 1;
                if (byte_eof) begin // eof detected  
                    next_frame_error = fifo_dout[DATA_WIDTH-1]; // error bit
                    next_frame_length = {fifo_dout[DATA_WIDTH-2:0]}; // get lower 7 bits
                    out_next_state = OUT_EOF;
                end
            end else begin
                next_fifo_underflow_count = fifo_underflow_count + 1;
                next_frame_valid = 1'b0; 
            end
        end

        OUT_EOF: begin
            if (block_size_ctr == BLOCK_SIZE-1) begin
                // completed block, set valid high
                next_frame_valid = 1'b1;
                next_frame_eof = 1'b1;
                // next_block_size_ctr = 0;
            end 
            if (!fifo_empty) begin 
                // eof=1, data = {4{1'b0}, byte_count[10:7]}
                next_frame_length = {fifo_dout[$clog2(MAX_FRAME_SIZE)-1-7:0], next_frame_length[DATA_WIDTH-2:0]}; // reconstruct length from two cycles
                next_block_size_ctr = block_size_ctr + 1;
                out_next_state = block_size_ctr == BLOCK_SIZE-1 ? OUT_READ : OUT_APPEND; // if block is incomplete, go to append state
            end else begin
                next_fifo_underflow_count = fifo_underflow_count + 1;
                next_frame_valid = 1'b0;
            end
        end

        OUT_APPEND: begin
            if (block_size_ctr == BLOCK_SIZE-1) begin
                // completed block, set valid high
                next_frame_valid = 1'b1;
                next_frame_eof = 1'b1;
                // next_block_size_ctr = 0;
                out_next_state = OUT_READ;
            end else begin
                next_frame_data = {frame_data[BLOCK_SIZE-1:1], 1'b0}; // shift in new byte
                next_block_size_ctr = block_size_ctr + 1;
                // stay in this state until block complete
            end
        end

        default: out_next_state = OUT_IDLE;
    endcase
end

// =========================================================================
// output state machine (switch clk domain) - seq logic 
// =========================================================================

always_ff @(posedge switch_clk or negedge sync_switch_rst_n) begin
    if (!sync_switch_rst_n) begin
        out_current_state <= OUT_IDLE;
        fifo_rd_en <= 1'b0;
        frame_data <= 0;
        // frame_byte_data <= 0;
        block_size_ctr <= 0;
        frame_eof <= 0;
        // frame_sof <= 0;
        frame_valid <= 0;
        frame_length <= 0;
        frame_error <= 0;
        fifo_underflow_count <= 0;
    end else begin
        out_current_state <= out_next_state;
        fifo_rd_en <= next_fifo_rd_en;
        frame_data <= next_frame_data;
        // frame_byte_data <= next_frame_byte_data;
        block_size_ctr <= next_block_size_ctr;
        frame_eof <= next_frame_eof;
        // frame_sof <= next_frame_sof;
        frame_valid <= next_frame_valid;
        frame_length <= next_frame_length;
        frame_error <= next_frame_error;
        fifo_underflow_count <= next_fifo_underflow_count;
    end
end
    
endmodule

module synchronizer (
    input logic clk,
    input logic rst_n_in,
    output logic rst_n_out
);
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