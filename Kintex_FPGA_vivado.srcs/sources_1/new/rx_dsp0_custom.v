`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 01.10.2018 17:14:42
// Design Name: 
// Module Name: rx_dsp0_custom
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module rx_dsp0_custom
#(
    //frontend bus width
    parameter WIDTH = 24
)
(
    //control signals
    input clock, input reset, input clear, input enable,

    //user settings bus, controlled through user setting regs API
    input set_stb, input [7:0] set_addr, input [31:0] set_data,

    //full rate inputs directly from the RX frontend
    input [WIDTH-1:0] frontend_i,
    input [WIDTH-1:0] frontend_q,

    //full rate outputs directly to the DDC chain
    output [WIDTH-1:0] ddc_in_i,
    output [WIDTH-1:0] ddc_in_q,

    //strobed samples {I16,Q16} from the RX DDC chain
    input [31:0] ddc_out_sample,
    input ddc_out_strobe, //high on valid sample
    output ddc_out_enable, //enables DDC module

    //strobbed baseband samples {I16,Q16} from this module
    output [31:0] bb_sample,
    output bb_strobe, //high on valid sample

    //debug output (optional)
    output [31:0] debug
);

    assign ddc_in_i = frontend_i;
    assign ddc_in_q = frontend_q;
    //assign bb_sample = ddc_out_sample;
    //assign bb_strobe = ddc_out_strobe;
    assign ddc_out_enable = enable;

    fractional_decimator fractional_decimator_i (
      .aresetn(~reset),                        // input wire aresetn
      .aclk(clock),                              // input wire aclk
      .aclken(enable),                          // input wire aclken
      .s_axis_data_tvalid(ddc_out_strobe),  // input wire s_axis_data_tvalid
      .s_axis_data_tready(),  // output wire s_axis_data_tready
      .s_axis_data_tdata(ddc_out_sample[31:16]),    // input wire [31 : 0] s_axis_data_tdata
      .m_axis_data_tvalid(bb_strobe),  // output wire m_axis_data_tvalid
      .m_axis_data_tdata(bb_sample[31:16])    // output wire [31 : 0] m_axis_data_tdata
    );
    
    fractional_decimator fractional_decimator_q (
      .aresetn(~reset),                        // input wire aresetn
      .aclk(clock),                              // input wire aclk
      .aclken(enable),                          // input wire aclken
      .s_axis_data_tvalid(ddc_out_strobe),  // input wire s_axis_data_tvalid
      .s_axis_data_tready(),  // output wire s_axis_data_tready
      .s_axis_data_tdata(ddc_out_sample[15:0]),    // input wire [31 : 0] s_axis_data_tdata
      .m_axis_data_tvalid(),  // output wire m_axis_data_tvalid
      .m_axis_data_tdata(bb_sample[15:0])    // output wire [31 : 0] m_axis_data_tdata
    );
    
    assign debug = 32'b0;

endmodule
