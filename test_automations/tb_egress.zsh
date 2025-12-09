#!/usr/bin/env zsh

verilator -sv --binary --trace packages/switch_pkg.sv packages/rx_tx_pkg.sv packages/voq_pkg.sv tests/tb_egress.sv src/egress.sv src/voq.sv src/tx_mac_control.sv src/mac_controllers.sv --top-module tb_egress -o sim_egress

./obj_dir/sim_egress

gtkwave tb_egress.vcd