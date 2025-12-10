#!/usr/bin/env zsh

verilator --Wall -sv --binary --trace --timing --Wno-UNUSED packages/switch_pkg.sv packages/mem_pkg.sv packages/rx_tx_pkg.sv packages/address_table_pkg.sv packages/voq_pkg.sv tests/tb_multiport_switch.sv src/* --top-module tb_multiport_switch -o sim_multiport_switch

./obj_dir/sim_multiport_switch

gtkwave tb_multiport_switch.vcd