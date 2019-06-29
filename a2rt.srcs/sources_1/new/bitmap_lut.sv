`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Buddies
// Engineer: Binaryman&Marco
// 
// Create Date: 06/28/2019 09:28:36 PM
// Module Name: bitmap_lut
// Description: 16K BRAM used as ROM/LUT for bitmap for a VGA 8*16 font
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module bitmap_lut (
    input  wire clk,
    input  wire [13:0] addr_in,
    output logic out
);

bitmap_vga_rom bitmap_vga_rom_inst (
    .clka  ( clk     ),
    .wea   ( 0       ),
    .addra ( addr_in ),
    .dina  ( 0       ),
    .douta ( out     )
 );

endmodule