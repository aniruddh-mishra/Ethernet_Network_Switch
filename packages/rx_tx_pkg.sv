package rx_tx_pkg;
    // rx module parameters
    localparam DATA_WIDTH = 8;

    // ethernet standards
    localparam PREAMBLE_BYTE = 8'h55; // repeated for 7 bytes
    localparam SFD_BYTE = 8'hD5; // 1 byte after preamble
    /* MIN_FRAME_SIZE includes: 
        6-byte destination addr
        6-byte source addr
        2-byte type
        46 to 1500-byte data
        4-byte FCS 
    */
    // localparam MIN_FRAME_SIZE = 64;
    // localparam MAX_FRAME_SIZE = 1518; // 1522 if including VLAN tag
    localparam CRC32_POLY_REFLECTED = 32'hEDB88320; // non-reflected polynomial: 32'h04C11DB7
    /* 
        when including FCS in the CRC calculation (since it would be difficult to exclude the FCS bytes themselves without sacrificing speed), the CRC of the entire frame (data + FCS) should equal 0xC704DD7B
        this only occurs when there are no errors in the data or FCS transmitted
        this is due to the properties of the polynomial division used in CRC calculations, where after all data is sent, the CRC_reg should equal the FCS, and thus the final CRC (data + FCS) equals a known constant
    */
    localparam CRC32_CONSTANT = 32'h4248_02E9;
    // localparam CRC32_CONSTANT = 32'hC704DD7B; // final XOR value
    /* 
        function that computes the next CRC-32 value,
        given current CRC and new data byte LSB first, transmitting MSB first
        1. left shift data up to 32 bits, XOR with current CRC
        2. for each bit in the byte:
            a. if MSB of CRC == 1, << 1 and XOR with polynomial
            b. else just << 1
    */
    function automatic [31:0] crc32_next(input logic [7:0] data, input logic [31:0] crc_in);
        integer i;
        logic [31:0] crc;
        logic [7:0] data_reflected;
        
        // Reflect input byte
        data_reflected = {data[0], data[1], data[2], data[3], data[4], data[5], data[6], data[7]};
        
        crc = crc_in ^ {24'h0, data_reflected}; // XOR at LSB side
        
        // Shift RIGHT with reflected polynomial
        for (i = 0; i < 8; i = i + 1) begin
            if (crc[0]) begin  // Check LSB
                crc = (crc >> 1) ^ CRC32_POLY_REFLECTED; // Reflected polynomial
            end else begin
                crc = crc >> 1;
            end
        end
        
        return crc;
    endfunction
endpackage
