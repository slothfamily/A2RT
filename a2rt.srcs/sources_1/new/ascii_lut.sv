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
    output logic [7:0] char
);
    
    always@(*) begin
        char = 8'h00;
        case (id)
            6'd00: char = " ";
            6'd01: char = ".";
            6'd02: char = "`";
            6'd03: char = "-";
            6'd04: char = ",";
            6'd05: char = ":";
            6'd06: char = ";";
            6'd07: char = "~";
            6'd08: char = "+";
            6'd09: char = "/";
            6'd10: char = "=";
            6'd11: char = ">";
            6'd12: char = "|";
            6'd13: char = "(";
            6'd14: char = ")";
            6'd15: char = "\\";
            6'd16: char = "i";
            6'd17: char = "%";
            6'd18: char = "{";
            6'd19: char = "*";
            6'd20: char = "s";
            6'd21: char = "v";
            6'd22: char = "7";
            6'd23: char = "a";
            6'd24: char = "e";
            6'd25: char = "C";
            6'd26: char = "J";
            6'd27: char = "L";
            6'd28: char = "T";
            6'd29: char = "Y";
            6'd30: char = "w";
            6'd31: char = "F";
            6'd32: char = "9";
            6'd33: char = "V";
            6'd34: char = "G";
            6'd35: char = "X";
            6'd36: char = "A";
            6'd37: char = "E";
            6'd38: char = "$";
            6'd39: char = "&";
            6'd40: char = "#";
            6'd41: char = "@";
            6'd42: char = "R";
            6'd43: char = "W";
            6'd44: char = "0";
            6'd45: char = "N";
            6'd46: char = "M";
            6'd47: char = "Q";
        endcase
    end
    
endmodule
`default_nettype wire