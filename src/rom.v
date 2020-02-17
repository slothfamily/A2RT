`timescale 1ns / 1ps
`default_nettype none
////////////////////////////////////////////////////////////////////////////////
//
// Create Date: 19/12/2019 07:50:11 PM
// Module Name: rom
//
//
////////////////////////////////////////////////////////////////////////////////


module rom #(
    parameter ROM_WIDTH = 1,
    parameter ROM_ADDR_BITS = 14,
    parameter BLOCK_TYPE = "block",  // distributed | block
    parameter PATH = ""
)(
    input wire clk,
    input wire [ROM_ADDR_BITS-1:0] address,
    input wire enable,
    output reg [ROM_WIDTH-1:0] output_data
);

    (* rom_style="block" *)
    reg [ROM_WIDTH-1:0] ROM [(2**ROM_ADDR_BITS)-1:0];

    initial
       $readmemb(PATH, ROM, 0, (2**ROM_ADDR_BITS)-1);

    always @(posedge clk)
       if (enable)
          output_data <= ROM[address];

endmodule
`default_nettype wire
