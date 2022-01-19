-- Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2018.2 (win64) Build 2258646 Thu Jun 14 20:03:12 MDT 2018
-- Date        : Tue Oct  2 15:30:18 2018
-- Host        : PC411-00 running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub {C:/Users/Yurii/Desktop/SDR/FPGA
--               3.10/Kintex_FPGA_vivado/Kintex_FPGA_vivado.srcs/sources_1/ip/fifo_xlnx_512x36_2clk_18to36/fifo_xlnx_512x36_2clk_18to36_stub.vhdl}
-- Design      : fifo_xlnx_512x36_2clk_18to36
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7k160tfbg484-2
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity fifo_xlnx_512x36_2clk_18to36 is
  Port ( 
    rst : in STD_LOGIC;
    wr_clk : in STD_LOGIC;
    rd_clk : in STD_LOGIC;
    din : in STD_LOGIC_VECTOR ( 17 downto 0 );
    wr_en : in STD_LOGIC;
    rd_en : in STD_LOGIC;
    dout : out STD_LOGIC_VECTOR ( 35 downto 0 );
    full : out STD_LOGIC;
    empty : out STD_LOGIC;
    prog_full : out STD_LOGIC
  );

end fifo_xlnx_512x36_2clk_18to36;

architecture stub of fifo_xlnx_512x36_2clk_18to36 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "rst,wr_clk,rd_clk,din[17:0],wr_en,rd_en,dout[35:0],full,empty,prog_full";
attribute x_core_info : string;
attribute x_core_info of stub : architecture is "fifo_generator_v13_2_2,Vivado 2018.2";
begin
end;
