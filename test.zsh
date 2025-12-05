#!/usr/bin/env zsh

verilator -sv --binary --trace packages/switch_pkg.sv packages* tests/* src/* --top-module tb_address_table -o sim_address_table

./obj_dir/sim_address_table

gtkwave tb_address_table.vcd