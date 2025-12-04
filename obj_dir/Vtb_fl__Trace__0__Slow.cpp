// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtb_fl__Syms.h"


VL_ATTR_COLD void Vtb_fl___024root__trace_init_sub__TOP__mem_pkg__0(Vtb_fl___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vtb_fl___024root__trace_init_sub__TOP__0(Vtb_fl___024root* vlSelf, VerilatedVcd* tracep) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root__trace_init_sub__TOP__0\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const int c = vlSymsp->__Vm_baseCode;
    tracep->pushPrefix("mem_pkg", VerilatedTracePrefixType::SCOPE_MODULE);
    Vtb_fl___024root__trace_init_sub__TOP__mem_pkg__0(vlSelf, tracep);
    tracep->popPrefix();
    tracep->pushPrefix("tb_fl", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+17,0,"NBITS",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->declBit(c+16,0,"clk",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+1,0,"rst_n",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+2,0,"alloc_req_i",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+10,0,"alloc_gnt_o",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+11,0,"alloc_block_idx_o",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBit(c+3,0,"free_req_i",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+4,0,"free_block_idx_i",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+5,0,"idx",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+6,0,"freed_idx",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+7,0,"bypass_free_idx",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+8,0,"bypass_alloc_idx",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->pushPrefix("dut", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+16,0,"clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+1,0,"rst_n",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+2,0,"alloc_req_i",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+10,0,"alloc_gnt_o",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+11,0,"alloc_block_idx_o",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBit(c+3,0,"free_req_i",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+4,0,"free_block_idx_i",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+12,0,"sp",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 12,0);
    tracep->declBit(c+13,0,"empty",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+14,0,"full",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("unnamedblk1", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+15,0,"i",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->popPrefix();
    tracep->popPrefix();
    tracep->pushPrefix("unnamedblk1", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBus(c+9,0,"i",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->popPrefix();
    tracep->popPrefix();
}

VL_ATTR_COLD void Vtb_fl___024root__trace_init_sub__TOP__mem_pkg__0(Vtb_fl___024root* vlSelf, VerilatedVcd* tracep) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root__trace_init_sub__TOP__mem_pkg__0\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const int c = vlSymsp->__Vm_baseCode;
    tracep->declBus(c+18,0,"BLOCK_BYTES",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->declBus(c+19,0,"NUM_BLOCKS",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->declBus(c+20,0,"DATA_WIDTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->declBus(c+21,0,"ADDR_W",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->declBus(c+22,0,"FOOTER_BYTES",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->declBus(c+23,0,"PAYLOAD_BYTES",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->declBus(c+24,0,"BLOCK_BITS",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
}

VL_ATTR_COLD void Vtb_fl___024root__trace_init_top(Vtb_fl___024root* vlSelf, VerilatedVcd* tracep) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root__trace_init_top\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_fl___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vtb_fl___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
VL_ATTR_COLD void Vtb_fl___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vtb_fl___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vtb_fl___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void Vtb_fl___024root__trace_register(Vtb_fl___024root* vlSelf, VerilatedVcd* tracep) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root__trace_register\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    tracep->addConstCb(&Vtb_fl___024root__trace_const_0, 0, vlSelf);
    tracep->addFullCb(&Vtb_fl___024root__trace_full_0, 0, vlSelf);
    tracep->addChgCb(&Vtb_fl___024root__trace_chg_0, 0, vlSelf);
    tracep->addCleanupCb(&Vtb_fl___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vtb_fl___024root__trace_const_0_sub_0(Vtb_fl___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vtb_fl___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root__trace_const_0\n"); );
    // Body
    Vtb_fl___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtb_fl___024root*>(voidSelf);
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    Vtb_fl___024root__trace_const_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vtb_fl___024root__trace_const_0_sub_0(Vtb_fl___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root__trace_const_0_sub_0\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    bufp->fullIData(oldp+17,(0x0000000cU),32);
    bufp->fullIData(oldp+18,(0x00000040U),32);
    bufp->fullIData(oldp+19,(0x00001000U),32);
    bufp->fullIData(oldp+20,(8U),32);
    bufp->fullIData(oldp+21,(0x0000000cU),32);
    bufp->fullIData(oldp+22,(2U),32);
    bufp->fullIData(oldp+23,(0x0000003eU),32);
    bufp->fullIData(oldp+24,(0x00000200U),32);
}

VL_ATTR_COLD void Vtb_fl___024root__trace_full_0_sub_0(Vtb_fl___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vtb_fl___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root__trace_full_0\n"); );
    // Body
    Vtb_fl___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtb_fl___024root*>(voidSelf);
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    Vtb_fl___024root__trace_full_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vtb_fl___024root__trace_full_0_sub_0(Vtb_fl___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_fl___024root__trace_full_0_sub_0\n"); );
    Vtb_fl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    bufp->fullBit(oldp+1,(vlSelfRef.tb_fl__DOT__rst_n));
    bufp->fullBit(oldp+2,(vlSelfRef.tb_fl__DOT__alloc_req_i));
    bufp->fullBit(oldp+3,(vlSelfRef.tb_fl__DOT__free_req_i));
    bufp->fullSData(oldp+4,(vlSelfRef.tb_fl__DOT__free_block_idx_i),12);
    bufp->fullSData(oldp+5,(vlSelfRef.tb_fl__DOT__idx),12);
    bufp->fullSData(oldp+6,(vlSelfRef.tb_fl__DOT__freed_idx),12);
    bufp->fullSData(oldp+7,(vlSelfRef.tb_fl__DOT__bypass_free_idx),12);
    bufp->fullSData(oldp+8,(vlSelfRef.tb_fl__DOT__bypass_alloc_idx),12);
    bufp->fullIData(oldp+9,(vlSelfRef.tb_fl__DOT__unnamedblk1__DOT__i),32);
    bufp->fullBit(oldp+10,(vlSelfRef.tb_fl__DOT__alloc_gnt_o));
    bufp->fullSData(oldp+11,(vlSelfRef.tb_fl__DOT__alloc_block_idx_o),12);
    bufp->fullSData(oldp+12,(vlSelfRef.tb_fl__DOT__dut__DOT__sp),13);
    bufp->fullBit(oldp+13,((0U == (IData)(vlSelfRef.tb_fl__DOT__dut__DOT__sp))));
    bufp->fullBit(oldp+14,((0x1000U == (IData)(vlSelfRef.tb_fl__DOT__dut__DOT__sp))));
    bufp->fullIData(oldp+15,(vlSelfRef.tb_fl__DOT__dut__DOT__unnamedblk1__DOT__i),32);
    bufp->fullBit(oldp+16,(vlSelfRef.tb_fl__DOT__clk));
}
