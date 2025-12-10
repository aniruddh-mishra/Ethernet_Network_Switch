module tb_async_fifo;
    // parameters
    localparam int DATA_WIDTH  = 8;
    localparam int ADDR_WIDTH  = 4;
    localparam int SYNC_STAGES = 2;
   
    logic wclk, rclk;
    logic wrst_n, rrst_n;
    logic w_en;
    logic [DATA_WIDTH-1:0] w_data;
    logic w_full;
    logic r_en;
    logic [DATA_WIDTH-1:0] r_data;
    logic r_empty;

    async_fifo #(
        .DATA_WIDTH (DATA_WIDTH),
        .ADDR_WIDTH (ADDR_WIDTH),
        .SYNC_STAGES(SYNC_STAGES)
    ) dut (
        .wclk   (wclk),
        .wrst_n (wrst_n),
        .w_en   (w_en),
        .w_data (w_data),
        .w_full (w_full),
        .rclk   (rclk),
        .rrst_n (rrst_n),
        .r_en   (r_en),
        .r_data (r_data),
        .r_empty(r_empty)
    );

    // Set clocks

    // write clock: 10 ns period
    initial begin
        wclk = 0;
        forever #5 wclk = ~wclk;
    end

    // read clock: 17 ns period
    initial begin
        rclk = 0;
        forever #8.5 rclk = ~rclk;
    end

    // resets, stagger them on purpose
    initial begin
        wrst_n = 0;
        rrst_n = 0;

        // bring up write side first
        repeat (5) @(posedge wclk);
        wrst_n = 1;

        // bring up read side a bit later
        repeat (3) @(posedge rclk);
        rrst_n = 1;
    end

    // expected data queue
    typedef logic [DATA_WIDTH-1:0] data_t;
    data_t q[$];  // SV queue — grows/shrinks as we push/pop

    int unsigned tx_cnt = 0;
    int unsigned rx_cnt = 0;

    // randomly scheduled writes
    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            w_en   <= 1'b0;
            w_data <= '0;
            tx_cnt <= 0;
        end else begin
            // randomly write with .5 probability
            if (!$urandom_range(0,1) && !w_full) begin
                w_en   <= 1'b1;
                w_data <= tx_cnt[DATA_WIDTH-1:0];
                
                // set expected
                q.push_back(tx_cnt[DATA_WIDTH-1:0]);

                tx_cnt <= tx_cnt + 1;
            end else begin
                w_en <= 1'b0;
            end
        end
    end

    // schedule reads
    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            r_en <= 1'b0;
        end else begin
            // read with .5 prob
            if (!$urandom_range(0,1) && !r_empty)
                r_en <= 1'b1;
            else
                r_en <= 1'b0;
        end
    end

    // actual check
    always_ff @(posedge rclk) begin
        if (rrst_n && r_en && !r_empty) begin
            if (q.size() == 0) begin
                $error("Scoreboard underflow at %0t", $time);
            end else begin
                data_t exp = q.pop_front();
                if (r_data !== exp) begin
                    $error("DATA MISMATCH @%0t: got=%0h exp=%0h",
                           $time, r_data, exp);
                end else begin
                    rx_cnt <= rx_cnt + 1;
                end
            end
        end
    end

    // useful checks
    always_ff @(posedge wclk) begin
        if (wrst_n && w_en && w_full)
            $error("Write when full @%0t", $time);
    end

    always_ff @(posedge rclk) begin
        if (rrst_n && r_en && r_empty)
            $error("Read when empty @%0t", $time);
    end

    initial begin
        #200_000;
        $display("TX=%0d RX=%0d remaining_in_q=%0d", tx_cnt, rx_cnt, q.size());
        $finish;
    end

endmodule
