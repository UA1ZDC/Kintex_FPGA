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

`timescale 1ns / 1ps
//`define LVDS 1
//`define DCM_FOR_RAMCLK
//////////////////////////////////////////////////////////////////////////////////

module u2plus
  (
   input CLK_FPGA_P, input CLK_FPGA_N,  // Diff
   
   // ADC
   input ADC_clkout_p, input ADC_clkout_n,	
	input [15:0] ADCA,input [15:0] ADCB,
	input ADCA_OF, input ADCB_OF,
   
   // DAC
	output DAC_DCI_p, output DAC_DCI_n,
	output DAC_FRAME_p, output DAC_FRAME_n,
	output [15:0] DAC_p, output [15:0] DAC_n,
	output DAC_RESETn, output DAC_TXEN,
	output DAC_IRQ1, output DAC_IRQ2,
   
   // DB IO Pins
   inout [15:0] io_tx,
   inout [15:0] io_rx,

   // Misc, debug
   output [5:1] leds,  // LED4 is shared w/INIT_B
   input FPGA_RESET,
   /*output [1:0] debug_clk,
   output [31:0] debug,*/
   //output [3:1] TXD, input [3:1] RXD, // UARTs
	output TXD, input RXD, // UARTs
   //input [3:0] dipsw,  // Forgot DIP Switches...
   
   // Clock Gen Control
   /*output [1:0] clk_en,
   output [1:0] clk_sel,
   input CLK_FUNC,*/        // FIXME is an input to control the 9510
   input clk_status,
	output clk_reset,
	output clk_sync,

   inout SCL, inout SDA,   // I2C

   // PPS
   input PPS_IN, //input PPS2_IN,

   // SPI
   output SEN_CLK, output SCLK_CLK, output MOSI_CLK, input MISO_CLK,
   output SEN_DAC, output SCLK_DAC, inout MOSIO_DAC, //output MOSI_DAC, input MISO_DAC,
   output SEN_ADC, output SCLK_ADC, output MOSI_ADC, input MISO_ADC,
   output SEN_TX_DB, output SCLK_TX_DB, output MOSI_TX_DB, input MISO_TX_DB,
   output SEN_TX_DAC, output SCLK_TX_DAC, output MOSI_TX_DAC,
   output SEN_TX_ADC, output SCLK_TX_ADC, output MOSI_TX_ADC, input MISO_TX_ADC,
   output SEN_RX_DB, output SCLK_RX_DB, output MOSI_RX_DB, input MISO_RX_DB,
   output SEN_RX_DAC, output SCLK_RX_DAC, output MOSI_RX_DAC,
   output SEN_RX_ADC, output SCLK_RX_ADC, output MOSI_RX_ADC, input MISO_RX_ADC,

   // GigE PHY
   input CLK_TO_MAC,

   output reg [7:0] GMII_TXD,
   output reg GMII_TX_EN,
   output reg GMII_TX_ER,
   output GMII_GTX_CLK,
   input GMII_TX_CLK,  // 100mbps clk

   input GMII_RX_CLK,
   input [7:0] GMII_RXD,
   input GMII_RX_DV,
   input GMII_RX_ER,
   input GMII_COL,
   input GMII_CRS,

   input PHY_INTn,   // open drain
   inout MDIO,
   output MDC,
   output PHY_RESETn,
   output ETH_LED,

   // SRAM
   inout [17:0] RAM_D,
   output [18:0] RAM_A,
   output RAM_CE1n,
   output RAM_CENn,
   output RAM_WEn,
   output RAM_OEn,
   output RAM_LDn,
   inout RAM_CLK,
   
   // SPI Flash
   output flash_cs,
   //output flash_clk,
   output flash_mosi,
   input flash_miso
   );
	
	
	assign clk_reset = 1'b1;
	assign clk_sync = 1'b1;

   IBUFG gmii_rx_clk (.O(GMII_RX_CLK_buf), .I(GMII_RX_CLK));	
   IBUFG phyclk (.O(CLK_TO_MAC_int), .I(CLK_TO_MAC));
	
	     
   // FPGA-specific pins connections
   IBUFGDS clk_fpga_pin (.O(clk_fpga),.I(CLK_FPGA_P),.IB(CLK_FPGA_N));
   defparam 	clk_fpga_pin.IOSTANDARD = "LVDS";

   reg [5:0] 	clock_ready_d;	
   always @(posedge clk_fpga)
     clock_ready_d[5:0] <= {clock_ready_d[4:0],clock_ready};
   wire 	dcm_rst = ~&clock_ready_d & |clock_ready_d;

	reg phy_ready;
	initial phy_ready = 1'b0;
	
	always @(negedge PHY_RESETn)
		phy_ready = 1'b1;
	
	reg [5:0] 	phy_ready_d;	
   always @(posedge clk_fpga)
     phy_ready_d[5:0] <= {phy_ready_d[4:0],phy_ready};
   wire 	dcm2_rst = ~&phy_ready_d & |phy_ready_d;

// ADC A is inverted on the schematic to facilitate a clean layout
//  We account for that here by inverting it

   wire [15:0] 	adc_a, adc_b;
   capture_ddrlvds #(.WIDTH(16)) capture_ddrlvds
     (.clk(dsp_clk), .ssclk_p(ADC_clkout_p), .ssclk_n(ADC_clkout_n),
      .in_p({{ADCA[15], ADCA[13], ADCA[11], ADCA[9], ADCA[7], ADCA[5], ADCA[3], ADCA[1]},
	     {ADCB[15], ADCB[13], ADCB[11], ADCB[9], ADCB[7], ADCB[5], ADCB[3], ADCB[1]}}), 
      .in_n({{ADCA[14], ADCA[12], ADCA[10], ADCA[8], ADCA[6], ADCA[4], ADCA[2], ADCA[0]},
	     {ADCB[14], ADCB[12], ADCB[10], ADCB[8], ADCB[6], ADCB[4], ADCB[2], ADCB[0]}}),
		.adc_of_p(ADCB_OF), .adc_of_n(ADCA_OF),
      .out({adc_a,adc_b}), .adca_of(adc_ovf_a), .adcb_of(adc_ovf_b));	
	
   
   // Handle Clocks
	PLLE2_ADV
  #(.BANDWIDTH            ("HIGH"),
    .COMPENSATION         ("ZHOLD"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT        (12),
    .CLKFBOUT_PHASE       (0),
    .CLKOUT0_DIVIDE       (12),
    .CLKOUT0_PHASE        (270.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKIN1_PERIOD        (8.000),
    .REF_JITTER1          (0.010))
  PLLE2_ADV_INST_RAM
    // Output clocks
   (.CLKFBOUT            (CLK_TO_MAC_fbout),
    .CLKOUT0             (CLK_TO_RAM),
     // Input clock control
    .CLKFBIN             (CLK_TO_MAC_fbin),
    .CLKIN1              (CLK_TO_MAC_int),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
    .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DWE                 (1'b0),
    // Other control and status signals
	 .LOCKED              (LOCKED_125),
    .PWRDWN              (1'b0),
    .RST                 (dcm2_rst));
	
	BUFG phyclk_fb (.O(CLK_TO_MAC_fbin), .I(CLK_TO_MAC_fbout));
	BUFG ramclk (.O(CLK_TO_RAM_buf), .I(CLK_TO_RAM));	
	
	// Create clock for external SRAM			
	 ODDR #(
      .DDR_CLK_EDGE("SAME_EDGE"), // "OPPOSITE_EDGE" or "SAME_EDGE" 
      .INIT(1'b0),    // Initial value of Q: 1'b0 or 1'b1
      .SRTYPE("SYNC") // Set/Reset type: "SYNC" or "ASYNC" 
   ) RAM_CLK_i1 (
      .Q(RAM_CLK),   // 1-bit DDR output
      .C(CLK_TO_RAM_buf),   // 1-bit clock input		//125MHz
      .CE(1'b1), // 1-bit clock enable input
      .D1(1'b1), // 1-bit data input (positive edge)
      .D2(1'b0), // 1-bit data input (negative edge)
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );
	
	
	PLLE2_ADV
  #(.BANDWIDTH            ("HIGH"),
    .COMPENSATION         ("ZHOLD"),
    .DIVCLK_DIVIDE        (1),
    .CLKFBOUT_MULT        (16),
    .CLKFBOUT_PHASE       (0.000),
    .CLKOUT0_DIVIDE       (32),
    .CLKOUT0_PHASE        (0.000),
    .CLKOUT0_DUTY_CYCLE   (0.500),
    .CLKOUT1_DIVIDE       (32),
    .CLKOUT1_PHASE        (270.000),
    .CLKOUT1_DUTY_CYCLE   (0.500),
    .CLKIN1_PERIOD        (10.000),
    .REF_JITTER1          (0.010))
  PLLE2_ADV_INST1
    // Output clocks
   (.CLKFBOUT            (dcm_out),
    .CLKOUT0             (clk_div),
    .CLKOUT1             (clk_div_270),
     // Input clock control
    .CLKFBIN             (dsp_clk),
    .CLKIN1              (clk_fpga),
    .CLKIN2              (1'b0),
     // Tied to always select the primary input clock
	 .CLKINSEL            (1'b1),
    // Ports for dynamic reconfiguration
    .DADDR               (7'h0),
    .DCLK                (1'b0),
    .DEN                 (1'b0),
    .DI                  (16'h0),
    .DWE                 (1'b0),
    // Other control and status signals
    .LOCKED              (LOCKED_100),
    .PWRDWN              (1'b0),
    .RST                 (dcm_rst));
	 

   BUFG dspclk_BUFG (.I(dcm_out), .O(dsp_clk));
   BUFG wbclk_BUFG (.I(clk_div), .O(wb_clk));
   
  
   // I2C -- Don't use external transistors for open drain, the FPGA implements this
   IOBUF scl_pin(.O(scl_pad_i), .IO(SCL), .I(scl_pad_o), .T(scl_pad_oen_o));
   IOBUF sda_pin(.O(sda_pad_i), .IO(SDA), .I(sda_pad_o), .T(sda_pad_oen_o));

   // /////////////////////////////////////////////////////////////////////////
   //  LEDS
   //    In Rev3 there are only 6 leds, and the highest one is on the ETH connector
   wire [5:0] leds_int;
   assign     {ETH_LED,leds} = {leds_int[5],~leds_int[4:0]};	//active low escape ETH_LED
   
   // SPI
   wire       miso, mosi, sclk;
	

	
	wire		MISO_DAC, MOSI_DAC;
	wire        spi_tristate;
	
	IOBUF #(
      .DRIVE(4), // Specify the output drive strength
      .IBUF_LOW_PWR("FALSE"),  // Low Power - "TRUE", High Performance = "FALSE" 
      .IOSTANDARD("LVCMOS18"), // Specify the I/O standard
      .SLEW("FAST") // Specify the output slew rate
   ) IOBUF_DAC (
      .O(MISO_DAC),     // Buffer output
      .IO(MOSIO_DAC),   // Buffer inout port (connect directly to top-level port)
      .I(MOSI_DAC),     // Buffer input
      .T(spi_tristate)      // 3-state enable input, high=input, low=output
   );
   
   
   
   
   wire		MDO, MDI;
   wire     MDOEN;
   
   IOBUF #(
     .DRIVE(4), // Specify the output drive strength
     .IBUF_LOW_PWR("FALSE"),  // Low Power - "TRUE", High Performance = "FALSE" 
     .IOSTANDARD("LVCMOS33"), // Specify the I/O standard
     .SLEW("FAST") // Specify the output slew rate
  ) IOBUF_MDIO (
     .O(MDI),     // Buffer output
     .IO(MDIO),   // Buffer inout port (connect directly to top-level port)
     .I(MDO),     // Buffer input
     .T(~MDOEN)      // 3-state enable input, high=input, low=output
  );
	

   assign 	{SCLK_CLK,MOSI_CLK} 	   = ~SEN_CLK ? {sclk,mosi} : 2'B0;
   assign 	{SCLK_DAC,MOSI_DAC} 	   = ~SEN_DAC ? {sclk,mosi} : 2'B0;
   assign 	{SCLK_ADC,MOSI_ADC} 	   = ~SEN_ADC ? {sclk,mosi} : 2'B0;
   assign 	{SCLK_TX_DB,MOSI_TX_DB}    = ~SEN_TX_DB ? {sclk,mosi} : 2'B0;
   assign 	{SCLK_TX_DAC,MOSI_TX_DAC}  = ~SEN_TX_DAC ? {sclk,mosi} : 2'B0;
   assign 	{SCLK_TX_ADC,MOSI_TX_ADC}  = ~SEN_TX_ADC ? {sclk,mosi} : 2'B0;
   assign 	{SCLK_RX_DB,MOSI_RX_DB}    = ~SEN_RX_DB ? {sclk,mosi} : 2'B0;
   assign 	{SCLK_RX_DAC,MOSI_RX_DAC}  = ~SEN_RX_DAC ? {sclk,mosi} : 2'B0;
   assign 	{SCLK_RX_ADC,MOSI_RX_ADC}  = ~SEN_RX_ADC ? {sclk,mosi} : 2'B0;
   
   assign 	miso 			   =(~SEN_CLK & MISO_CLK) | (~SEN_DAC & MISO_DAC) |
					     (~SEN_TX_DB & MISO_TX_DB) | (~SEN_TX_ADC & MISO_TX_ADC) |
					     (~SEN_RX_DB & MISO_RX_DB) | (~SEN_RX_ADC & MISO_RX_ADC) | (~SEN_ADC & MISO_ADC);
   
   wire 	GMII_TX_EN_unreg, GMII_TX_ER_unreg;
   wire [7:0] 	GMII_TXD_unreg;
   wire 	GMII_GTX_CLK_int;
   
   always @(posedge GMII_GTX_CLK_int)
     begin
	GMII_TX_EN <= GMII_TX_EN_unreg;
	GMII_TX_ER <= GMII_TX_ER_unreg;
	GMII_TXD <= GMII_TXD_unreg;
     end

		
	ODDR ODDR_gmii_inst (
      .Q(GMII_GTX_CLK),   // 1-bit DDR output
      .C(GMII_GTX_CLK_int),   // 1-bit clock input
      .CE(1'b1), // 1-bit clock enable input
      .D1(1'b0), // 1-bit data input (positive edge)
      .D2(1'b1), // 1-bit data input (negative edge)
      .R(1'b0),   // 1-bit reset
      .S(1'b0)    // 1-bit set
   );

   //
   // Instantiate IO for Bidirectional bus to SRAM
   //
   wire [17:0] RAM_D_pi;
   wire [17:0] RAM_D_po;
   wire        RAM_D_poe;
   
   genvar      i;
   
   generate  
      for (i=0;i<18;i=i+1)
        begin : gen_RAM_D_IO

	   IOBUF #(
           .DRIVE(12),
           .IOSTANDARD("LVCMOS33"),
           .SLEW("FAST")
           ) RAM_D_i(
		      .O(RAM_D_pi[i]),
		      .I(RAM_D_po[i]),
		      .IO(RAM_D[i]),
		      .T(RAM_D_poe)
		      );
	end // block: gen_RAM_D_IO
   endgenerate

   
   
   wire [15:0] dac_a_int, dac_b_int;

	transmit_ddrlvds
	#(.WIDTH(16)) transmit_ddrlvds
		 (.daca(dac_b_int),					//inverted for routing
		 .dacb(dac_a_int),
		 .dac_p(DAC_p),
		 .dac_n(DAC_n),
		 .clk(dsp_clk),
		 .dci_p(DAC_DCI_p),
		 .dci_n(DAC_DCI_n),
		 .frame_p(DAC_FRAME_p),
		 .frame_n(DAC_FRAME_n)
		 );
		 
	assign DAC_IRQ1 = 1'b1;
	assign DAC_IRQ2 = 1'b1;
	assign DAC_TXEN = 1'b1;
	
	
   // STARTUPE2: STARTUP Block
   //            Artix-7
   // Xilinx HDL Language Template, version 14.7

   STARTUPE2 #(
      .PROG_USR("FALSE"),  // Activate program event security feature. Requires encrypted bitstreams.
      .SIM_CCLK_FREQ(0.0)  // Set the Configuration Clock Frequency(ns) for simulation.
   )
   STARTUPE2_inst (
      .CFGCLK(CFGCLK),       // 1-bit output: Configuration main clock output
      .CFGMCLK(CFGMCLK),     // 1-bit output: Configuration internal oscillator clock output
      .EOS(EOS),             // 1-bit output: Active high output signal indicating the End Of Startup.
      .PREQ(PREQ),           // 1-bit output: PROGRAM request to fabric output
      .CLK(1'b0),             // 1-bit input: User start-up clock input
      .GSR(1'b0),             // 1-bit input: Global Set/Reset input (GSR cannot be used for the port name)
      .GTS(1'b0),             // 1-bit input: Global 3-state input (GTS cannot be used for the port name)
      .KEYCLEARB(1'b0), // 1-bit input: Clear AES Decrypter Key input from Battery-Backed RAM (BBRAM)
      .PACK(1'b0),           // 1-bit input: PROGRAM acknowledge input
      .USRCCLKO(flash_clk),   // 1-bit input: User CCLK input
      .USRCCLKTS(1'b0), // 1-bit input: User CCLK 3-state enable input
      .USRDONEO(1'b1),   // 1-bit input: User DONE pin output control
      .USRDONETS(1'b0)  // 1-bit input: User DONE 3-state enable output
   );
   
   
   u2plus_core u2p_c(.dsp_clk (dsp_clk),
		     .wb_clk            (wb_clk),	     
		     .clock_ready       (clock_ready),
			 .clk_to_mac	(CLK_TO_MAC_fbin),
		     .pps_in		(PPS_IN),
		     .leds		(leds_int),
		     //.debug		(debug[31:0]),
		     //.debug_clk		(debug_clk[1:0]),
		     //.exp_time_in	(exp_time_in),
		     //.exp_time_out	(exp_time_out),
		     .GMII_COL		(GMII_COL),
		     .GMII_CRS		(GMII_CRS),
		     .GMII_TXD		(GMII_TXD_unreg[7:0]),
		     .GMII_TX_EN	(GMII_TX_EN_unreg),
		     .GMII_TX_ER	(GMII_TX_ER_unreg),
		     .GMII_GTX_CLK	(GMII_GTX_CLK_int),
		     .GMII_TX_CLK	(GMII_TX_CLK),
		     .GMII_RXD		(GMII_RXD[7:0]),
		     .GMII_RX_CLK	(GMII_RX_CLK_buf),
		     .GMII_RX_DV	(GMII_RX_DV),
		     .GMII_RX_ER	(GMII_RX_ER),
		     //.MDIO		(MDIO),
		     .MDC		(MDC),
		     .MDO(MDO),
		     .MDOEN(MDOEN),
		     .MDI(MDI),
		     .PHY_INTn		(PHY_INTn),
		     .PHY_RESETn	(PHY_RESETn),
		     .ser_enable	(),
		     .ser_prbsen	(),
		     .ser_loopen	(),
		     .ser_rx_en		(),
		     .ser_tx_clk	(),
		     .ser_t		(),
		     .ser_tklsb		(),
		     .ser_tkmsb		(),
		     .ser_rx_clk	(),
		     .ser_r		(),
		     .ser_rklsb		(),
		     .ser_rkmsb		(),
		     .adc_a		(adc_a),
		     .adc_ovf_a		(adc_ovf_a),
		     .adc_on_a		(),
		     .adc_oe_a		(),
		     .adc_b		(adc_b),
		     .adc_ovf_b		(adc_ovf_b),
		     .adc_on_b		(),
		     .adc_oe_b		(),
		     .dac_a		(dac_a_int),
		     .dac_b		(dac_b_int),
			  .DAC_RESETn	(DAC_RESETn),
		     .scl_pad_i		(scl_pad_i),
		     .scl_pad_o		(scl_pad_o),
		     .scl_pad_oen_o	(scl_pad_oen_o),
		     .sda_pad_i		(sda_pad_i),
		     .sda_pad_o		(sda_pad_o),
		     .sda_pad_oen_o	(sda_pad_oen_o),
		     .clk_en		(),
		     .clk_sel		(),
		     .clk_func		(),
		     .clk_status	(clk_status),
		     .sclk		(sclk),
		     .mosi		(mosi),
		     .miso		(miso),
		     .sen_clk		(SEN_CLK),
		     .sen_dac		(SEN_DAC),
		     .sen_adc           (SEN_ADC),
		     .sen_tx_db		(SEN_TX_DB),
		     .sen_tx_adc	(SEN_TX_ADC),
		     .sen_tx_dac	(SEN_TX_DAC),
		     .sen_rx_db		(SEN_RX_DB),
		     .sen_rx_adc	(SEN_RX_ADC),
		     .sen_rx_dac	(SEN_RX_DAC),
			  .spi_tristate(spi_tristate),
		     .io_tx		(io_tx[15:0]),		     
		     .io_rx		(io_rx[15:0]),
		     .RAM_D_po          (RAM_D_po),
		     .RAM_D_pi          (RAM_D_pi),
		     .RAM_D_poe         (RAM_D_poe),
		     .RAM_A             (RAM_A),
		     .RAM_CE1n          (RAM_CE1n),
		     .RAM_CENn          (RAM_CENn),
		     .RAM_WEn           (RAM_WEn),
		     .RAM_OEn           (RAM_OEn),
		     .RAM_LDn           (RAM_LDn), 
			  
			  // Debug stuff
		     .uart_tx_o         (TXD),
		     .uart_rx_i         ({3'b111,RXD}),
		     .uart_baud_o       (),
		     .sim_mode          (1'b0),
		     .clock_divider     (2),
			  
		     .button            (FPGA_RESET),
		     .spiflash_cs       (flash_cs),
		     .spiflash_clk      (flash_clk),
		     .spiflash_miso     (flash_miso),
		     .spiflash_mosi     (flash_mosi)
		     );

   // Drive low so that RAM does not sleep.
   //assign RAM_ZZ = 0;
   // Byte Writes are qualified by the global write enable
   // Always do 36bit operations to extram.
   //assign RAM_BWn = 4'b0000;
   
endmodule // u2plus
