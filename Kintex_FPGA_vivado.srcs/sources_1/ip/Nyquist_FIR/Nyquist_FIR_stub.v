// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Fri Feb  8 19:07:48 2019
// Host        : PC411-00 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub -rename_top Nyquist_FIR -prefix
//               Nyquist_FIR_ Nyquist_FIR_stub.v
// Design      : Nyquist_FIR
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k160tfbg484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fir_compiler_v7_2_11,Vivado 2018.2" *)
module Nyquist_FIR(aresetn, aclk, aclken, s_axis_data_tvalid, 
  s_axis_data_tready, s_axis_data_tdata, m_axis_data_tvalid, m_axis_data_tuser, 
  m_axis_data_tdata)
/* synthesis syn_black_box black_box_pad_pin="aresetn,aclk,aclken,s_axis_data_tvalid,s_axis_data_tready,s_axis_data_tdata[23:0],m_axis_data_tvalid,m_axis_data_tuser[0:0],m_axis_data_tdata[15:0]" */;
  input aresetn;
  input aclk;
  input aclken;
  input s_axis_data_tvalid;
  output s_axis_data_tready;
  input [23:0]s_axis_data_tdata;
  output m_axis_data_tvalid;
  output [0:0]m_axis_data_tuser;
  output [15:0]m_axis_data_tdata;
endmodule
