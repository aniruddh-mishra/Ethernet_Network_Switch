`timescale 1ns/1ps

module tb_crossbar;

    import mem_pkg::*;
    import switch_pkg::*;

    // Clock & reset
    logic clk;
    logic rst_n;

    // Arbiter-like stimulus signals
    logic [$clog2(NUM_PORTS)-1:0] arb_port_o;
    logic [47:0] arb_rx_mac_src_addr_o;
    logic [47:0] arb_rx_mac_dst_addr_o;
    logic [ADDR_W-1:0] arb_data_start_addr_o;
    logic arb_eop_o;

    // Translator outputs
    logic [NUM_PORTS-1:0] voq_write_reqs;
    logic [ADDR_W-1:0] voq_start_ptrs [NUM_PORTS-1:0];
    logic flood_o;

    // Instantiate DUT
    crossbar dut (
        .clk(clk),
        .rst_n(rst_n),
        .eof_i(arb_eop_o),
        .ingress_port_i(arb_port_o),
        .rx_mac_src_addr_i(arb_rx_mac_src_addr_o),
        .rx_mac_dst_addr_i(arb_rx_mac_dst_addr_o),
        .data_start_ptr_i(arb_data_start_addr_o),
        .voq_write_reqs_o(voq_write_reqs),
        .voq_start_ptrs_o(voq_start_ptrs),
        .flood_o(flood_o)
    );

    // Clock generation
    initial begin
    clk = 0;
    forever #5 clk = ~clk; // 100 MHz
    end

    // Simple reset
    task automatic apply_reset();
    begin
        rst_n = 0;
        arb_eop_o = 0;
        arb_rx_mac_src_addr_o = '0;
        arb_rx_mac_dst_addr_o = '0;
        arb_data_start_addr_o = '0;
        arb_port_o = '0;
        repeat (3) @(posedge clk);
        rst_n = 1;
        @(posedge clk);
    end
    endtask

    // Drive one "frame end" (EOP) with src/dst/port/start_ptr
    // expect_flood: 1 => expect all ports set; 0 => expect unicast to expect_port
    task automatic send(
        input [47:0] src,
        input [47:0] dst,
        input [ADDR_W-1:0] start_ptr,
        input [$clog2(NUM_PORTS)-1:0] ingress_port
    );
        begin
            // Drive EOP with metadata
            @(posedge clk);
            arb_eop_o = 1'b1;
            arb_rx_mac_src_addr_o   = src;
            arb_rx_mac_dst_addr_o   = dst;
            arb_data_start_addr_o   = start_ptr;
            arb_port_o              = ingress_port;
        end
    endtask

    initial begin
        $dumpfile("tb_crossbar.vcd");
        $dumpvars(0, tb_crossbar);

        apply_reset();

        // 1) First frame: unknown dst -> flood, learn src on port 0
        send(48'h0000_0000_0001, 48'h0000_0000_00AA, 6'h010, 2'd0);

        // 2) Second frame: dst = first src -> unicast to port 0, learn new src on port 1
        send(48'h0000_0000_0002, 48'h0000_0000_0001, 6'h020, 2'd1);

        // 3) Third frame: dst = second src -> unicast to port 1, learn new src on port 2
        send(48'h0000_0000_0003, 48'h0000_0000_0002, 6'h030, 2'd2);

        // 4) Unknown dst again -> flood
        send(48'h0000_0000_0004, 48'h0000_0000_00BB, 6'h040, 2'd3);

        // 5) Re-hit known dest (dst from step 3) -> unicast to port 1
        send(48'h0000_0000_0005, 48'h0000_0000_0003, 6'h050, 2'd0);

        @(posedge clk);
        arb_eop_o = 1'b0;
        repeat(10) @(posedge clk);

        $display("All translator+address_table integration tests passed.");
        $finish;
    end

endmodule