`timescale 1ns/1ps

module tb_switch();
    import switch_pkg::*;
    import rx_tx_pkg::*;

    // clocks and reset
    logic switch_clk;
    logic rst_n;

    // per-port GMII rx signals
    logic gmii_rx_clk_i [NUM_PORTS-1:0];
    logic [DATA_WIDTH-1:0] gmii_rx_data_i [NUM_PORTS-1:0];
    logic gmii_rx_dv_i [NUM_PORTS-1:0];
    logic gmii_rx_er_i [NUM_PORTS-1:0];

    // instantiate DUT
    switch uut (
        .switch_clk(switch_clk),
        .rst_n(rst_n),
        .gmii_rx_clk_i(gmii_rx_clk_i),
        .gmii_rx_data_i(gmii_rx_data_i),
        .gmii_rx_dv_i(gmii_rx_dv_i),
        .gmii_rx_er_i(gmii_rx_er_i)
    );

    // clock generation
    initial begin
        switch_clk = 0;
        forever #5 switch_clk = ~switch_clk; // 100MHz
    end

    // tie GMII rx clocks to same clock for simple simulation
    initial begin
        for (int i = 0; i < NUM_PORTS; i++) begin
            gmii_rx_clk_i[i] = 0;
            fork
                forever #5 gmii_rx_clk_i[i] = ~gmii_rx_clk_i[i];
            join_none
        end
    end

    // reset
    initial begin
        rst_n = 0;
        for (int i = 0; i < NUM_PORTS; i++) begin
            gmii_rx_data_i[i] = 0;
            gmii_rx_dv_i[i] = 0;
            gmii_rx_er_i[i] = 0;
        end
        #20;
        rst_n = 1;
        #20;

        // send a broadcast frame from port 0 (learning source on port 0)
        send_eth_frame(0, 48'hFFFFFFFFFFFF, 48'h0000_0000_0001);
        #200;

        // send a frame from port 1 whose dest is the source we sent earlier (non-flood)
        send_eth_frame(1, 48'h0000_0000_0001, 48'h0000_0000_0002);
        #200;

        $display("Testbench complete, finishing simulation.");
        #100 $finish;
    end

    // task to send a simple Ethernet-like frame on a port: preamble(7x0x55) + SFD + dst(6) + src(6) + type(2) + 4 bytes payload
    task automatic send_eth_frame(input int port, input logic [47:0] dst, input logic [47:0] src);
        byte payload [4];
        payload[0] = 8'h11; payload[1] = 8'h22; payload[2] = 8'h33; payload[3] = 8'h44;
        // ensure starting aligned to gmii clock edge
        @(posedge gmii_rx_clk_i[port]);
        // preamble 7 bytes
        for (int i = 0; i < 7; i++) begin
            send_byte_on_port(port, PREAMBLE_BYTE);
        end
        // SFD
        send_byte_on_port(port, SFD_BYTE);
        // destination MAC msb..lsb (send bytes high->low)
        for (int i = 5; i >= 0; i--) send_byte_on_port(port, dst >> (8*i));
        // source MAC
        for (int i = 5; i >= 0; i--) send_byte_on_port(port, src >> (8*i));
        // type 0x0800
        send_byte_on_port(port, 8'h08);
        send_byte_on_port(port, 8'h00);
        // payload
        for (int i = 0; i < 4; i++) send_byte_on_port(port, payload[i]);
        // deassert DV to end frame
        @(posedge gmii_rx_clk_i[port]);
        gmii_rx_dv_i[port] <= 0;
        gmii_rx_data_i[port] <= 0;
        #(10);
    endtask

    // helper task: put one byte on gmii for one cycle
    task automatic send_byte_on_port(input int port, input logic [7:0] data);
        @(posedge gmii_rx_clk_i[port]);
        gmii_rx_data_i[port] <= data;
        gmii_rx_dv_i[port] <= 1;
        gmii_rx_er_i[port] <= 0;
    endtask

endmodule
