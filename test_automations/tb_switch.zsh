#!/usr/bin/env zsh

verilator -sv --binary --trace --timing packages/switch_pkg.sv packages/mem_pkg.sv packages/rx_tx_pkg.sv packages/address_table_pkg.sv packages/voq_pkg.sv tests/tb_switch.sv src/* --top-module tb_switch -o sim_switch

./obj_dir/sim_switch

gtkwave tb_switch.vcd