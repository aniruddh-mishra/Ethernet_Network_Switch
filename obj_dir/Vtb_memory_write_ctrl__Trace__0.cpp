// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Tracing implementation internals
#include "verilated_vcd_c.h"
#include "Vtb_memory_write_ctrl__Syms.h"


void Vtb_memory_write_ctrl___024root__trace_chg_0_sub_0(Vtb_memory_write_ctrl___024root* vlSelf, VerilatedVcd::Buffer* bufp);

void Vtb_memory_write_ctrl___024root__trace_chg_0(void* voidSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root__trace_chg_0\n"); );
    // Body
    Vtb_memory_write_ctrl___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtb_memory_write_ctrl___024root*>(voidSelf);
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    if (VL_UNLIKELY(!vlSymsp->__Vm_activity)) return;
    Vtb_memory_write_ctrl___024root__trace_chg_0_sub_0((&vlSymsp->TOP), bufp);
}

extern const VlWide<16>/*511:0*/ Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0;

void Vtb_memory_write_ctrl___024root__trace_chg_0_sub_0(Vtb_memory_write_ctrl___024root* vlSelf, VerilatedVcd::Buffer* bufp) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root__trace_chg_0_sub_0\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    uint32_t* const oldp VL_ATTR_UNUSED = bufp->oldp(vlSymsp->__Vm_baseCode + 1);
    if (VL_UNLIKELY(((vlSelfRef.__Vm_traceActivity[1U] 
                      | vlSelfRef.__Vm_traceActivity
                      [2U])))) {
        bufp->chgBit(oldp+0,(vlSelfRef.tb_memory_write_ctrl__DOT__rst_n));
        bufp->chgCData(oldp+1,(vlSelfRef.tb_memory_write_ctrl__DOT__data_i),8);
        bufp->chgBit(oldp+2,(vlSelfRef.tb_memory_write_ctrl__DOT__data_valid_i));
        bufp->chgBit(oldp+3,(vlSelfRef.tb_memory_write_ctrl__DOT__data_begin_i));
        bufp->chgBit(oldp+4,(vlSelfRef.tb_memory_write_ctrl__DOT__data_end_i));
    }
    if (VL_UNLIKELY((vlSelfRef.__Vm_traceActivity[3U]))) {
        bufp->chgBit(oldp+5,((1U & (~ (((~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__mem_trans_success)) 
                                        & (3U == (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state))) 
                                       | (2U == (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state)))))));
        bufp->chgBit(oldp+6,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__fl_alloc_req_o));
        bufp->chgBit(oldp+7,(vlSelfRef.tb_memory_write_ctrl__DOT__fl_alloc_gnt_i));
        bufp->chgSData(oldp+8,(vlSelfRef.tb_memory_write_ctrl__DOT__fl_alloc_block_idx_i),12);
        bufp->chgBit(oldp+9,(vlSelfRef.tb_memory_write_ctrl__DOT__mem_ready_i));
        bufp->chgBit(oldp+10,(vlSelfRef.tb_memory_write_ctrl__DOT__mem_we_o));
        bufp->chgSData(oldp+11,(vlSelfRef.tb_memory_write_ctrl__DOT__mem_addr_o),12);
        bufp->chgWData(oldp+12,(vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o),512);
        bufp->chgSData(oldp+28,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__start_addr),12);
        bufp->chgIData(oldp+29,(vlSelfRef.tb_memory_write_ctrl__DOT__write_count),32);
        bufp->chgSData(oldp+30,(vlSelfRef.tb_memory_write_ctrl__DOT__next_block_idx),12);
        bufp->chgSData(oldp+31,(vlSelfRef.tb_memory_write_ctrl__DOT__footer_dec),16);
        bufp->chgBit(oldp+32,((1U & VL_REDXOR_32(((
                                                   ((((((((((((((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[0U] 
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
                                                   ^ 
                                                   (Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[0x0000000eU] 
                                                    & ((vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000fU] 
                                                        << 0x00000010U) 
                                                       | (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000eU] 
                                                          >> 0x00000010U)))) 
                                                  ^ 
                                                  (Vtb_memory_write_ctrl__ConstPool__CONST_h8b2c9f06_0[0x0000000fU] 
                                                   & (vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000fU] 
                                                      >> 0x00000010U)))))));
        bufp->chgBit(oldp+33,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated));
        bufp->chgBit(oldp+34,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__next_frame_allocated));
        bufp->chgCData(oldp+35,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state),2);
        bufp->chgSData(oldp+36,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__footer),16);
        bufp->chgWData(oldp+37,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg),496);
        bufp->chgCData(oldp+53,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt),6);
        bufp->chgSData(oldp+54,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__curr_idx),12);
        bufp->chgSData(oldp+55,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__next_idx),12);
        bufp->chgBit(oldp+56,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__mem_trans_success));
        bufp->chgSData(oldp+57,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_cnt),12);
    }
    bufp->chgBit(oldp+58,(vlSelfRef.tb_memory_write_ctrl__DOT__clk));
    bufp->chgCData(oldp+59,(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state_n),2);
}

void Vtb_memory_write_ctrl___024root__trace_cleanup(void* voidSelf, VerilatedVcd* /*unused*/) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root__trace_cleanup\n"); );
    // Body
    Vtb_memory_write_ctrl___024root* const __restrict vlSelf VL_ATTR_UNUSED = static_cast<Vtb_memory_write_ctrl___024root*>(voidSelf);
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    vlSymsp->__Vm_activity = false;
    vlSymsp->TOP.__Vm_traceActivity[0U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[1U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[2U] = 0U;
    vlSymsp->TOP.__Vm_traceActivity[3U] = 0U;
}
