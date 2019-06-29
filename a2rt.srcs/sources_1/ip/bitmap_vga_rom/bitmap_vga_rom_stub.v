// Copyright 1986-2018 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2018.3 (lin64) Build 2405991 Thu Dec  6 23:36:41 MST 2018
// Date        : Fri Jun 28 21:27:20 2019
// Host        : 0xCAFEBABE running 64-bit unknown
// Command     : write_verilog -force -mode synth_stub
//               /home/binaryman/Documents/fpga/pynq/a2rt/a2rt.srcs/sources_1/ip/bitmap_vga_rom/bitmap_vga_rom_stub.v
// Design      : bitmap_vga_rom
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7z020clg400-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* x_core_info = "blk_mem_gen_v8_4_2,Vivado 2018.3" *)
module bitmap_vga_rom(clka, wea, addra, dina, douta)
/* synthesis syn_black_box black_box_pad_pin="clka,wea[0:0],addra[13:0],dina[0:0],douta[0:0]" */;
  input clka;
  input [0:0]wea;
  input [13:0]addra;
  input [0:0]dina;
  output [0:0]douta;
endmodule
