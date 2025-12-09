module tb_rx_top;

    // Import the package
    import rx_tx_pkg::*;
    import mem_pkg::*;
    import switch_pkg::*;

    // Parameters
    localparam int GMII_CLK_PERIOD   = 8;  // 125 MHz
    localparam int SWITCH_CLK_PERIOD = 2;  // 500 MHz

    localparam int unsigned NUM_PKTS_PER_PORT = 3;

    // Random payload bounds (bytes)
    localparam int unsigned MIN_PAYLOAD_LEN = 48;
    localparam int unsigned MAX_PAYLOAD_LEN = 300;

    // DUT signals
    logic gmii_rx_clk;
    logic [DATA_WIDTH-1:0] gmii_rx_data [NUM_PORTS-1:0];
    logic gmii_rx_dv [NUM_PORTS-1:0];
    logic gmii_rx_er [NUM_PORTS-1:0];

    logic switch_clk, switch_rst_n;

    // Small, sized port type
    typedef logic [$clog2(NUM_PORTS)-1:0] port_t;

    // Precomputed random payload lengths per port per packet
    int unsigned payload_len_tbl [NUM_PORTS][NUM_PKTS_PER_PORT];

    // Per-port bases
    logic [47:0] base_dst_arr  [NUM_PORTS];
    logic [47:0] base_src_arr  [NUM_PORTS];
    logic [15:0] base_type_arr [NUM_PORTS];

    // Round control (NO fork)
    bit start_go;
    bit round_go;
    int unsigned round_idx;
    logic [NUM_PORTS-1:0] port_done;

    logic [47:0] learn_dst;
    logic [47:0] learn_src;
    logic [15:0] learn_type;

    // Clock generation
    initial begin
        gmii_rx_clk = 0;
        forever #(GMII_CLK_PERIOD/2) gmii_rx_clk = ~gmii_rx_clk;
    end

    initial begin
        switch_clk = 0;
        forever #(SWITCH_CLK_PERIOD/2) switch_clk = ~switch_clk;
    end

    initial begin
        $dumpfile("tb_rx_top.vcd");
        $dumpvars(0, tb_rx_top);
    end

    // DUT instantiation
    rx_top dut (
        // GMII interface
        .gmii_rx_clk_i(gmii_rx_clk),
        .gmii_rx_data_i(gmii_rx_data),
        .gmii_rx_dv_i  (gmii_rx_dv),
        .gmii_rx_er_i  (gmii_rx_er),

        // switch's clk domain
        .switch_clk  (switch_clk),
        .switch_rst_n(switch_rst_n)
    );

    // Enforce expected port count
    initial begin
        if (NUM_PORTS != 4) begin
            $error("tb_rx_top expects NUM_PORTS=4, but package NUM_PORTS=%0d", NUM_PORTS);
            $finish;
        end
    end

    // Simple MAC increment helper
    function automatic logic [47:0] mac_add(
        input logic [47:0] base,
        input int unsigned inc
    );
        mac_add = base + {16'h0, inc[31:0]};
    endfunction

    // Drive one GMII byte on a specific port
    task automatic send_byte(
        input logic [7:0] data,
        input port_t port,
        input logic dv = 1'b1,
        input logic er = 1'b0
    );
        @(posedge gmii_rx_clk);
        gmii_rx_data[port] = data;
        gmii_rx_dv  [port] = dv;
        gmii_rx_er  [port] = er;
    endtask

    // Idle a port
    task automatic idle_port(input port_t port);
        @(posedge gmii_rx_clk);
        gmii_rx_data[port] = '0;
        gmii_rx_dv  [port] = 1'b0;
        gmii_rx_er  [port] = 1'b0;
    endtask

    // Initialize arrays
    task automatic init_gmii;
        for (int p = 0; p < NUM_PORTS; p++) begin
            gmii_rx_data[p] = '0;
            gmii_rx_dv  [p] = 1'b0;
            gmii_rx_er  [p] = 1'b0;
        end
    endtask

    task automatic send_simple_frame(
        input logic [47:0] dst_mac,
        input logic [47:0] src_mac,
        input logic [15:0] eth_type,
        input int unsigned payload_len,
        input port_t port
    );
        logic [31:0] fcs;

        // Preamble (7 x 0x55)
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

        // Payload pattern
        for (int i = 0; i < payload_len; i++) begin
            send_byte(i[7:0], port);
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
            @(posedge gmii_rx_clk);
            gmii_rx_data[port] = '0;
            gmii_rx_dv  [port] = 1'b0;
            gmii_rx_er  [port] = 1'b0;
        end
    endtask

    // Send the kth frame on one port
    task automatic send_kth_frame_on_port(
        input port_t port,
        input int unsigned k,
        input logic [47:0] base_dst,
        input logic [47:0] base_src,
        input logic [15:0] base_type,
        input int unsigned payload_len
    );
        logic [47:0] dst, src;
        logic [15:0] et;

        dst = mac_add(base_dst, k);
        src = mac_add(base_src, k);
        et  = base_type + k[15:0];

        $display("[%0t] Port %0d sending pkt %0d dst=%h src=%h type=%h payload=%0d",
                 $time, port, k, dst, src, et, payload_len);

        send_simple_frame(dst, src, et, payload_len, port);
    endtask

    // ----------------------------
    // Per-port worker processes
    // ----------------------------

    // initial begin : PORT0_PROC
    //     port_t ap;
    //     ap = port_t'(0);

    //     wait (start_go);

    //     for (int k = 0; k < NUM_PKTS_PER_PORT; k++) begin
    //         wait (round_go && (round_idx == k));
    //         send_kth_frame_on_port(ap, k, base_dst_arr[0], base_src_arr[0], base_type_arr[0], payload_len_tbl[0][k]);
    //         port_done[0] = 1'b1;
    //         wait (!round_go);
    //     end
    // end

    // initial begin : PORT1_PROC
    //     port_t ap;
    //     ap = port_t'(1);

    //     wait (start_go);

    //     for (int k = 0; k < NUM_PKTS_PER_PORT; k++) begin
    //         wait (round_go && (round_idx == k));
    //         send_kth_frame_on_port(ap, k, base_dst_arr[1], base_src_arr[1], base_type_arr[1], payload_len_tbl[1][k]);
    //         port_done[1] = 1'b1;
    //         wait (!round_go);
    //     end
    // end

    // initial begin : PORT2_PROC
    //     port_t ap;
    //     ap = port_t'(2);

    //     wait (start_go);

    //     for (int k = 0; k < NUM_PKTS_PER_PORT; k++) begin
    //         wait (round_go && (round_idx == k));
    //         send_kth_frame_on_port(ap, k, base_dst_arr[2], base_src_arr[2], base_type_arr[2], payload_len_tbl[2][k]);
    //         port_done[2] = 1'b1;
    //         wait (!round_go);
    //     end
    // end

    // initial begin : PORT3_PROC
    //     port_t ap;
    //     ap = port_t'(3);

    //     wait (start_go);

    //     for (int k = 0; k < NUM_PKTS_PER_PORT; k++) begin
    //         wait (round_go && (round_idx == k));
    //         send_kth_frame_on_port(ap, k, base_dst_arr[3], base_src_arr[3], base_type_arr[3], payload_len_tbl[3][k]);
    //         port_done[3] = 1'b1;
    //         wait (!round_go);
    //     end
    // end

    // ----------------------------
    // Controller process
    // ----------------------------
    initial begin : CTRL_PROC
        int unsigned seed;

        // // Init control signals
        // start_go  = 1'b0;
        // round_go  = 1'b0;
        // round_idx = 0;
        // port_done = '0;

        // // Optional reproducible randomness
        // seed = 32'hC0FFEE01;
        // void'($urandom(seed));

        // init_gmii();

        // // Reset
        // switch_rst_n = 1'b0;
        // repeat(10) @(posedge switch_clk);
        // switch_rst_n = 1'b1;
        // repeat(10) @(posedge switch_clk);

        // $display("\n=== RX parallel 4-port, 3-packet/port test (random payload 48..300, lockstep, NO fork) ===");
        // $display("NUM_PORTS=%0d, pkts/port=%0d", NUM_PORTS, NUM_PKTS_PER_PORT);

        // // Precompute random payload lengths
        // for (int p = 0; p < NUM_PORTS; p++) begin
        //     for (int k = 0; k < NUM_PKTS_PER_PORT; k++) begin
        //         payload_len_tbl[p][k] = $urandom_range(MAX_PAYLOAD_LEN, MIN_PAYLOAD_LEN);
        //     end
        // end

        // // Initialize per-port bases
        // for (int p = 0; p < NUM_PORTS; p++) begin
        //     base_dst_arr[p]  = 48'h10_20_30_40_50_00 + {16'h0, p[31:0]};
        //     base_src_arr[p]  = 48'h00_11_22_33_44_00 + {16'h0, p[31:0]};
        //     base_type_arr[p] = 16'h0800 + p[15:0];
        // end

        // // Release workers
        // @(posedge gmii_rx_clk);
        // start_go = 1'b1;

        // // Lockstep rounds driven by handshake
        // for (int k = 0; k < NUM_PKTS_PER_PORT; k++) begin
        //     port_done = '0;
        //     round_idx = k;
        //     round_go  = 1'b1;

        //     // Wait all ports finish this round
        //     wait (&port_done);

        //     // Drop round flag so workers can advance
        //     round_go = 1'b0;

        //     // Give a GMII edge for clean observation
        //     @(posedge gmii_rx_clk);
        // end

        // MAC learning duplicate test: send same MAC twice on two ports
        $display("\n=== MAC learning duplicate test ===");
        learn_dst = 48'hAA_BB_CC_DD_EE_00;
        learn_src = 48'h12_34_56_78_9A_00;
        learn_type = 16'h9000;

        // Port 0 duplicate frames
        send_simple_frame(learn_dst, learn_src, learn_type, 64, port_t'(0));
        send_simple_frame(learn_dst, learn_src, learn_type, 72, port_t'(0));

        // Port 1 duplicate frames
        send_simple_frame(learn_src, learn_dst + 1, learn_type + 1, 80, port_t'(1));
        send_simple_frame(learn_src, learn_dst + 1, learn_type + 1, 88, port_t'(1));

        // Give the switch domain time after all completes
        repeat(200) @(posedge switch_clk);

        // Optional visibility if these internal signals exist in your rx_top
        $display("[%0t] Port0 frame_error = %0b", $time, dut.rx_mac_control_frame_error[0]);
        $display("[%0t] Port1 frame_error = %0b", $time, dut.rx_mac_control_frame_error[1]);
        $display("[%0t] Port2 frame_error = %0b", $time, dut.rx_mac_control_frame_error[2]);
        $display("[%0t] Port3 frame_error = %0b", $time, dut.rx_mac_control_frame_error[3]);

        $display("\n=== Done ===");
        $finish;
    end

endmodule
