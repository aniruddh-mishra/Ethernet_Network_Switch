#!/usr/bin/env zsh

verilator -sv --binary --trace packages/switch_pkg.sv packages/address_table_pkg.sv packages/mem_pkg.sv tests/tb_crossbar.sv src/translator.sv src/address_table.sv src/crossbar.sv --top-module tb_crossbar -o sim_crossbar

./obj_dir/sim_crossbar

gtkwave tb_crossbar.vcd