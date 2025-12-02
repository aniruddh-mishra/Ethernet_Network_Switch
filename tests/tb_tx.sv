`timescale 1ns/1ps

module tb_tx;

// Parameters
localparam DATA_WIDTH = 8;
localparam VOQ_DEPTH = 256;
localparam CLK_PERIOD = 2; // 500MHz switch clock
localparam GMII_CLK_PERIOD = 8; // 125MHz GMII clock (after div by 4)

// DUT signals
logic gmii_tx_clk_o;
logic [DATA_WIDTH-1:0] gmii_tx_data_o;
logic gmii_tx_en_o;
logic gmii_tx_er_o;

logic switch_clk, switch_rst_n;

logic [DATA_WIDTH-1:0] frame_data_i;
logic frame_valid_i;
logic frame_eof_i;
logic [$clog2(VOQ_DEPTH)-1:0] mem_ptr_o;

logic voq_valid_i;
logic [$clog2(VOQ_DEPTH)-1:0] voq_ptr_i;
logic voq_ready_o;

// Instantiate DUT
tx_mac_control dut (
    .gmii_tx_clk_o(gmii_tx_clk_o),
    .gmii_tx_data_o(gmii_tx_data_o),
    .gmii_tx_en_o(gmii_tx_en_o),
    .gmii_tx_er_o(gmii_tx_er_o),
    
    .switch_clk(switch_clk),
    .switch_rst_n(switch_rst_n),
    
    .frame_data_i(frame_data_i),
    .frame_valid_i(frame_valid_i),
    .frame_eof_i(frame_eof_i),
    .mem_ptr_o(mem_ptr_o),
    
    .voq_valid_i(voq_valid_i),
    .voq_ptr_i(voq_ptr_i),
    .voq_ready_o(voq_ready_o)
);

// Clock generation
initial begin
    switch_clk = 0;
    forever #(CLK_PERIOD/2) switch_clk = ~switch_clk;
end

// Test frame data
logic [7:0] test_frame [0:63]; // 64-byte test frame
int frame_idx;

// Initialize test frame (simple pattern)
initial begin
    for (int i = 0; i < 64; i++) begin
        test_frame[i] = i[7:0];
    end
end

// Main test sequence
initial begin
    // Initialize signals
    switch_rst_n = 0;
    frame_data_i = 0;
    frame_valid_i = 0;
    frame_eof_i = 0;
    voq_valid_i = 0;
    voq_ptr_i = 0;
    frame_idx = 0;
    
    // Reset
    repeat(10) @(posedge switch_clk);
    switch_rst_n = 1;
    repeat(5) @(posedge switch_clk);
    
    $display("=== Starting TX MAC Control Test ===");
    $display("Time: %0t - Reset released", $time);
    
    // Wait for voq_ready
    wait(voq_ready_o);
    $display("Time: %0t - VOQ Ready", $time);
    
    // Trigger frame transmission
    @(posedge switch_clk);
    voq_valid_i = 1;
    voq_ptr_i = 8'd10; // Start pointer
    
    @(posedge switch_clk);
    voq_valid_i = 0;
    
    // Wait a few cycles then start providing frame data
    repeat(10) @(posedge switch_clk);
    
    // Send frame data
    $display("Time: %0t - Starting frame data transmission", $time);
    for (frame_idx = 0; frame_idx < 64; frame_idx++) begin
        @(posedge switch_clk);
        frame_valid_i = 1;
        frame_data_i = test_frame[frame_idx];
        frame_eof_i = (frame_idx == 63); // EOF on last byte
        
        if (frame_idx == 0)
            $display("Time: %0t - First data byte: 0x%02h", $time, frame_data_i);
        if (frame_eof_i)
            $display("Time: %0t - Last data byte: 0x%02h (EOF)", $time, frame_data_i);
    end
    
    @(posedge switch_clk);
    frame_valid_i = 0;
    frame_eof_i = 0;
    
    // Wait for IFG and next ready
    wait(voq_ready_o);
    $display("Time: %0t - Frame complete, VOQ ready again", $time);
    
    // Wait some time to observe GMII output
    repeat(100) @(posedge switch_clk);
    
    $display("=== Test Complete ===");
    $display("Total frames transmitted: %0d", dut.tx_frame_count);
    $finish;
end

// Monitor GMII output
initial begin
    int byte_count = 0;
    logic prev_tx_en = 0;
    
    forever begin
        @(posedge gmii_tx_clk_o);
        
        if (gmii_tx_en_o && !prev_tx_en) begin
            $display("Time: %0t - GMII TX started", $time);
            byte_count = 0;
        end
        
        if (gmii_tx_en_o) begin
            if (byte_count < 10) // Show first 10 bytes
                $display("  GMII byte %0d: 0x%02h", byte_count, gmii_tx_data_o);
            byte_count++;
        end
        
        if (!gmii_tx_en_o && prev_tx_en) begin
            $display("Time: %0t - GMII TX ended (%0d bytes total)", $time, byte_count);
        end
        
        prev_tx_en = gmii_tx_en_o;
    end
end

// Timeout watchdog
initial begin
    #50000;
    $display("ERROR: Timeout!");
    $finish;
end

endmodule