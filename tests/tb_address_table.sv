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

    // instantiate DUT
    address_table #(.NUM_PORTS(NUM_PORTS)) dut (
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
        $dumpvars(1, tb_address_table, address_table);
    end

    // Helper tasks for learn and read operations
    task automatic do_learn(input logic [47:0] addr, input logic [$clog2(NUM_PORTS)-1:0] port);
    begin
        learn_address_i = addr;
        learn_port_i = port;
        @(posedge clk) learn_req_i = 1;
        @(posedge clk) learn_req_i = 0;
        #1; // tiny settle
    end
    endtask

    task automatic do_read(input logic [47:0] addr);
    begin
        read_address_i = addr;
        @(posedge clk) read_req_i = 1;
        #1; // tiny settle
        if (read_port_valid_o) $display("Read: addr %04x -> port %0d (valid)", addr, read_port_o);
        else $display("Read: addr %04x -> no entry", addr);
        @(posedge clk) read_req_i = 0;
        @(posedge clk);
    end
    endtask

    logic [47:0] rcount;
    logic [47:0] base;
    logic [47:0] i;

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

        $display("Starting extended address_table eviction test...");

        // 1) Fill the table with 16 unique addresses (table size)
        base = 48'h0000_0000_1000;
        for (i = 1; i <= 16; i = i + 1) begin
            do_learn(base + i, (i[1:0] % NUM_PORTS[1:0]));
        end

        #10;

        // 2) Establish distinct read counters for each entry so eviction is predictable
        //    make address (base+1) the least-read (0 reads), (base+2) -> 1 read, ... (base+16) -> 15 reads
        for (i = 1; i <= 16; i = i + 1) begin
            rcount = i - 1; // number of reads for entry i
            repeat (rcount[31:0]) begin
                do_read(base + i);
            end
        end

        #20;

        // 3) Insert 4 new addresses to force eviction of the 4 least-read entries
        //    According to our read schedule those should be base+1..base+4 (0..3 reads)
        $display("Learning addresses 17..20 to force 4 evictions (least-read should be evicted)");
        for (i = 17; i <= 20; i = i + 1) begin
            do_learn(base + i, (i[1:0] % NUM_PORTS[1:0]));
            $display("Learned new addr %04x (index %0d)", base + i, i);
        end

        #20;

        // 4) Verify which of original addresses remain or were evicted
        for (i = 1; i <= 20; i = i + 1) begin
            do_read(base + i);
        end

        #20;

        // 5) Bump reads for a subset of survivors to protect them, and leave others low
        $display("Bumping reads for some survivors to change eviction ordering");
        // Bump reads heavily for base+8..base+11
        for (i = 8; i <= 11; i = i + 1) begin
            repeat (10) begin
                do_read(base + i);
            end
            $display("Bumped reads for addr %04x", base + i);
        end

        #20;

        // 6) Insert another 4 addresses to trigger further evictions
        $display("Learning addresses 21..24 to force more evictions");
        for (i = 21; i <= 24; i = i + 1) begin
            do_learn(base + i, (i[1:0] % NUM_PORTS[1:0]));
            $display("Learned new addr %04x (index %0d)", base + i, i);
        end

        #20;

        // 7) Final verification: read through addresses 1..24 and print status
        $display("Final table contents (addresses 1..24):");
        for (i = 1; i <= 24; i = i + 1) begin
            do_read(base + i);
            if (read_port_valid_o) $display("Final: addr %04x -> port %0d", base + i, read_port_o);
            else $display("Final: addr %04x -> (not present)", base + i);
        end

        $display("Extended eviction test complete");
        #50 $finish;
    end

endmodule
