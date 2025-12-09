#!/usr/bin/env zsh

verilator -sv --binary --trace packages/switch_pkg.sv packages/voq_pkg.sv packages/mem_pkg.sv tests/tb_voq.sv src/voq.sv --top-module tb_voq -o sim_voq

./obj_dir/sim_voq

gtkwave tb_voq.vcd