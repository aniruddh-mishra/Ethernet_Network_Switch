// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design internal header
// See Vtb_fl.h for the primary calling header

#ifndef VERILATED_VTB_FL___024ROOT_H_
#define VERILATED_VTB_FL___024ROOT_H_  // guard

#include "verilated.h"
#include "verilated_timing.h"


class Vtb_fl__Syms;

class alignas(VL_CACHE_LINE_BYTES) Vtb_fl___024root final : public VerilatedModule {
  public:

    // DESIGN SPECIFIC STATE
    CData/*0:0*/ tb_fl__DOT__clk;
    CData/*0:0*/ tb_fl__DOT__rst_n;
    CData/*0:0*/ tb_fl__DOT__alloc_req_i;
    CData/*0:0*/ tb_fl__DOT__alloc_gnt_o;
    CData/*0:0*/ tb_fl__DOT__free_req_i;
    CData/*0:0*/ tb_fl__DOT__dut__DOT__empty;
    CData/*0:0*/ tb_fl__DOT__dut__DOT__full;
    CData/*0:0*/ __VstlFirstIteration;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_fl__DOT__clk__0;
    CData/*0:0*/ __Vtrigprevexpr___TOP__tb_fl__DOT__rst_n__0;
    SData/*11:0*/ tb_fl__DOT__alloc_block_idx_o;
    SData/*11:0*/ tb_fl__DOT__free_block_idx_i;
    SData/*11:0*/ tb_fl__DOT__idx;
    SData/*11:0*/ tb_fl__DOT__freed_idx;
    SData/*11:0*/ tb_fl__DOT__bypass_free_idx;
    SData/*11:0*/ tb_fl__DOT__bypass_alloc_idx;
    SData/*12:0*/ tb_fl__DOT__dut__DOT__sp;
    SData/*11:0*/ tb_fl__DOT__dut__DOT____Vlvbound_hab8335fc__0;
    SData/*11:0*/ tb_fl__DOT__dut__DOT____Vlvbound_hd8c48ffd__0;
    IData/*31:0*/ tb_fl__DOT__unnamedblk1__DOT__i;
    IData/*31:0*/ tb_fl__DOT__dut__DOT__unnamedblk1__DOT__i;
    IData/*31:0*/ __VactIterCount;
    VlUnpacked<SData/*11:0*/, 4097> tb_fl__DOT__dut__DOT__stack;
    VlUnpacked<QData/*63:0*/, 1> __VstlTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VactTriggered;
    VlUnpacked<QData/*63:0*/, 1> __VnbaTriggered;
    VlUnpacked<CData/*0:0*/, 4> __Vm_traceActivity;
    VlNBACommitQueue<VlUnpacked<SData/*11:0*/, 4097>, false, SData/*11:0*/, 1> __VdlyCommitQueuetb_fl__DOT__dut__DOT__stack;
    VlDelayScheduler __VdlySched;
    VlTriggerScheduler __VtrigSched_h5a35964b__0;

    // INTERNAL VARIABLES
    Vtb_fl__Syms* const vlSymsp;

    // CONSTRUCTORS
    Vtb_fl___024root(Vtb_fl__Syms* symsp, const char* v__name);
    ~Vtb_fl___024root();
    VL_UNCOPYABLE(Vtb_fl___024root);

    // INTERNAL METHODS
    void __Vconfigure(bool first);
};


#endif  // guard
