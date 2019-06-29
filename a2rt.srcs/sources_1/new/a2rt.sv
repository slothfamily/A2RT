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
//
//
//
//
//
//
//////////////////////////////////////////////////////////////////////////////////


module a2rt #(
    parameter DATA_WIDTH = 24
)
(
    // System signals
    input  wire clk,
    input  wire rst_n,

    // SLAVE SIDE

    // control signals
    output logic rtr_o, // ready_o
    input  wire rts_i, // valid_i
    input  wire sow_i, // first_i
    input  wire eow_i, // last_i
    // data in
    input  wire [DATA_WIDTH-1:0] pixel_i,

    // MASTER SIDE

    // control signals
    input  wire rtr_i, // ready_i
    output logic rts_o, // valid_o
    output logic sow_o, // first_o
    output logic eow_o, // last_o
    // data out
    output logic [DATA_WIDTH-1:0] pixel_o

);


// local parameters
localparam SCREEN_WIDTH = 1280;  // 16:9
localparam SCRENN_HEIGHT = 720;  // 720p
localparam ASCII_WIDTH = 8;
localparam ASCII_HEIGHT = 16;
localparam NB_CHANNEL = 3;  // RGB
localparam CHANNEL_BIT_DEPTH = DATA_WIDTH / NB_CHANNEL;  // 8
localparam LOG_NB_ACCUM = $clog2(ASCII_WIDTH * ASCII_HEIGHT);  // 7
localparam BRAM_DEPTH = SCREEN_WIDTH / ASCII_WIDTH;  // 160
localparam BRAM_WIDTH = CHANNEL_BIT_DEPTH + LOG_NB_ACCUM;  // 15

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
logic swap;
logic bram_pointer;

// selected char after average
logic [7:0] selected_char;

// pix monochrome selected after VGA LUT
logic pix_out;


// logic

// avrg address
assign avrg_addr = x_pixels_counter >> $clog2(ASCII_WIDTH);

// x counter
// count from 0 to 1279 (SCREEN WIDTH)
always_ff @(posedge clk or negedge rst_n) begin
    if ( ~rst_n ) begin
        x_pixels_counter <= 0;
    end
    else if ( rts_i & rtr_i ) begin
        if ( sow_i ) begin
            x_pixels_counter <= 1;
        end
        else if ( eow_i | (x_pixels_counter >= SCREEN_WIDTH-1) )  begin
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
        swap <= 0;
    end
    else if ( rts_i & rtr_i ) begin
        if ( (x_pixels_counter >= SCREEN_WIDTH-1) ) begin
            if ( y_lines_counter >= ASCII_HEIGHT-1 ) begin  // reset lines when last pixel of last line
                y_lines_counter <= 0;
                swap <= 1;
            end
            else begin
                swap <= 0;
                y_lines_counter <= y_lines_counter + 1;
            end
        end
    end
end


// bram pointer
always_comb begin
    if ( swap ) begin
        bram_pointer <= ~bram_pointer;
    end
end


// Average accumulation

ascii_lut ascii_lut_inst (
    .id   ( ),
    .char ( selected_char )
);

bitmap_lut bitmap_lut_inst (
    .clk     (         ),
    .addr_in (         ),
    .out     ( pix_out )  // W&B
); 

assign rtr_o = 1;


endmodule
`default_nettype wire