// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_memory_write_ctrl.h for the primary calling header

#ifndef VERILATED_VTB_MEMORY_WRITE_CTRL___024ROOT_H_
#define VERILATED_VTB_MEMORY_WRITE_CTRL___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_memory_write_ctrl__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_memory_write_ctrl___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    CData/*0:0*/ tb_memory_write_ctrl__DOT__clk;
    CData/*0:0*/ tb_memory_write_ctrl__DOT__rst_n;
    CData/*7:0*/ tb_memory_write_ctrl__DOT__data_i;
    CData/*0:0*/ tb_memory_write_ctrl__DOT__data_valid_i;
    CData/*0:0*/ tb_memory_write_ctrl__DOT__data_begin_i;
    CData/*0:0*/ tb_memory_write_ctrl__DOT__data_end_i;
    CData/*0:0*/ tb_memory_write_ctrl__DOT__fl_alloc_gnt_i;
    CData/*0:0*/ tb_memory_write_ctrl__DOT__mem_ready_i;
    CData/*0:0*/ tb_memory_write_ctrl__DOT__mem_we_o;
    CData/*0:0*/ tb_memory_write_ctrl__DOT__dut__DOT__fl_alloc_req_o;
    CData/*0:0*/ tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated;
    CData/*0:0*/ tb_memory_write_ctrl__DOT__dut__DOT__next_frame_allocated;
    CData/*1:0*/ tb_memory_write_ctrl__DOT__dut__DOT__state;
    CData/*1:0*/ tb_memory_write_ctrl__DOT__dut__DOT__state_n;
    CData/*5:0*/ tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt;
    CData/*0:0*/ tb_memory_write_ctrl__DOT__dut__DOT__mem_trans_success;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_memory_write_ctrl__DOT__clk__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_memory_write_ctrl__DOT__rst_n__0;
    SData/*11:0*/ tb_memory_write_ctrl__DOT__fl_alloc_block_idx_i;
    SData/*11:0*/ tb_memory_write_ctrl__DOT__mem_addr_o;
    SData/*11:0*/ tb_memory_write_ctrl__DOT__next_block_idx;
    SData/*15:0*/ tb_memory_write_ctrl__DOT__footer_dec;
    SData/*15:0*/ tb_memory_write_ctrl__DOT__dut__DOT__footer;
    SData/*11:0*/ tb_memory_write_ctrl__DOT__dut__DOT__curr_idx;
    SData/*11:0*/ tb_memory_write_ctrl__DOT__dut__DOT__next_idx;
    SData/*11:0*/ tb_memory_write_ctrl__DOT__dut__DOT__start_addr;
    SData/*11:0*/ tb_memory_write_ctrl__DOT__dut__DOT__frame_cnt;
    VlWide<16>/*511:0*/ tb_memory_write_ctrl__DOT__mem_wdata_o;
    IData/*31:0*/ tb_memory_write_ctrl__DOT__write_count;
    VlWide<16>/*495:0*/ tb_memory_write_ctrl__DOT__dut__DOT__payload_reg;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    VlUnpacked<CData/*0:0*/, 4> __Vm_traceActivity;
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_hf33a98da__0;
    VlTriggerScheduler __VtrigSched_hf33a9799__0;

    // INTERNAL VARIABLES
    Vtb_memory_write_ctrl__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vtb_memory_write_ctrl___024root(Vtb_memory_write_ctrl__Syms* symsp, const char* v__name);
    ~Vtb_memory_write_ctrl___024root();
    VL_UNCOPYABLE(Vtb_memory_write_ctrl___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
