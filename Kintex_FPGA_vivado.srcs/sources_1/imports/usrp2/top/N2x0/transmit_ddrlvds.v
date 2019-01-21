`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:57:41 11/07/2017 
// Design Name: 
// Module Name:    transmit_ddrlvds 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module transmit_ddrlvds
#(parameter WIDTH=16)
    (input [WIDTH-1:0] daca,
    input [WIDTH-1:0] dacb,
    output [WIDTH-1:0] dac_p,
    output [WIDTH-1:0] dac_n,
    input clk,
    output dci_p,
    output dci_n,
	 output frame_p,
    output frame_n
    );	 
	 
	// OBUFDS: Differential Output Buffer
   //         Kintex-7
   // Xilinx HDL Language Template, version 14.7
   
   OBUFDS #(
      .IOSTANDARD("DIFF_HSTL_I_18"), // Specify the output I/O standard
      .SLEW("FAST")           // Specify the output slew rate
   ) OBUFDS_inst1 (
      .O(dci_p),     // Diff_p output (connect directly to top-level port)
      .OB(dci_n),   // Diff_n output (connect directly to top-level port)
      .I(clk)      // Buffer input 
   );	

   OBUFDS #(
      .IOSTANDARD("LVDS"), // Specify the output I/O standard
      .SLEW("FAST")           // Specify the output slew rate
   ) OBUFDS_inst2 (
      .O(frame_p),     // Diff_p output (connect directly to top-level port)
      .OB(frame_n),   // Diff_n output (connect directly to top-level port)
      .I(clk)      // Buffer input 
   );	
	
	wire [WIDTH-1:0] data;
	
    reg [WIDTH-1:0] daca_reg;
    reg [WIDTH-1:0] dacb_reg;	
	 
	always @(negedge clk)
     daca_reg      <= daca;
	always @(negedge clk)
     dacb_reg      <= dacb;
	
	genvar 	       i;
   generate
      for(i = 0; i < WIDTH; i = i + 1)
	begin : gen_ddr_word
	
	// ODDR: Output Double Data Rate Output Register with Set, Reset
   //       and Clock Enable.
   //       Kintex-7
   // Xilinx HDL Language Template, version 14.7

   ODDR #(
      .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) ODDR_inst (
      .Q(data[i]),   // 1-bit DDR output
      .C(clk),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D1(daca_reg[i]), // 1-bit data input (positive edge)
      .D2(dacb_reg[i]), // 1-bit data input (negative edge)
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );
	
	// OBUFDS: Differential Output Buffer
   //         Kintex-7
   // Xilinx HDL Language Template, version 14.7
   
   OBUFDS #(
      .IOSTANDARD("LVDS"), // Specify the output I/O standard
      .SLEW("FAST")           // Specify the output slew rate
   ) OBUFDS_inst (
      .O(dac_p[i]),     // Diff_p output (connect directly to top-level port)
      .OB(dac_n[i]),   // Diff_n output (connect directly to top-level port)
      .I(data[i])      // Buffer input 
   );
	end
   endgenerate

endmodule
