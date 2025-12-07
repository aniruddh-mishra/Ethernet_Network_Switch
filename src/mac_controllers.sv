/* verilator lint_off DECLFILENAME */
module synchronizer (input logic clk, input logic rst_n_in, output logic rst_n_out);
    logic sync_ff1, sync_ff2;

    always_ff @(posedge clk or negedge rst_n_in) begin
        if (!rst_n_in) begin
            sync_ff1 <= 1'b0;
            sync_ff2 <= 1'b0;
        end else begin
            sync_ff1 <= 1'b1;
            sync_ff2 <= sync_ff1;
        end
    end

    assign rst_n_out = sync_ff2;
endmodule

/* verilator lint_off DECLFILENAME */
module clk_div #(parameter int DIVIDE = 3)(input logic clk_in, input logic rst_n, output logic clk_out);
    logic [$clog2(DIVIDE)-1:0] div_ctr, div_ff;
    assign div_ff = DIVIDE[1:0];

    always_ff @(posedge clk_in or negedge rst_n) begin
        if (!rst_n) begin
            div_ctr <= 0;
            clk_out <= 0;
        end else begin
            if (div_ctr == (div_ff>>1)) begin
                clk_out <= ~clk_out;
                div_ctr <= 0;
            end else begin
                div_ctr <= div_ctr + 1;
            end
        end
    end
endmodule
