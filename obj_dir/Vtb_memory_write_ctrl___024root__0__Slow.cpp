// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_memory_write_ctrl.h for the primary calling header

#include "Vtb_memory_write_ctrl__pch.h"

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root___eval_static(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___eval_static\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vtrigprevexpr___TOP__tb_memory_write_ctrl__DOT__clk__0 
        = vlSelfRef.tb_memory_write_ctrl__DOT__clk;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_memory_write_ctrl__DOT__rst_n__0 
        = vlSelfRef.tb_memory_write_ctrl__DOT__rst_n;
}

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root___eval_initial__TOP(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___eval_initial__TOP\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSymsp->_vm_contextp__->dumpfile("mem_wr.vcd"s);
    vlSymsp->_traceDumpOpen();
    vlSelfRef.tb_memory_write_ctrl__DOT__clk = 0U;
    vlSymsp->_vm_contextp__->dumpfile("wave.vcd"s);
    vlSymsp->_traceDumpOpen();
}

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root___eval_final(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___eval_final\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_memory_write_ctrl___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG
VL_ATTR_COLD bool Vtb_memory_write_ctrl___024root___eval_phase__stl(Vtb_memory_write_ctrl___024root* vlSelf);

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root___eval_settle(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___eval_settle\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VstlIterCount;
    // Body
    __VstlIterCount = 0U;
    vlSelfRef.__VstlFirstIteration = 1U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VstlIterCount)))) {
#ifdef VL_DEBUG
            Vtb_memory_write_ctrl___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
#endif
            VL_FATAL_MT("test/tb_memory_write_ctrl.sv", 1, "", "Settle region did not converge after 100 tries");
        }
        __VstlIterCount = ((IData)(1U) + __VstlIterCount);
    } while (Vtb_memory_write_ctrl___024root___eval_phase__stl(vlSelf));
}

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root___eval_triggers__stl(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___eval_triggers__stl\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VstlTriggered[0U] = ((0xfffffffffffffffeULL 
                                      & vlSelfRef.__VstlTriggered
                                      [0U]) | (IData)((IData)(vlSelfRef.__VstlFirstIteration)));
    vlSelfRef.__VstlFirstIteration = 0U;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_memory_write_ctrl___024root___dump_triggers__stl(vlSelfRef.__VstlTriggered, "stl"s);
    }
#endif
}

VL_ATTR_COLD bool Vtb_memory_write_ctrl___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_memory_write_ctrl___024root___dump_triggers__stl(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___dump_triggers__stl\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_memory_write_ctrl___024root___trigger_anySet__stl(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: Internal 'stl' trigger - first iteration\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD bool Vtb_memory_write_ctrl___024root___trigger_anySet__stl(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___trigger_anySet__stl\n"); );
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

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root___stl_sequent__TOP__0(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___stl_sequent__TOP__0\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__fl_alloc_req_o 
        = ((0U != (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state)) 
           & (((~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated)) 
               & (~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__fl_alloc_gnt_i))) 
              | ((~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__next_frame_allocated)) 
                 & ((~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated)) 
                    | (~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__fl_alloc_gnt_i))))));
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state_n 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state;
    if ((2U & (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state))) {
        if ((1U & (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state))) {
            if (vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__mem_trans_success) {
                vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state_n 
                    = ((IData)(vlSelfRef.tb_memory_write_ctrl__DOT__data_end_i)
                        ? 0U : 1U);
            }
        } else if (((IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated) 
                    & (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__next_frame_allocated))) {
            vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state_n = 3U;
        }
    } else if ((1U & (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state))) {
        if (((IData)(vlSelfRef.tb_memory_write_ctrl__DOT__data_valid_i) 
             & (0x3dU == (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt)))) {
            vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state_n 
                = (((IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated) 
                    & (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__next_frame_allocated))
                    ? 3U : 2U);
        }
    } else if (((IData)(vlSelfRef.tb_memory_write_ctrl__DOT__data_valid_i) 
                & (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__data_begin_i))) {
        vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state_n = 1U;
    }
}

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root____Vm_traceActivitySetAll(Vtb_memory_write_ctrl___024root* vlSelf);

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root___eval_stl(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___eval_stl\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VstlTriggered[0U])) {
        Vtb_memory_write_ctrl___024root___stl_sequent__TOP__0(vlSelf);
        Vtb_memory_write_ctrl___024root____Vm_traceActivitySetAll(vlSelf);
    }
}

VL_ATTR_COLD bool Vtb_memory_write_ctrl___024root___eval_phase__stl(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___eval_phase__stl\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VstlExecute;
    // Body
    Vtb_memory_write_ctrl___024root___eval_triggers__stl(vlSelf);
    __VstlExecute = Vtb_memory_write_ctrl___024root___trigger_anySet__stl(vlSelfRef.__VstlTriggered);
    if (__VstlExecute) {
        Vtb_memory_write_ctrl___024root___eval_stl(vlSelf);
    }
    return (__VstlExecute);
}

bool Vtb_memory_write_ctrl___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in);

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_memory_write_ctrl___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___dump_triggers__act\n"); );
    // Body
    if ((1U & (~ (IData)(Vtb_memory_write_ctrl___024root___trigger_anySet__act(triggers))))) {
        VL_DBG_MSGS("         No '" + tag + "' region triggers active\n");
    }
    if ((1U & (IData)(triggers[0U]))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 0 is active: @(posedge tb_memory_write_ctrl.clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 1U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 1 is active: @(negedge tb_memory_write_ctrl.rst_n)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 2U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 2 is active: @(negedge tb_memory_write_ctrl.clk)\n");
    }
    if ((1U & (IData)((triggers[0U] >> 3U)))) {
        VL_DBG_MSGS("         '" + tag + "' region trigger index 3 is active: @([true] __VdlySched.awaitingCurrentTime())\n");
    }
}
#endif  // VL_DEBUG

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root____Vm_traceActivitySetAll(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root____Vm_traceActivitySetAll\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__Vm_traceActivity[0U] = 1U;
    vlSelfRef.__Vm_traceActivity[1U] = 1U;
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.__Vm_traceActivity[3U] = 1U;
}

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root___ctor_var_reset(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___ctor_var_reset\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const uint64_t __VscopeHash = VL_MURMUR64_HASH(vlSelf->name());
    vlSelf->tb_memory_write_ctrl__DOT__clk = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 11363408012234969994ull);
    vlSelf->tb_memory_write_ctrl__DOT__rst_n = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14497675573198692799ull);
    vlSelf->tb_memory_write_ctrl__DOT__data_i = VL_SCOPED_RAND_RESET_I(8, __VscopeHash, 7865439166444541751ull);
    vlSelf->tb_memory_write_ctrl__DOT__data_valid_i = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17027615526358370354ull);
    vlSelf->tb_memory_write_ctrl__DOT__data_begin_i = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 268491406666676478ull);
    vlSelf->tb_memory_write_ctrl__DOT__data_end_i = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 3266780454053636571ull);
    vlSelf->tb_memory_write_ctrl__DOT__fl_alloc_gnt_i = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 4320133930497304537ull);
    vlSelf->tb_memory_write_ctrl__DOT__fl_alloc_block_idx_i = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 3601414545877119390ull);
    vlSelf->tb_memory_write_ctrl__DOT__mem_ready_i = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 1239823244509822605ull);
    vlSelf->tb_memory_write_ctrl__DOT__mem_we_o = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 17231059284379206848ull);
    vlSelf->tb_memory_write_ctrl__DOT__mem_addr_o = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 10830071197287476407ull);
    VL_SCOPED_RAND_RESET_W(512, vlSelf->tb_memory_write_ctrl__DOT__mem_wdata_o, __VscopeHash, 14872798137446030165ull);
    vlSelf->tb_memory_write_ctrl__DOT__write_count = 0;
    vlSelf->tb_memory_write_ctrl__DOT__next_block_idx = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 10534960642832082740ull);
    vlSelf->tb_memory_write_ctrl__DOT__footer_dec = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 4390054036696854380ull);
    vlSelf->tb_memory_write_ctrl__DOT__dut__DOT__fl_alloc_req_o = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 5841696942121629117ull);
    vlSelf->tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 13428096363896771723ull);
    vlSelf->tb_memory_write_ctrl__DOT__dut__DOT__next_frame_allocated = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 8535608649384722103ull);
    vlSelf->tb_memory_write_ctrl__DOT__dut__DOT__state = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 14672451924742773893ull);
    vlSelf->tb_memory_write_ctrl__DOT__dut__DOT__state_n = VL_SCOPED_RAND_RESET_I(2, __VscopeHash, 5448622175857930909ull);
    vlSelf->tb_memory_write_ctrl__DOT__dut__DOT__footer = VL_SCOPED_RAND_RESET_I(16, __VscopeHash, 3153777515988554503ull);
    VL_SCOPED_RAND_RESET_W(496, vlSelf->tb_memory_write_ctrl__DOT__dut__DOT__payload_reg, __VscopeHash, 3286550950544598823ull);
    vlSelf->tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt = VL_SCOPED_RAND_RESET_I(6, __VscopeHash, 11433138262659585806ull);
    vlSelf->tb_memory_write_ctrl__DOT__dut__DOT__curr_idx = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 13942747985673033628ull);
    vlSelf->tb_memory_write_ctrl__DOT__dut__DOT__next_idx = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 18130963685790561029ull);
    vlSelf->tb_memory_write_ctrl__DOT__dut__DOT__mem_trans_success = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 18364003624611762996ull);
    vlSelf->tb_memory_write_ctrl__DOT__dut__DOT__start_addr = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 8832618336930633777ull);
    vlSelf->tb_memory_write_ctrl__DOT__dut__DOT__frame_cnt = VL_SCOPED_RAND_RESET_I(12, __VscopeHash, 6005956876175090081ull);
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VstlTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VactTriggered[__Vi0] = 0;
    }
    vlSelf->__Vtrigprevexpr___TOP__tb_memory_write_ctrl__DOT__clk__0 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 14328052956316726595ull);
    vlSelf->__Vtrigprevexpr___TOP__tb_memory_write_ctrl__DOT__rst_n__0 = VL_SCOPED_RAND_RESET_I(1, __VscopeHash, 7359814477395831810ull);
    for (int __Vi0 = 0; __Vi0 < 1; ++__Vi0) {
        vlSelf->__VnbaTriggered[__Vi0] = 0;
    }
    for (int __Vi0 = 0; __Vi0 < 4; ++__Vi0) {
        vlSelf->__Vm_traceActivity[__Vi0] = 0;
    }
}
