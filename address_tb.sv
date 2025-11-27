module address_testbench;

logic clk;
logic reset;

logic [48:0] table_addresses [NUM_ENTRIES-1:0];
logic [$clog2(NUM_PORTS)-1:0] table_ports [NUM_ENTRIES-1:0];
logic table_usage [NUM_ENTRIES-1:0];
logic [$clog2(NUM_ENTRIES)-1:0] table_hits [NUM_ENTRIES-1:0];

logic learn_ports_en [NUM_PORTS-1:0];
logic [48:0] learn_addresses [NUM_PORTS-1:0];

logic read_en;
logic read_out;

address_learn dut_learn (.clk(clk), .reset(reset), .source_address_valid_i(learn_ports_en), .source_address_i(learn_addresses), .table_addresses(table_addresses), .table_ports(table_ports), .table_usage(table_usage), .table_hits(table_hits));
address_read dut_read (.clk(clk), .reset(reset), .read_en(read_en), .read_address(read_address), .read_out(read_out), .read_out_valid(read_out_valid));

initial begin
    #1
    reset <= 0;
    #20
    reset <= 1;
    #24
    learn_ports_en[0] <= 1;
    learn_ports_en[1] <= 1;
    learn_ports_en[4] <= 1;
    learn_addresses[0] <= 49'd34;
    learn_addresses[1] <= 49'd35;
    learn_addresses[4] <= 49'd46;
    #10
    learn_ports_en <= '{default: '0}
    read_en <= 1;
    read_address <= 49'd34;
    #10
    learn_ports_en[0] <= 1;
    learn_addresses[0] <= 49'd46;
    #10
    read_en <= 1;
    read_address <= 49'd46;
    #10
    learn_ports_en[5] <= 1;
    learn_ports_en[6] <= 1;
    learn_ports_en[7] <= 1;
    learn_addresses[5] <= 49'd74;
    learn_addresses[6] <= 49'd75;
    learn_addresses[7] <= 49'd86; // TODO: Verify that it is possible for a new port to not always immediately be kicked off... might need to initialize hit at nonzero value
    #10
    read_en <= 1;
    read_address <= 49'd35; // Replace with evicted
    read_address <= 49'd39;
end

always begin
    clk <= 0;
    #5
    clk <= 1;
    #5
end

endmodule