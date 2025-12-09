`timescale 1ns/1ps

module tb_translator;

import mem_pkg::*;
import switch_pkg::*;

parameter CLK_PERIOD = 10;

logic clk, rst_n;
logic [ADDR_W-1:0] start_ptr_i;
logic [47:0] dest_addr_i;
logic input_valid_i;
logic [$clog2(NUM_PORTS)-1:0] address_port_i;
logic address_port_valid_i;
logic address_learn_enable_o;
logic [47:0] address_learn_address_o;
logic [NUM_PORTS-1:0] write_reqs_o;
logic [ADDR_W-1:0] start_ptrs_o [NUM_PORTS-1:0];

// Instantiate DUT
translator #(
    .NUM_PORTS(NUM_PORTS),
    .ADDR_W(ADDR_W)
) dut (
    .clk(clk),
    .rst_n(rst_n),
    .start_ptr_i(start_ptr_i),
    .dest_addr_i(dest_addr_i),
    .input_valid_i(input_valid_i),
    .address_port_i(address_port_i),
    .address_port_valid_i(address_port_valid_i),
    .address_learn_enable_o(address_learn_enable_o),
    .address_learn_address_o(address_learn_address_o),
    .write_reqs_o(write_reqs_o),
    .start_ptrs_o(start_ptrs_o)
);

// Clock generation
initial begin
    clk = 0;
    forever #(CLK_PERIOD/2) clk = ~clk;
end

// Test stimulus
initial begin
    $dumpfile("tb_translator.vcd");
    $dumpvars(0, tb_translator);

    // Initialize
    rst_n = 0;
    start_ptr_i = 0;
    dest_addr_i = 0;
    input_valid_i = 0;
    address_port_i = 0;
    address_port_valid_i = 0;

    repeat(2) @(posedge clk);
    rst_n = 1;
    repeat(2) @(posedge clk);

    $display("=== Test 1: Non-flood case - address port valid ===");
    // Send input with valid address lookup
    @(posedge clk);
    input_valid_i = 1;
    dest_addr_i = 48'hAABBCCDDEEFF;
    start_ptr_i = 12'h0100;
    @(posedge clk);
    input_valid_i = 0;
    
    // Wait for next_valid, then provide address port
    address_port_valid_i = 1;
    address_port_i = 2;
    @(posedge clk);
    #1; // tiny settle
    address_port_valid_i = 0;
    
    // Verify outputs
    @(posedge clk);
    if (write_reqs_o == 4'b0100 && start_ptrs_o[2] == 12'h0100) begin
        $display("PASS: Write request to port 2 only, start_ptr = 0x0100");
    end else begin
        $display("FAIL: Expected write_reqs_o=0100, got %b", write_reqs_o);
    end
    
    repeat(2) @(posedge clk);

    $display("=== Test 2: Flood case - address port NOT valid ===");
    // Send input without valid address lookup (flood)
    @(posedge clk);
    input_valid_i = 1;
    dest_addr_i = 48'h112233445566;
    start_ptr_i = 12'h0200;
    @(posedge clk);
    input_valid_i = 0;
    
    // Wait for next_valid, address port stays invalid
    @(posedge clk);
    address_port_valid_i = 0;
    @(posedge clk);
    
    // Verify flooding to all ports
    @(posedge clk);
    if (write_reqs_o == 4'b1111) begin
        $display("PASS: Flooding - write requests to all ports");
        for (int i = 0; i < NUM_PORTS; i++) begin
            if (start_ptrs_o[i] == 12'h0200) begin
                $display("  Port %0d: start_ptr = 0x0200", i);
            end else begin
                $display("  FAIL: Port %0d has wrong start_ptr = 0x%h", i, start_ptrs_o[i]);
            end
        end
    end else begin
        $display("FAIL: Expected write_reqs_o=1111 (flood), got %b", write_reqs_o);
    end

    repeat(2) @(posedge clk);

    $display("=== Test 3: Multiple non-flood cases ===");
    // Test port 0
    @(posedge clk);
    input_valid_i = 1;
    dest_addr_i = 48'hFEDCBA987654;
    start_ptr_i = 12'h0300;
    @(posedge clk);
    input_valid_i = 0;
    @(posedge clk);
    address_port_valid_i = 1;
    address_port_i = 0;
    @(posedge clk);
    address_port_valid_i = 0;
    @(posedge clk);
    if (write_reqs_o[0] && start_ptrs_o[0] == 12'h0300) begin
        $display("PASS: Port 0 write request");
    end else begin
        $display("FAIL: Port 0 test failed");
    end

    repeat(2) @(posedge clk);

    // Test port 3
    @(posedge clk);
    input_valid_i = 1;
    dest_addr_i = 48'h123456789ABC;
    start_ptr_i = 12'h0400;
    @(posedge clk);
    input_valid_i = 0;
    @(posedge clk);
    address_port_valid_i = 1;
    address_port_i = 3;
    @(posedge clk);
    address_port_valid_i = 0;
    @(posedge clk);
    if (write_reqs_o[3] && start_ptrs_o[3] == 12'h0400) begin
        $display("PASS: Port 3 write request");
    end else begin
        $display("FAIL: Port 3 test failed");
    end

    repeat(2) @(posedge clk);

    $display("=== Test 4: Address learn enable verification ===");
    @(posedge clk);
    input_valid_i = 1;
    dest_addr_i = 48'hCAFEBABEDEAD;
    start_ptr_i = 12'h0500;
    @(posedge clk);
    if (address_learn_enable_o && address_learn_address_o == 48'hCAFEBABEDEAD) begin
        $display("PASS: Address learn enabled with correct address");
    end else begin
        $display("FAIL: Address learn not working correctly");
    end
    input_valid_i = 0;
    @(posedge clk);
    if (!address_learn_enable_o) begin
        $display("PASS: Address learn disabled after input_valid_i=0");
    end else begin
        $display("FAIL: Address learn should be disabled");
    end

    repeat(5) @(posedge clk);
    $display("=== All tests complete ===");
    $finish;
end

endmodule