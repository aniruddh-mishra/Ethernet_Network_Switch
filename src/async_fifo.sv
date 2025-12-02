module async_fifo #(
    parameter int ADDR_WIDTH = 4,
    parameter int SYNC_STAGES = 2
) (
    input logic wclk,
    input logic wrst_n,
    input logic w_en,
    input logic [DATA_WIDTH-1:0] w_data,
    output logic w_full,

    input logic rclk,
    input logic rrst_n,
    input logic r_en,
    output logic [DATA_WIDTH-1:0] r_data,
    output logic r_empty
);
    import mem_pkg::*;

    localparam int PTR_WIDTH = ADDR_WIDTH + 1;
    localparam int DEPTH = 1 << ADDR_WIDTH;

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];

    logic [PTR_WIDTH-1:0] w_bin, w_bin_n;
    logic [PTR_WIDTH-1:0] w_gray, w_gray_n;

    logic [PTR_WIDTH-1:0] r_bin, r_bin_n;
    logic [PTR_WIDTH-1:0] r_gray, r_gray_n;

    logic [PTR_WIDTH-1:0] r_gray_wclk [SYNC_STAGES];
    logic [PTR_WIDTH-1:0] w_gray_rclk [SYNC_STAGES];

    function automatic logic [PTR_WIDTH-1:0] bin2gray (input logic [PTR_WIDTH-1:0] b);
        bin2gray = b ^ (b >> 1);
    endfunction

    always_comb begin
        w_bin_n = w_bin;
        if (w_en && !w_full)
            w_bin_n = w_bin + 1'b1;
        w_gray_n = bin2gray(w_bin_n);
    end

    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            w_bin <= '0;
            w_gray <= '0;
        end else begin
            w_bin <= w_bin_n;
            w_gray <= w_gray_n;
        end
    end

    always_ff @(posedge wclk) begin
        if (w_en && !w_full)
            mem[w_bin[ADDR_WIDTH-1:0]] <= w_data;
    end

    genvar i;
    generate
        for (i = 0; i < SYNC_STAGES; i++) begin : g_sync_r2w
            always_ff @(posedge wclk or negedge wrst_n) begin
                if (!wrst_n) begin
                    r_gray_wclk[i] <= '0;
                end else begin
                    if (i == 0)
                        r_gray_wclk[i] <= r_gray;
                    else
                        r_gray_wclk[i] <= r_gray_wclk[i - 1];
                end
            end
        end
    endgenerate

    always_comb begin
        logic [PTR_WIDTH-1:0] r_gray_sync;
        logic [PTR_WIDTH-1:0] w_bin_next;
        logic [PTR_WIDTH-1:0] w_gray_next;

        r_gray_sync = r_gray_wclk[SYNC_STAGES-1];
        w_bin_next  = w_bin + 1'b1;
        w_gray_next = bin2gray(w_bin_next);

        w_full = (w_gray_next ==
                  {~r_gray_sync[PTR_WIDTH-1:PTR_WIDTH-2],
                    r_gray_sync[PTR_WIDTH-3:0]});
    end

    always_comb begin
        r_bin_n = r_bin;
        if (r_en && !r_empty)
            r_bin_n = r_bin + 1'b1;
        r_gray_n = bin2gray(r_bin_n);
    end

    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            r_bin <= '0;
            r_gray <= '0;
        end else begin
            r_bin <= r_bin_n;
            r_gray <= r_gray_n;
        end
    end

    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n)
            r_data <= '0;
        else if (r_en && !r_empty)
            r_data <= mem[r_bin[ADDR_WIDTH-1:0]];
    end

    generate
        for (i = 0; i < SYNC_STAGES; i++) begin : g_sync_w2r
            always_ff @(posedge rclk or negedge rrst_n) begin
                if (!rrst_n) begin
                    w_gray_rclk[i] <= '0;
                end
                else begin
                    if (i == 0)
                        w_gray_rclk[i] <= w_gray;
                    else
                        w_gray_rclk[i] <= w_gray_rclk[i - 1];
                end
            end
        end
    endgenerate

    always_comb begin
        r_empty = (w_gray_rclk[SYNC_STAGES-1] == r_gray);
    end
endmodule
