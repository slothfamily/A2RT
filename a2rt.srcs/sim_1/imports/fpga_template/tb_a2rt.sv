////////////////////////////////////////////////////////////////////////////////
//
// Company: Buddies
// Author: Marco&Binaryman
//
// Create Date: 04/06/2019
// Module Name: tb_a2rt
// Description:
//     test bench for a2rt project
//
////////////////////////////////////////////////////////////////////////////////

module tb_a2rt();

    parameter CLK_PERIOD      = 2;
    parameter CLK_HALF_PERIOD = CLK_PERIOD / 2;

    localparam integer DATA_WIDTH = 24;
    localparam integer PIC_WIDTH  = 1280;
    localparam integer PIC_HEIGHT = 720;
    localparam integer NB_DATA = PIC_WIDTH * PIC_HEIGHT;
    localparam  INPUT_BASE_PATH = "/home/binaryman/Documents/fpga/pynq/a2rt/a2rt.srcs/sim_1/imports/fpga_template/";
    localparam  INPUT_PATH = "input_pic.raw";
    localparam  OUTPUT_BASE_PATH = INPUT_BASE_PATH;
    localparam  OUTPUT_PATH = "output_pic.raw";
    localparam  t = {OUTPUT_BASE_PATH, OUTPUT_PATH};
    localparam  READ_B_OR_H = "H";

    logic [31:0] FD; // file descriptor of 32 bits

    // write to file
    //initial write_file = $fopen(t, "w");



    //----------------------------------------------------------------
    // Signals, clocks, and reset
    //----------------------------------------------------------------

    logic tb_clk;
    logic tb_reset_n;

    // file (picture) read
    logic s_axis_in_aclk;
    logic s_axis_in_tready;
    logic s_axis_in_aresetn;
    logic s_axis_in_tvalid;
    logic [DATA_WIDTH-1:0] s_axis_in_tdata;
    logic [(DATA_WIDTH/8)-1:0] s_axis_in_tstrb;
    logic s_axis_in_tlast;
    logic sow_i;

    // output (picture) ascii out
    logic a2rt_rts_o;
    logic a2rt_eow_o;
    logic a2rt_sow_o;
    logic [DATA_WIDTH-1:0] a2rt_pixel_o;

    // read from file
    axi_stream_generator_from_file #
    (
        .WIDTH       ( DATA_WIDTH           ),
        .base_path   ( INPUT_BASE_PATH      ),
        .path        ( INPUT_PATH           ),
        .nb_data     ( NB_DATA              ),
        .READ_B_OR_H ( READ_B_OR_H          )
    )
    axi_stream_generator_inst
    (

       .rst_n         ( tb_reset_n       ),
       // Starts an axi_stream transaction
       .start         ( s_axis_in_tready ),

       // axi stream ports
       .m_axis_clk    ( tb_clk           ),
       .m_axis_tvalid ( s_axis_in_tvalid ),
       .m_axis_tdata  ( s_axis_in_tdata  ),
       .m_axis_tstrb  ( s_axis_in_tstrb  ),
       .m_axis_tlast  ( s_axis_in_tlast  )
    );

    // logic for sow
    logic s_axis_in_tvalid_r;
    always_ff @(posedge tb_clk or negedge tb_reset_n) begin
        if ( ~tb_reset_n ) begin
            s_axis_in_tvalid_r <= 0;
        end
        else begin
            s_axis_in_tvalid_r <= s_axis_in_tvalid;
        end
    end
    assign sow_i = s_axis_in_tvalid & ~s_axis_in_tvalid_r;


    // INSTANCIATE DUT
    a2rt #(
        .DATA_WIDTH ( DATA_WIDTH )
    ) a2rt_inst (
        // System signals
        .clk     ( tb_clk     ),
        .rst_n   ( tb_reset_n ),

        // SLAVE SIDE

        // control signals
        .rtr_o   ( s_axis_in_tready ),
        .rts_i   ( s_axis_in_tvalid ),
        .sow_i   ( sow_i            ),
        .eow_i   ( s_axis_in_tlast  ),
        // data in
        .pixel_i ( s_axis_in_tdata  ),

        // MASTER SIDE

        // control signals
        .rtr_i   ( 1                ),  // no downstream module, simulate always ready to accept data
        .rts_o   ( a2rt_rts_o       ),
        .sow_o   ( a2rt_sow_o       ),
        .eow_o   ( a2rt_eow_o       ),
        // data out
        .pixel_o ( a2rt_pixel_o     )
    );

    logic [128:0] buffer = 0;
//    initial begin
//        FD = $fopen(t, "wb");
//        if (!FD)
//            $display("Could not open %s", t);
//        else begin
//            $display(FD, "Result is: %4b", FD);
//            $fdisplay(FD, "%u", buffer);
//            $fclose(FD);
//        end
//    end

initial begin
    $dumpfile(t);
    #100;
    $dumpvars(buffer);
end




    //----------------------------------------------------------------
    // writing in a file
    //
    // WIP, experiment
    //----------------------------------------------------------------

    // initial begin
    //     f = $fopen("output.txt","w");

    //     //@(negedge reset); //Wait for reset to be released
    //     //@(posedge clk);   //Wait for fisrt clock out of reset

    //     for (i = 0; i<14; i=i+1) begin
    //     @(posedge clk);
    //     lfsr[i] <= out;
    //     $display("LFSR %b", out);
    //     $fwrite(f,"%b\n",   out);
    // end

    // $fclose(f);

    //----------------------------------------------------------------
    // clk_gen
    //
    // Always running clock generator process.
    //----------------------------------------------------------------

    initial tb_clk = 0;
    always #CLK_HALF_PERIOD tb_clk = !tb_clk;

    //----------------------------------------------------------------
    // reset_dut()
    //
    // Toggle reset to put the DUT into a well known state.
    //----------------------------------------------------------------
    task reset_dut;
        begin
            $display("*** Toggle reset.");
            tb_reset_n = 0;
            #(100 * CLK_PERIOD);
            tb_reset_n = 1;
        end
    endtask // reset_dut

    //----------------------------------------------------------------
    // init_sim()
    //
    // All the init part
    //----------------------------------------------------------------
    task init_sim;
        begin
            $display("*** init sim.");
            tb_clk = 0;
            tb_reset_n = 1;
        end
    endtask // reset_dut

    //----------------------------------------------------------------
    // init sim
    //----------------------------------------------------------------
    initial begin

        assign s_axis_in_aclk    = tb_clk;
        assign s_axis_in_aresetn = tb_reset_n;

        init_sim();
        reset_dut();
    end

endmodule
