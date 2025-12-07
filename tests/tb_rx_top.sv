// unused macro
// `define RX(port) dut.GEN_RX_MAC[port].rx_mac_control_u

module tb_rx_top;

// Import the package
import rx_tx_pkg::*;
import mem_pkg::*;
import switch_pkg::*;

// Parameters
localparam GMII_CLK_PERIOD = 8;  // 125 MHz
localparam SWITCH_CLK_PERIOD = 2; // 500 MHz

// DUT signals
logic gmii_rx_clk;
logic [DATA_WIDTH-1:0] gmii_rx_data [NUM_PORTS];
logic gmii_rx_dv [NUM_PORTS];
logic gmii_rx_er [NUM_PORTS];
logic switch_clk, switch_rst_n;

// Clock generation
initial begin
    gmii_rx_clk = 0;
    forever #(GMII_CLK_PERIOD/2) gmii_rx_clk = ~gmii_rx_clk;
end

initial begin
    switch_clk = 0;
    forever #(SWITCH_CLK_PERIOD/2) switch_clk = ~switch_clk;
end

// DUT instantiation
rx_top dut (
    // GMII interface
    .gmii_rx_clk_i(gmii_rx_clk),
    .gmii_rx_data_i(gmii_rx_data),
    .gmii_rx_dv_i(gmii_rx_dv),
    .gmii_rx_er_i(gmii_rx_er),

    // switch's clk domain
    .switch_clk(switch_clk),
    .switch_rst_n(switch_rst_n)
);

// Task to send a byte on GMII interface
task send_byte(input logic [7:0] data, input logic [$clog2(NUM_PORTS)-1:0] port, input logic dv = 1'b1, input logic er = 1'b0);
    @(posedge gmii_rx_clk);
    gmii_rx_data[port] = data;
    gmii_rx_dv[port] = dv;
    gmii_rx_er[port] = er;
endtask

// Task to calculate CRC32 for a frame
function automatic logic [31:0] calc_crc32(input logic [7:0] frame_bytes[]);
    logic [31:0] crc = 32'hFFFFFFFF;
    foreach(frame_bytes[i]) begin
        crc = crc32_next(frame_bytes[i], crc);
        // $display("[%0t] CRC after byte %0d (%h): %h", $time, i, frame_bytes[i], crc);
    end
    $display("[%0t] Final CRC: %h", $time, crc);
    return crc; // No invert for final CRC
endfunction

// Task to send a complete Ethernet frame
task send_frame(
    input logic [47:0] dst_mac,
    input logic [47:0] src_mac,
    input logic [15:0] eth_type,
    input logic [7:0] payload[],
    input logic corrupt_crc = 1'b0,
    input logic [$clog2(NUM_PORTS)-1:0] port
);
    logic [31:0] crc;
    logic [7:0] frame_data[];
    int idx;
    
    $display("[%0t] [Port %0d] Sending frame: DST=%h, SRC=%h, Type=%h, Payload size=%0d, Corrupt CRC=%0b",
             $time, port, dst_mac, src_mac, eth_type, payload.size(), corrupt_crc);
    
    // Build frame for CRC calculation (header + payload)
    frame_data = new[14 + payload.size()];
    idx = 0;
    
    // Destination MAC (6 bytes)
    for(int i = 5; i >= 0; i--) frame_data[idx++] = dst_mac[i*8 +: 8];
    // Source MAC (6 bytes)
    for(int i = 5; i >= 0; i--) frame_data[idx++] = src_mac[i*8 +: 8];
    // EtherType (2 bytes)
    frame_data[idx++] = eth_type[15:8];
    frame_data[idx++] = eth_type[7:0];
    // Payload
    foreach(payload[i]) frame_data[idx++] = payload[i];
    
    // Calculate CRC
    crc = calc_crc32(frame_data);
    if (corrupt_crc) crc = crc ^ 32'hFFFFFFFF; // Corrupt it
    
    // Send preamble (7 bytes of 0x55)
    for(int i = 0; i < 7; i++) send_byte(8'h5, port);
    
    // Send SFD (1 byte of 0xD5)
    send_byte(8'hD5, port);
    
    // Send frame data
    foreach(frame_data[i]) send_byte(frame_data[i], port);
    
    // Send CRC (LSB first)
//    send_byte(crc[7:0]); $display("[%0t] Sent CRC byte: %h", $time, crc[7:0]);
//    send_byte(crc[15:8]); $display("[%0t] Sent CRC byte: %h", $time, crc[15:8]);
//    send_byte(crc[23:16]); $display("[%0t] Sent CRC byte: %h", $time, crc[23:16]);
//    send_byte(crc[31:24]); $display("[%0t] Sent CRC byte: %h", $time, crc[31:24]);
    // MSB first
    send_byte(crc[31:24], port); $display("[%0t] [Port %0d] Sent CRC byte: %h", $time, port, crc[31:24]);
    send_byte(crc[23:16], port); $display("[%0t] [Port %0d] Sent CRC byte: %h", $time, port, crc[23:16]);
    send_byte(crc[15:8], port); $display("[%0t] [Port %0d] Sent CRC byte: %h", $time, port, crc[15:8]);
    send_byte(crc[7:0], port); $display("[%0t] [Port %0d] Sent CRC byte: %h", $time, port, crc[7:0]);
    
    // End transmission
    @(posedge gmii_rx_clk);
    gmii_rx_dv = '{default:0};
    gmii_rx_data = '{default:0};
    
    // Inter-frame gap (12 bytes minimum)
    repeat(12) @(posedge gmii_rx_clk);
endtask

logic [$clog2(NUM_PORTS)-1:0] port; // outside begin end scope so monitor has same port
// Main test
initial begin
    logic [7:0] test_payload[];
    
    // Initialize signals
    gmii_rx_data = '{default:0};
    gmii_rx_dv = '{default:0};
    gmii_rx_er = '{default:0};
    switch_rst_n = 0;
    // frame_grant = 1; // Always grant for simplicity
    
    // Reset
    repeat(10) @(posedge switch_clk);
    switch_rst_n = 1;
    repeat(10) @(posedge switch_clk);
    
    $display("\n=== Test 1: Valid frame with correct CRC ===");
    test_payload = new[46]; // Minimum payload for 64-byte frame
    for(int i = 0; i < 46; i++) test_payload[i] = i[7:0];
    
    fork
        port = 0;
        begin 
        send_frame(
            .dst_mac(48'hFF_FF_FF_FF_FF_FF),  // Broadcast
            .src_mac(48'h00_11_22_33_44_55),
            .eth_type(16'h0800),  // IPv4
            .payload(test_payload),
            .corrupt_crc(1'b0),
            .port(port)
        );
        end
        
        begin
        // Wait for frame to be processed
        @(posedge dut.rx_mac_control_frame_sof[port]);
        $display("[%0t] [Port %0d] Frame SOF detected", $time, port);
        @(posedge dut.rx_mac_control_frame_eof[port]);
        $display("[%0t] [Port %0d] Frame EOF detected", $time, port);
        $display("[%0t] [Port %0d] DST MAC: %h", $time, port, dut.rx_mac_control_mac_dst_addr[port]);
        $display("[%0t] [Port %0d] SRC MAC: %h", $time, port, dut.rx_mac_control_mac_src_addr[port]);
        $display("[%0t] [Port %0d] Frame Error: %0b (Expected: 0)", $time, port, dut.rx_mac_control_frame_error[port]);
        end
    join 
    
    repeat(20) @(posedge switch_clk);
    
    $display("\n=== Test 2: Valid frame with CORRUPTED CRC ===");
    test_payload = new[46];
    for(int i = 0; i < 46; i++) test_payload[i] = 8'hAA;
    
    fork
        port = 0;
        begin
        send_frame(
            .dst_mac(48'h01_02_03_04_05_06),
            .src_mac(48'hAA_BB_CC_DD_EE_FF),
            .eth_type(16'h0806),  // ARP
            .payload(test_payload),
            .corrupt_crc(1'b1),  // Corrupt the CRC
            .port(port)
        );
        end
    
        begin
        @(posedge dut.rx_mac_control_frame_sof);
        $display("[%0t] [Port: %0d] Frame SOF detected", $time, port);
        @(posedge dut.rx_mac_control_frame_eof[port]);
        $display("[%0t] [Port: %0d] Frame EOF detected", $time, port);
        $display("[%0t] [Port: %0d] DST MAC: %h", $time, port, dut.rx_mac_control_mac_dst_addr[port]);
        $display("[%0t] [Port: %0d] SRC MAC: %h", $time, port, dut.rx_mac_control_mac_src_addr[port]);
        $display("[%0t] [Port: %0d] Frame Error: %0b (Expected: 1)", $time, port, dut.rx_mac_control_frame_error[port]);
        end
    join
    
    repeat(20) @(posedge switch_clk);
    
    $display("\n=== Test 3: Another valid frame ===");
    test_payload = new[50];
    for(int i = 0; i < 50; i++) test_payload[i] = i[7:0];
    
    fork
        port = 1;
        begin
        send_frame(
            .dst_mac(48'h12_34_56_78_9A_BC),
            .src_mac(48'hDE_AD_BE_EF_CA_FE),
            .eth_type(16'h86DD),  // IPv6
            .payload(test_payload),
            .corrupt_crc(1'b0),
            .port(port)
        );
        end
        
        begin
        @(posedge dut.rx_mac_control_frame_sof);
        $display("[%0t] [Port: %0d] Frame SOF detected", $time, port);
        @(posedge dut.rx_mac_control_frame_eof[port]);
        $display("[%0t] [Port: %0d] Frame EOF detected", $time, port);
        $display("[%0t] [Port: %0d] DST MAC: %h", $time, port, dut.rx_mac_control_mac_dst_addr[port]);
        $display("[%0t] [Port: %0d] SRC MAC: %h", $time, port, dut.rx_mac_control_mac_src_addr[port]);
        $display("[%0t] [Port: %0d] Frame Error: %0b (Expected: 0)", $time, port, dut.rx_mac_control_frame_error[port]);
        end
    join

    repeat(20) @(posedge switch_clk);

    /*
        NOTE: for these following backpressure tests, in the rx only tb i simulated frame_grant having backpressure, but now we have the actual module so backpressure has to be made happen frfr
    */
    
    $display("\n=== Test 4: Grant deasserted during HEADER (backpressure) ===");
    test_payload = new[46];
    for(int i = 0; i < 46; i++) test_payload[i] = i[7:0] + 8'h55;
    port = 2;
    // Fork off frame sender and grant controller
    fork
        // Send frame
        begin
            send_frame(
                .dst_mac(48'hAA_AA_AA_AA_AA_AA),
                .src_mac(48'hBB_BB_BB_BB_BB_BB),
                .eth_type(16'h0800),
                .payload(test_payload),
                .corrupt_crc(1'b0),
                .port(port)
            );
        end
        
        // Control grant signal - deassert during header
        // begin
        //     @(posedge dut.rx_mac_control_frame_sof);
        //     $display("[%0t] [Port: %0d] SOF detected, deasserting grant after 3 cycles", $time, port);
        //     repeat(3) @(posedge switch_clk);
        //     frame_grant = 0;
        //     $display("[%0t] Grant deasserted - frame should freeze", $time);
        //     repeat(10) @(posedge switch_clk);
        //     frame_grant = 1;
        //     $display("[%0t] Grant reasserted - frame should resume", $time);
        // end
    join_none
    
    @(posedge dut.rx_mac_control_frame_eof[port]);
    $display("[%0t] [Port: %0d] Frame EOF detected", $time, port);
    $display("[%0t] [Port: %0d] DST MAC: %h", $time, port, dut.rx_mac_control_mac_dst_addr[port]);
    $display("[%0t] [Port: %0d] SRC MAC: %h", $time, port, dut.rx_mac_control_mac_src_addr[port]);
    $display("[%0t] [Port: %0d] Frame Error: %0b (Expected: 0)", $time, port, dut.rx_mac_control_frame_error[port]);
    
    repeat(20) @(posedge switch_clk);
    
    $display("\n=== Test 5: Grant deasserted during PAYLOAD (backpressure) ===");
    test_payload = new[100];
    for(int i = 0; i < 100; i++) test_payload[i] = i[7:0] + 8'h10;
    
    fork
        // Send frame
        begin
            send_frame(
                .dst_mac(48'hCC_CC_CC_CC_CC_CC),
                .src_mac(48'hDD_DD_DD_DD_DD_DD),
                .eth_type(16'h0806),
                .payload(test_payload),
                .corrupt_crc(1'b0), 
                .port(port)
            );
        end
        
        // Control grant - deassert in middle of payload
        // begin
        //     @(posedge frame_sof);
        //     // Wait to get into payload state
        //     repeat(15) @(posedge switch_clk);
        //     $display("[%0t] In PAYLOAD state, deasserting grant", $time);
        //     frame_grant = 0;
        //     $display("[%0t] Grant deasserted - payload should freeze", $time);
        //     repeat(20) @(posedge switch_clk);
        //     frame_grant = 1;
        //     $display("[%0t] Grant reasserted - payload should resume", $time);
        // end
    join_none
    
    @(posedge dut.rx_mac_control_frame_eof[port]);
    $display("[%0t] [Port: %0d] Frame EOF detected", $time, port);
    $display("[%0t] [Port: %0d] DST MAC: %h", $time, port, dut.rx_mac_control_mac_dst_addr[port]);
    $display("[%0t] [Port: %0d] SRC MAC: %h", $time, port, dut.rx_mac_control_mac_src_addr[port]);
    $display("[%0t] [Port: %0d] Frame Error: %0b (Expected: 0)", $time, port, dut.rx_mac_control_frame_error[port]);
    
    repeat(20) @(posedge switch_clk);
    
    $display("\n=== Test 6: Grant toggling multiple times during frame ===");
    test_payload = new[200];
    for(int i = 0; i < 200; i++) test_payload[i] = i[7:0];
    
    port = 3;
    fork
        // Send frame
        begin
            send_frame(
                .dst_mac(48'hEE_EE_EE_EE_EE_EE),
                .src_mac(48'hFF_FF_FF_FF_FF_FF),
                .eth_type(16'h86DD),
                .payload(test_payload),
                .corrupt_crc(1'b0), 
                .port(port)
            );
        end
        
        // // Toggle grant multiple times
        // begin
        //     @(posedge frame_sof);
        //     repeat(5) @(posedge switch_clk);
            
        //     // Toggle grant 5 times
        //     for(int i = 0; i < 5; i++) begin
        //         frame_grant = 0;
        //         $display("[%0t] Grant deasserted (cycle %0d)", $time, i);
        //         repeat(5) @(posedge switch_clk);
        //         frame_grant = 1;
        //         $display("[%0t] Grant reasserted (cycle %0d)", $time, i);
        //         repeat(5) @(posedge switch_clk);
        //     end
        // end
    join_none
    
    @(posedge dut.rx_mac_control_frame_eof[port]);
    $display("[%0t] [Port: %0d] Frame EOF detected", $time, port);
    $display("[%0t] [Port: %0d] DST MAC: %h", $time, port, dut.rx_mac_control_mac_dst_addr[port]);
    $display("[%0t] [Port: %0d] SRC MAC: %h", $time, port, dut.rx_mac_control_mac_src_addr[port]);
    $display("[%0t] [Port: %0d] Frame Error: %0b (Expected: 0)", $time, port, dut.rx_mac_control_frame_error[port]);
    
    repeat(20) @(posedge switch_clk);
    
    $display("\n=== Test 7: Grant stays past end of frame ===");
    test_payload = new[50];
    for(int i = 0; i < 50; i++) test_payload[i] = i[7:0];
    
    port = 0;
    fork
        // Send frame
        begin
            send_frame(
                .dst_mac(48'hEE_EE_EE_EE_EE_EE),
                .src_mac(48'hFF_FF_FF_FF_FF_FF),
                .eth_type(16'h86DD),
                .payload(test_payload),
                .corrupt_crc(1'b0),
                .port(port)
            );
        end
        
        // // Toggle grant multiple times
        // begin
        //     @(posedge frame_sof);
        //     repeat(20) @(posedge switch_clk);
            
        //     // Keep !grant past eof
        //     frame_grant = 0;
        //     $display("[%0t] Grant deasserted", $time);
        //     repeat(5) @(posedge switch_clk);
        // end
    join_none
    
    @(posedge dut.rx_mac_control_frame_eof[port]);
    $display("[%0t] [Port: %0d] Frame EOF detected", $time, port);
    $display("[%0t] [Port: %0d] DST MAC: %h", $time, port, dut.rx_mac_control_mac_dst_addr[port]);
    $display("[%0t] [Port: %0d] SRC MAC: %h", $time, port, dut.rx_mac_control_mac_src_addr[port]);
    $display("[%0t] [Port: %0d] Frame Error: %0b (Expected: 1)", $time, port, dut.rx_mac_control_frame_error[port]); // err due to fifo_full
    
    repeat(10) @(posedge switch_clk);
    // frame_grant = 1;
    // $display("[%0t] Grant reasserted", $time);
    repeat(10) @(posedge switch_clk);
    
    test_payload = new[50];
    for(int i = 0; i < 50; i++) test_payload[i] = {i[3:0], i[7:4]};
    
    fork 
    // Send frame
    begin
        send_frame(
            .dst_mac(48'hEF_EF_EF_EF_EF_EF),
            .src_mac(48'hFE_FE_FE_FE_FE_FE),
            .eth_type(16'h86DD),
            .payload(test_payload),
            .corrupt_crc(1'b0),
            .port(port)
        );
    end
    
    begin
    @(posedge dut.rx_mac_control_frame_eof[port]);
    $display("[%0t] [Port: %0d] Frame EOF detected", $time, port);
    $display("[%0t] [Port: %0d] DST MAC: %h", $time, port, dut.rx_mac_control_mac_dst_addr[port]);
    $display("[%0t] [Port: %0d] SRC MAC: %h", $time, port, dut.rx_mac_control_mac_src_addr[port]);
    $display("[%0t] [Port: %0d] Frame Error: %0b (Expected: 0)", $time, port, dut.rx_mac_control_frame_error[port]);
    end
    join
    
    repeat(50) @(posedge switch_clk);
    
    $display("\n=== Test Complete ===");
    $finish;
end

// Monitor for debugging
initial begin
    $display("\n=== Frame Data Monitor ===");
    $display("Time\t\tGrant\tSOF\tEOF\tValid\tError\tData");
    forever begin
        @(posedge switch_clk);
        if (dut.rx_mac_control_frame_valid[port] || dut.rx_mac_control_frame_sof[port] || dut.rx_mac_control_frame_eof[port] || !dut.memory_write_ctrl_data_ready[port]) begin
            $display("%0t\t%0d\t%b\t%b\t%b\t%b\t%b\t%h", $time, port,
            dut.memory_write_ctrl_data_ready[port], 
            dut.rx_mac_control_frame_sof[port], 
            dut.rx_mac_control_frame_eof[port], 
            dut.rx_mac_control_frame_valid[port], 
            dut.rx_mac_control_frame_error[port], 
            dut.rx_mac_control_frame_data[port]);
        end
    end
end

endmodule
