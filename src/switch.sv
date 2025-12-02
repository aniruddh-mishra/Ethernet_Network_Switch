module switch (
    input gmii_clk, switch_clk, rst_n,
    
    // GMII Input
    input logic gmii_rx_clk_i,
    input logic [DATA_WIDTH-1:0] gmii_rx_data_i,
    input logic gmii_rx_dv_i,
    input logic gmii_rx_er_i,

    // GMII Out
    output logic gmii_tx_clk_o,
    output logic [DATA_WIDTH-1:0] gmii_tx_data_o,
    output logic gmii_tx_en_o,
    output logic gmii_tx_er_o
);


    
endmodule