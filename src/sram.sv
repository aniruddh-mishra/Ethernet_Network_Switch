module sram (
    input logic clk,

    // Port Write
    input logic we_i,
    input logic [ADDR_W-1:0] w_addr_i,
    input logic [BLOCK_BITS-1:0] w_data_i,

    // Port Read
    input logic [ADDR_W-1:0] r_addr_i,
    output logic [BLOCK_BITS-1:0] r_data_o
);

    logic [BLOCK_BITS-1:0] mem [NUM_BLOCKS-1:0];

    always_ff @(posedge clk) begin
        if (we_i) mem[w_addr_i] <= w_data_i;
        r_data_o <= mem[r_addr_i];
    end
endmodule
