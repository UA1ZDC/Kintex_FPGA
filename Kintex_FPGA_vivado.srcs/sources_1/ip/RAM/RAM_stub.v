// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
// Date        : Fri Feb  1 16:12:56 2019
// Host        : PC411-00 running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub {C:/Users/yurii/Desktop/SDR/FPGA
//               3.10/Kintex_FPGA_vivado/Kintex_FPGA_vivado.srcs/sources_1/ip/RAM/RAM_stub.v}
// Design      : RAM
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7k160tfbg484-2
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_1,Vivado 2018.2" *)
module RAM(clka, ena, wea, addra, dina, douta, clkb, enb, web, addrb, 
  dinb, doutb)
/* synthesis syn_black_box black_box_pad_pin="clka,ena,wea[3:0],addra[11:0],dina[35:0],douta[35:0],clkb,enb,web[3:0],addrb[11:0],dinb[35:0],doutb[35:0]" */;
  input clka;
  input ena;
  input [3:0]wea;
  input [11:0]addra;
  input [35:0]dina;
  output [35:0]douta;
  input clkb;
  input enb;
  input [3:0]web;
  input [11:0]addrb;
  input [35:0]dinb;
  output [35:0]doutb;
endmodule
