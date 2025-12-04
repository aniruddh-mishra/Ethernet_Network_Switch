// Verilated -*- C++ -*-
// DESCRIPTION: Verilator output: Design implementation internals
// See Vtb_memory_write_ctrl.h for the primary calling header

#include "Vtb_memory_write_ctrl__pch.h"

VL_ATTR_COLD void Vtb_memory_write_ctrl___024root___eval_initial__TOP(Vtb_memory_write_ctrl___024root* vlSelf);
VlCoroutine Vtb_memory_write_ctrl___024root___eval_initial__TOP__Vtiming__0(Vtb_memory_write_ctrl___024root* vlSelf);
VlCoroutine Vtb_memory_write_ctrl___024root___eval_initial__TOP__Vtiming__1(Vtb_memory_write_ctrl___024root* vlSelf);

void Vtb_memory_write_ctrl___024root___eval_initial(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___eval_initial\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    Vtb_memory_write_ctrl___024root___eval_initial__TOP(vlSelf);
    vlSelfRef.__Vm_traceActivity[1U] = 1U;
    Vtb_memory_write_ctrl___024root___eval_initial__TOP__Vtiming__0(vlSelf);
    Vtb_memory_write_ctrl___024root___eval_initial__TOP__Vtiming__1(vlSelf);
}

VlCoroutine Vtb_memory_write_ctrl___024root___eval_initial__TOP__Vtiming__0(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___eval_initial__TOP__Vtiming__0\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ tb_memory_write_ctrl__DOT__unnamedblk1_1__DOT____Vrepeat0;
    tb_memory_write_ctrl__DOT__unnamedblk1_1__DOT____Vrepeat0 = 0;
    IData/*31:0*/ tb_memory_write_ctrl__DOT__unnamedblk1_2__DOT____Vrepeat1;
    tb_memory_write_ctrl__DOT__unnamedblk1_2__DOT____Vrepeat1 = 0;
    IData/*31:0*/ tb_memory_write_ctrl__DOT__unnamedblk1_3__DOT____Vrepeat2;
    tb_memory_write_ctrl__DOT__unnamedblk1_3__DOT____Vrepeat2 = 0;
    IData/*31:0*/ __Vtask_tb_memory_write_ctrl__DOT__send_packet__0__num_bytes;
    __Vtask_tb_memory_write_ctrl__DOT__send_packet__0__num_bytes = 0;
    IData/*31:0*/ __Vtask_tb_memory_write_ctrl__DOT__send_packet__0__i;
    __Vtask_tb_memory_write_ctrl__DOT__send_packet__0__i = 0;
    // Body
    vlSelfRef.tb_memory_write_ctrl__DOT__rst_n = 0U;
    vlSelfRef.tb_memory_write_ctrl__DOT__data_i = 0U;
    vlSelfRef.tb_memory_write_ctrl__DOT__data_valid_i = 0U;
    vlSelfRef.tb_memory_write_ctrl__DOT__data_begin_i = 0U;
    vlSelfRef.tb_memory_write_ctrl__DOT__data_end_i = 0U;
    tb_memory_write_ctrl__DOT__unnamedblk1_1__DOT____Vrepeat0 = 5U;
    while (VL_LTS_III(32, 0U, tb_memory_write_ctrl__DOT__unnamedblk1_1__DOT____Vrepeat0)) {
        co_await vlSelfRef.__VtrigSched_hf33a98da__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_memory_write_ctrl.clk)", 
                                                             "test/tb_memory_write_ctrl.sv", 
                                                             180);
        vlSelfRef.__Vm_traceActivity[2U] = 1U;
        tb_memory_write_ctrl__DOT__unnamedblk1_1__DOT____Vrepeat0 
            = (tb_memory_write_ctrl__DOT__unnamedblk1_1__DOT____Vrepeat0 
               - (IData)(1U));
    }
    vlSelfRef.tb_memory_write_ctrl__DOT__rst_n = 1U;
    tb_memory_write_ctrl__DOT__unnamedblk1_2__DOT____Vrepeat1 = 5U;
    while (VL_LTS_III(32, 0U, tb_memory_write_ctrl__DOT__unnamedblk1_2__DOT____Vrepeat1)) {
        co_await vlSelfRef.__VtrigSched_hf33a98da__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_memory_write_ctrl.clk)", 
                                                             "test/tb_memory_write_ctrl.sv", 
                                                             182);
        vlSelfRef.__Vm_traceActivity[2U] = 1U;
        tb_memory_write_ctrl__DOT__unnamedblk1_2__DOT____Vrepeat1 
            = (tb_memory_write_ctrl__DOT__unnamedblk1_2__DOT____Vrepeat1 
               - (IData)(1U));
    }
    VL_WRITEF_NX("=== TEST 1: large packet (4 * PAYLOAD_BYTES bytes) ===\n",0);
    __Vtask_tb_memory_write_ctrl__DOT__send_packet__0__num_bytes = 0x000000f8U;
    __Vtask_tb_memory_write_ctrl__DOT__send_packet__0__i = 0;
    VL_WRITEF_NX("[%0t] >>> Sending packet with %0d bytes\n",0,
                 64,VL_TIME_UNITED_Q(1),-12,32,__Vtask_tb_memory_write_ctrl__DOT__send_packet__0__num_bytes);
    __Vtask_tb_memory_write_ctrl__DOT__send_packet__0__i = 0U;
    while (VL_LTS_III(32, __Vtask_tb_memory_write_ctrl__DOT__send_packet__0__i, __Vtask_tb_memory_write_ctrl__DOT__send_packet__0__num_bytes)) {
        co_await vlSelfRef.__VtrigSched_hf33a9799__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(negedge tb_memory_write_ctrl.clk)", 
                                                             "test/tb_memory_write_ctrl.sv", 
                                                             136);
        vlSelfRef.__Vm_traceActivity[2U] = 1U;
        while ((((~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__mem_trans_success)) 
                 & (3U == (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state))) 
                | (2U == (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state)))) {
            co_await vlSelfRef.__VtrigSched_hf33a9799__0.trigger(0U, 
                                                                 nullptr, 
                                                                 "@(negedge tb_memory_write_ctrl.clk)", 
                                                                 "test/tb_memory_write_ctrl.sv", 
                                                                 137);
            vlSelfRef.__Vm_traceActivity[2U] = 1U;
        }
        vlSelfRef.tb_memory_write_ctrl__DOT__data_valid_i = 1U;
        vlSelfRef.tb_memory_write_ctrl__DOT__data_begin_i 
            = (0U == __Vtask_tb_memory_write_ctrl__DOT__send_packet__0__i);
        vlSelfRef.tb_memory_write_ctrl__DOT__data_end_i 
            = (__Vtask_tb_memory_write_ctrl__DOT__send_packet__0__i 
               == (__Vtask_tb_memory_write_ctrl__DOT__send_packet__0__num_bytes 
                   - (IData)(1U)));
        vlSelfRef.tb_memory_write_ctrl__DOT__data_i 
            = (0x000000ffU & __Vtask_tb_memory_write_ctrl__DOT__send_packet__0__i);
        __Vtask_tb_memory_write_ctrl__DOT__send_packet__0__i 
            = ((IData)(1U) + __Vtask_tb_memory_write_ctrl__DOT__send_packet__0__i);
    }
    co_await vlSelfRef.__VtrigSched_hf33a9799__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_memory_write_ctrl.clk)", 
                                                         "test/tb_memory_write_ctrl.sv", 
                                                         146);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    vlSelfRef.tb_memory_write_ctrl__DOT__data_valid_i = 0U;
    vlSelfRef.tb_memory_write_ctrl__DOT__data_begin_i = 0U;
    vlSelfRef.tb_memory_write_ctrl__DOT__data_end_i = 0U;
    co_await vlSelfRef.__VtrigSched_hf33a9799__0.trigger(0U, 
                                                         nullptr, 
                                                         "@(negedge tb_memory_write_ctrl.clk)", 
                                                         "test/tb_memory_write_ctrl.sv", 
                                                         152);
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
    tb_memory_write_ctrl__DOT__unnamedblk1_3__DOT____Vrepeat2 = 0x000000c8U;
    while (VL_LTS_III(32, 0U, tb_memory_write_ctrl__DOT__unnamedblk1_3__DOT____Vrepeat2)) {
        co_await vlSelfRef.__VtrigSched_hf33a98da__0.trigger(0U, 
                                                             nullptr, 
                                                             "@(posedge tb_memory_write_ctrl.clk)", 
                                                             "test/tb_memory_write_ctrl.sv", 
                                                             202);
        vlSelfRef.__Vm_traceActivity[2U] = 1U;
        tb_memory_write_ctrl__DOT__unnamedblk1_3__DOT____Vrepeat2 
            = (tb_memory_write_ctrl__DOT__unnamedblk1_3__DOT____Vrepeat2 
               - (IData)(1U));
    }
    VL_WRITEF_NX("=== Simulation done. Total memory writes: %0d ===\n",0,
                 32,vlSelfRef.tb_memory_write_ctrl__DOT__write_count);
    VL_FINISH_MT("test/tb_memory_write_ctrl.sv", 205, "");
    vlSelfRef.__Vm_traceActivity[2U] = 1U;
}

VlCoroutine Vtb_memory_write_ctrl___024root___eval_initial__TOP__Vtiming__1(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___eval_initial__TOP__Vtiming__1\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    while (VL_LIKELY(!vlSymsp->_vm_contextp__->gotFinish())) {
        co_await vlSelfRef.__VdlySched.delay(5ULL, 
                                             nullptr, 
                                             "test/tb_memory_write_ctrl.sv", 
                                             65);
        vlSelfRef.tb_memory_write_ctrl__DOT__clk = 
            (1U & (~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__clk)));
    }
}

#ifdef VL_DEBUG
VL_ATTR_COLD void Vtb_memory_write_ctrl___024root___dump_triggers__act(const VlUnpacked<QData/*63:0*/, 1> &triggers, const std::string &tag);
#endif  // VL_DEBUG

void Vtb_memory_write_ctrl___024root___eval_triggers__act(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___eval_triggers__act\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    vlSelfRef.__VactTriggered[0U] = (QData)((IData)(
                                                    (((vlSelfRef.__VdlySched.awaitingCurrentTime() 
                                                       << 3U) 
                                                      | (((~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__clk)) 
                                                          & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_memory_write_ctrl__DOT__clk__0)) 
                                                         << 2U)) 
                                                     | ((((~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__rst_n)) 
                                                          & (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_memory_write_ctrl__DOT__rst_n__0)) 
                                                         << 1U) 
                                                        | ((IData)(vlSelfRef.tb_memory_write_ctrl__DOT__clk) 
                                                           & (~ (IData)(vlSelfRef.__Vtrigprevexpr___TOP__tb_memory_write_ctrl__DOT__clk__0)))))));
    vlSelfRef.__Vtrigprevexpr___TOP__tb_memory_write_ctrl__DOT__clk__0 
        = vlSelfRef.tb_memory_write_ctrl__DOT__clk;
    vlSelfRef.__Vtrigprevexpr___TOP__tb_memory_write_ctrl__DOT__rst_n__0 
        = vlSelfRef.tb_memory_write_ctrl__DOT__rst_n;
#ifdef VL_DEBUG
    if (VL_UNLIKELY(vlSymsp->_vm_contextp__->debug())) {
        Vtb_memory_write_ctrl___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
    }
#endif
}

bool Vtb_memory_write_ctrl___024root___trigger_anySet__act(const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___trigger_anySet__act\n"); );
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

void Vtb_memory_write_ctrl___024root___act_comb__TOP__0(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___act_comb__TOP__0\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
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

void Vtb_memory_write_ctrl___024root___eval_act(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___eval_act\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((5ULL & vlSelfRef.__VactTriggered[0U])) {
        Vtb_memory_write_ctrl___024root___act_comb__TOP__0(vlSelf);
    }
}

extern const VlWide<16>/*511:0*/ Vtb_memory_write_ctrl__ConstPool__CONST_h93e1b771_0;
extern const VlWide<16>/*511:0*/ Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0;
extern const VlWide<16>/*511:0*/ Vtb_memory_write_ctrl__ConstPool__CONST_hdb52ae45_0;

void Vtb_memory_write_ctrl___024root___nba_sequent__TOP__0(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___nba_sequent__TOP__0\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __Vdly__tb_memory_write_ctrl__DOT__write_count;
    __Vdly__tb_memory_write_ctrl__DOT__write_count = 0;
    SData/*11:0*/ __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__curr_idx;
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__curr_idx = 0;
    CData/*0:0*/ __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated;
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated = 0;
    SData/*11:0*/ __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__next_idx;
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__next_idx = 0;
    CData/*5:0*/ __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt;
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt = 0;
    VlWide<16>/*495:0*/ __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg;
    VL_ZERO_W(496, __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg);
    // Body
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__curr_idx 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__curr_idx;
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__next_idx 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__next_idx;
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0U] 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0U];
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[1U] 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[1U];
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[2U] 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[2U];
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[3U] 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[3U];
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[4U] 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[4U];
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[5U] 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[5U];
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[6U] 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[6U];
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[7U] 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[7U];
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[8U] 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[8U];
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[9U] 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[9U];
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000aU] 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000aU];
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000bU] 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000bU];
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000cU] 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000cU];
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000dU] 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000dU];
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000eU] 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000eU];
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000fU] 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000fU];
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt;
    __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated 
        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated;
    __Vdly__tb_memory_write_ctrl__DOT__write_count 
        = vlSelfRef.tb_memory_write_ctrl__DOT__write_count;
    if (vlSelfRef.tb_memory_write_ctrl__DOT__rst_n) {
        if (VL_UNLIKELY((vlSelfRef.tb_memory_write_ctrl__DOT__mem_we_o))) {
            __Vdly__tb_memory_write_ctrl__DOT__write_count 
                = ((IData)(1U) + vlSelfRef.tb_memory_write_ctrl__DOT__write_count);
            VL_WRITEF_NX("[%0t] MEM WRITE #%0d: addr=%0# start_addr_o=%0#\n           footer: next_idx=%0# eop=%0b rsvd=%0x\n",0,
                         64,VL_TIME_UNITED_Q(1),-12,
                         32,vlSelfRef.tb_memory_write_ctrl__DOT__write_count,
                         12,(IData)(vlSelfRef.tb_memory_write_ctrl__DOT__mem_addr_o),
                         12,vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__start_addr,
                         12,(0x00000fffU & ((IData)(vlSelfRef.tb_memory_write_ctrl__DOT__footer_dec) 
                                            >> 4U)),
                         1,(1U & ((IData)(vlSelfRef.tb_memory_write_ctrl__DOT__footer_dec) 
                                  >> 3U)),3,(7U & (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__footer_dec)));
            vlSelfRef.tb_memory_write_ctrl__DOT__footer_dec 
                = (0x0000ffffU & vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0U]);
        }
    } else {
        __Vdly__tb_memory_write_ctrl__DOT__write_count = 0U;
        vlSelfRef.tb_memory_write_ctrl__DOT__footer_dec = 0U;
    }
    if (vlSelfRef.tb_memory_write_ctrl__DOT__rst_n) {
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_we_o = 0U;
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_addr_o = 0U;
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_h93e1b771_0[0U];
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[1U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_h93e1b771_0[1U];
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[2U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_h93e1b771_0[2U];
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[3U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_h93e1b771_0[3U];
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[4U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_h93e1b771_0[4U];
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[5U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_h93e1b771_0[5U];
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[6U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_h93e1b771_0[6U];
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[7U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_h93e1b771_0[7U];
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[8U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_h93e1b771_0[8U];
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[9U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_h93e1b771_0[9U];
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000aU] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_h93e1b771_0[0x0000000aU];
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000bU] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_h93e1b771_0[0x0000000bU];
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000cU] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_h93e1b771_0[0x0000000cU];
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000dU] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_h93e1b771_0[0x0000000dU];
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000eU] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_h93e1b771_0[0x0000000eU];
        vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000fU] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_h93e1b771_0[0x0000000fU];
        if ((0U != (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state))) {
            if (((~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated)) 
                 & (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__fl_alloc_gnt_i))) {
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__curr_idx 
                    = vlSelfRef.tb_memory_write_ctrl__DOT__fl_alloc_block_idx_i;
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated = 1U;
                if ((0U == (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_cnt))) {
                    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__start_addr 
                        = vlSelfRef.tb_memory_write_ctrl__DOT__fl_alloc_block_idx_i;
                }
            }
            if ((((IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated) 
                  & (~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__next_frame_allocated))) 
                 & (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__fl_alloc_gnt_i))) {
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__next_idx 
                    = vlSelfRef.tb_memory_write_ctrl__DOT__fl_alloc_block_idx_i;
                vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__next_frame_allocated = 1U;
            }
        }
        if ((2U & (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state))) {
            if ((1U & (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state))) {
                if (vlSelfRef.tb_memory_write_ctrl__DOT__mem_ready_i) {
                    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_cnt 
                        = (0x00000fffU & ((IData)(1U) 
                                          + (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_cnt)));
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_addr_o 
                        = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__curr_idx;
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0U] 
                        = ((vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0U] 
                            << 0x00000010U) | (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__footer));
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[1U] 
                        = ((vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0U] 
                            >> 0x00000010U) | (vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[1U] 
                                               << 0x00000010U));
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[2U] 
                        = ((vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[1U] 
                            >> 0x00000010U) | (vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[2U] 
                                               << 0x00000010U));
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[3U] 
                        = ((vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[2U] 
                            >> 0x00000010U) | (vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[3U] 
                                               << 0x00000010U));
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[4U] 
                        = ((vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[3U] 
                            >> 0x00000010U) | (vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[4U] 
                                               << 0x00000010U));
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[5U] 
                        = ((vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[4U] 
                            >> 0x00000010U) | (vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[5U] 
                                               << 0x00000010U));
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[6U] 
                        = ((vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[5U] 
                            >> 0x00000010U) | (vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[6U] 
                                               << 0x00000010U));
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[7U] 
                        = ((vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[6U] 
                            >> 0x00000010U) | (vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[7U] 
                                               << 0x00000010U));
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[8U] 
                        = ((vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[7U] 
                            >> 0x00000010U) | (vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[8U] 
                                               << 0x00000010U));
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[9U] 
                        = ((vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[8U] 
                            >> 0x00000010U) | (vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[9U] 
                                               << 0x00000010U));
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000aU] 
                        = ((vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[9U] 
                            >> 0x00000010U) | (vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000aU] 
                                               << 0x00000010U));
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000bU] 
                        = ((vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000aU] 
                            >> 0x00000010U) | (vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000bU] 
                                               << 0x00000010U));
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000cU] 
                        = ((vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000bU] 
                            >> 0x00000010U) | (vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000cU] 
                                               << 0x00000010U));
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000dU] 
                        = ((vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000cU] 
                            >> 0x00000010U) | (vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000dU] 
                                               << 0x00000010U));
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000eU] 
                        = ((vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000dU] 
                            >> 0x00000010U) | (vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000eU] 
                                               << 0x00000010U));
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_wdata_o[0x0000000fU] 
                        = ((vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000eU] 
                            >> 0x00000010U) | (vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000fU] 
                                               << 0x00000010U));
                    vlSelfRef.tb_memory_write_ctrl__DOT__mem_we_o = 1U;
                    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__footer 
                        = (((IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__next_idx) 
                            << 4U) | ((IData)(vlSelfRef.tb_memory_write_ctrl__DOT__data_end_i) 
                                      << 3U));
                    if ((1U & (~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__data_end_i)))) {
                        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt = 0U;
                        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated = 1U;
                        vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__next_frame_allocated = 0U;
                        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__curr_idx 
                            = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__next_idx;
                        if (vlSelfRef.tb_memory_write_ctrl__DOT__data_valid_i) {
                            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt = 1U;
                            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0U] 
                                = vlSelfRef.tb_memory_write_ctrl__DOT__data_i;
                            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[1U] = 0U;
                            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[2U] = 0U;
                            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[3U] = 0U;
                            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[4U] = 0U;
                            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[5U] = 0U;
                            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[6U] = 0U;
                            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[7U] = 0U;
                            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[8U] = 0U;
                            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[9U] = 0U;
                            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000aU] = 0U;
                            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000bU] = 0U;
                            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000cU] = 0U;
                            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000dU] = 0U;
                            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000eU] = 0U;
                            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000fU] = 0U;
                        }
                    }
                }
            }
        } else if ((1U & (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state))) {
            if (vlSelfRef.tb_memory_write_ctrl__DOT__data_valid_i) {
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0U] 
                    = (((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[0U] 
                         & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0U]) 
                        << 8U) | (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__data_i));
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[1U] 
                    = (((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[0U] 
                         & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0U]) 
                        >> 0x00000018U) | ((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[1U] 
                                            & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[1U]) 
                                           << 8U));
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[2U] 
                    = (((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[1U] 
                         & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[1U]) 
                        >> 0x00000018U) | ((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[2U] 
                                            & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[2U]) 
                                           << 8U));
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[3U] 
                    = (((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[2U] 
                         & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[2U]) 
                        >> 0x00000018U) | ((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[3U] 
                                            & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[3U]) 
                                           << 8U));
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[4U] 
                    = (((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[3U] 
                         & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[3U]) 
                        >> 0x00000018U) | ((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[4U] 
                                            & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[4U]) 
                                           << 8U));
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[5U] 
                    = (((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[4U] 
                         & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[4U]) 
                        >> 0x00000018U) | ((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[5U] 
                                            & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[5U]) 
                                           << 8U));
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[6U] 
                    = (((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[5U] 
                         & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[5U]) 
                        >> 0x00000018U) | ((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[6U] 
                                            & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[6U]) 
                                           << 8U));
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[7U] 
                    = (((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[6U] 
                         & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[6U]) 
                        >> 0x00000018U) | ((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[7U] 
                                            & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[7U]) 
                                           << 8U));
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[8U] 
                    = (((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[7U] 
                         & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[7U]) 
                        >> 0x00000018U) | ((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[8U] 
                                            & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[8U]) 
                                           << 8U));
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[9U] 
                    = (((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[8U] 
                         & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[8U]) 
                        >> 0x00000018U) | ((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[9U] 
                                            & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[9U]) 
                                           << 8U));
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000aU] 
                    = (((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[9U] 
                         & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[9U]) 
                        >> 0x00000018U) | ((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[0x0000000aU] 
                                            & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000aU]) 
                                           << 8U));
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000bU] 
                    = (((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[0x0000000aU] 
                         & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000aU]) 
                        >> 0x00000018U) | ((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[0x0000000bU] 
                                            & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000bU]) 
                                           << 8U));
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000cU] 
                    = (((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[0x0000000bU] 
                         & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000bU]) 
                        >> 0x00000018U) | ((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[0x0000000cU] 
                                            & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000cU]) 
                                           << 8U));
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000dU] 
                    = (((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[0x0000000cU] 
                         & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000cU]) 
                        >> 0x00000018U) | ((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[0x0000000dU] 
                                            & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000dU]) 
                                           << 8U));
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000eU] 
                    = (((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[0x0000000dU] 
                         & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000dU]) 
                        >> 0x00000018U) | ((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[0x0000000eU] 
                                            & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000eU]) 
                                           << 8U));
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000fU] 
                    = (((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[0x0000000eU] 
                         & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000eU]) 
                        >> 0x00000018U) | ((Vtb_memory_write_ctrl__ConstPool__CONST_h8b2d9e06_0[0x0000000fU] 
                                            & vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000fU]) 
                                           << 8U));
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt 
                    = (0x0000003fU & ((IData)(1U) + (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt)));
            }
        } else {
            vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_cnt = 0U;
            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated = 0U;
            vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__next_frame_allocated = 0U;
            __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt = 0U;
            if (((IData)(vlSelfRef.tb_memory_write_ctrl__DOT__data_valid_i) 
                 & (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__data_begin_i))) {
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt = 1U;
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0U] 
                    = vlSelfRef.tb_memory_write_ctrl__DOT__data_i;
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[1U] = 0U;
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[2U] = 0U;
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[3U] = 0U;
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[4U] = 0U;
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[5U] = 0U;
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[6U] = 0U;
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[7U] = 0U;
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[8U] = 0U;
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[9U] = 0U;
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000aU] = 0U;
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000bU] = 0U;
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000cU] = 0U;
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000dU] = 0U;
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000eU] = 0U;
                __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000fU] = 0U;
            }
        }
        if (vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__fl_alloc_req_o) {
            vlSelfRef.tb_memory_write_ctrl__DOT__fl_alloc_block_idx_i 
                = vlSelfRef.tb_memory_write_ctrl__DOT__next_block_idx;
            vlSelfRef.tb_memory_write_ctrl__DOT__next_block_idx 
                = (0x00000fffU & ((IData)(1U) + (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__next_block_idx)));
        }
        vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state 
            = vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state_n;
    } else {
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__curr_idx = 0U;
        vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_cnt = 0U;
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_hdb52ae45_0[0U];
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[1U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_hdb52ae45_0[1U];
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[2U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_hdb52ae45_0[2U];
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[3U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_hdb52ae45_0[3U];
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[4U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_hdb52ae45_0[4U];
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[5U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_hdb52ae45_0[5U];
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[6U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_hdb52ae45_0[6U];
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[7U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_hdb52ae45_0[7U];
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[8U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_hdb52ae45_0[8U];
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[9U] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_hdb52ae45_0[9U];
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000aU] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_hdb52ae45_0[0x0000000aU];
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000bU] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_hdb52ae45_0[0x0000000bU];
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000cU] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_hdb52ae45_0[0x0000000cU];
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000dU] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_hdb52ae45_0[0x0000000dU];
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000eU] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_hdb52ae45_0[0x0000000eU];
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000fU] 
            = Vtb_memory_write_ctrl__ConstPool__CONST_hdb52ae45_0[0x0000000fU];
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt = 0U;
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__next_idx = 0U;
        __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated = 0U;
        vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__next_frame_allocated = 0U;
        vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__start_addr = 0U;
        vlSelfRef.tb_memory_write_ctrl__DOT__next_block_idx = 0U;
        vlSelfRef.tb_memory_write_ctrl__DOT__fl_alloc_block_idx_i = 0U;
        vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state = 0U;
    }
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__mem_trans_success 
        = ((IData)(vlSelfRef.tb_memory_write_ctrl__DOT__rst_n) 
           && (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__mem_ready_i));
    vlSelfRef.tb_memory_write_ctrl__DOT__write_count 
        = __Vdly__tb_memory_write_ctrl__DOT__write_count;
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__curr_idx 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__curr_idx;
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__next_idx 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__next_idx;
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0U] 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0U];
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[1U] 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[1U];
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[2U] 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[2U];
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[3U] 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[3U];
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[4U] 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[4U];
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[5U] 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[5U];
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[6U] 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[6U];
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[7U] 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[7U];
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[8U] 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[8U];
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[9U] 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[9U];
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000aU] 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000aU];
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000bU] 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000bU];
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000cU] 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000cU];
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000dU] 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000dU];
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000eU] 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000eU];
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000fU] 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__payload_reg[0x0000000fU];
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__beat_cnt;
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated 
        = __Vdly__tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated;
    vlSelfRef.tb_memory_write_ctrl__DOT__mem_ready_i 
        = vlSelfRef.tb_memory_write_ctrl__DOT__rst_n;
    vlSelfRef.tb_memory_write_ctrl__DOT__fl_alloc_gnt_i 
        = ((IData)(vlSelfRef.tb_memory_write_ctrl__DOT__rst_n) 
           && (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__fl_alloc_req_o));
    vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__fl_alloc_req_o 
        = ((0U != (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__state)) 
           & (((~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated)) 
               & (~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__fl_alloc_gnt_i))) 
              | ((~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__next_frame_allocated)) 
                 & ((~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__dut__DOT__frame_allocated)) 
                    | (~ (IData)(vlSelfRef.tb_memory_write_ctrl__DOT__fl_alloc_gnt_i))))));
}

void Vtb_memory_write_ctrl___024root___eval_nba(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___eval_nba\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((3ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_memory_write_ctrl___024root___nba_sequent__TOP__0(vlSelf);
        vlSelfRef.__Vm_traceActivity[3U] = 1U;
    }
    if ((7ULL & vlSelfRef.__VnbaTriggered[0U])) {
        Vtb_memory_write_ctrl___024root___act_comb__TOP__0(vlSelf);
    }
}

void Vtb_memory_write_ctrl___024root___timing_commit(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___timing_commit\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((! (1ULL & vlSelfRef.__VactTriggered[0U]))) {
        vlSelfRef.__VtrigSched_hf33a98da__0.commit(
                                                   "@(posedge tb_memory_write_ctrl.clk)");
    }
    if ((! (4ULL & vlSelfRef.__VactTriggered[0U]))) {
        vlSelfRef.__VtrigSched_hf33a9799__0.commit(
                                                   "@(negedge tb_memory_write_ctrl.clk)");
    }
}

void Vtb_memory_write_ctrl___024root___timing_resume(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___timing_resume\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Body
    if ((1ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_hf33a98da__0.resume(
                                                   "@(posedge tb_memory_write_ctrl.clk)");
    }
    if ((4ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VtrigSched_hf33a9799__0.resume(
                                                   "@(negedge tb_memory_write_ctrl.clk)");
    }
    if ((8ULL & vlSelfRef.__VactTriggered[0U])) {
        vlSelfRef.__VdlySched.resume();
    }
}

void Vtb_memory_write_ctrl___024root___trigger_orInto__act(VlUnpacked<QData/*63:0*/, 1> &out, const VlUnpacked<QData/*63:0*/, 1> &in) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___trigger_orInto__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = (out[n] | in[n]);
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vtb_memory_write_ctrl___024root___eval_phase__act(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___eval_phase__act\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VactExecute;
    // Body
    Vtb_memory_write_ctrl___024root___eval_triggers__act(vlSelf);
    Vtb_memory_write_ctrl___024root___timing_commit(vlSelf);
    Vtb_memory_write_ctrl___024root___trigger_orInto__act(vlSelfRef.__VnbaTriggered, vlSelfRef.__VactTriggered);
    __VactExecute = Vtb_memory_write_ctrl___024root___trigger_anySet__act(vlSelfRef.__VactTriggered);
    if (__VactExecute) {
        Vtb_memory_write_ctrl___024root___timing_resume(vlSelf);
        Vtb_memory_write_ctrl___024root___eval_act(vlSelf);
    }
    return (__VactExecute);
}

void Vtb_memory_write_ctrl___024root___trigger_clear__act(VlUnpacked<QData/*63:0*/, 1> &out) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___trigger_clear__act\n"); );
    // Locals
    IData/*31:0*/ n;
    // Body
    n = 0U;
    do {
        out[n] = 0ULL;
        n = ((IData)(1U) + n);
    } while ((1U > n));
}

bool Vtb_memory_write_ctrl___024root___eval_phase__nba(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___eval_phase__nba\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    CData/*0:0*/ __VnbaExecute;
    // Body
    __VnbaExecute = Vtb_memory_write_ctrl___024root___trigger_anySet__act(vlSelfRef.__VnbaTriggered);
    if (__VnbaExecute) {
        Vtb_memory_write_ctrl___024root___eval_nba(vlSelf);
        Vtb_memory_write_ctrl___024root___trigger_clear__act(vlSelfRef.__VnbaTriggered);
    }
    return (__VnbaExecute);
}

void Vtb_memory_write_ctrl___024root___eval(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___eval\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
    // Locals
    IData/*31:0*/ __VnbaIterCount;
    // Body
    __VnbaIterCount = 0U;
    do {
        if (VL_UNLIKELY(((0x00000064U < __VnbaIterCount)))) {
#ifdef VL_DEBUG
            Vtb_memory_write_ctrl___024root___dump_triggers__act(vlSelfRef.__VnbaTriggered, "nba"s);
#endif
            VL_FATAL_MT("test/tb_memory_write_ctrl.sv", 1, "", "NBA region did not converge after 100 tries");
        }
        __VnbaIterCount = ((IData)(1U) + __VnbaIterCount);
        vlSelfRef.__VactIterCount = 0U;
        do {
            if (VL_UNLIKELY(((0x00000064U < vlSelfRef.__VactIterCount)))) {
#ifdef VL_DEBUG
                Vtb_memory_write_ctrl___024root___dump_triggers__act(vlSelfRef.__VactTriggered, "act"s);
#endif
                VL_FATAL_MT("test/tb_memory_write_ctrl.sv", 1, "", "Active region did not converge after 100 tries");
            }
            vlSelfRef.__VactIterCount = ((IData)(1U) 
                                         + vlSelfRef.__VactIterCount);
        } while (Vtb_memory_write_ctrl___024root___eval_phase__act(vlSelf));
    } while (Vtb_memory_write_ctrl___024root___eval_phase__nba(vlSelf));
}

#ifdef VL_DEBUG
void Vtb_memory_write_ctrl___024root___eval_debug_assertions(Vtb_memory_write_ctrl___024root* vlSelf) {
    VL_DEBUG_IF(VL_DBG_MSGF("+    Vtb_memory_write_ctrl___024root___eval_debug_assertions\n"); );
    Vtb_memory_write_ctrl__Syms* const __restrict vlSymsp VL_ATTR_UNUSED = vlSelf->vlSymsp;
    auto& vlSelfRef = std::ref(*vlSelf).get();
}
#endif  // VL_DEBUG
