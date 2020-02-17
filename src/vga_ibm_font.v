`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////////////////
//
// Create Date: 19/12/2019 07:55:10 PM
// Module Name: vga_ibm_font
//
// Description:
//
// 128 characters (the first half of IBM font, normally 256)
// 8 width
// 16 height
// W&B
// 128*8*16*1b = 16384 (fits in 1 18k_BRAM)
//
////////////////////////////////////////////////////////////////////////////////

module vga_ibm_font #(
    parameter PATH = ""
)(
    input wire clk,
    input wire [13:0] address,
    output wire output_data
);

    rom #(
        .ROM_WIDTH     ( 1       ),
        .ROM_ADDR_BITS ( 14      ),
        .BLOCK_TYPE    ( "block" ),  // distributed | block
        .PATH          ( PATH    )
    ) vga_rom_inst (
        .clk         ( clk         ),
        .address     ( address     ),
        .enable      ( 1'b1        ),
        .output_data ( output_data )
    );

endmodule
`default_nettype wire
