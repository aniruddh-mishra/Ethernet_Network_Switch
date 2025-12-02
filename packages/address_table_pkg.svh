package address_table_pkg;
    parameter int NUM_ENTRIES = NUM_PORTS * 4; // Number entries in the addres learning table (~4 per port)
    parameter int MAX_HIT = 16; // Maximum number of hits in the hit table before saturation

    // Priority encoder function
    function automatic [$clog2(NUM_ENTRIES)-1:0] free_index(logic table_usage [NUM_ENTRIES-1:0], logic [$clog2(MAX_HIT)-1:0] table_hits [NUM_ENTRIES-1:0]);
        for (int i=0; i<(NUM_ENTRIES - 1); i=i+1) begin
            if (table_usage[i]) begin
                return i[$clog2(NUM_ENTRIES)-1:0];
            end
        end
        return min_used(table_hits);
    endfunction

    function automatic [$clog2(NUM_ENTRIES)-1:0] min_used(logic [$clog2(MAX_HIT)-1:0] table_hits [NUM_ENTRIES-1:0]);
        int smallest = {{(32-$clog2(MAX_HIT)){1'b0}}, table_hits[0]}; 
        logic [$clog2(NUM_ENTRIES)-1:0] return_address = 0;
        for (int i=0; i<(NUM_ENTRIES - 1); i=i+1) begin
            if ({{(32-$clog2(MAX_HIT)){1'b0}}, table_hits[i]} <= smallest) begin
                smallest = {{(32-$clog2(MAX_HIT)){1'b0}}, table_hits[i]};
                return_address = i[$clog2(NUM_ENTRIES)-1:0];
            end
        end
        return return_address;
    endfunction

endpackage
