//
// Copyright 2011 Ettus Research LLC
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//



module capture_ddrlvds
  #(parameter WIDTH=8)
   (input clk,
    input ssclk_p,
    input ssclk_n,
	 input adc_of_p,
	 input adc_of_n,
    input [WIDTH-1:0] in_p,
    input [WIDTH-1:0] in_n,
	 output adca_of,
	 output adcb_of,
    output reg [(2*WIDTH)-1:0] out);

   wire [WIDTH-1:0] 	   ddr_dat;
   wire 		   ssclk;
   wire [(2*WIDTH)-1:0]    out_pre;
   
   IBUFGDS #(.IOSTANDARD("LVDS"), .DIFF_TERM("TRUE")) 
   clkbuf (.O(ssclk), .I(ssclk_p), .IB(ssclk_n));
	
	IBUFDS #(.IOSTANDARD("LVDS"), .DIFF_TERM("TRUE")) 
   ofbuf (.O(adc_of), .I(adc_of_p), .IB(adc_of_n));
   
   genvar 	       i;
   generate
      for(i = 0; i < WIDTH; i = i + 1)
	begin : gen_lvds_pins
	   IBUFDS #(.IOSTANDARD("LVDS"),.DIFF_TERM("TRUE")) ibufds 
	      (.O(ddr_dat[i]), .I(in_p[i]), .IB(in_n[i]) );
			
			
	// IDDR: Input Double Data Rate Input Register with Set, Reset
   //       and Clock Enable.
   //       Kintex-7
   // Xilinx HDL Language Template, version 14.7

   IDDR #(
      .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                      //    or "SAME_EDGE_PIPELINED" 
      .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) IDDR_inst (
      .Q1(out_pre[2*i]), // 1-bit output for positive edge of clock 
      .Q2(out_pre[(2*i)+1]), // 1-bit output for negative edge of clock
      .C(ssclk),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D(ddr_dat[i]),   // 1-bit DDR data input
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );
	end
   endgenerate
	
	IDDR #(
      .DDR_CLK_EDGE("SAME_EDGE_PIPELINED"), // "OPPOSITE_EDGE", "SAME_EDGE" 
                                      //    or "SAME_EDGE_PIPELINED" 
      .INIT_Q1(1'b0), // Initial value of Q1: 1'b0 or 1'b1
      .INIT_Q2(1'b0), // Initial value of Q2: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) IDDR_inst (
      .Q1(adca_of), // 1-bit output for positive edge of clock 
      .Q2(adcb_of), // 1-bit output for negative edge of clock
      .C(ssclk),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D(adc_of),   // 1-bit DDR data input
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );

	   always @(posedge clk)
     out      <= out_pre;
   
endmodule // capture_ddrlvds
