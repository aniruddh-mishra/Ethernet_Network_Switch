// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_fl.h for the primary calling header

#include "Vtb_fl__pch.h"

VL_ATTR_COLD void Vtb_fl___024root___eval_initial__TOP(Vtb_fl___024root* vlSelf);
VlCoroutine Vtb_fl___024root___eval_initial__TOP__Vtiming__0(Vtb_fl___024root* vlSelf);
VlCoroutine Vtb_fl___024root___eval_initial__TOP__Vtiming__1(Vtb_fl___024root* vlSelf);

void Vtb_fl___024root___eval_initial(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___eval_initial\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_fl___024root___eval_initial__TOP(vlSelf);
    vlSelfRef.__Vm_traceActivity[1U] = 1U;
    Vtb_fl___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vtb_fl___024root___eval_initial__TOP__Vtiming__1(vlSelf);
}

VlCoroutine Vtb_fl___024root___eval_initial__TOP__Vtiming__0(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __Vtask_tb_fl__DOT__do_reset__0__tb_fl__DOT__unnamedblk1_1__DOT____Vrepeat0;
    __Vtask_tb_fl__DOT__do_reset__0__tb_fl__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0;
    SData/*11:0*/ __Vtask_tb_fl__DOT__do_alloc__1__idx_o;
    __Vtask_tb_fl__DOT__do_alloc__1__idx_o = 0;
    CData/*0:0*/ __Vtask_tb_fl__DOT__do_alloc__1__expect_gnt;
    __Vtask_tb_fl__DOT__do_alloc__1__expect_gnt = 0;
    std::string __Vtask_tb_fl__DOT__do_alloc__1__tag;
    SData/*11:0*/ __Vtask_tb_fl__DOT__do_alloc__2__idx_o;
    __Vtask_tb_fl__DOT__do_alloc__2__idx_o = 0;
    CData/*0:0*/ __Vtask_tb_fl__DOT__do_alloc__2__expect_gnt;
    __Vtask_tb_fl__DOT__do_alloc__2__expect_gnt = 0;
    std::string __Vtask_tb_fl__DOT__do_alloc__2__tag;
    SData/*11:0*/ __Vtask_tb_fl__DOT__do_free__3__idx_i;
    __Vtask_tb_fl__DOT__do_free__3__idx_i = 0;
    std::string __Vtask_tb_fl__DOT__do_free__3__tag;
    SData/*11:0*/ __Vtask_tb_fl__DOT__do_alloc__4__idx_o;
    __Vtask_tb_fl__DOT__do_alloc__4__idx_o = 0;
    CData/*0:0*/ __Vtask_tb_fl__DOT__do_alloc__4__expect_gnt;
    __Vtask_tb_fl__DOT__do_alloc__4__expect_gnt = 0;
    std::string __Vtask_tb_fl__DOT__do_alloc__4__tag;
    SData/*11:0*/ __Vtask_tb_fl__DOT__do_alloc_free_same_cycle__5__free_idx_i;
    __Vtask_tb_fl__DOT__do_alloc_free_same_cycle__5__free_idx_i = 0;
    SData/*11:0*/ __Vtask_tb_fl__DOT__do_alloc_free_same_cycle__5__alloc_idx_o;
    __Vtask_tb_fl__DOT__do_alloc_free_same_cycle__5__alloc_idx_o = 0;
    // Body
    vlSelfRef.tb_fl__DOT__rst_n = 0U;
    vlSelfRef.tb_fl__DOT__alloc_req_i = 0U;
    vlSelfRef.tb_fl__DOT__free_req_i = 0U;
    vlSelfRef.tb_fl__DOT__free_block_idx_i = 0U;
    __Vtask_tb_fl__DOT__do_reset__0__tb_fl__DOT__unnamedblk1_1__DOT____Vrepeat0 = 5U;
    while (VL_LTS_III(32, 0U, __Vtask_tb_fl__DOT__do_reset__0__tb_fl__DOT__unnamedblk1_1__DOT____Vrepeat0)) {
        co_await vlSelfRef.__VtrigSched_h5a35964b__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_fl.clk)", 
                                                             "test/tb_fl.sv", 
                                                             55);
        vlSelfRef.__Vm_traceActivity[2U] = 1U;
        __Vtask_tb_fl__DOT__do_reset__0__tb_fl__DOT__unnamedblk1_1__DOT____Vrepeat0 
            = (__Vtask_tb_fl__DOT__do_reset__0__tb_fl__DOT__unnamedblk1_1__DOT____Vrepeat0 
               - (IData)(1U));
    }
    vlSelfRef.tb_fl__DOT__rst_n = 1U;
    co_await vlSelfRef.__VtrigSched_h5a35964b__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_fl.clk)", 
                                                         "test/tb_fl.sv", 
                                                         57);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    VL_WRITEF_NX("[%0t] Reset deasserted\n=== TEST 1: allocate until empty ===\n",0,
                 64,VL_TIME_UNITED_Q(1),-12);
    vlSelfRef.tb_fl__DOT__unnamedblk1__DOT__i = 0U;
    while ((0x00001000U > vlSelfRef.tb_fl__DOT__unnamedblk1__DOT__i)) {
        __Vtask_tb_fl__DOT__do_alloc__1__tag = VL_SFORMATF_N_NX("alloc %0d",0,
                                                                32,
                                                                vlSelfRef.tb_fl__DOT__unnamedblk1__DOT__i) ;
        __Vtask_tb_fl__DOT__do_alloc__1__expect_gnt = 1U;
        vlSelfRef.tb_fl__DOT__alloc_req_i = 1U;
        vlSelfRef.tb_fl__DOT__free_req_i = 0U;
        co_await vlSelfRef.__VtrigSched_h5a35964b__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_fl.clk)", 
                                                             "test/tb_fl.sv", 
                                                             70);
        vlSelfRef.__Vm_traceActivity[2U] = 1U;
        __Vtask_tb_fl__DOT__do_alloc__1__idx_o = vlSelfRef.tb_fl__DOT__alloc_block_idx_o;
        if (VL_UNLIKELY((((IData)(vlSelfRef.tb_fl__DOT__alloc_gnt_o) 
                          != (IData)(__Vtask_tb_fl__DOT__do_alloc__1__expect_gnt))))) {
            VL_WRITEF_NX("[%0t] %%Error: tb_fl.sv:75: Assertion failed in %Ntb_fl.do_alloc: [%0t] %@: expected grant=%0b, got %0b\n",0,
                         64,VL_TIME_UNITED_Q(1),-12,
                         vlSymsp->name(),64,VL_TIME_UNITED_Q(1),
                         -12,-1,&(__Vtask_tb_fl__DOT__do_alloc__1__tag),
                         1,(IData)(__Vtask_tb_fl__DOT__do_alloc__1__expect_gnt),
                         1,vlSelfRef.tb_fl__DOT__alloc_gnt_o);
            VL_STOP_MT("test/tb_fl.sv", 75, "");
        } else {
            VL_WRITEF_NX("[%0t] %@: alloc_gnt_o=%0b, idx=%0#\n",0,
                         64,VL_TIME_UNITED_Q(1),-12,
                         -1,&(__Vtask_tb_fl__DOT__do_alloc__1__tag),
                         1,(IData)(vlSelfRef.tb_fl__DOT__alloc_gnt_o),
                         12,__Vtask_tb_fl__DOT__do_alloc__1__idx_o);
        }
        vlSelfRef.tb_fl__DOT__alloc_req_i = 0U;
        co_await vlSelfRef.__VtrigSched_h5a35964b__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_fl.clk)", 
                                                             "test/tb_fl.sv", 
                                                             83);
        vlSelfRef.__Vm_traceActivity[2U] = 1U;
        vlSelfRef.tb_fl__DOT__idx = __Vtask_tb_fl__DOT__do_alloc__1__idx_o;
        vlSelfRef.tb_fl__DOT__unnamedblk1__DOT__i = 
            ((IData)(1U) + vlSelfRef.tb_fl__DOT__unnamedblk1__DOT__i);
    }
    VL_WRITEF_NX("=== TEST 2: allocation when empty (expect no grant) ===\n",0);
    __Vtask_tb_fl__DOT__do_alloc__2__tag = "alloc when empty"s;
    __Vtask_tb_fl__DOT__do_alloc__2__expect_gnt = 0U;
    vlSelfRef.tb_fl__DOT__alloc_req_i = 1U;
    vlSelfRef.tb_fl__DOT__free_req_i = 0U;
    co_await vlSelfRef.__VtrigSched_h5a35964b__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_fl.clk)", 
                                                         "test/tb_fl.sv", 
                                                         70);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    __Vtask_tb_fl__DOT__do_alloc__2__idx_o = vlSelfRef.tb_fl__DOT__alloc_block_idx_o;
    if (VL_UNLIKELY((((IData)(vlSelfRef.tb_fl__DOT__alloc_gnt_o) 
                      != (IData)(__Vtask_tb_fl__DOT__do_alloc__2__expect_gnt))))) {
        VL_WRITEF_NX("[%0t] %%Error: tb_fl.sv:75: Assertion failed in %Ntb_fl.do_alloc: [%0t] %@: expected grant=%0b, got %0b\n",0,
                     64,VL_TIME_UNITED_Q(1),-12,vlSymsp->name(),
                     64,VL_TIME_UNITED_Q(1),-12,-1,
                     &(__Vtask_tb_fl__DOT__do_alloc__2__tag),
                     1,(IData)(__Vtask_tb_fl__DOT__do_alloc__2__expect_gnt),
                     1,vlSelfRef.tb_fl__DOT__alloc_gnt_o);
        VL_STOP_MT("test/tb_fl.sv", 75, "");
    } else {
        VL_WRITEF_NX("[%0t] %@: alloc_gnt_o=%0b, idx=%0#\n",0,
                     64,VL_TIME_UNITED_Q(1),-12,-1,
                     &(__Vtask_tb_fl__DOT__do_alloc__2__tag),
                     1,(IData)(vlSelfRef.tb_fl__DOT__alloc_gnt_o),
                     12,__Vtask_tb_fl__DOT__do_alloc__2__idx_o);
    }
    vlSelfRef.tb_fl__DOT__alloc_req_i = 0U;
    co_await vlSelfRef.__VtrigSched_h5a35964b__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_fl.clk)", 
                                                         "test/tb_fl.sv", 
                                                         83);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.tb_fl__DOT__idx = __Vtask_tb_fl__DOT__do_alloc__2__idx_o;
    VL_WRITEF_NX("=== TEST 3: free one, then allocate it back ===\n",0);
    vlSelfRef.tb_fl__DOT__freed_idx = 0x0800U;
    __Vtask_tb_fl__DOT__do_free__3__tag = "free mid index"s;
    __Vtask_tb_fl__DOT__do_free__3__idx_i = vlSelfRef.tb_fl__DOT__freed_idx;
    vlSelfRef.tb_fl__DOT__free_block_idx_i = __Vtask_tb_fl__DOT__do_free__3__idx_i;
    vlSelfRef.tb_fl__DOT__free_req_i = 1U;
    vlSelfRef.tb_fl__DOT__alloc_req_i = 0U;
    co_await vlSelfRef.__VtrigSched_h5a35964b__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_fl.clk)", 
                                                         "test/tb_fl.sv", 
                                                         95);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    VL_WRITEF_NX("[%0t] %@: freed idx=%0#\n",0,64,VL_TIME_UNITED_Q(1),
                 -12,-1,&(__Vtask_tb_fl__DOT__do_free__3__tag),
                 12,(IData)(__Vtask_tb_fl__DOT__do_free__3__idx_i));
    vlSelfRef.tb_fl__DOT__free_req_i = 0U;
    co_await vlSelfRef.__VtrigSched_h5a35964b__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_fl.clk)", 
                                                         "test/tb_fl.sv", 
                                                         100);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    __Vtask_tb_fl__DOT__do_alloc__4__tag = "alloc after single free"s;
    __Vtask_tb_fl__DOT__do_alloc__4__expect_gnt = 1U;
    vlSelfRef.tb_fl__DOT__alloc_req_i = 1U;
    vlSelfRef.tb_fl__DOT__free_req_i = 0U;
    co_await vlSelfRef.__VtrigSched_h5a35964b__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_fl.clk)", 
                                                         "test/tb_fl.sv", 
                                                         70);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    __Vtask_tb_fl__DOT__do_alloc__4__idx_o = vlSelfRef.tb_fl__DOT__alloc_block_idx_o;
    if (VL_UNLIKELY((((IData)(vlSelfRef.tb_fl__DOT__alloc_gnt_o) 
                      != (IData)(__Vtask_tb_fl__DOT__do_alloc__4__expect_gnt))))) {
        VL_WRITEF_NX("[%0t] %%Error: tb_fl.sv:75: Assertion failed in %Ntb_fl.do_alloc: [%0t] %@: expected grant=%0b, got %0b\n",0,
                     64,VL_TIME_UNITED_Q(1),-12,vlSymsp->name(),
                     64,VL_TIME_UNITED_Q(1),-12,-1,
                     &(__Vtask_tb_fl__DOT__do_alloc__4__tag),
                     1,(IData)(__Vtask_tb_fl__DOT__do_alloc__4__expect_gnt),
                     1,vlSelfRef.tb_fl__DOT__alloc_gnt_o);
        VL_STOP_MT("test/tb_fl.sv", 75, "");
    } else {
        VL_WRITEF_NX("[%0t] %@: alloc_gnt_o=%0b, idx=%0#\n",0,
                     64,VL_TIME_UNITED_Q(1),-12,-1,
                     &(__Vtask_tb_fl__DOT__do_alloc__4__tag),
                     1,(IData)(vlSelfRef.tb_fl__DOT__alloc_gnt_o),
                     12,__Vtask_tb_fl__DOT__do_alloc__4__idx_o);
    }
    vlSelfRef.tb_fl__DOT__alloc_req_i = 0U;
    co_await vlSelfRef.__VtrigSched_h5a35964b__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_fl.clk)", 
                                                         "test/tb_fl.sv", 
                                                         83);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.tb_fl__DOT__idx = __Vtask_tb_fl__DOT__do_alloc__4__idx_o;
    if (VL_UNLIKELY((((IData)(vlSelfRef.tb_fl__DOT__idx) 
                      != (IData)(vlSelfRef.tb_fl__DOT__freed_idx))))) {
        VL_WRITEF_NX("[%0t] %%Error: tb_fl.sv:153: Assertion failed in %Ntb_fl.unnamedblk1: [%0t] Expected to re-allocate freed_idx=%0#, got %0#\n",0,
                     64,VL_TIME_UNITED_Q(1),-12,vlSymsp->name(),
                     64,VL_TIME_UNITED_Q(1),-12,12,
                     (IData)(vlSelfRef.tb_fl__DOT__freed_idx),
                     12,vlSelfRef.tb_fl__DOT__idx);
        VL_STOP_MT("test/tb_fl.sv", 153, "");
    } else {
        VL_WRITEF_NX("[%0t] Re-allocated freed_idx correctly (%0#)\n",0,
                     64,VL_TIME_UNITED_Q(1),-12,12,
                     (IData)(vlSelfRef.tb_fl__DOT__idx));
    }
    VL_WRITEF_NX("=== TEST 4: simultaneous alloc + free bypass ===\n",0);
    vlSelfRef.tb_fl__DOT__bypass_free_idx = 0x04b0U;
    __Vtask_tb_fl__DOT__do_alloc_free_same_cycle__5__free_idx_i 
        = vlSelfRef.tb_fl__DOT__bypass_free_idx;
    vlSelfRef.tb_fl__DOT__free_block_idx_i = __Vtask_tb_fl__DOT__do_alloc_free_same_cycle__5__free_idx_i;
    vlSelfRef.tb_fl__DOT__free_req_i = 1U;
    vlSelfRef.tb_fl__DOT__alloc_req_i = 1U;
    co_await vlSelfRef.__VtrigSched_h5a35964b__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_fl.clk)", 
                                                         "test/tb_fl.sv", 
                                                         112);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    __Vtask_tb_fl__DOT__do_alloc_free_same_cycle__5__alloc_idx_o 
        = vlSelfRef.tb_fl__DOT__alloc_block_idx_o;
    if (VL_LIKELY((vlSelfRef.tb_fl__DOT__alloc_gnt_o))) {
        VL_WRITEF_NX("[%0t] alloc_free_same_cycle: freed=%0#, allocated=%0#\n",0,
                     64,VL_TIME_UNITED_Q(1),-12,12,
                     (IData)(__Vtask_tb_fl__DOT__do_alloc_free_same_cycle__5__free_idx_i),
                     12,__Vtask_tb_fl__DOT__do_alloc_free_same_cycle__5__alloc_idx_o);
    } else {
        VL_WRITEF_NX("[%0t] %%Error: tb_fl.sv:117: Assertion failed in %Ntb_fl.do_alloc_free_same_cycle: [%0t] alloc_free_same_cycle: expected grant=1, got 0\n",0,
                     64,VL_TIME_UNITED_Q(1),-12,vlSymsp->name(),
                     64,VL_TIME_UNITED_Q(1),-12);
        VL_STOP_MT("test/tb_fl.sv", 117, "");
    }
    vlSelfRef.tb_fl__DOT__free_req_i = 0U;
    vlSelfRef.tb_fl__DOT__alloc_req_i = 0U;
    co_await vlSelfRef.__VtrigSched_h5a35964b__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(posedge tb_fl.clk)", 
                                                         "test/tb_fl.sv", 
                                                         125);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.tb_fl__DOT__bypass_alloc_idx = __Vtask_tb_fl__DOT__do_alloc_free_same_cycle__5__alloc_idx_o;
    if (VL_UNLIKELY((((IData)(vlSelfRef.tb_fl__DOT__bypass_alloc_idx) 
                      != (IData)(vlSelfRef.tb_fl__DOT__bypass_free_idx))))) {
        VL_WRITEF_NX("[%0t] %%Error: tb_fl.sv:165: Assertion failed in %Ntb_fl.unnamedblk1: [%0t] Expected alloc_idx == free_idx in bypass path, got %0# vs %0#\n",0,
                     64,VL_TIME_UNITED_Q(1),-12,vlSymsp->name(),
                     64,VL_TIME_UNITED_Q(1),-12,12,
                     (IData)(vlSelfRef.tb_fl__DOT__bypass_alloc_idx),
                     12,vlSelfRef.tb_fl__DOT__bypass_free_idx);
        VL_STOP_MT("test/tb_fl.sv", 165, "");
    } else {
        VL_WRITEF_NX("[%0t] Bypass OK: alloc_idx==free_idx==%0#\n",0,
                     64,VL_TIME_UNITED_Q(1),-12,12,
                     (IData)(vlSelfRef.tb_fl__DOT__bypass_alloc_idx));
    }
    VL_WRITEF_NX("=== TESTBENCH DONE ===\n",0);
    co_await vlSelfRef.__VdlySched.delay(0x0000000000000032ULL, 
                                         nullptr, "test/tb_fl.sv", 
                                         173);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    VL_FINISH_MT("test/tb_fl.sv", 174, "");
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
}

VlCoroutine Vtb_fl___024root___eval_initial__TOP__Vtiming__1(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___eval_initial__TOP__Vtiming__1\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (VL_LIKELY(!vlSymsp->_vm_contextp__->gotFinish())) {
        co_await vlSelfRef.__VdlySched.delay(5ULL, 
                                             nullptr, 
                                             "test/tb_fl.sv", 
                                             37);
        vlSelfRef.tb_fl__DOT__clk = (1U & (~ (IData)(vlSelfRef.tb_fl__DOT__clk)));
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_fl___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

void Vtb_fl___024root___eval_triggers__act(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___eval_triggers__act\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                    ((vlSelfRef.__VdlySched.awaitingCurrentTime() 
                                                      << 2U) 
                                                     | ((((~ (IData)(vlSelfRef.tb_fl__DOT__rst_n)) 
                                                          & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_fl__DOT__rst_n__0)) 
                                                         << 1U) 
                                                        | ((IData)(vlSelfRef.tb_fl__DOT__clk) 
                                                           & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_fl__DOT__clk__0)))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_fl__DOT__clk__0 
        = vlSelfRef.tb_fl__DOT__clk;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_fl__DOT__rst_n__0 
        = vlSelfRef.tb_fl__DOT__rst_n;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_fl___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
}

bool Vtb_fl___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___trigger_anySet__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        if (in[n]) {
            return (1U);
        }
        n = ((IData)(1U) + n);
    } while ((1U > n));
    return (0U);
}

void Vtb_fl___024root___nba_sequent__TOP__0(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___nba_sequent__TOP__0\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    SData/*12:0*/ __Vdly__tb_fl__DOT__dut__DOT__sp;
    __Vdly__tb_fl__DOT__dut__DOT__sp = 0;
    SData/*11:0*/ __VdlyVal__tb_fl__DOT__dut__DOT__stack__v0;
    __VdlyVal__tb_fl__DOT__dut__DOT__stack__v0 = 0;
    SData/*12:0*/ __VdlyDim0__tb_fl__DOT__dut__DOT__stack__v0;
    __VdlyDim0__tb_fl__DOT__dut__DOT__stack__v0 = 0;
    SData/*11:0*/ __VdlyVal__tb_fl__DOT__dut__DOT__stack__v1;
    __VdlyVal__tb_fl__DOT__dut__DOT__stack__v1 = 0;
    SData/*12:0*/ __VdlyDim0__tb_fl__DOT__dut__DOT__stack__v1;
    __VdlyDim0__tb_fl__DOT__dut__DOT__stack__v1 = 0;
    // Body
    __Vdly__tb_fl__DOT__dut__DOT__sp = vlSelfRef.tb_fl__DOT__dut__DOT__sp;
    if (vlSelfRef.tb_fl__DOT__rst_n) {
        vlSelfRef.tb_fl__DOT__alloc_gnt_o = 0U;
        if (((IData)(vlSelfRef.tb_fl__DOT__alloc_req_i) 
             & (IData)(vlSelfRef.tb_fl__DOT__free_req_i))) {
            vlSelfRef.tb_fl__DOT__alloc_gnt_o = 1U;
        } else if (((IData)(vlSelfRef.tb_fl__DOT__alloc_req_i) 
                    & (0U != (IData)(vlSelfRef.tb_fl__DOT__dut__DOT__sp)))) {
            vlSelfRef.tb_fl__DOT__alloc_gnt_o = 1U;
        }
    }
    if (vlSelfRef.tb_fl__DOT__rst_n) {
        if (((IData)(vlSelfRef.tb_fl__DOT__alloc_req_i) 
             & (IData)(vlSelfRef.tb_fl__DOT__free_req_i))) {
            vlSelfRef.tb_fl__DOT__alloc_block_idx_o 
                = vlSelfRef.tb_fl__DOT__free_block_idx_i;
        } else if (((IData)(vlSelfRef.tb_fl__DOT__alloc_req_i) 
                    & (~ (IData)(vlSelfRef.tb_fl__DOT__dut__DOT__empty)))) {
            vlSelfRef.tb_fl__DOT__alloc_block_idx_o 
                = ((0x1000U >= (IData)(vlSelfRef.tb_fl__DOT__dut__DOT__sp))
                    ? vlSelfRef.tb_fl__DOT__dut__DOT__stack
                   [vlSelfRef.tb_fl__DOT__dut__DOT__sp]
                    : 0U);
            __Vdly__tb_fl__DOT__dut__DOT__sp = (0x00001fffU 
                                                & ((IData)(vlSelfRef.tb_fl__DOT__dut__DOT__sp) 
                                                   - (IData)(1U)));
        } else if (((IData)(vlSelfRef.tb_fl__DOT__free_req_i) 
                    & (~ (IData)(vlSelfRef.tb_fl__DOT__dut__DOT__full)))) {
            vlSelfRef.tb_fl__DOT__dut__DOT____Vlvbound_hab8335fc__0 
                = vlSelfRef.tb_fl__DOT__free_block_idx_i;
            if ((0x1000U >= (0x00001fffU & ((IData)(1U) 
                                            + (IData)(vlSelfRef.tb_fl__DOT__dut__DOT__sp))))) {
                __VdlyVal__tb_fl__DOT__dut__DOT__stack__v0 
                    = vlSelfRef.tb_fl__DOT__dut__DOT____Vlvbound_hab8335fc__0;
                __VdlyDim0__tb_fl__DOT__dut__DOT__stack__v0 
                    = (0x00001fffU & ((IData)(1U) + (IData)(vlSelfRef.tb_fl__DOT__dut__DOT__sp)));
                vlSelfRef.__VdlyCommitQueuetb_fl__DOT__dut__DOT__stack.enqueue(__VdlyVal__tb_fl__DOT__dut__DOT__stack__v0, (IData)(__VdlyDim0__tb_fl__DOT__dut__DOT__stack__v0));
            }
            __Vdly__tb_fl__DOT__dut__DOT__sp = (0x00001fffU 
                                                & ((IData)(1U) 
                                                   + (IData)(vlSelfRef.tb_fl__DOT__dut__DOT__sp)));
        }
    } else {
        __Vdly__tb_fl__DOT__dut__DOT__sp = 0x1000U;
        vlSelfRef.tb_fl__DOT__dut__DOT__unnamedblk1__DOT__i = 0U;
        while ((0x00001000U >= vlSelfRef.tb_fl__DOT__dut__DOT__unnamedblk1__DOT__i)) {
            vlSelfRef.tb_fl__DOT__dut__DOT____Vlvbound_hd8c48ffd__0 
                = (0x00000fffU & vlSelfRef.tb_fl__DOT__dut__DOT__unnamedblk1__DOT__i);
            if (VL_LIKELY(((0x1000U >= (0x00001fffU 
                                        & vlSelfRef.tb_fl__DOT__dut__DOT__unnamedblk1__DOT__i))))) {
                __VdlyVal__tb_fl__DOT__dut__DOT__stack__v1 
                    = vlSelfRef.tb_fl__DOT__dut__DOT____Vlvbound_hd8c48ffd__0;
                __VdlyDim0__tb_fl__DOT__dut__DOT__stack__v1 
                    = (0x00001fffU & vlSelfRef.tb_fl__DOT__dut__DOT__unnamedblk1__DOT__i);
                vlSelfRef.__VdlyCommitQueuetb_fl__DOT__dut__DOT__stack.enqueue(__VdlyVal__tb_fl__DOT__dut__DOT__stack__v1, (IData)(__VdlyDim0__tb_fl__DOT__dut__DOT__stack__v1));
            }
            vlSelfRef.tb_fl__DOT__dut__DOT__unnamedblk1__DOT__i 
                = ((IData)(1U) + vlSelfRef.tb_fl__DOT__dut__DOT__unnamedblk1__DOT__i);
        }
    }
    vlSelfRef.__VdlyCommitQueuetb_fl__DOT__dut__DOT__stack.commit(vlSelfRef.tb_fl__DOT__dut__DOT__stack);
    vlSelfRef.tb_fl__DOT__dut__DOT__sp = __Vdly__tb_fl__DOT__dut__DOT__sp;
    vlSelfRef.tb_fl__DOT__dut__DOT__empty = (0U == (IData)(vlSelfRef.tb_fl__DOT__dut__DOT__sp));
    vlSelfRef.tb_fl__DOT__dut__DOT__full = (0x1000U 
                                            == (IData)(vlSelfRef.tb_fl__DOT__dut__DOT__sp));
}

void Vtb_fl___024root___eval_nba(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___eval_nba\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_fl___024root___nba_sequent__TOP__0(vlSelf);
        vlSelfRef.__Vm_traceActivity[3U] = 1U;
    }
}

void Vtb_fl___024root___timing_commit(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___timing_commit\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((! (1ULL & vlSelfRef.__VactTriggered[0U]))) {
        vlSelfRef.__VtrigSched_h5a35964b__0.commit(
                                                   "@(posedge tb_fl.clk)");
    }
}

void Vtb_fl___024root___timing_resume(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___timing_resume\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_h5a35964b__0.resume(
                                                   "@(posedge tb_fl.clk)");
    }
    if ((4ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_fl___024root___trigger_orInto__act(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___trigger_orInto__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vtb_fl___024root___eval_phase__act(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___eval_phase__act\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VactExecute;
    // Body
    Vtb_fl___024root___eval_triggers__act(vlSelf);
    Vtb_fl___024root___timing_commit(vlSelf);
    Vtb_fl___024root___trigger_orInto__act(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    __VactExecute = Vtb_fl___024root___trigger_anySet__act(vlSelfRef.__VactTriggered);
    if (__VactExecute) {
        Vtb_fl___024root___timing_resume(vlSelf);
    }
    return (__VactExecute);
}

void Vtb_fl___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vtb_fl___024root___eval_phase__nba(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___eval_phase__nba\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vtb_fl___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vtb_fl___024root___eval_nba(vlSelf);
        Vtb_fl___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

void Vtb_fl___024root___eval(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___eval\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VnbaIterCount;
    // Body
    __VnbaIterCount = 0U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vtb_fl___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
            VL_FATAL_MT("test/tb_fl.sv", 1, "", "NBA region did not converge after 100 tries");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        vlSelfRef.__VactIterCount = 0U;
        do {
            if (VL_UNLIKELY(((0x00000064U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                Vtb_fl___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
                VL_FATAL_MT("test/tb_fl.sv", 1, "", "Active region did not converge after 100 tries");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
        } while (Vtb_fl___024root___eval_phase__act(vlSelf));
    } while (Vtb_fl___024root___eval_phase__nba(vlSelf));
}

#ifdef VL_DEBUG
void Vtb_fl___024root___eval_debug_assertions(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___eval_debug_assertions\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
