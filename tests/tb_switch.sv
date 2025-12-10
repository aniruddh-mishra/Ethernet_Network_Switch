module tb_switch;

    // Import the package
    import rx_tx_pkg::*;
    import mem_pkg::*;
    import switch_pkg::*;

    // Parameters
    localparam int GMII_CLK_PERIOD   = 8;  // 125 MHz
    localparam int SWITCH_CLK_PERIOD = 2;  // 500 MHz

    // Keep the original count, but we will only drive port 0
    localparam int unsigned NUM_PKTS_PER_PORT = 3;

    // Random payload bounds (bytes)
    localparam int unsigned MIN_PAYLOAD_LEN = 48;
    localparam int unsigned MAX_PAYLOAD_LEN = 300;

    // DUT signals
    logic gmii_rx_clk [NUM_PORTS-1:0];
    logic [DATA_WIDTH-1:0] gmii_rx_data [NUM_PORTS-1:0];
    logic gmii_rx_dv [NUM_PORTS-1:0];
    logic gmii_rx_er [NUM_PORTS-1:0];

    logic gmii_tx_clk_o [NUM_PORTS-1:0];
    logic [DATA_WIDTH-1:0] gmii_tx_data_o [NUM_PORTS-1:0];
    logic gmii_tx_en_o [NUM_PORTS-1:0];
    logic gmii_tx_er_o [NUM_PORTS-1:0];

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

    // Clock generation
    initial begin
        gmii_rx_clk = '{default:'0};
        forever #(GMII_CLK_PERIOD/2) begin
            for (int i = 0; i < NUM_PORTS; i++) begin
                gmii_rx_clk[i] = ~gmii_rx_clk[i];
            end
        end
    end

    initial begin
        switch_clk = 0;
        forever #(SWITCH_CLK_PERIOD/2) switch_clk = ~switch_clk;
    end

    initial begin
        $dumpfile("tb_switch.vcd");
        $dumpvars(0, tb_switch);
    end

    // DUT instantiation
    switch dut (
        // GMII interface
        .gmii_rx_clk_i(gmii_rx_clk),
        .gmii_rx_data_i(gmii_rx_data),
        .gmii_rx_dv_i  (gmii_rx_dv),
        .gmii_rx_er_i  (gmii_rx_er),

        // switch's clk domain
        .switch_clk  (switch_clk),
        .switch_rst_n(switch_rst_n),
        
        // GMII Outputs
        .gmii_tx_clk_o(gmii_tx_clk_o),
        .gmii_tx_data_o(gmii_tx_data_o),
        .gmii_tx_en_o(gmii_tx_en_o),
        .gmii_tx_er_o(gmii_tx_er_o)
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

    // Reuse pattern: with 3 pkts, repeat pkt0 MACs on pkt2
    function automatic int unsigned mac_inc_sel(input int unsigned k);
        if (k == (NUM_PKTS_PER_PORT-1))
            mac_inc_sel = 0;  // last pkt repeats inc 0
        else
            mac_inc_sel = k;
    endfunction

    // Drive one GMII byte on a specific port
    task automatic send_byte(
        input logic [7:0] data,
        input port_t port,
        input logic dv = 1'b1,
        input logic er = 1'b0
    );
        @(posedge gmii_rx_clk[0]);
        gmii_rx_data[port] = data;
        gmii_rx_dv  [port] = dv;
        gmii_rx_er  [port] = er;
    endtask

    // Idle a port
    task automatic idle_port(input port_t port);
        @(posedge gmii_rx_clk[0]);
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
            @(posedge gmii_rx_clk[0]);
            gmii_rx_data[port] = '0;
            gmii_rx_dv  [port] = 1'b0;
            gmii_rx_er  [port] = 1'b0;
        end
    endtask

    // Send the kth frame on one port
    // - Port 0 only in this TB
    // - For k>=1: dst MAC matches previous packet's src MAC
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
        int unsigned k_sel, k_prev_sel;

        k_sel = mac_inc_sel(k);

        // Current source MAC
        src = mac_add(base_src, k_sel);

        // Destination MAC:
        // pkt0 uses base dst.
        // subsequent pkts target the previous pkt's source
        if (k == 0) begin
            dst = mac_add(base_dst, k_sel);
        end else begin
            k_prev_sel = mac_inc_sel(k-1);
            dst = mac_add(base_src, k_prev_sel);
        end

        et  = base_type + k[15:0];

        $display("[%0t] Port %0d sending pkt %0d (mac_sel=%0d) dst=%h src=%h type=%h payload=%0d",
                 $time, port, k, k_sel, dst, src, et, payload_len);

        send_simple_frame(dst, src, et, payload_len, port);
    endtask

    // ----------------------------
    // Single-port worker process (PORT 0 only)
    // ----------------------------
    initial begin : PORT0_PROC
        port_t ap;
        ap = port_t'(0);

        wait (start_go);

        for (int k = 0; k < NUM_PKTS_PER_PORT; k++) begin
            wait (round_go && (round_idx == k));
            send_kth_frame_on_port(ap, k,
                                   base_dst_arr[0],
                                   base_src_arr[0],
                                   base_type_arr[0],
                                   payload_len_tbl[0][k]);
            port_done[0] = 1'b1;
            wait (!round_go);
        end
    end

    // ----------------------------
    // Controller process
    // ----------------------------
    initial begin : CTRL_PROC
        int unsigned seed;

        // Init control signals
        start_go  = 1'b0;
        round_go  = 1'b0;
        round_idx = 0;
        port_done = '0;

        // Optional reproducible randomness
        seed = 32'hC0FFEE01;
        void'($urandom(seed));

        init_gmii();

        // Reset
        switch_rst_n = 1'b0;
        repeat(10) @(posedge switch_clk);
        switch_rst_n = 1'b1;
        repeat(10) @(posedge switch_clk);

        $display("\n=== RX single-port test (port 0 only) ===");
        $display("Packets: 0 normal, 1 dst=src(pkt0), 2 dst=src(pkt1) with MAC reuse");

        // Precompute random payload lengths (only port 0 is used)
        for (int k = 0; k < NUM_PKTS_PER_PORT; k++) begin
            payload_len_tbl[0][k] = $urandom_range(MAX_PAYLOAD_LEN, MIN_PAYLOAD_LEN);
        end

        // Initialize port 0 bases (others unused)
        base_dst_arr[0]  = 48'h10_20_30_40_50_00;
        base_src_arr[0]  = 48'h00_11_22_33_44_00;
        base_type_arr[0] = 16'h0800;

        // Release worker
        @(posedge gmii_rx_clk[0]);
        start_go = 1'b1;

        // Lockstep rounds driven by handshake (only wait port 0)
        for (int k = 0; k < NUM_PKTS_PER_PORT; k++) begin
            port_done = '0;
            round_idx = k;
            round_go  = 1'b1;

            wait (port_done[0]);

            round_go = 1'b0;

            @(posedge gmii_rx_clk[0]);
        end

        // Give the switch domain time after completion
        repeat(2000) @(posedge switch_clk);

        // Optional visibility if these internal signals exist in your rx_top
        // $display("[%0t] Port0 frame_error = %0b", $time, dut.rx_mac_control_frame_error[0]);

        $display("\n=== Done ===");
        $finish;
    end

endmodule
