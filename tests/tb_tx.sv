import rx_tx_pkg::*;
import mem_pkg::*;

/*
    finally fixed: 
    - corrected mem stall to be simple check valid after prev_mem_re_o
    - mem_re_o being asserted for multiple cycles due to !fifo and mem stall + block_ctr not moving, fixed with mem_req_flag
    - frame_end_i signal got lost when latching new block in
    - don't latch new block in until after !fifo_full (last data sent out)
    - all logic with block_ctr == 62 and 63 in DATA  
*/


module tb_tx;

// Parameters
localparam DATA_WIDTH = 8;
localparam ADDR_W = 16;
localparam BLOCK_BYTES = 64;
localparam PREAMBLE_BYTE = 8'h55;
localparam SFD_BYTE = 8'hD5;

// Clock and reset
logic switch_clk;
logic switch_rst_n;

// GMII interface
logic gmii_tx_clk_o;
logic [DATA_WIDTH-1:0] gmii_tx_data_o;
logic gmii_tx_en_o;
logic gmii_tx_er_o;

// Memory read control interface
logic mem_re_o, mem_start_o;
logic [ADDR_W-1:0] mem_start_addr_o;
logic [BLOCK_BYTES-1:0][DATA_WIDTH-1:0] frame_data_i;
logic frame_valid_i;
logic frame_end_i;

// VOQ signals
logic voq_valid_i;
logic [ADDR_W-1:0] voq_ptr_i;
logic voq_ready_o;

// Test variables
int test_num = 0;
int errors = 0;
logic [7:0] captured_frame[$];

// DUT instantiation
tx_mac_control #(
    .ADDR_W(ADDR_W),
    .BLOCK_BYTES(BLOCK_BYTES)
) dut (
    .gmii_tx_clk_o(gmii_tx_clk_o),
    .gmii_tx_data_o(gmii_tx_data_o),
    .gmii_tx_en_o(gmii_tx_en_o),
    .gmii_tx_er_o(gmii_tx_er_o),
    .switch_clk(switch_clk),
    .switch_rst_n(switch_rst_n),
    .mem_re_o(mem_re_o),
    .mem_start_o(mem_start_o),
    .mem_start_addr_o(mem_start_addr_o),
    .frame_data_i(frame_data_i),
    .frame_valid_i(frame_valid_i),
    .frame_end_i(frame_end_i),
    .voq_valid_i(voq_valid_i),
    .voq_ptr_i(voq_ptr_i),
    .voq_ready_o(voq_ready_o)
);

// Clock generation - 500MHz switch clock
initial begin
    switch_clk = 0;
    forever #1 switch_clk = ~switch_clk; // 2ns period = 500MHz
end

initial begin
    $dumpfile("tb_tx.vcd");
    $dumpvars(0, tb_tx);
end

// GMII transmit data capture
always @(posedge gmii_tx_clk_o) begin
    if (gmii_tx_en_o && !gmii_tx_er_o) begin
        captured_frame.push_back(gmii_tx_data_o);
    end
end

// Task to reset the DUT
task reset_dut();
    switch_rst_n = 0;
    voq_valid_i = 0;
    voq_ptr_i = 0;
    frame_data_i = '0;
    frame_valid_i = 0;
    frame_end_i = 0;
    repeat(10) @(posedge switch_clk);
    switch_rst_n = 1;
    repeat(10) @(posedge switch_clk);
    $display("[%0t] Reset complete", $time);
endtask

// Task to send a frame through VOQ and memory interface
task send_frame(input [ADDR_W-1:0] start_addr, input int frame_size_bytes);
    int blocks_needed;
    int i, j;
    logic [7:0] test_data;
    logic [31:0] test_data_temp;
    
    blocks_needed = (frame_size_bytes + BLOCK_BYTES - 1) / BLOCK_BYTES;
    
    $display("[%0t] Sending frame: addr=0x%0h, size=%0d bytes, blocks=%0d", 
             $time, start_addr, frame_size_bytes, blocks_needed);
    
    // Clear captured frame
    captured_frame = {};
    
    // Assert VOQ valid with starting address
    @(posedge switch_clk);
    voq_valid_i = 1;
    voq_ptr_i = start_addr;
    
    fork
    begin
        // Wait for VOQ ready to go low (frame accepted)
        wait(!voq_ready_o);
        @(posedge switch_clk);
        voq_valid_i = 0;
    end

    begin
        // Supply data blocks
        for (i = 0; i < blocks_needed; i++) begin
            // Wait for memory read enable
            wait(mem_re_o || mem_start_o);
            $display("[%0t] Mem_re_o is %b, mem_start_o is %b: Block %0d", $time, mem_re_o, mem_start_o, i);
            @(posedge switch_clk);
            
            // Prepare block data
            for (j = 0; j < BLOCK_BYTES; j++) begin
                if ((i * BLOCK_BYTES + j) < frame_size_bytes) begin
                    test_data_temp = i * BLOCK_BYTES + j; 
                    test_data = test_data_temp[7:0] & 8'hFF;
                    frame_data_i[j] = test_data;
                end else begin
                    frame_data_i[j] = 8'h00;
                end
            end
            
            // Assert valid and end signal if last block
            $display("[%0t] Frame Valid Cycle: Block %0d", $time, i);
            frame_valid_i = 1;
            frame_end_i = (i == blocks_needed - 1);
            
            @(posedge switch_clk);
            $display("[%0t] Frame_valid_i goes low: Block %0d", $time, i);
            frame_valid_i = 0;
            @(posedge switch_clk);
        end
    end
    join_none

    // Wait for transmission to complete (VOQ ready goes high)
    wait(voq_ready_o);
    @(posedge switch_clk);
    
    $display("[%0t] Frame transmission complete", $time);
endtask

// Task to verify captured frame
task verify_frame(input int expected_payload_size);
    int i;
    logic [7:0] expected_data;
    logic [31:0] temp_expected_data;
    int preamble_count;
    preamble_count = 0;
    
    $display("[%0t] Verifying captured frame (total bytes: %0d)", $time, captured_frame.size());
    
    // Check minimum frame size (preamble + SFD + payload)
    if (captured_frame.size() < (8 + expected_payload_size)) begin
        $display("ERROR: Frame too short! Expected at least %0d, got %0d", 
                 8 + expected_payload_size, captured_frame.size());
        errors++;
        return;
    end
    
    // Verify preamble (7 bytes of 0x55)
    for (i = 0; i < 7; i++) begin
        if (captured_frame[i] !== PREAMBLE_BYTE) begin
            $display("ERROR: Preamble byte %0d incorrect! Expected 0x%0h, got 0x%0h", 
                     i, PREAMBLE_BYTE, captured_frame[i]);
            errors++;
        end
    end
    
    // Verify SFD (1 byte of 0xD5)
    if (captured_frame[7] !== SFD_BYTE) begin
        $display("ERROR: SFD incorrect! Expected 0x%0h, got 0x%0h", 
                 SFD_BYTE, captured_frame[7]);
        errors++;
    end
    
    // Verify payload data
    for (i = 0; i < expected_payload_size; i++) begin
        temp_expected_data = i;
        expected_data = temp_expected_data[7:0] & 8'hFF;
        if (captured_frame[i + 8] !== expected_data) begin
            $display("ERROR: Payload byte %0d incorrect! Expected 0x%0h, got 0x%0h", 
                     i, expected_data, captured_frame[i + 8]);
            errors++;
            if (errors > 10) begin
                $display("Too many errors, stopping verification...");
                return;
            end
        end
    end
    
    $display("Frame verification PASSED");
endtask

// Main test sequence
initial begin
    $display("========================================");
    $display("TX MAC Control Testbench Starting");
    $display("========================================");
    
    // Test 1: Reset and initialization
    test_num = 1;
    $display("\n[TEST %0d] Reset and Initialization", test_num);
    reset_dut();
    
    // Verify initial state
    if (voq_ready_o !== 1'b1) begin
        $display("ERROR: VOQ not ready after reset");
        errors++;
    end
    
    // Test 2: Single small frame (64 bytes - fits in one block)
    test_num = 2;
    $display("\n[TEST %0d] Single Frame - 64 bytes", test_num);
    send_frame(16'h1000, 64);
    #1000; // Wait for GMII transmission
    verify_frame(64);
    
    // Test 3: Multi-block frame (150 bytes)
    test_num = 3;
    $display("\n[TEST %0d] Multi-block Frame - 150 bytes", test_num);
    send_frame(16'h2000, 150);
    #2000;
    verify_frame(150);
    
    // Test 4: Back-to-back frames
    test_num = 4;
    $display("\n[TEST %0d] Back-to-back Frames", test_num);
    send_frame(16'h3000, 64);
    #1000;
    verify_frame(64);
    send_frame(16'h3100, 64);
    #1000;
    verify_frame(64);
    
    // Test 5: Large frame (500 bytes)
    test_num = 5;
    $display("\n[TEST %0d] Large Frame - 500 bytes", test_num);
    send_frame(16'h4000, 500);
    #5000;
    verify_frame(500);
    
    // Final results
    #1000;
    $display("\n========================================");
    $display("Test Results");
    $display("========================================");
    $display("Tests completed: %0d", test_num);
    $display("Errors detected: %0d", errors);
    
    if (errors == 0) begin
        $display("ALL TESTS PASSED!");
    end else begin
        $display("TESTS FAILED - %0d errors", errors);
    end
    
    $display("========================================");
    $finish;
end

endmodule