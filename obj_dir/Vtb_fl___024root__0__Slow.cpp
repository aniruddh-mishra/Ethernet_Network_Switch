// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_fl.h for the primary calling header

#include "Vtb_fl__pch.h"

VL_ATTR_COLD void Vtb_fl___024root___eval_static(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___eval_static\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vtrigprevexpr___TOP__tb_fl__DOT__clk__0 
        = vlSelfRef.tb_fl__DOT__clk;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_fl__DOT__rst_n__0 
        = vlSelfRef.tb_fl__DOT__rst_n;
}

VL_ATTR_COLD void Vtb_fl___024root___eval_initial__TOP(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___eval_initial__TOP\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_fl__DOT__clk = 0U;
    vlSymsp->_vm_contextp__->dumpfile("fl_tb.vcd"s);
    vlSymsp->_traceDumpOpen();
}

VL_ATTR_COLD void Vtb_fl___024root___eval_final(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___eval_final\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_fl___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtb_fl___024root___eval_phase__stl(Vtb_fl___024root* vlSelf);

VL_ATTR_COLD void Vtb_fl___024root___eval_settle(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___eval_settle\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VstlIterCount;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VstlIterCount)))) {
#ifdef VL_DEBUG
            Vtb_fl___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
            VL_FATAL_MT("test/tb_fl.sv", 1, "", "Settle region did not converge after 100 tries");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
    } while (Vtb_fl___024root___eval_phase__stl(vlSelf));
}

VL_ATTR_COLD void Vtb_fl___024root___eval_triggers__stl(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___eval_triggers__stl\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered
                                      [0U]) | (IData)((IData)(vlSelfRef.__VstlFirstIteration)));
    vlSelfRef.__VstlFirstIteration = 0U;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_fl___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
}

VL_ATTR_COLD bool Vtb_fl___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_fl___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_fl___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vtb_fl___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___trigger_anySet__stl\n"); );
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

VL_ATTR_COLD void Vtb_fl___024root___stl_sequent__TOP__0(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___stl_sequent__TOP__0\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_fl__DOT__dut__DOT__empty = (0U == (IData)(vlSelfRef.tb_fl__DOT__dut__DOT__sp));
    vlSelfRef.tb_fl__DOT__dut__DOT__full = (0x1000U 
                                            == (IData)(vlSelfRef.tb_fl__DOT__dut__DOT__sp));
}

VL_ATTR_COLD void Vtb_fl___024root___eval_stl(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___eval_stl\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
        Vtb_fl___024root___stl_sequent__TOP__0(vlSelf);
    }
}

VL_ATTR_COLD bool Vtb_fl___024root___eval_phase__stl(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___eval_phase__stl\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    Vtb_fl___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = Vtb_fl___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        Vtb_fl___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

bool Vtb_fl___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_fl___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_fl___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge tb_fl.clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @(negedge tb_fl.rst_n)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 2U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 2 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_fl___024root___ctor_var_reset(Vtb_fl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root___ctor_var_reset\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->name());
    vlSelf->tb_fl__DOT__clk = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1006219610288537898ull);
    vlSelf->tb_fl__DOT__rst_n = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11142048947858021936ull);
    vlSelf->tb_fl__DOT__alloc_req_i = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14693669959458196666ull);
    vlSelf->tb_fl__DOT__alloc_gnt_o = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1882327304581613551ull);
    vlSelf->tb_fl__DOT__alloc_block_idx_o = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 9123272234246493877ull);
    vlSelf->tb_fl__DOT__free_req_i = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 15710640072697112857ull);
    vlSelf->tb_fl__DOT__free_block_idx_i = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 2927498074118189858ull);
    vlSelf->tb_fl__DOT__idx = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 4289829534272040385ull);
    vlSelf->tb_fl__DOT__freed_idx = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 4260022187584615927ull);
    vlSelf->tb_fl__DOT__bypass_free_idx = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 1628589047279276251ull);
    vlSelf->tb_fl__DOT__bypass_alloc_idx = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 6673372167511699439ull);
    vlSelf->tb_fl__DOT__unnamedblk1__DOT__i = 0;
    for (int __Vi0 = 0; __Vi0 < 4097; ++__Vi0) {
        vlSelf->tb_fl__DOT__dut__DOT__stack[__Vi0] = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 1851462821189185710ull);
    }
    vlSelf->tb_fl__DOT__dut__DOT__sp = VL_SCOPED_RAND_RESET_I(13, __VscopeHash, 16037902820987224610ull);
    vlSelf->tb_fl__DOT__dut__DOT__empty = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 421250358147203780ull);
    vlSelf->tb_fl__DOT__dut__DOT__full = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17063148457208913666ull);
    vlSelf->tb_fl__DOT__dut__DOT__unnamedblk1__DOT__i = 0;
    vlSelf->tb_fl__DOT__dut__DOT____Vlvbound_hab8335fc__0 = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 3075815048840227757ull);
    vlSelf->tb_fl__DOT__dut__DOT____Vlvbound_hd8c48ffd__0 = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 7515755132293685737ull);
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VstlTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggered[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__tb_fl__DOT__clk__0 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 12262084411783959266ull);
    vlSelf->__Vtrigprevexpr___TOP__tb_fl__DOT__rst_n__0 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 10640891489446005698ull);
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->__Vm_traceActivity[__Vi0] = 0;
    }
}
