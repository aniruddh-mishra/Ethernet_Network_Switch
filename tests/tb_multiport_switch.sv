// 4-port parallel address-learning stress test
// - 2 packets per port
// - Round 0: unknown unicast destinations -> EXPECT FLOOD
// - Round 1: destinations = other ports' Round-0 sources -> EXPECT UNICAST ONLY (NO FLOOD)
// - Packets are unique per port via:
//      * unique src MAC per port per pkt
//      * unique dst MAC in round0 per port
//      * unique payload length per port per pkt
//      * strong per-(port,pkt) payload signature in first 4 bytes
//
// Parallelism:
// - All ports send pkt0 concurrently, then all ports send pkt1 concurrently.

module tb_multiport_switch;

    // Import packages
    import rx_tx_pkg::*;
    import mem_pkg::*;
    import switch_pkg::*;

    // Parameters
    localparam int GMII_CLK_PERIOD   = 8;  // 125 MHz
    localparam int SWITCH_CLK_PERIOD = 2;  // 500 MHz

    localparam int unsigned NUM_PKTS_PER_PORT = 2;
    localparam int unsigned BASE_PAYLOAD_LEN  = 64;

    // DUT signals
    logic gmii_rx_clk   [NUM_PORTS-1:0];
    logic [DATA_WIDTH-1:0] gmii_rx_data [NUM_PORTS-1:0];
    logic gmii_rx_dv    [NUM_PORTS-1:0];
    logic gmii_rx_er    [NUM_PORTS-1:0];

    logic gmii_tx_clk_o [NUM_PORTS-1:0];
    logic [DATA_WIDTH-1:0] gmii_tx_data_o [NUM_PORTS-1:0];
    logic gmii_tx_en_o  [NUM_PORTS-1:0];
    logic gmii_tx_er_o  [NUM_PORTS-1:0];

    logic switch_clk, switch_rst_n;

    typedef logic [$clog2(NUM_PORTS)-1:0] port_t;

    // Round control
    bit start_go;
    bit round_go;
    int unsigned round_idx;
    logic [NUM_PORTS-1:0] port_done;

    // Tables
    logic [47:0] src_mac_tbl      [NUM_PORTS][NUM_PKTS_PER_PORT];
    logic [47:0] dst_mac_tbl      [NUM_PORTS][NUM_PKTS_PER_PORT];
    logic [15:0] eth_type_tbl     [NUM_PORTS][NUM_PKTS_PER_PORT];
    int unsigned payload_len_tbl  [NUM_PORTS][NUM_PKTS_PER_PORT];

    // ----------------------------
    // Clock generation
    // ----------------------------
    initial begin
        for (int i = 0; i < NUM_PORTS; i++) begin
            gmii_rx_clk[i] = 1'b0;
        end
        forever #(GMII_CLK_PERIOD/2) begin
            for (int i = 0; i < NUM_PORTS; i++) begin
                gmii_rx_clk[i] = ~gmii_rx_clk[i];
            end
        end
    end

    initial begin
        switch_clk = 1'b0;
        forever #(SWITCH_CLK_PERIOD/2) switch_clk = ~switch_clk;
    end

    initial begin
        $dumpfile("tb_multiport_switch.vcd");
        $dumpvars(0, tb_multiport_switch);
    end

    // ----------------------------
    // DUT
    // ----------------------------
    switch dut (
        .gmii_rx_clk_i (gmii_rx_clk),
        .gmii_rx_data_i(gmii_rx_data),
        .gmii_rx_dv_i  (gmii_rx_dv),
        .gmii_rx_er_i  (gmii_rx_er),

        .switch_clk    (switch_clk),
        .switch_rst_n  (switch_rst_n),

        .gmii_tx_clk_o (gmii_tx_clk_o),
        .gmii_tx_data_o(gmii_tx_data_o),
        .gmii_tx_en_o  (gmii_tx_en_o),
        .gmii_tx_er_o  (gmii_tx_er_o)
    );

    // Enforce expected port count
    initial begin
        if (NUM_PORTS != 4) begin
            $error("tb_multiport_switch expects NUM_PORTS=4, but package NUM_PORTS=%0d", NUM_PORTS);
            $finish;
        end
    end

    // ----------------------------
    // Helpers / Tasks
    // ----------------------------
    task automatic init_gmii;
        for (int p = 0; p < NUM_PORTS; p++) begin
            gmii_rx_data[p] = '0;
            gmii_rx_dv  [p] = 1'b0;
            gmii_rx_er  [p] = 1'b0;
        end
    endtask

    task automatic send_byte(
        input logic [7:0] data,
        input port_t port,
        input logic dv = 1'b1,
        input logic er = 1'b0
    );
        @(posedge gmii_rx_clk[port]);
        gmii_rx_data[port] = data;
        gmii_rx_dv  [port] = dv;
        gmii_rx_er  [port] = er;
    endtask

    task automatic idle_port(input port_t port);
        @(posedge gmii_rx_clk[port]);
        gmii_rx_data[port] = '0;
        gmii_rx_dv  [port] = 1'b0;
        gmii_rx_er  [port] = 1'b0;
    endtask

    // Strong per-(port,pkt) signature in first 4 bytes, then port/pkt-mixed pattern.
    function automatic logic [7:0] payload_byte(
        input port_t port,
        input int unsigned pkt_k,
        input int unsigned i
    );
        logic [7:0] p8, k8;
        p8 = {6'b0, port};
        k8 = pkt_k[7:0];

        unique case (i)
            0: payload_byte = 8'hA0 ^ p8;          // tag0
            1: payload_byte = 8'hB0 ^ k8;          // tag1
            2: payload_byte = 8'hC0 ^ p8 ^ k8;     // tag2
            3: payload_byte = 8'hD0 ^ (p8 << 1);   // tag3
            default: payload_byte = (i[7:0] + 8'h11)
                                    ^ (p8 * 8'h13)
                                    ^ (k8 * 8'h29);
        endcase
    endfunction

    task automatic send_simple_frame(
        input logic [47:0] dst_mac,
        input logic [47:0] src_mac,
        input logic [15:0] eth_type,
        input int unsigned payload_len,
        input port_t port,
        input int unsigned pkt_k
    );
        logic [31:0] fcs;

        // Preamble
        for (int i = 0; i < 7; i++) begin
            send_byte(8'h55, port);
        end

        // SFD
        send_byte(8'hD5, port);

        // Destination MAC (MSB-first)
        for (int i = 5; i >= 0; i--) begin
            send_byte(dst_mac[i*8 +: 8], port);
        end

        // Source MAC
        for (int i = 5; i >= 0; i--) begin
            send_byte(src_mac[i*8 +: 8], port);
        end

        // EtherType
        send_byte(eth_type[15:8], port);
        send_byte(eth_type[7:0],  port);

        // Payload
        for (int i = 0; i < payload_len; i++) begin
            send_byte(payload_byte(port, pkt_k, i), port);
        end

        // Dummy FCS
        fcs = 32'hDEADBEEF;
        send_byte(fcs[7:0],   port);
        send_byte(fcs[15:8],  port);
        send_byte(fcs[23:16], port);
        send_byte(fcs[31:24], port);

        // End of frame
        idle_port(port);

        // IFG >= 12 GMII clocks
        repeat (12) begin
            @(posedge gmii_rx_clk[port]);
            gmii_rx_data[port] = '0;
            gmii_rx_dv  [port] = 1'b0;
            gmii_rx_er  [port] = 1'b0;
        end
    endtask

    // ----------------------------
    // Per-port worker processes
    // ----------------------------
    genvar gp;
    generate
        for (gp = 0; gp < NUM_PORTS; gp++) begin : PORT_PROCS
            initial begin : PORT_WORKER
                port_t ap;
                ap = port_t'(gp);

                wait (start_go);

                for (int k = 0; k < NUM_PKTS_PER_PORT; k++) begin
                    wait (round_go && (round_idx == k));

                    $display("[%0t] Port %0d sending pkt %0d dst=%h src=%h type=%h payload=%0d",
                             $time, ap, k,
                             dst_mac_tbl[ap][k],
                             src_mac_tbl[ap][k],
                             eth_type_tbl[ap][k],
                             payload_len_tbl[ap][k]);

                    send_simple_frame(
                        dst_mac_tbl[ap][k],
                        src_mac_tbl[ap][k],
                        eth_type_tbl[ap][k],
                        payload_len_tbl[ap][k],
                        ap,
                        k
                    );

                    port_done[ap] = 1'b1;
                    wait (!round_go);
                end
            end
        end
    endgenerate

    // ----------------------------
    // Controller process
    // ----------------------------
    initial begin : CTRL_PROC

        // Init controls
        start_go  = 1'b0;
        round_go  = 1'b0;
        round_idx = 0;
        port_done = '0;

        init_gmii();

        // Reset
        switch_rst_n = 1'b0;
        repeat(10) @(posedge switch_clk);
        switch_rst_n = 1'b1;
        repeat(10) @(posedge switch_clk);

        // Build MAC/type/payload tables (explicit bytes to avoid SELRANGE warnings)
        //
        // Round 0 (pkt0):
        //   src0[p] = 02:00:00:00:00:(10+p)
        //   dst0[p] = 0A:00:00:00:00:(A0+p)  (unknown unicast)
        //   EXPECT FLOOD
        //
        // Round 1 (pkt1):
        //   src1[p] = 02:00:00:00:00:(20+p)
        //   dst1 ring:
        //      p0 -> src0[p1]
        //      p1 -> src0[p0]
        //      p2 -> src0[p3]
        //      p3 -> src0[p2]
        //   EXPECT UNICAST ONLY
        //
        for (int p = 0; p < NUM_PORTS; p++) begin
            logic [7:0] pb;
            pb = p[7:0];

            // pkt0
            src_mac_tbl[p][0]  = {40'h02_00_00_00_00, 8'h10 + pb};
            dst_mac_tbl[p][0]  = {40'h0A_00_00_00_00, 8'hA0 + pb};
            eth_type_tbl[p][0] = 16'h0800;
            payload_len_tbl[p][0] = BASE_PAYLOAD_LEN + (p * 8);

            // pkt1
            src_mac_tbl[p][1]  = {40'h02_00_00_00_00, 8'h20 + pb};
            dst_mac_tbl[p][1]  = {40'h0B_00_00_00_00, 8'hB0 + pb}; // overridden below
            eth_type_tbl[p][1] = 16'h0800;
            payload_len_tbl[p][1] = BASE_PAYLOAD_LEN + 4 + (p * 8);
        end

        // Ring mapping for learning check
        dst_mac_tbl[0][1] = src_mac_tbl[1][0];
        dst_mac_tbl[1][1] = src_mac_tbl[0][0];
        dst_mac_tbl[2][1] = src_mac_tbl[3][0];
        dst_mac_tbl[3][1] = src_mac_tbl[2][0];

        // Expected behavior summary
        $display("\n=== 4-port parallel learning stress ===");
        $display("Round 0 (pkt0 on ports 0..3): unknown unicast dst -> EXPECT FLOOD");
        $display("Round 1 (pkt1 on ports 0..3): dst = other port's pkt0 src -> EXPECT UNICAST ONLY");
        $display("Ring mapping: p0->p1, p1->p0, p2->p3, p3->p2");
        $display("Payloads: unique per (port,pkt) via 4-byte signature + length skew");

        // Release workers
        @(posedge gmii_rx_clk[0]);
        start_go = 1'b1;

        // ----------------------------
        // Round 0: all ports send pkt0 in parallel
        // ----------------------------
        port_done = '0;
        round_idx = 0;
        round_go  = 1'b1;

        wait (&port_done);   // wait all ports finished pkt0

        round_go = 1'b0;

        // Allow learning updates to commit in switch clock domain
        repeat(200) @(posedge switch_clk);

        // ----------------------------
        // Round 1: all ports send pkt1 in parallel
        // ----------------------------
        port_done = '0;
        round_idx = 1;
        round_go  = 1'b1;

        wait (&port_done);   // wait all ports finished pkt1

        round_go = 1'b0;

        // Let switch flush pipelines
        repeat(8000) @(posedge switch_clk);

        $display("\n=== Done ===");
        $finish;
    end

endmodule
