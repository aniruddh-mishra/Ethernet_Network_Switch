module rx_mac_control (
    // GMII interface
    input logic gmii_rx_clk_i,
    input logic [DATA_WIDTH-1:0] gmii_rx_data_i,
    input logic gmii_rx_dv_i,
    input logic gmii_rx_er_i,
    
    // switch's clk domain
    input logic switch_clk, switch_rst_n,

    // outputs to MAC learning/lookup - specific to bytes
    output logic [5:0][7:0] mac_dst_addr_o, mac_src_addr_o,

    // outputs to learning/lookup and memory
    output logic [DATA_WIDTH-1:0] frame_data_o, // outputs data one byte at a time
    output logic frame_valid_o, // high for every cycle data is valid
    input logic frame_grant_i, // from mem
    output logic frame_sof_o, // single high start of frame - set on first valid data outputted
    output logic frame_eof_o, // single high end of frame - follows after last data/FCS byte - implicitly handles FIFO_full too which drops bytes
    output logic frame_error_o // high at eof if CRC or other error
);

// status and debug signals (simulation only)
logic [31:0] crc_error_count; // # of frames with CRC errors
logic [31:0] rx_error_count; // # of frames with any errors
logic [31:0] rx_frame_count; // # of frames received (valid or invalid)
logic [31:0] fifo_overflow_count; // # of times FIFO was full when trying to write - gmii clk domain
logic [31:0] fifo_underflow_count; // # of times FIFO was empty when trying to read in eof metadata state - switch clk domain

// FIFO signals for CDC (GMII -> switch clk)
logic [DATA_WIDTH-1:0] fifo_dout;
logic fifo_rd_en; // continuous signal, no reg
logic fifo_full;
logic fifo_empty;

// sync switch clk reset to gmii/PHY clk
logic sync_switch_rst_n;
synchronizer sync_rst(gmii_rx_clk_i, switch_rst_n, sync_switch_rst_n);

// CDC FIFO instance (async FIFO)
async_fifo cdc_fifo (
    .wclk(gmii_rx_clk_i),
    .wrst_n(sync_switch_rst_n),
    .w_en(gmii_rx_dv_i && !gmii_rx_er_i),
    .w_data(gmii_rx_data_i),
    .w_full(fifo_full),
    
    .rclk(switch_clk),
    .rrst_n(switch_rst_n),
    .r_en(fifo_rd_en),
    .r_data(fifo_dout),
    .r_empty(fifo_empty)
);

// output state machine (switch clk domain) - comb logic 
typedef enum logic [1:0] {IDLE, PREAMBLE, HEADER, PAYLOAD} state_t;

state_t current_state, next_state;

logic [4:0] preamble_header_ctr, next_preamble_header_ctr; // preamble = 8 bytes, header = 6 + 6 + 2 bytes, total = 22 bytes
logic prev_fifo_rd_en; // needed b/c 1st cycle: req read, 2nd cycle: check data
logic [5:0][7:0] next_mac_dst_addr_o, next_mac_src_addr_o;
logic [DATA_WIDTH-1:0] next_frame_data_o;
logic next_frame_valid_o;
logic next_frame_sof_o; logic next_frame_eof_o; logic next_frame_error_o;

// output status and debug signals
logic [31:0] next_crc_error_count; 
logic [31:0] next_rx_error_count; 
logic [31:0] next_rx_frame_count; 

// data valid and error logic
logic rx_dv, rx_er; 
logic [1:0] gmii_rx_dv_i_sync, gmii_rx_er_i_sync;
always_ff @(posedge switch_clk or negedge switch_rst_n) begin
    if (!switch_rst_n) begin
        gmii_rx_dv_i_sync <= 0;
        gmii_rx_er_i_sync <= 0;
    end else begin
        gmii_rx_dv_i_sync <= {gmii_rx_dv_i_sync[0], gmii_rx_dv_i};
        gmii_rx_er_i_sync <= {gmii_rx_er_i_sync[0], gmii_rx_er_i};
    end
end
assign rx_dv = gmii_rx_dv_i_sync[1]; 
assign rx_er = gmii_rx_er_i_sync[1];

// crc logic
logic [31:0] crc_reg, next_crc_reg;
// instead of looking for CRC_32 constant, create a 4-deep buffer for CRC and 3-deep buffer for data to compare FCS vs CRC before FCS
/*
    when (!rx_dv && prev_prev_fifo_rd_en), 
    crc_buffer = {crc after final data, crc after FCS byte 1, crc after FCS byte 2, crc after FCS byte 3}, crc_reg = crc after FCS byte 4
    data_buffer = {FCS byte 1, FCS byte 2, FCS byte 3}, frame_data_o = FCS byte 4
*/
logic [3:0][31:0] crc_buffer;
logic [2:0][7:0] data_buffer;
logic prev_prev_fifo_rd_en;
always_ff @(posedge switch_clk) begin
    prev_prev_fifo_rd_en <= prev_fifo_rd_en;
    if (prev_prev_fifo_rd_en && rx_dv && frame_grant_i) begin // only update when crc_reg and frame_data_o have just been updated with valid results, except for final time (!rx_dv) or frozen (!frame_grant_i)
        crc_buffer <= {crc_buffer[2:0], crc_reg}; // crc reg is clocked already, this stores 5 total clocked values --> needed for crc before all 4 FCS bytes
        data_buffer <= {data_buffer[1:0], frame_data_o}; // frame_data_o is also clocked, only 4 values needed for FCS
        // $display("[%0t] DUT CRC buffer updated: %h %h %h %h", $time, crc_buffer[2], crc_buffer[1], crc_buffer[0], crc_reg);
        // $display("[%0t] DUT Data buffer updated: %h %h %h", $time, data_buffer[1], data_buffer[0], frame_data_o);
    end
end

always_comb begin
    // default values
    next_state = current_state;
    fifo_rd_en = 1'b0; // default false
    next_frame_valid_o = 1'b0; // default false
    next_crc_reg = crc_reg;
    next_preamble_header_ctr = preamble_header_ctr;
    next_mac_dst_addr_o = mac_dst_addr_o; next_mac_src_addr_o = mac_src_addr_o;
    next_frame_data_o = frame_data_o;
    next_frame_eof_o = 1'b0; next_frame_sof_o = 1'b0; // default false
    next_frame_error_o = rx_er || frame_error_o; // sticky error during frame
    
    // debug
    next_crc_error_count = crc_error_count;
    next_rx_error_count = rx_error_count;
    next_rx_frame_count = rx_frame_count;


    case (current_state)
        IDLE: begin // assume IFG is not violated from sender
            next_crc_reg = 32'hFFFFFFFF;
            next_frame_error_o = 1'b0; // resets frame error which stays high during frame
            if (!fifo_empty) fifo_rd_en = 1'b1; 
            if (prev_fifo_rd_en) begin
                if (fifo_dout == PREAMBLE_BYTE) begin
                    next_preamble_header_ctr = 1; // resets ctr
                    next_state = PREAMBLE;
                end
            end
        end
        PREAMBLE: begin
            if (!fifo_empty) fifo_rd_en = 1'b1;
            if (prev_fifo_rd_en) begin
                if (preamble_header_ctr == 7) begin
                    if (fifo_dout == SFD_BYTE) begin 
                        next_preamble_header_ctr = preamble_header_ctr + 1;
                        next_state = HEADER;
                    end else begin
                        next_state = IDLE; // invalid SFD byte, go back to IDLE
                    end
                end else begin
                    if (fifo_dout == PREAMBLE_BYTE) next_preamble_header_ctr = preamble_header_ctr + 1;
                    else next_state = IDLE; // invalid preamble byte, go back to IDLE
                end
            end
        end
        HEADER: begin // parse header bytes for MAC addresses
            if (!fifo_empty && frame_grant_i) begin
                fifo_rd_en = 1'b1; 
                if (frame_grant_i)$display("Reading FIFO in HEADER state");
            end 
            if (prev_fifo_rd_en) begin
                next_crc_reg = crc32_next(fifo_dout, crc_reg);
                // $display("[%0t] DUT in-progress CRC: %h", $time, next_crc_reg);

                if (preamble_header_ctr == 8) begin
                    next_frame_sof_o = 1'b1;
                    next_mac_dst_addr_o = {mac_dst_addr_o[4:0], fifo_dout}; // SIPO
                end else if (preamble_header_ctr < 14) begin // 8 + 6 = 14
                    next_mac_dst_addr_o = {mac_dst_addr_o[4:0], fifo_dout}; 
                end else if (preamble_header_ctr < 20) begin
                    next_mac_src_addr_o = {mac_src_addr_o[4:0], fifo_dout};
                end 
                // else if (preamble_header_ctr < 22) begin // ignore mac_type for now
                //     next_mac_type = {mac_type[0], fifo_dout};
                // end
                if (preamble_header_ctr == 21) next_state = PAYLOAD;
                if (frame_grant_i) $display("Incrementing preamble_header_ctr to %0d in HEADER state", preamble_header_ctr + 1);
                next_preamble_header_ctr = preamble_header_ctr + 1;
                next_frame_data_o = fifo_dout;
                if (frame_grant_i) $display("Sending data %h in HEADER state", fifo_dout);
                next_frame_valid_o = 1'b1;
            end
        end
        PAYLOAD: begin // assume frame fits within max and min bytes + follows IFG
            if (!fifo_empty && frame_grant_i) fifo_rd_en = 1'b1;
            if (prev_fifo_rd_en) begin
                next_crc_reg = crc32_next(fifo_dout, crc_reg);
                // $display("[%0t] DUT in-progress CRC: %h", $time, next_crc_reg);
                next_frame_data_o = fifo_dout;
                next_frame_valid_o = 1'b1;
            end else if (!rx_dv && prev_prev_fifo_rd_en) begin // sender has finished sending frame + we have read all data --> don't end early before last data
                $display("[%0t] Final DUT test, calc CRC %h vs exp CRC %h", $time, crc_buffer[3], {data_buffer, frame_data_o});
                if ((crc_buffer[3]) != {data_buffer, frame_data_o}) begin
                    next_frame_error_o = 1'b1; // allow payload to cut through, perform CRC calculations as data arrives, flag error at end
                    // update debug ctrs
                    next_crc_error_count = crc_error_count + 1;
                    next_rx_error_count = rx_error_count + 1;
                end
                next_frame_eof_o = 1'b1;
                next_state = IDLE;
                next_rx_frame_count = rx_frame_count + 1; // update debug ctrs
            end
        end
        default: next_state = IDLE;
    endcase
end

// output state machine (switch clk domain) - seq logic 
always_ff @(posedge switch_clk or negedge switch_rst_n) begin
    if (!switch_rst_n) begin
        current_state <= IDLE;
        prev_fifo_rd_en <= 0;
        frame_data_o <= 0;
        frame_eof_o <= 0;
        frame_sof_o <= 0;
        frame_valid_o <= 0;
        frame_error_o <= 0;
        preamble_header_ctr <= 0;
        mac_dst_addr_o <= 0;
        mac_src_addr_o <= 0;

        // debug
        crc_error_count <= 0;
        rx_error_count <= 0;
        rx_frame_count <= 0;
        fifo_underflow_count <= 0;
    end else begin
        if (frame_grant_i || (current_state == IDLE) || (current_state == PREAMBLE)) begin // freeze current data if mem is backed up during data sending (header/payload)
            current_state <= next_state;
            prev_fifo_rd_en <= fifo_rd_en;
            frame_data_o <= next_frame_data_o;
            frame_eof_o <= next_frame_eof_o;
            frame_sof_o <= next_frame_sof_o;
            frame_valid_o <= next_frame_valid_o;
            frame_error_o <= next_frame_error_o;
            preamble_header_ctr <= next_preamble_header_ctr;
            mac_dst_addr_o <= next_mac_dst_addr_o;
            mac_src_addr_o <= next_mac_src_addr_o;
            crc_reg <= next_crc_reg;
            
            // debug
            crc_error_count <= next_crc_error_count;
            rx_error_count <= next_rx_error_count;
            rx_frame_count <= next_rx_frame_count;
        end else begin
            if (!frame_grant_i && fifo_rd_en) prev_fifo_rd_en <= 1'b1; // the only case this will be true is if fifo_rd_en asserts on the same cycle grant is deasserted, so keep it high to not lose this byte
            if (!rx_dv) begin
                current_state <= IDLE; // if frame ended while mem backlogged, reset to IDLE, set error and eof for one cycle
                frame_error_o <= ((current_state == IDLE) || (current_state == PREAMBLE)) ? 1'b0 : 1'b1; // mark error + eof so mem knows frame ended
                frame_eof_o <= ((current_state == IDLE) || (current_state == PREAMBLE)) ? 1'b0 : 1'b1;
                rx_frame_count <= rx_frame_count + 1; 
            end
        end 

        if (!frame_grant_i) $display("[%0t] frame_grant_i deasserted", $time);

        if (fifo_empty) fifo_underflow_count <= fifo_underflow_count + 1;
    end
end

// debug for gmii
always_ff @(posedge gmii_rx_clk_i or negedge sync_switch_rst_n) begin
    if (!sync_switch_rst_n) begin
        fifo_overflow_count <= 0;
    end else begin
        if (fifo_full) fifo_overflow_count <= fifo_overflow_count + 1;
    end
end

endmodule
