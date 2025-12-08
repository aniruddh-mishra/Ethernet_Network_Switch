module tb_rx_top;

    // Import the package
    import rx_tx_pkg::*;
    import mem_pkg::*;
    import switch_pkg::*;

    // Parameters
    localparam int GMII_CLK_PERIOD   = 8;  // 125 MHz
    localparam int SWITCH_CLK_PERIOD = 2;  // 500 MHz

    // DUT signals
    logic gmii_rx_clk;
    logic [DATA_WIDTH-1:0] gmii_rx_data [NUM_PORTS];
    logic gmii_rx_dv [NUM_PORTS];
    logic gmii_rx_er [NUM_PORTS];

    logic switch_clk, switch_rst_n;

    // Clock generation (kept)
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
        $dumpvars(0, tb_memory_read_ctrl);
    end

    // DUT instantiation (exact style you requested)
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

    // Small, sized port type (avoids UNUSEDSIGNAL)
    typedef logic [$clog2(NUM_PORTS)-1:0] port_t;

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

    // Send a very simple Ethernet frame:
    // preamble + SFD + header + payload + dummy FCS
   
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
        // --- locals must be declared first for Verilator ---
        logic [31:0] fcs;

        // Preamble (7 x 0x55)
        for (int i = 0; i < 7; i++) begin
            send_byte(8'h55, port);
        end

        // SFD
        send_byte(8'hD5, port);

        // Destination MAC (MSB-first byte order)
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

        // Dummy FCS (LSB-first at byte level)
        fcs = 32'hDEADBEEF;
        send_byte(fcs[7:0],   port);
        send_byte(fcs[15:8],  port);
        send_byte(fcs[23:16], port);
        send_byte(fcs[31:24], port);

        // End of frame on this port
        idle_port(port);

        // IFG: keep DV low for at least 12 GMII clocks
        repeat (12) begin
            @(posedge gmii_rx_clk);
            gmii_rx_data[port] = '0;
            gmii_rx_dv  [port] = 1'b0;
            gmii_rx_er  [port] = 1'b0;
        end
    endtask

    // Main test
    initial begin
        port_t p0, p1;
        p0 = port_t'(0);
        p1 = port_t'(1);

        init_gmii();

        // Reset
        switch_rst_n = 1'b0;
        repeat(10) @(posedge switch_clk);
        switch_rst_n = 1'b1;
        repeat(10) @(posedge switch_clk);

        $display("\n=== Simple RX smoke test ===");

        // Frame 1: minimum payload-ish (46 bytes) on port 0
        $display("[%0t] Sending frame 1 on port 0 (payload 46)", $time);
        send_simple_frame(
            48'hFF_FF_FF_FF_FF_FF,
            48'h00_11_22_33_44_55,
            16'h0800,
            64,
            p0
        );

        // Give the switch domain time
        repeat(50) @(posedge switch_clk);

        // Frame 2: slightly larger payload (60 bytes) on port 1
        $display("[%0t] Sending frame 2 on port 1 (payload 60)", $time);
        send_simple_frame(
            48'h12_34_56_78_9A_BC,
            48'hDE_AD_BE_EF_CA_FE,
            16'h86DD,
            64,
            p1
        );

        repeat(100) @(posedge switch_clk);

        // Optional visibility if these internal signals exist in your rx_top
        // (You used them previously)
        $display("[%0t] Port0 frame_error = %0b", $time, dut.rx_mac_control_frame_error[p0]);
        $display("[%0t] Port1 frame_error = %0b", $time, dut.rx_mac_control_frame_error[p1]);

        $display("\n=== Done ===");
        $finish;
    end

endmodule
