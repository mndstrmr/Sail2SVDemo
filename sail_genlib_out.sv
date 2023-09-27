`ifndef SAIL_LIBRARY_GENERATED
`define SAIL_LIBRARY_GENERATED

typedef struct packed {
    logic [7:0] size;
    logic [127:0] bits;
} sail_bits;

localparam SAIL_BITS_WIDTH = 128;
localparam SAIL_INDEX_WIDTH = 8;

function automatic logic [7:0] sail_bits_size(sail_bits bv); return bv.size; endfunction
function automatic logic [127:0] sail_bits_value(sail_bits bv); return bv.bits; endfunction

typedef logic [127:0] sail_int;

function automatic sail_unit sail_print_bits(sail_unit prefix, sail_bits bv);
    return SAIL_UNIT;
endfunction

function automatic sail_unit sail_string_of_bits(sail_bits bv);
    return SAIL_UNIT;
endfunction

function automatic sail_unit sail_print_int(sail_unit prefix, logic [127:0] i);
    return SAIL_UNIT;
endfunction

function automatic sail_unit sail_dec_str(logic [127:0] i);
    return SAIL_UNIT;
endfunction

function automatic sail_unit sail_hex_str(logic [127:0] i);
    return SAIL_UNIT;
endfunction

function automatic sail_unit sail_hex_str_upper(logic [127:0] i);
    return SAIL_UNIT;
endfunction

logic [127:0] sail_cycle_count_var;

function automatic logic [127:0] sail_get_cycle_count(sail_unit u);
    return sail_cycle_count_var;
endfunction

function automatic sail_unit sail_cycle_count(sail_unit u);
    sail_cycle_count_var = sail_cycle_count_var + 1;
    return SAIL_UNIT;
endfunction

function automatic sail_unit sail_string_of_bits_2(logic [1:0] bv);
    return SAIL_UNIT;
endfunction

function automatic sail_unit sail_string_of_bits_32(logic [31:0] bv);
    return SAIL_UNIT;
endfunction

function automatic sail_unit sail_string_of_bits_8(logic [7:0] bv);
    return SAIL_UNIT;
endfunction

function automatic sail_unit sail_string_of_bits_64(logic [63:0] bv);
    return SAIL_UNIT;
endfunction

function automatic sail_unit sail_string_of_bits_1(logic [0:0] bv);
    return SAIL_UNIT;
endfunction

function automatic sail_unit sail_string_of_bits_48(logic [47:0] bv);
    return SAIL_UNIT;
endfunction

function automatic sail_unit sail_print_fixed_bits_12(sail_unit prefix, logic [11:0] bv);
    return SAIL_UNIT;
endfunction

`endif
