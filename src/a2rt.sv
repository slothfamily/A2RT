`timescale 1ns / 1ps
`default_nettype none
//////////////////////////////////////////////////////////////////////////////////
// Company: Buddies
// Engineer: Marco&Binaryman
//
// Create Date: 06/04/2019 07:50:11 PM
// Design Name:
// Module Name: a2rt
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
//
//
//
//////////////////////////////////////////////////////////////////////////////////


module a2rt #(
    parameter DATA_WIDTH = 24,
    parameter integer SCREEN_WIDTH = 800,
    parameter integer SCREEN_HEIGHT = 600
)
(
    // System signals
    input  wire clk,
    input  wire rst_n,

    // SLAVE SIDE

    // control signals
    output logic rtr_o, // ready_o
    input  wire rts_i,  // valid_i
    input  wire eow_i,  // last_i
    // data in
    input  wire [DATA_WIDTH-1:0] pixel_i,

    // MASTER SIDE

    // control signals
    input  wire rtr_i,  // ready_i
    output logic rts_o, // valid_o
    output logic eow_o, // last_o
    // data out
    output logic [DATA_WIDTH-1:0] pixel_o

);


// local parameters

localparam ASCII_WIDTH = 8;
localparam ASCII_HEIGHT = 16;
localparam NB_CHANNEL = 3;  // RGB
localparam CHANNEL_BIT_DEPTH = DATA_WIDTH / NB_CHANNEL;  // 8
localparam LOG_NB_ACCUM = $clog2(ASCII_WIDTH * ASCII_HEIGHT);  // 7
localparam BRAM_DEPTH = SCREEN_WIDTH / ASCII_WIDTH;  // 160
localparam BRAM_WIDTH = CHANNEL_BIT_DEPTH + LOG_NB_ACCUM;  // 15

localparam PATH_VGA_FONT = "/home/lledoux/Desktop/perso/A2RT/src/vga_ibm_font.mem";


// signals

// Page swapping BRAMs
logic [BRAM_WIDTH-1:0] avg_r_a [0:BRAM_DEPTH-1];
logic [BRAM_WIDTH-1:0] avg_g_a [0:BRAM_DEPTH-1];
logic [BRAM_WIDTH-1:0] avg_b_a [0:BRAM_DEPTH-1];
logic [BRAM_WIDTH-1:0] avg_r_b [0:BRAM_DEPTH-1];
logic [BRAM_WIDTH-1:0] avg_g_b [0:BRAM_DEPTH-1];
logic [BRAM_WIDTH-1:0] avg_b_b [0:BRAM_DEPTH-1];

// x pixel counter
logic [$clog2(SCREEN_WIDTH)-1:0] x_pixels_counter;

// y lines counter
logic [$clog2(ASCII_HEIGHT)-1:0] y_lines_counter;

// average address
logic [$clog2(BRAM_DEPTH)-1:0] avrg_addr;

// pointer to know which BRAM is used to accumulate
// 0 for BRAM A ; 1 for BRAM B
logic bram_pointer;

// reset an average in one of the BRAMs
logic avrg_clear;

// input colors
logic [CHANNEL_BIT_DEPTH-1:0] r_in;
logic [CHANNEL_BIT_DEPTH-1:0] g_in;
logic [CHANNEL_BIT_DEPTH-1:0] b_in;

// average
logic [BRAM_WIDTH-1:0] avg_r_out;
logic [BRAM_WIDTH-1:0] avg_g_out;
logic [BRAM_WIDTH-1:0] avg_b_out;

// selected char after average
logic [5:0] ramp_value;  // 48 char in the ramp so 6 bits
logic [7:0] selected_char;

// address of the pixel in VGA ROM
logic [13:0] pixel_address;

// pix monochrome selected after VGA LUT
logic pixel_out;


// logic

// x counter
// count from 0 to 1279 (SCREEN WIDTH)
always_ff @(posedge clk or negedge rst_n) begin
    if ( ~rst_n ) begin
        x_pixels_counter <= 0;
    end
    else if ( rts_i & rtr_i ) begin
        if ( eow_i | (x_pixels_counter >= SCREEN_WIDTH-1) )  begin
            x_pixels_counter <= 0;
        end
        else begin
            x_pixels_counter <= x_pixels_counter + 1;
        end
    end
end

// y counter
// count from 0 to 15 ( ASCII HEIGHT )
// count number of lines
// if ascii height we can swap brams
always_ff @(posedge clk or negedge rst_n) begin
    if ( ~rst_n ) begin
        y_lines_counter <= 0;
        bram_pointer <= 0;
    end
    else if ( rts_i & rtr_i ) begin
        if ( (x_pixels_counter >= SCREEN_WIDTH-1) ) begin
            if ( y_lines_counter >= ASCII_HEIGHT-1 ) begin  // reset lines when last pixel of last line
                y_lines_counter <= 0;
                bram_pointer <= ~bram_pointer;
            end
            else begin
                y_lines_counter <= y_lines_counter + 1;
            end
        end
    end
end

assign r_in = pixel_i[23:16];
assign g_in = pixel_i[15:8];
assign b_in = pixel_i[7:0];


assign avrg_clear = ((y_lines_counter[3:0] == 4'b0000)&&(x_pixels_counter[2:0] == 3'b000)) ? 1 : 0;

// avrg address
// we accumulate in the same address bitmap_width consecutively
assign avrg_addr = x_pixels_counter >> $clog2(ASCII_WIDTH);

// Average accumulation or clear
always_ff @( posedge clk ) begin
    if ( bram_pointer ) begin
        avg_r_a[avrg_addr] <= ((avrg_clear) ? {BRAM_WIDTH{1'b0}} : (avg_r_a[avrg_addr])) + r_in;
        avg_g_a[avrg_addr] <= ((avrg_clear) ? {BRAM_WIDTH{1'b0}} : (avg_g_a[avrg_addr])) + g_in;
        avg_b_a[avrg_addr] <= ((avrg_clear) ? {BRAM_WIDTH{1'b0}} : (avg_b_a[avrg_addr])) + b_in;
    end
    else begin
        avg_r_b[avrg_addr] <= ((avrg_clear) ? {BRAM_WIDTH{1'b0}} : (avg_r_b[avrg_addr])) + r_in;
        avg_g_b[avrg_addr] <= ((avrg_clear) ? {BRAM_WIDTH{1'b0}} : (avg_g_b[avrg_addr])) + g_in;
        avg_b_b[avrg_addr] <= ((avrg_clear) ? {BRAM_WIDTH{1'b0}} : (avg_b_b[avrg_addr])) + b_in;
    end
end
    
// color select
assign avg_r_out = bram_pointer ? avg_r_b[avrg_addr] : avg_r_a[avrg_addr];
assign avg_g_out = bram_pointer ? avg_g_b[avrg_addr] : avg_g_a[avrg_addr];
assign avg_b_out = bram_pointer ? avg_b_b[avrg_addr] : avg_b_a[avrg_addr];

// char selection by averaging color
// 3*max_value mapped into 48 char ramp is division by 2048
assign ramp_value = (avg_r_out + avg_g_out + avg_b_out) >> 11; 
ascii_lut ascii_lut_inst (
    .id        ( ramp_value    ),
    .character ( selected_char )
);

// verify adress
assign pixel_address = {selected_char[6:1], ~selected_char[0], y_lines_counter[3:0], ~x_pixels_counter[2:0]};

vga_ibm_font #(
   .PATH ( PATH_VGA_FONT )
) vga_ibm_font_inst (
    .clk         ( clk           ),
    .address     ( pixel_address ),
    .output_data ( pixel_out     )
);

// TODO
// - color part colorizer module
// - clean integration in BD

assign pixel_o = pixel_out? {DATA_WIDTH{1'b1}}: {DATA_WIDTH{1'b0}};
assign rtr_o = 1;
always_ff @(posedge clk or negedge rst_n) begin
    if (  ~rst_n ) begin
        rts_o <= 0;
        eow_o <= 0;
    end
    else begin
        rts_o <= rts_i;
        eow_o <= eow_i;
    end
end


endmodule
`default_nettype wire