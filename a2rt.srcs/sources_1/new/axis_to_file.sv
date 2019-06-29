`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer:
//
// Create Date: 06/07/2019 09:37:10 PM
// Design Name:
// Module Name: axis_to_file
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


module axis_to_file #(
    parameter DATA_WIDTH = 32
)
(
    // System
    input logic clk,
    input logic rst_n,

    // Slave
    input logic rts_i,
    input logic sow_i,
    input logic eow_i,
    output logic rtr_o,
    input logic [DATA_WIDTH-1:0] data_i
);



endmodule
