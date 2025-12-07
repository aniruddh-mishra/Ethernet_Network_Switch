#!/usr/bin/env zsh

verilator -sv --binary --trace packages/switch_pkg.sv packages/mem_pkg.sv tests/tb_translator.sv src/translator.sv --top-module tb_translator -o sim_translator

./obj_dir/sim_translator

gtkwave tb_translator.vcd