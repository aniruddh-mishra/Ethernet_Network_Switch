`timescale 1ns/1ps

module tb_address_table;

    import switch_pkg::*;

    logic clk;
    logic rst_n;

    // // DUT signals
    logic learn_req_i;
    logic [47:0] learn_address_i;
    logic [$clog2(NUM_PORTS)-1:0] learn_port_i;

    logic read_req_i;
    logic [47:0] read_address_i;

    logic [$clog2(NUM_PORTS)-1:0] read_port_o;
    logic read_port_valid_o;

    // // instantiate DUT
    address_table dut (
        .clk(clk), .rst_n(rst_n),
        .learn_req_i(learn_req_i), .learn_address_i(learn_address_i), .learn_port_i(learn_port_i),
        .read_req_i(read_req_i), .read_address_i(read_address_i),
        .read_port_o(read_port_o), .read_port_valid_o(read_port_valid_o)
    );

    // clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100 MHz
    end

    // Waveform Dump
     initial begin
        $dumpfile("tb_address_table.vcd");
        $dumpvars(0, tb_address_table);
    end

    initial begin
        rst_n = 0;
        learn_req_i = 0;
        read_req_i = 0;
        learn_address_i = 0;
        learn_port_i = 0;
        read_address_i = 0;
        read_port_valid_o = 0;
        read_port_o = 0;

        #20;
        rst_n = 1;
        #20;

        $display("Starting address_table test...");

        // Learn two addresses on different ports
        learn_address_i = 48'h0000_0000_0001; learn_port_i = 2'd0;
        @(posedge clk) learn_req_i = 1;
        @(posedge clk) learn_req_i = 0;
        #10;

        learn_address_i = 48'h0000_0000_0002; learn_port_i = 2'd1;
        @(posedge clk) learn_req_i = 1;
        @(posedge clk) learn_req_i = 0;
        #10;

        // Read back address 0 (LSBs) should yield port 0
        read_address_i = 48'h0000_0000_0001;
        @(posedge clk) read_req_i = 1;
        @(posedge clk) read_req_i = 0;
        @(posedge clk);
        if (read_port_valid_o) $display("Read address 0001 -> port %0d", read_port_o);
        else $display("Read address 0001 -> no valid entry");

        // Read back address 2
        read_address_i = 48'h0000_0000_0002;
        @(posedge clk) read_req_i = 1;
        @(posedge clk) read_req_i = 0;
        @(posedge clk);
        if (read_port_valid_o) $display("Read address 0002 -> port %0d", read_port_o);
        else $display("Read address 0002 -> no valid entry");

        $display("address_table test complete");
        #20 $finish;
    end

endmodule
