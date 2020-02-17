`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: Buddies
// Engineer: Marco&Binaryman
// 
// Create Date: 06/13/2019 10:19:49 PM
// Design Name: 
// Module Name: ascii_lut
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// taken from : 
//   https://github.com/zephray/vga_to_ascii/blob/master/vga_input/ascii_lut.v
// 
//////////////////////////////////////////////////////////////////////////////////


module ascii_lut
(
    input  wire [5:0] id,
    output logic [7:0] character
);
    
    always@(*) begin
        character = 8'h00;
        case (id)
            6'd00: character = " ";
            6'd01: character = ".";
            6'd02: character = "`";
            6'd03: character = "-";
            6'd04: character = ",";
            6'd05: character = ":";
            6'd06: character = ";";
            6'd07: character = "~";
            6'd08: character = "+";
            6'd09: character = "/";
            6'd10: character = "=";
            6'd11: character = ">";
            6'd12: character = "|";
            6'd13: character = "(";
            6'd14: character = ")";
            6'd15: character = "\\";
            6'd16: character = "i";
            6'd17: character = "%";
            6'd18: character = "{";
            6'd19: character = "*";
            6'd20: character = "s";
            6'd21: character = "v";
            6'd22: character = "7";
            6'd23: character = "a";
            6'd24: character = "e";
            6'd25: character = "C";
            6'd26: character = "J";
            6'd27: character = "L";
            6'd28: character = "T";
            6'd29: character = "Y";
            6'd30: character = "w";
            6'd31: character = "F";
            6'd32: character = "9";
            6'd33: character = "V";
            6'd34: character = "G";
            6'd35: character = "X";
            6'd36: character = "A";
            6'd37: character = "E";
            6'd38: character = "$";
            6'd39: character = "&";
            6'd40: character = "#";
            6'd41: character = "@";
            6'd42: character = "R";
            6'd43: character = "W";
            6'd44: character = "0";
            6'd45: character = "N";
            6'd46: character = "M";
            6'd47: character = "Q";
        endcase
    end

endmodule
`default_nettype wire
