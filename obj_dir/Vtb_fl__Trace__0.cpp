// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtb_fl__Syms.h"


void Vtb_fl___024root__trace_chg_0_sub_0(Vtb_fl___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vtb_fl___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root__trace_chg_0\n"); );
    // Body
    Vtb_fl___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtb_fl___024root*>(voidSelf);
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    Vtb_fl___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

void Vtb_fl___024root__trace_chg_0_sub_0(Vtb_fl___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root__trace_chg_0_sub_0\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    if (VL_UNLIKELY(((vlSelfRef.__Vm_traceActivity[1U] 
                      | vlSelfRef.__Vm_traceActivity
                      [2U])))) {
        bufp->chgBit(oldp+0,(vlSelfRef.tb_fl__DOT__rst_n));
        bufp->chgBit(oldp+1,(vlSelfRef.tb_fl__DOT__alloc_req_i));
        bufp->chgBit(oldp+2,(vlSelfRef.tb_fl__DOT__free_req_i));
        bufp->chgSData(oldp+3,(vlSelfRef.tb_fl__DOT__free_block_idx_i),12);
        bufp->chgSData(oldp+4,(vlSelfRef.tb_fl__DOT__idx),12);
        bufp->chgSData(oldp+5,(vlSelfRef.tb_fl__DOT__freed_idx),12);
        bufp->chgSData(oldp+6,(vlSelfRef.tb_fl__DOT__bypass_free_idx),12);
        bufp->chgSData(oldp+7,(vlSelfRef.tb_fl__DOT__bypass_alloc_idx),12);
        bufp->chgIData(oldp+8,(vlSelfRef.tb_fl__DOT__unnamedblk1__DOT__i),32);
    }
    if (VL_UNLIKELY((vlSelfRef.__Vm_traceActivity[3U]))) {
        bufp->chgBit(oldp+9,(vlSelfRef.tb_fl__DOT__alloc_gnt_o));
        bufp->chgSData(oldp+10,(vlSelfRef.tb_fl__DOT__alloc_block_idx_o),12);
        bufp->chgSData(oldp+11,(vlSelfRef.tb_fl__DOT__dut__DOT__sp),13);
        bufp->chgBit(oldp+12,((0U == (IData)(vlSelfRef.tb_fl__DOT__dut__DOT__sp))));
        bufp->chgBit(oldp+13,((0x1000U == (IData)(vlSelfRef.tb_fl__DOT__dut__DOT__sp))));
        bufp->chgIData(oldp+14,(vlSelfRef.tb_fl__DOT__dut__DOT__unnamedblk1__DOT__i),32);
    }
    bufp->chgBit(oldp+15,(vlSelfRef.tb_fl__DOT__clk));
}

void Vtb_fl___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root__trace_cleanup\n"); );
    // Body
    Vtb_fl___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtb_fl___024root*>(voidSelf);
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[2U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[3U] = 0U;
}
