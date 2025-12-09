#!/usr/bin/env zsh

verilator -sv --binary --trace packages/switch_pkg.sv packages/rx_tx_pkg.sv packages/mem_pkg.sv packages/voq_pkg.sv packages/address_table_pkg.sv tests/tb_rx_top.sv src/rx_top.sv src/translator.sv src/rx_mac_control.sv src/crossbar.sv src/address_table.sv src/voq.sv src/memory_read_ctrl.sv src/mac_controllers.sv src/memory_write_ctrl.sv src/sram.sv src/fl.sv src/async_fifo.sv src/arbiter.sv --top-module tb_rx_top -o sim_rx_top

./obj_dir/sim_rx_top

gtkwave tb_rx_top.vcd