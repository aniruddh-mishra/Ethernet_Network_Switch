#!/usr/bin/env zsh

verilator -Wall -sv --binary --trace tests/tb_address_table.sv packages/address_table_pkg.sv packages/switch_pkg.sv src/address_table.sv --top-module tb_address_table -o sim_address_table

./obj_dir/sim_address_table

gtkwave tb_address_table.vcd