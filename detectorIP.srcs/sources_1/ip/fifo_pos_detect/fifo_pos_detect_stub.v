// Copyright 1986-2016 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2016.4 (win64) Build 1733598 Wed Dec 14 22:35:39 MST 2016
// Date        : Fri Jun 23 16:54:10 2017
// Host        : DESKTOP-BL87T2D running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               D:/workspace/IP/Detector/detectorIP/detectorIP.srcs/sources_1/ip/fifo_pos_detect/fifo_pos_detect_stub.v
// Design      : fifo_pos_detect
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg484-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "fifo_generator_v13_1_3,Vivado 2016.4" *)
module fifo_pos_detect(clk, din, wr_en, rd_en, dout, full, empty)
/* synthesis syn_black_box black_box_pad_pin="clk,din[35:0],wr_en,rd_en,dout[35:0],full,empty" */;
  input clk;
  input [35:0]din;
  input wr_en;
  input rd_en;
  output [35:0]dout;
  output full;
  output empty;
endmodule
