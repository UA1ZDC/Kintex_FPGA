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


// Boot RAM for S3A, 8KB, dual port

// RAMB16BWE_S36_S36: 512 x 32 + 4 Parity bits byte-wide write Dual-Port RAM
//      Spartan-3A Xilinx HDL Libraries Guide, version 10.1.1

module bootram
  (input clk, input reset,
   input [13:0] if_adr,
   output [31:0] if_data,

   input [13:0] dwb_adr_i,
   input [31:0] dwb_dat_i,
   output [31:0] dwb_dat_o,
   input dwb_we_i,
   output reg dwb_ack_o,
   input dwb_stb_i,
   input [3:0] dwb_sel_i);

/*   wire [31:0] DOA0, DOA1, DOA2, DOA3;
   wire [31:0] DOB0, DOB1, DOB2, DOB3;
   wire        ENB0, ENB1, ENB2, ENB3;*/
   wire [3:0]  WEB;

/*   reg [1:0]   delayed_if_bank;
   always @(posedge clk)
     delayed_if_bank <= if_adr[13:12];
   
   assign if_data = delayed_if_bank[1] ?
						  (delayed_if_bank[0] ?  DOA3 : DOA2)
						: (delayed_if_bank[0] ?  DOA1 : DOA0);
   
   
   assign dwb_dat_o = dwb_adr_i[13] ?
                    (dwb_adr_i[12] ?  DOB3 : DOB2)
						: (dwb_adr_i[12] ?  DOB1 : DOB0);*/

   always @(posedge clk)
     if(reset)
       dwb_ack_o <= 0;
     else
       dwb_ack_o <= dwb_stb_i & ~dwb_ack_o;
   
/*   assign ENB0 = dwb_stb_i & (dwb_adr_i[13:12] == 3'b00);
   assign ENB1 = dwb_stb_i & (dwb_adr_i[13:12] == 3'b01);
   assign ENB2 = dwb_stb_i & (dwb_adr_i[13:12] == 3'b10);
   assign ENB3 = dwb_stb_i & (dwb_adr_i[13:12] == 3'b11);*/

   assign WEB = {4{dwb_we_i}} & dwb_sel_i;
		
    RAM RAM0 (
     .clka(clk),    // input wire clka
     .wea(1'b0),      // input wire [0 : 0] wea
     .addra(if_adr[13:2]),  // input wire [11 : 0] addra
     .dina(32'hffffffff),    // input wire [35 : 0] dina
     .douta(if_data),  // output wire [35 : 0] douta
     .clkb(clk),    // input wire clkb
     .web(WEB),      // input wire [0 : 0] web
     .addrb(dwb_adr_i[13:2]),  // input wire [11 : 0] addrb
     .dinb(dwb_dat_i),    // input wire [35 : 0] dinb
     .doutb(dwb_dat_o)  // output wire [35 : 0] doutb
   );
		
		
		
/*		BRAM_TDP_MACRO #(
      .BRAM_SIZE("36Kb"), // Target BRAM: "18Kb" or "36Kb" 
      .DEVICE("7SERIES"), // Target device: "VIRTEX5", "VIRTEX6", "SPARTAN6", "7SERIES" 
      .DOA_REG(0),        // Optional port A output register (0 or 1)
      .DOB_REG(0),        // Optional port B output register (0 or 1)
      .INIT_A(36'h0000000),  // Initial values on port A output port
      .INIT_B(36'h00000000), // Initial values on port B output port
      .INIT_FILE ("NONE"),
      .READ_WIDTH_A (36),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      .READ_WIDTH_B (36),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      .SIM_COLLISION_CHECK ("ALL"), // Collision check enable "ALL", "WARNING_ONLY", 
                                    //   "GENERATE_X_ONLY" or "NONE" 
      .SRVAL_A(36'h00000000), // Set/Reset value for port A output
      .SRVAL_B(36'h00000000), // Set/Reset value for port B output
      .WRITE_MODE_A("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
      .WRITE_MODE_B("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
      .WRITE_WIDTH_A(36), // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      .WRITE_WIDTH_B(36) // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      )
		RAM0 (
      .DOA(DOA0),       // Output port-A data, width defined by READ_WIDTH_A parameter
      .DOB(DOB0),       // Output port-B data, width defined by READ_WIDTH_B parameter
      .ADDRA(if_adr[11:2]),   // Input port-A address, width defined by Port A depth
      .ADDRB(dwb_adr_i[11:2]),   // Input port-B address, width defined by Port B depth
      .CLKA(clk),     // 1-bit input port-A clock
      .CLKB(clk),     // 1-bit input port-B clock
      .DIA(32'hffffffff),       // Input port-A data, width defined by WRITE_WIDTH_A parameter
      .DIB(dwb_dat_i),       // Input port-B data, width defined by WRITE_WIDTH_B parameter
      .ENA(1'b1),       // 1-bit input port-A enable
      .ENB(ENB0),       // 1-bit input port-B enable
      .REGCEA(1'b0), // 1-bit input port-A output register enable
      .REGCEB(1'b0), // 1-bit input port-B output register enable
      .RSTA(1'b0),     // 1-bit input port-A reset
      .RSTB(1'b0),     // 1-bit input port-B reset
      .WEA(4'b0000),       // Input port-A write enable, width defined by Port A depth
      .WEB(WEB)        // Input port-B write enable, width defined by Port B depth
   );

		BRAM_TDP_MACRO #(
      .BRAM_SIZE("36Kb"), // Target BRAM: "18Kb" or "36Kb" 
      .DEVICE("7SERIES"), // Target device: "VIRTEX5", "VIRTEX6", "SPARTAN6", "7SERIES" 
      .DOA_REG(0),        // Optional port A output register (0 or 1)
      .DOB_REG(0),        // Optional port B output register (0 or 1)
      .INIT_A(36'h0000000),  // Initial values on port A output port
      .INIT_B(36'h00000000), // Initial values on port B output port
      .INIT_FILE ("NONE"),
      .READ_WIDTH_A (36),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      .READ_WIDTH_B (36),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      .SIM_COLLISION_CHECK ("ALL"), // Collision check enable "ALL", "WARNING_ONLY", 
                                    //   "GENERATE_X_ONLY" or "NONE" 
      .SRVAL_A(36'h00000000), // Set/Reset value for port A output
      .SRVAL_B(36'h00000000), // Set/Reset value for port B output
      .WRITE_MODE_A("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
      .WRITE_MODE_B("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
      .WRITE_WIDTH_A(36), // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      .WRITE_WIDTH_B(36) // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      )
		RAM1 (
      .DOA(DOA1),       // Output port-A data, width defined by READ_WIDTH_A parameter
      .DOB(DOB1),       // Output port-B data, width defined by READ_WIDTH_B parameter
      .ADDRA(if_adr[11:2]),   // Input port-A address, width defined by Port A depth
      .ADDRB(dwb_adr_i[11:2]),   // Input port-B address, width defined by Port B depth
      .CLKA(clk),     // 1-bit input port-A clock
      .CLKB(clk),     // 1-bit input port-B clock
      .DIA(32'hffffffff),       // Input port-A data, width defined by WRITE_WIDTH_A parameter
      .DIB(dwb_dat_i),       // Input port-B data, width defined by WRITE_WIDTH_B parameter
      .ENA(1'b1),       // 1-bit input port-A enable
      .ENB(ENB1),       // 1-bit input port-B enable
      .REGCEA(1'b0), // 1-bit input port-A output register enable
      .REGCEB(1'b0), // 1-bit input port-B output register enable
      .RSTA(1'b0),     // 1-bit input port-A reset
      .RSTB(1'b0),     // 1-bit input port-B reset
      .WEA(4'b0000),       // Input port-A write enable, width defined by Port A depth
      .WEB(WEB)        // Input port-B write enable, width defined by Port B depth
   );

		BRAM_TDP_MACRO #(
      .BRAM_SIZE("36Kb"), // Target BRAM: "18Kb" or "36Kb" 
      .DEVICE("7SERIES"), // Target device: "VIRTEX5", "VIRTEX6", "SPARTAN6", "7SERIES" 
      .DOA_REG(0),        // Optional port A output register (0 or 1)
      .DOB_REG(0),        // Optional port B output register (0 or 1)
      .INIT_A(36'h0000000),  // Initial values on port A output port
      .INIT_B(36'h00000000), // Initial values on port B output port
      .INIT_FILE ("NONE"),
      .READ_WIDTH_A (36),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      .READ_WIDTH_B (36),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      .SIM_COLLISION_CHECK ("ALL"), // Collision check enable "ALL", "WARNING_ONLY", 
                                    //   "GENERATE_X_ONLY" or "NONE" 
      .SRVAL_A(36'h00000000), // Set/Reset value for port A output
      .SRVAL_B(36'h00000000), // Set/Reset value for port B output
      .WRITE_MODE_A("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
      .WRITE_MODE_B("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
      .WRITE_WIDTH_A(36), // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      .WRITE_WIDTH_B(36) // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      )
		RAM2 (
      .DOA(DOA2),       // Output port-A data, width defined by READ_WIDTH_A parameter
      .DOB(DOB2),       // Output port-B data, width defined by READ_WIDTH_B parameter
      .ADDRA(if_adr[11:2]),   // Input port-A address, width defined by Port A depth
      .ADDRB(dwb_adr_i[11:2]),   // Input port-B address, width defined by Port B depth
      .CLKA(clk),     // 1-bit input port-A clock
      .CLKB(clk),     // 1-bit input port-B clock
      .DIA(32'hffffffff),       // Input port-A data, width defined by WRITE_WIDTH_A parameter
      .DIB(dwb_dat_i),       // Input port-B data, width defined by WRITE_WIDTH_B parameter
      .ENA(1'b1),       // 1-bit input port-A enable
      .ENB(ENB2),       // 1-bit input port-B enable
      .REGCEA(1'b0), // 1-bit input port-A output register enable
      .REGCEB(1'b0), // 1-bit input port-B output register enable
      .RSTA(1'b0),     // 1-bit input port-A reset
      .RSTB(1'b0),     // 1-bit input port-B reset
      .WEA(4'b0000),       // Input port-A write enable, width defined by Port A depth
      .WEB(WEB)        // Input port-B write enable, width defined by Port B depth
   );
				
		BRAM_TDP_MACRO #(
      .BRAM_SIZE("36Kb"), // Target BRAM: "18Kb" or "36Kb" 
      .DEVICE("7SERIES"), // Target device: "VIRTEX5", "VIRTEX6", "SPARTAN6", "7SERIES" 
      .DOA_REG(0),        // Optional port A output register (0 or 1)
      .DOB_REG(0),        // Optional port B output register (0 or 1)
      .INIT_A(36'h0000000),  // Initial values on port A output port
      .INIT_B(36'h00000000), // Initial values on port B output port
      .INIT_FILE ("NONE"),
      .READ_WIDTH_A (36),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      .READ_WIDTH_B (36),   // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      .SIM_COLLISION_CHECK ("ALL"), // Collision check enable "ALL", "WARNING_ONLY", 
                                    //   "GENERATE_X_ONLY" or "NONE" 
      .SRVAL_A(36'h00000000), // Set/Reset value for port A output
      .SRVAL_B(36'h00000000), // Set/Reset value for port B output
      .WRITE_MODE_A("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
      .WRITE_MODE_B("WRITE_FIRST"), // "WRITE_FIRST", "READ_FIRST", or "NO_CHANGE" 
      .WRITE_WIDTH_A(36), // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      .WRITE_WIDTH_B(36) // Valid values are 1-36 (19-36 only valid when BRAM_SIZE="36Kb")
      )
		RAM3 (
      .DOA(DOA3),       // Output port-A data, width defined by READ_WIDTH_A parameter
      .DOB(DOB3),       // Output port-B data, width defined by READ_WIDTH_B parameter
      .ADDRA(if_adr[11:2]),   // Input port-A address, width defined by Port A depth
      .ADDRB(dwb_adr_i[11:2]),   // Input port-B address, width defined by Port B depth
      .CLKA(clk),     // 1-bit input port-A clock
      .CLKB(clk),     // 1-bit input port-B clock
      .DIA(32'hffffffff),       // Input port-A data, width defined by WRITE_WIDTH_A parameter
      .DIB(dwb_dat_i),       // Input port-B data, width defined by WRITE_WIDTH_B parameter
      .ENA(1'b1),       // 1-bit input port-A enable
      .ENB(ENB3),       // 1-bit input port-B enable
      .REGCEA(1'b0), // 1-bit input port-A output register enable
      .REGCEB(1'b0), // 1-bit input port-B output register enable
      .RSTA(1'b0),     // 1-bit input port-A reset
      .RSTB(1'b0),     // 1-bit input port-B reset
      .WEA(4'b0000),       // Input port-A write enable, width defined by Port A depth
      .WEB(WEB)        // Input port-B write enable, width defined by Port B depth
   );*/

endmodule // bootram
