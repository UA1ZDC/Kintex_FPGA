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
    parameter BASE = 0,
    //the dsp unit number: 0, 1, 2...
    parameter DSPNO = 0,
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

    //assign ddc_in_i = frontend_i;
    //assign ddc_in_q = frontend_q;
    //assign bb_sample = ddc_out_sample;
    //assign bb_strobe = ddc_out_strobe;
    assign ddc_out_enable = 1'b0;
    
 
    

    localparam  cwidth = 25;
    localparam  zwidth = 24;  
    
    wire ddc_enb;
    wire [31:0] phase_inc;
    reg [31:0]  phase;
 
    wire [17:0] scale_factor;
    wire [cwidth-1:0] i_cordic, q_cordic;
    wire [WIDTH-1:0] i_cordic_clip, q_cordic_clip;
    
    wire        strobe_cic, strobe_hb1, strobe_hb2;
    wire        enable_hb1, enable_hb2;
    wire [7:0]  cic_decim_rate;
    
    setting_reg #(.my_addr(BASE+0)) sr_0
      (.clk(clock),.rst(reset),.strobe(set_stb),.addr(set_addr),
       .in(set_data),.out(phase_inc),.changed());
 
    setting_reg #(.my_addr(BASE+1), .width(18)) sr_1
      (.clk(clock),.rst(reset),.strobe(set_stb),.addr(set_addr),
       .in(set_data),.out(scale_factor),.changed());
 
    setting_reg #(.my_addr(BASE+2), .width(10)) sr_2
      (.clk(clock),.rst(reset),.strobe(set_stb),.addr(set_addr),
       .in(set_data),.out({enable_hb1, enable_hb2, cic_decim_rate}),.changed());
 

 
    // NCO
    always @(posedge clock)
      if(reset)
        phase <= 0;
      else if(~enable)
        phase <= 0;
      else
        phase <= phase + phase_inc;
 
    //sign extension of cordic input
    wire [cwidth-1:0] to_cordic_i, to_cordic_q;
    sign_extend #(.bits_in(WIDTH), .bits_out(cwidth)) sign_extend_cordic_i (.in(frontend_i), .out(to_cordic_i));
    sign_extend #(.bits_in(WIDTH), .bits_out(cwidth)) sign_extend_cordic_q (.in(frontend_q), .out(to_cordic_q));
 
    // CORDIC  24-bit I/O
    cordic_z24 #(.bitwidth(cwidth))
      cordic(.clock(clock), .reset(reset), .enable(enable),
         .xi(to_cordic_i),. yi(to_cordic_q), .zi(phase[31:32-zwidth]),
         .xo(i_cordic),.yo(q_cordic),.zo() );
 
    clip_reg #(.bits_in(cwidth), .bits_out(WIDTH)) clip_i
      (.clk(clock), .in(i_cordic), .strobe_in(1'b1), .out(i_cordic_clip));
    clip_reg #(.bits_in(cwidth), .bits_out(WIDTH)) clip_q
      (.clk(clock), .in(q_cordic), .strobe_in(1'b1), .out(q_cordic_clip));
        
    
    
    Nyquist_FIR Nyquist_FIR_i (
        .aresetn(~reset),                        // input wire aresetn
        .aclk(clock),                              // input wire aclk
        .aclken(enable),                          // input wire aclken
        .s_axis_data_tvalid(1'b1),  // input wire s_axis_data_tvalid
        .s_axis_data_tready(),  // output wire s_axis_data_tready
        .s_axis_data_tdata(i_cordic_clip),    // input wire [23 : 0] s_axis_data_tdata
        .m_axis_data_tvalid(bb_strobe),  // output wire m_axis_data_tvalid
        .m_axis_data_tuser(),    // output wire [0 : 0] m_axis_data_tuser
        .m_axis_data_tdata(bb_sample[31:16])    // output wire [15 : 0] m_axis_data_tdata
      );
          
    Nyquist_FIR Nyquist_FIR_q (
          .aresetn(~reset),                        // input wire aresetn
          .aclk(clock),                              // input wire aclk
          .aclken(enable),                          // input wire aclken
          .s_axis_data_tvalid(1'b1),  // input wire s_axis_data_tvalid
          .s_axis_data_tready(),  // output wire s_axis_data_tready
          .s_axis_data_tdata(q_cordic_clip),    // input wire [23 : 0] s_axis_data_tdata
          .m_axis_data_tvalid(),  // output wire m_axis_data_tvalid
          .m_axis_data_tuser(),    // output wire [0 : 0] m_axis_data_tuser
          .m_axis_data_tdata(bb_sample[15:0])    // output wire [15 : 0] m_axis_data_tdata
      );  

/*    fractional_decimator fractional_decimator_i (
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
    );*/
    
    assign debug = 32'b0;

endmodule
