// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Tue Oct  2 15:29:33 2018
// Host        : PC411-00 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {C:/Users/Yurii/Desktop/SDR/FPGA
//               3.10/Kintex_FPGA_vivado/Kintex_FPGA_vivado.srcs/sources_1/ip/fifo_xlnx_16x40_2clk/fifo_xlnx_16x40_2clk_stub.v}
// Design      : fifo_xlnx_16x40_2clk
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k160tfbg484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_2_2,Vivado 2018.2" *)
module fifo_xlnx_16x40_2clk(rst, wr_clk, rd_clk, din, wr_en, rd_en, dout, full, 
  empty)
/* synthesis syn_black_box black_box_pad_pin="rst,wr_clk,rd_clk,din[39:0],wr_en,rd_en,dout[39:0],full,empty" */;
  input rst;
  input wr_clk;
  input rd_clk;
  input [39:0]din;
  input wr_en;
  input rd_en;
  output [39:0]dout;
  output full;
  output empty;
endmodule
