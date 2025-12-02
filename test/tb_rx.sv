`timescale 1ns / 1ps

`include "rx_tx_pkg.svh"
// import params and crc32 function
import rx_tx_pkg::*;

module tb_rx;

    // parameters
    parameter DATA_WIDTH = 8;
    parameter GMII_CLK_PERIOD = 8;    // 125 MHz
    parameter SWITCH_CLK_PERIOD = 10; // 100 MHz
    
    // tb signals
    logic gmii_rx_clk;
    logic [DATA_WIDTH-1:0] gmii_rx_data;
    logic gmii_rx_dv;
    logic gmii_rx_er;
    logic switch_clk;
    logic switch_rst_n;
    
    // grant signals (from tb to DUT)
    logic mac_dst_grant;
    logic mac_src_grant;
    logic mac_type_grant;
    logic frame_grant;
    
    // DUT outputs
    logic [5:0][7:0] mac_dst_addr, mac_src_addr;
    logic [1:0][7:0] mac_type;
    logic mac_dst_valid, mac_src_valid, mac_type_valid;
    logic [DATA_WIDTH-1:0] frame_data;
    logic frame_valid;
    logic frame_sof;
    logic frame_eof;
    logic frame_error;
    logic [31:0] crc_error_count;
    logic [31:0] rx_error_count;
    logic [31:0] rx_frame_count;
    logic [31:0] fifo_overflow_count;
    logic [31:0] fifo_underflow_count;
    
    // test variables
    int byte_index;
    int test_num;
    
    // DUT Instantiation    
    rx_mac_control #(
        .DATA_WIDTH(DATA_WIDTH)
    ) dut (
        .gmii_rx_clk(gmii_rx_clk),
        .gmii_rx_data(gmii_rx_data),
        .gmii_rx_dv(gmii_rx_dv),
        .gmii_rx_er(gmii_rx_er),
        .switch_clk(switch_clk),
        .switch_rst_n(switch_rst_n),
        .mac_dst_addr(mac_dst_addr),
        .mac_src_addr(mac_src_addr),
        .mac_type(mac_type),
        .mac_dst_valid(mac_dst_valid),
        .mac_src_valid(mac_src_valid),
        .mac_type_valid(mac_type_valid),
        .mac_dst_grant(mac_dst_grant),
        .mac_src_grant(mac_src_grant),
        .mac_type_grant(mac_type_grant),
        .frame_data(frame_data),
        .frame_valid(frame_valid),
        .frame_grant(frame_grant),
        .frame_sof(frame_sof),
        .frame_eof(frame_eof),
        .frame_error(frame_error),
        .crc_error_count(crc_error_count),
        .rx_error_count(rx_error_count),
        .rx_frame_count(rx_frame_count),
        .fifo_overflow_count(fifo_overflow_count),
        .fifo_underflow_count(fifo_underflow_count)
    );
    
    initial begin
        gmii_rx_clk = 0;
        forever #(GMII_CLK_PERIOD/2) gmii_rx_clk = ~gmii_rx_clk;
    end
    
    initial begin
        switch_clk = 0;
        forever #(SWITCH_CLK_PERIOD/2) switch_clk = ~switch_clk;
    end
    
    function automatic [31:0] crc32_next(input logic [7:0] data, input logic [31:0] crc_in);
        integer i;
        logic [31:0] crc;
        logic [7:0] data_reflected;
        // ethernet data comes in lSB first, so reflect byte
        data_reflected = {data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]};
        crc = crc_in ^ (data_reflected << 24);
        // unrolls into 8 shifts/xors
        for (i = 0; i < 8; i = i + 1) begin
            if (crc[31]) begin
                crc = (crc << 1) ^ CRC32_POLY_REFLECTED;
            end else begin
                crc = crc << 1;
            end
        end
        return ~crc; // final inversion step needed(?)
    endfunction
    
    // grant logic
    initial begin
        mac_dst_grant = 1'b0;
        mac_src_grant = 1'b0;
        mac_type_grant = 1'b0;
        frame_grant = 1'b0;
        wait(switch_rst_n);
        repeat(5) @(posedge switch_clk);
        
        // grant by default (no backpressure)
        mac_dst_grant = 1'b1;
        mac_src_grant = 1'b1;
        mac_type_grant = 1'b1;
        frame_grant = 1'b1;
    end
    
    // monitor 
    always @(posedge switch_clk) begin
        if (frame_sof) begin
            $display("[%0t] SOF detected", $time);
        end
        
        if (frame_valid) begin
            $display("[%0t] Data: %h", $time, frame_data);
        end
        
        if (frame_eof) begin
            $display("[%0t] EOF detected - Error: %b", $time, frame_error);
            $display("---");
        end
        
        if (mac_dst_valid && mac_dst_grant) begin
            $display("[%0t] DST MAC: %h:%h:%h:%h:%h:%h", $time,
                     mac_dst_addr[5], mac_dst_addr[4], mac_dst_addr[3],
                     mac_dst_addr[2], mac_dst_addr[1], mac_dst_addr[0]);
        end
        
        if (mac_src_valid && mac_src_grant) begin
            $display("[%0t] SRC MAC: %h:%h:%h:%h:%h:%h", $time,
                     mac_src_addr[5], mac_src_addr[4], mac_src_addr[3],
                     mac_src_addr[2], mac_src_addr[1], mac_src_addr[0]);
        end
        
        if (mac_type_valid && mac_type_grant) begin
            $display("[%0t] ETH TYPE: %h", $time, {mac_type[1], mac_type[0]});
        end
    end
    
    initial begin
        logic [31:0] crc;
        
        // init signals
        gmii_rx_data = 8'h00;
        gmii_rx_dv = 1'b0;
        gmii_rx_er = 1'b0;
        switch_rst_n = 1'b0;
        test_num = 0;
        
        // rst
        repeat(20) @(posedge switch_clk);
        switch_rst_n = 1'b1;
        repeat(20) @(posedge switch_clk);
        
        // test 1: min size frame with grants enabled
        test_num = 1;
        $display("\n=== Test %0d: Minimum size frame (all grants enabled) ===", test_num);
        
        crc = 32'hFFFFFFFF;
        
        repeat(10) @(posedge gmii_rx_clk);
        
        // send preamble + SFD
        @(posedge gmii_rx_clk);
        gmii_rx_dv = 1'b1;
        for (byte_index = 0; byte_index < 7; byte_index++) begin
            gmii_rx_data = 8'h55;
            @(posedge gmii_rx_clk);
        end
        gmii_rx_data = 8'hD5;
        @(posedge gmii_rx_clk);
        
        // dst MAC: FF:FF:FF:FF:FF:FF
        gmii_rx_data = 8'hFF; crc = calc_crc32(8'hFF, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'hFF; crc = calc_crc32(8'hFF, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'hFF; crc = calc_crc32(8'hFF, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'hFF; crc = calc_crc32(8'hFF, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'hFF; crc = calc_crc32(8'hFF, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'hFF; crc = calc_crc32(8'hFF, crc); @(posedge gmii_rx_clk);
        
        // src MAC: 11:22:33:44:55:66
        gmii_rx_data = 8'h11; crc = calc_crc32(8'h11, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h22; crc = calc_crc32(8'h22, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h33; crc = calc_crc32(8'h33, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h44; crc = calc_crc32(8'h44, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h55; crc = calc_crc32(8'h55, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h66; crc = calc_crc32(8'h66, crc); @(posedge gmii_rx_clk);
        
        // EtherType: 0x0800 (IPv4)
        gmii_rx_data = 8'h08; crc = calc_crc32(8'h08, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h00; crc = calc_crc32(8'h00, crc); @(posedge gmii_rx_clk);
        
        // payload (46 bytes min for 64-byte frame)
        for (byte_index = 0; byte_index < 46; byte_index++) begin
            gmii_rx_data = byte_index[7:0];
            crc = calc_crc32(byte_index[7:0], crc);
            @(posedge gmii_rx_clk);
        end
        
        // FCS (4 bytes CRC, LSB first)
        gmii_rx_data = crc[7:0];   @(posedge gmii_rx_clk);
        gmii_rx_data = crc[15:8];  @(posedge gmii_rx_clk);
        gmii_rx_data = crc[23:16]; @(posedge gmii_rx_clk);
        gmii_rx_data = crc[31:24]; @(posedge gmii_rx_clk);
        
        // eof (deassert dv)
        gmii_rx_dv = 1'b0;
        gmii_rx_data = 8'h00;
        
        // IFG (12 bytes)
        repeat(12) @(posedge gmii_rx_clk);
        
        // wait
        repeat(100) @(posedge switch_clk);
        
        // test 2: backpressure on frame_grant
        test_num = 2;
        $display("\n=== Test %0d: Frame with backpressure ===", test_num);
        
        // background process to toggle frame_grant during this test
        fork
            begin
                // toggle frame_grant 
                repeat(50) begin
                    @(posedge switch_clk);
                    frame_grant = ~frame_grant;
                end
                frame_grant = 1'b1; // re-enable at end
            end
        join_none
        
        crc = 32'hFFFFFFFF;
        
        gmii_rx_dv = 1'b1;
        for (byte_index = 0; byte_index < 7; byte_index++) begin
            gmii_rx_data = 8'h55;
            @(posedge gmii_rx_clk);
        end
        gmii_rx_data = 8'hD5;
        @(posedge gmii_rx_clk);
        
        // dst MAC: AA:BB:CC:DD:EE:FF
        gmii_rx_data = 8'hAA; crc = calc_crc32(8'hAA, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'hBB; crc = calc_crc32(8'hBB, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'hCC; crc = calc_crc32(8'hCC, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'hDD; crc = calc_crc32(8'hDD, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'hEE; crc = calc_crc32(8'hEE, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'hFF; crc = calc_crc32(8'hFF, crc); @(posedge gmii_rx_clk);
        
        // src MAC: 00:11:22:33:44:55
        gmii_rx_data = 8'h00; crc = calc_crc32(8'h00, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h11; crc = calc_crc32(8'h11, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h22; crc = calc_crc32(8'h22, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h33; crc = calc_crc32(8'h33, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h44; crc = calc_crc32(8'h44, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h55; crc = calc_crc32(8'h55, crc); @(posedge gmii_rx_clk);
        
        // EtherType: 0x86DD (IPv6)
        gmii_rx_data = 8'h86; crc = calc_crc32(8'h86, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'hDD; crc = calc_crc32(8'hDD, crc); @(posedge gmii_rx_clk);
        
        for (byte_index = 0; byte_index < 100; byte_index++) begin
            gmii_rx_data = (byte_index * 3) % 256;
            crc = calc_crc32((byte_index * 3) % 256, crc);
            @(posedge gmii_rx_clk);
        end
        
        gmii_rx_data = crc[7:0];   @(posedge gmii_rx_clk);
        gmii_rx_data = crc[15:8];  @(posedge gmii_rx_clk);
        gmii_rx_data = crc[23:16]; @(posedge gmii_rx_clk);
        gmii_rx_data = crc[31:24]; @(posedge gmii_rx_clk);
        
        gmii_rx_dv = 1'b0;
        gmii_rx_data = 8'h00;
        
        repeat(12) @(posedge gmii_rx_clk);
        
        repeat(300) @(posedge switch_clk);
        
        // test 3: delayed MAC address grants
        test_num = 3;
        $display("\n=== Test %0d: Frame with delayed MAC address grants ===", test_num);
        
        // deassert grants
        @(posedge switch_clk);
        mac_dst_grant = 1'b0;
        mac_src_grant = 1'b0;
        mac_type_grant = 1'b0;
        
        crc = 32'hFFFFFFFF;
        
        gmii_rx_dv = 1'b1;
        for (byte_index = 0; byte_index < 7; byte_index++) begin
            gmii_rx_data = 8'h55;
            @(posedge gmii_rx_clk);
        end
        gmii_rx_data = 8'hD5;
        @(posedge gmii_rx_clk);
        
        // dst MAC: 12:34:56:78:9A:BC
        gmii_rx_data = 8'h12; crc = calc_crc32(8'h12, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h34; crc = calc_crc32(8'h34, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h56; crc = calc_crc32(8'h56, crc); @(posedge gmii_rx_clk);
        
        // grant dst after a few bytes
        repeat(10) @(posedge switch_clk);
        mac_dst_grant = 1'b1;
        
        gmii_rx_data = 8'h78; crc = calc_crc32(8'h78, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h9A; crc = calc_crc32(8'h9A, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'hBC; crc = calc_crc32(8'hBC, crc); @(posedge gmii_rx_clk);
        
        // src MAC: DE:F0:12:34:56:78
        gmii_rx_data = 8'hDE; crc = calc_crc32(8'hDE, crc); @(posedge gmii_rx_clk);
        
        repeat(10) @(posedge switch_clk);
        mac_src_grant = 1'b1;
        
        gmii_rx_data = 8'hF0; crc = calc_crc32(8'hF0, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h12; crc = calc_crc32(8'h12, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h34; crc = calc_crc32(8'h34, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h56; crc = calc_crc32(8'h56, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h78; crc = calc_crc32(8'h78, crc); @(posedge gmii_rx_clk);
        
        // EtherType: 0806 (ARP)
        gmii_rx_data = 8'h08; crc = calc_crc32(8'h08, crc); @(posedge gmii_rx_clk);
        
        repeat(10) @(posedge switch_clk);
        mac_type_grant = 1'b1;
        
        gmii_rx_data = 8'h06; crc = calc_crc32(8'h06, crc); @(posedge gmii_rx_clk);
        
        for (byte_index = 0; byte_index < 46; byte_index++) begin
            gmii_rx_data = 8'hA5;
            crc = calc_crc32(8'hA5, crc);
            @(posedge gmii_rx_clk);
        end
        
        gmii_rx_data = crc[7:0];   @(posedge gmii_rx_clk);
        gmii_rx_data = crc[15:8];  @(posedge gmii_rx_clk);
        gmii_rx_data = crc[23:16]; @(posedge gmii_rx_clk);
        gmii_rx_data = crc[31:24]; @(posedge gmii_rx_clk);
        
        gmii_rx_dv = 1'b0;
        gmii_rx_data = 8'h00;
        
        repeat(12) @(posedge gmii_rx_clk);
        
        repeat(100) @(posedge switch_clk);
        
        // test 4: invalid CRC
        test_num = 4;
        $display("\n=== Test %0d: Frame with bad CRC ===", test_num);
        
        crc = 32'hFFFFFFFF;
        
        gmii_rx_dv = 1'b1;
        for (byte_index = 0; byte_index < 7; byte_index++) begin
            gmii_rx_data = 8'h55;
            @(posedge gmii_rx_clk);
        end
        gmii_rx_data = 8'hD5;
        @(posedge gmii_rx_clk);
        
        // dst MAC: 99:88:77:66:55:44
        gmii_rx_data = 8'h99; crc = calc_crc32(8'h99, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h88; crc = calc_crc32(8'h88, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h77; crc = calc_crc32(8'h77, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h66; crc = calc_crc32(8'h66, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h55; crc = calc_crc32(8'h55, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h44; crc = calc_crc32(8'h44, crc); @(posedge gmii_rx_clk);
        
        // src MAC: 33:22:11:00:FF:EE
        gmii_rx_data = 8'h33; crc = calc_crc32(8'h33, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h22; crc = calc_crc32(8'h22, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h11; crc = calc_crc32(8'h11, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h00; crc = calc_crc32(8'h00, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'hFF; crc = calc_crc32(8'hFF, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'hEE; crc = calc_crc32(8'hEE, crc); @(posedge gmii_rx_clk);
        
        // EtherType: 0x0800 (IPv4)
        gmii_rx_data = 8'h08; crc = calc_crc32(8'h08, crc); @(posedge gmii_rx_clk);
        gmii_rx_data = 8'h00; crc = calc_crc32(8'h00, crc); @(posedge gmii_rx_clk);
        
        for (byte_index = 0; byte_index < 46; byte_index++) begin
            gmii_rx_data = 8'h5A;
            crc = calc_crc32(8'h5A, crc);
            @(posedge gmii_rx_clk);
        end
        
        // send wrong FCS (flip all bits)
        gmii_rx_data = crc[7:0] ^ 8'hFF;   @(posedge gmii_rx_clk); 
        gmii_rx_data = crc[15:8] ^ 8'hFF;  @(posedge gmii_rx_clk);
        gmii_rx_data = crc[23:16] ^ 8'hFF; @(posedge gmii_rx_clk);
        gmii_rx_data = crc[31:24] ^ 8'hFF; @(posedge gmii_rx_clk);
        
        gmii_rx_dv = 1'b0;
        gmii_rx_data = 8'h00;
        
        repeat(12) @(posedge gmii_rx_clk);
        
        repeat(100) @(posedge switch_clk);
        
        // Test Summary
        $display("\n========================================");
        $display("Test Summary");
        $display("RX frames received:  %0d", rx_frame_count);
        $display("RX errors:           %0d", rx_error_count);
        $display("CRC errors:          %0d", crc_error_count);
        $display("FIFO overflows:      %0d", fifo_overflow_count);
        $display("FIFO underflows:     %0d", fifo_underflow_count);
        $display("========================================\n");
        
        if (rx_frame_count != 4 || crc_error_count != 1) begin
            $display("Exp: 4 frames, 1 CRC error");
            $display("Got: %0d frames, %0d CRC errors", rx_frame_count, crc_error_count);
        end
        
        $finish;
    end

endmodule