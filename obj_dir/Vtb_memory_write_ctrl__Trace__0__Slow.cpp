// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtb_memory_write_ctrl__Syms.h"


VL_ATTR_COLD void Vtb_memory_write_ctrl___024root__trace_init_sub__TOP__mem_pkg__0(Vtb_memory_write_ctrl___024root* vlSelf, VerilatedVcd* tracep);

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root__trace_init_sub__TOP__0(Vtb_memory_write_ctrl___024root* vlSelf, VerilatedVcd* tracep) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root__trace_init_sub__TOP__0\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const int c = vlSymsp->__Vm_baseCode;
    tracep->pushPrefix("mem_pkg", VerilatedTracePrefixType::SCOPE_MODULE);
    Vtb_memory_write_ctrl___024root__trace_init_sub__TOP__mem_pkg__0(vlSelf, tracep);
    tracep->popPrefix();
    tracep->pushPrefix("tb_memory_write_ctrl", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+59,0,"clk",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+1,0,"rst_n",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+2,0,"data_i",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBit(c+3,0,"data_valid_i",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+4,0,"data_begin_i",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+5,0,"data_end_i",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+6,0,"data_ready_o",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+7,0,"fl_alloc_req_o",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+8,0,"fl_alloc_gnt_i",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+9,0,"fl_alloc_block_idx_i",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBit(c+10,0,"mem_ready_i",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+11,0,"mem_we_o",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+12,0,"mem_addr_o",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declArray(c+13,0,"mem_wdata_o",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 511,0);
    tracep->declBus(c+29,0,"start_addr_o",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+30,0,"write_count",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->declDouble(c+61,0,"CLK_PERIOD",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::DOUBLE, false,-1);
    tracep->declBus(c+31,0,"next_block_idx",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+63,0,"FOOTER_BITS",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->declBus(c+32,0,"footer_dec",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 15,0);
    tracep->declBit(c+33,0,"unused_upper_reduce",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->pushPrefix("dut", VerilatedTracePrefixType::SCOPE_MODULE);
    tracep->declBit(c+59,0,"clk",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+1,0,"rst_n",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+2,0,"data_i",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 7,0);
    tracep->declBit(c+3,0,"data_valid_i",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+4,0,"data_begin_i",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+5,0,"data_end_i",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+6,0,"data_ready_o",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+7,0,"fl_alloc_req_o",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+8,0,"fl_alloc_gnt_i",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+9,0,"fl_alloc_block_idx_i",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBit(c+10,0,"mem_ready_i",-1, VerilatedTraceSigDirection::INPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+11,0,"mem_we_o",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+12,0,"mem_addr_o",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declArray(c+13,0,"mem_wdata_o",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 511,0);
    tracep->declBus(c+29,0,"start_addr_o",-1, VerilatedTraceSigDirection::OUTPUT, VerilatedTraceSigKind::WIRE, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+64,0,"PAYLOAD_BITS",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->declBit(c+34,0,"frame_allocated",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBit(c+35,0,"next_frame_allocated",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+36,0,"state",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+60,0,"state_n",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 1,0);
    tracep->declBus(c+37,0,"footer",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 15,0);
    tracep->declArray(c+38,0,"payload_reg",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 495,0);
    tracep->declBus(c+54,0,"beat_cnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 5,0);
    tracep->declBus(c+55,0,"curr_idx",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+56,0,"next_idx",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBit(c+57,0,"mem_trans_success",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1);
    tracep->declBus(c+29,0,"start_addr",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->declBus(c+58,0,"frame_cnt",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::VAR, VerilatedTraceSigType::LOGIC, false,-1, 11,0);
    tracep->popPrefix();
    tracep->popPrefix();
}

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root__trace_init_sub__TOP__mem_pkg__0(Vtb_memory_write_ctrl___024root* vlSelf, VerilatedVcd* tracep) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root__trace_init_sub__TOP__mem_pkg__0\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    const int c = vlSymsp->__Vm_baseCode;
    tracep->declBus(c+65,0,"BLOCK_BYTES",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->declBus(c+66,0,"NUM_BLOCKS",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->declBus(c+67,0,"DATA_WIDTH",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->declBus(c+68,0,"ADDR_W",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->declBus(c+69,0,"FOOTER_BYTES",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->declBus(c+70,0,"PAYLOAD_BYTES",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
    tracep->declBus(c+71,0,"BLOCK_BITS",-1, VerilatedTraceSigDirection::NONE, VerilatedTraceSigKind::PARAMETER, VerilatedTraceSigType::INT, false,-1, 31,0);
}

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root__trace_init_top(Vtb_memory_write_ctrl___024root* vlSelf, VerilatedVcd* tracep) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root__trace_init_top\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_memory_write_ctrl___024root__trace_init_sub__TOP__0(vlSelf, tracep);
}

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
VL_ATTR_COLD void Vtb_memory_write_ctrl___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vtb_memory_write_ctrl___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp);
void Vtb_memory_write_ctrl___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/);

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root__trace_register(Vtb_memory_write_ctrl___024root* vlSelf, VerilatedVcd* tracep) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root__trace_register\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    tracep->addConstCb(&Vtb_memory_write_ctrl___024root__trace_const_0, 0, vlSelf);
    tracep->addFullCb(&Vtb_memory_write_ctrl___024root__trace_full_0, 0, vlSelf);
    tracep->addChgCb(&Vtb_memory_write_ctrl___024root__trace_chg_0, 0, vlSelf);
    tracep->addCleanupCb(&Vtb_memory_write_ctrl___024root__trace_cleanup, vlSelf);
}

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root__trace_const_0_sub_0(Vtb_memory_write_ctrl___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root__trace_const_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root__trace_const_0\n"); );
    // Body
    Vtb_memory_write_ctrl___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtb_memory_write_ctrl___024root*>(voidSelf);
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    Vtb_memory_write_ctrl___024root__trace_const_0_sub_0((&vlSymsp->TOP), bufp);
}

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root__trace_const_0_sub_0(Vtb_memory_write_ctrl___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root__trace_const_0_sub_0\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    bufp->fullDouble(oldp+61,(10.0));
    bufp->fullIData(oldp+63,(0x00000010U),32);
    bufp->fullIData(oldp+64,(0x000001f0U),32);
    bufp->fullIData(oldp+65,(0x00000040U),32);
    bufp->fullIData(oldp+66,(0x00001000U),32);
    bufp->fullIData(oldp+67,(8U),32);
    bufp->fullIData(oldp+68,(0x0000000cU),32);
    bufp->fullIData(oldp+69,(2U),32);
    bufp->fullIData(oldp+70,(0x0000003eU),32);
    bufp->fullIData(oldp+71,(0x00000200U),32);
}

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root__trace_full_0_sub_0(Vtb_memory_write_ctrl___024root* vlSelf, VerilatedVcd::Buffer* bufp);

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root__trace_full_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root__trace_full_0\n"); );
    // Body
    Vtb_memory_write_ctrl___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtb_memory_write_ctrl___024root*>(voidSelf);
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    Vtb_memory_write_ctrl___024root__trace_full_0_sub_0((&vlSymsp->TOP), bufp);
}

extern const VlWide<16>/*511:0*/ Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0;

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root__trace_full_0_sub_0(Vtb_memory_write_ctrl___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root__trace_full_0_sub_0\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode);
    bufp->fullBit(oldp+1,(vlSelfRef.tb_memory_write_ctrl__DOT__rst_n));
    bufp->fullCData(oldp+2,(vlSelfRef.tb_memory_write_ctrl__DOT__data_i),8);
    bufp->fullBit(oldp+3,(vlSelfRef.tb_memory_write_ctrl__DOT__data_valid_i));
    bufp->fullBit(oldp+4,(vlSelfRef.tb_memory_write_ctrl__DOT__data_begin_i));
    bufp->fullBit(oldp+5,(vlSelfRef.tb_memory_write_ctrl__DOT__data_end_i));
    bufp->fullBit(oldp+6,((1U & (~ (((~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__mem_trans_success)) 
                                     & (3U == (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state))) 
                                    | (2U == (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state)))))));
    bufp->fullBit(oldp+7,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__fl_alloc_req_o));
    bufp->fullBit(oldp+8,(vlSelfRef.tb_memory_write_ctrl__DOT__fl_alloc_gnt_i));
    bufp->fullSData(oldp+9,(vlSelfRef.tb_memory_write_ctrl__DOT__fl_alloc_block_idx_i),12);
    bufp->fullBit(oldp+10,(vlSelfRef.tb_memory_write_ctrl__DOT__mem_ready_i));
    bufp->fullBit(oldp+11,(vlSelfRef.tb_memory_write_ctrl__DOT__mem_we_o));
    bufp->fullSData(oldp+12,(vlSelfRef.tb_memory_write_ctrl__DOT__mem_addr_o),12);
    bufp->fullWData(oldp+13,(vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o),512);
    bufp->fullSData(oldp+29,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__start_addr),12);
    bufp->fullIData(oldp+30,(vlSelfRef.tb_memory_write_ctrl__DOT__write_count),32);
    bufp->fullSData(oldp+31,(vlSelfRef.tb_memory_write_ctrl__DOT__next_block_idx),12);
    bufp->fullSData(oldp+32,(vlSelfRef.tb_memory_write_ctrl__DOT__footer_dec),16);
    bufp->fullBit(oldp+33,((1U & VL_REDXOR_32((((((
                                                   (((((((((((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[0U] 
                                                              & ((vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[1U] 
                                                                  << 0x00000010U) 
                                                                 | (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0U] 
                                                                    >> 0x00000010U))) 
                                                             ^ 
                                                             (Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[1U] 
                                                              & ((vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[2U] 
                                                                  << 0x00000010U) 
                                                                 | (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[1U] 
                                                                    >> 0x00000010U)))) 
                                                            ^ 
                                                            (Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[2U] 
                                                             & ((vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[3U] 
                                                                 << 0x00000010U) 
                                                                | (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[2U] 
                                                                   >> 0x00000010U)))) 
                                                           ^ 
                                                           (Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[3U] 
                                                            & ((vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[4U] 
                                                                << 0x00000010U) 
                                                               | (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[3U] 
                                                                  >> 0x00000010U)))) 
                                                          ^ 
                                                          (Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[4U] 
                                                           & ((vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[5U] 
                                                               << 0x00000010U) 
                                                              | (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[4U] 
                                                                 >> 0x00000010U)))) 
                                                         ^ 
                                                         (Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[5U] 
                                                          & ((vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[6U] 
                                                              << 0x00000010U) 
                                                             | (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[5U] 
                                                                >> 0x00000010U)))) 
                                                        ^ 
                                                        (Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[6U] 
                                                         & ((vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[7U] 
                                                             << 0x00000010U) 
                                                            | (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[6U] 
                                                               >> 0x00000010U)))) 
                                                       ^ 
                                                       (Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[7U] 
                                                        & ((vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[8U] 
                                                            << 0x00000010U) 
                                                           | (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[7U] 
                                                              >> 0x00000010U)))) 
                                                      ^ 
                                                      (Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[8U] 
                                                       & ((vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[9U] 
                                                           << 0x00000010U) 
                                                          | (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[8U] 
                                                             >> 0x00000010U)))) 
                                                     ^ 
                                                     (Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[9U] 
                                                      & ((vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000aU] 
                                                          << 0x00000010U) 
                                                         | (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[9U] 
                                                            >> 0x00000010U)))) 
                                                    ^ 
                                                    (Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[0x0000000aU] 
                                                     & ((vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000bU] 
                                                         << 0x00000010U) 
                                                        | (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000aU] 
                                                           >> 0x00000010U)))) 
                                                   ^ 
                                                   (Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[0x0000000bU] 
                                                    & ((vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000cU] 
                                                        << 0x00000010U) 
                                                       | (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000bU] 
                                                          >> 0x00000010U)))) 
                                                  ^ 
                                                  (Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[0x0000000cU] 
                                                   & ((vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000dU] 
                                                       << 0x00000010U) 
                                                      | (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000cU] 
                                                         >> 0x00000010U)))) 
                                                 ^ 
                                                 (Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[0x0000000dU] 
                                                  & ((vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000eU] 
                                                      << 0x00000010U) 
                                                     | (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000dU] 
                                                        >> 0x00000010U)))) 
                                                ^ (
                                                   Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[0x0000000eU] 
                                                   & ((vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000fU] 
                                                       << 0x00000010U) 
                                                      | (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000eU] 
                                                         >> 0x00000010U)))) 
                                               ^ (Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[0x0000000fU] 
                                                  & (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000fU] 
                                                     >> 0x00000010U)))))));
    bufp->fullBit(oldp+34,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated));
    bufp->fullBit(oldp+35,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__next_frame_allocated));
    bufp->fullCData(oldp+36,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state),2);
    bufp->fullSData(oldp+37,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__footer),16);
    bufp->fullWData(oldp+38,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg),496);
    bufp->fullCData(oldp+54,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt),6);
    bufp->fullSData(oldp+55,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__curr_idx),12);
    bufp->fullSData(oldp+56,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__next_idx),12);
    bufp->fullBit(oldp+57,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__mem_trans_success));
    bufp->fullSData(oldp+58,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_cnt),12);
    bufp->fullBit(oldp+59,(vlSelfRef.tb_memory_write_ctrl__DOT__clk));
    bufp->fullCData(oldp+60,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state_n),2);
}
