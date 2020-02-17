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
    localparam integer PIC_WIDTH  = 800;
    localparam integer PIC_HEIGHT = 600;
    localparam integer NB_DATA = PIC_WIDTH * PIC_HEIGHT;
    localparam  INPUT_BASE_PATH = "/home/lledoux/Desktop/perso/A2RT/tb/";
    localparam  INPUT_PATH = "input_pic4.raw";
    localparam  OUTPUT_BASE_PATH = INPUT_BASE_PATH;
    localparam  OUTPUT_PATH = "output_pic.raw";
    localparam  t = {OUTPUT_BASE_PATH, OUTPUT_PATH};
    localparam  READ_B_OR_H = "H";

    //logic [31:0] FD; // file descriptor of 32 bits
    integer write_file;

    // write to file
    initial begin
        write_file = $fopen(t, "w");
    end


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
//    a2rt #(
//        .DATA_WIDTH ( DATA_WIDTH )
//    ) a2rt_inst (
//        // System signals
//        .clk     ( tb_clk     ),
//        .rst_n   ( tb_reset_n ),

//        // SLAVE SIDE

//        // control signals
//        .rtr_o   ( s_axis_in_tready ),
//        .rts_i   ( s_axis_in_tvalid ),
//        .eow_i   ( s_axis_in_tlast  ),
//        // data in
//        .pixel_i ( s_axis_in_tdata  ),

//        // MASTER SIDE

//        // control signals
//        .rtr_i   ( 1                ),  // no downstream module, simulate always ready to accept data
//        .rts_o   ( a2rt_rts_o       ),
//        .eow_o   ( a2rt_eow_o       ),
//        // data out
//        .pixel_o ( a2rt_pixel_o     )
//    );
    
   a2rt_v1_0 #(
  .C_S_AXIS_TDATA_WIDTH(24),  // AXI4Stream sink: Data Width
  .C_M_AXIS_TDATA_WIDTH(24),  // Width of S_AXIS address bus. The slave accepts the read and write addresses of width C_M_AXIS_TDATA_WIDTH.
  .C_M_AXIS_START_COUNT(32),  // Start count is the number of clock cycles the master will wait before initiating/issuing any transaction.
  .SCREEN_WIDTH(800),
  .SCREEN_HEIGHT(600)
) inst (
            .m_axis_aclk(tb_clk),
            .m_axis_aresetn(tb_reset_n),
            .m_axis_tdata(s_axis_in_tdata),
            .m_axis_tlast(s_axis_in_tlast),
            .m_axis_tready(s_axis_in_tready),
            .m_axis_tvalid(s_axis_in_tvalid),
            .s_axis_aclk(tb_clk),
            .s_axis_aresetn(tb_reset_n),
            .s_axis_tdata(a2rt_pixel_o),
            .s_axis_tlast(a2rt_eow_o),
            .s_axis_tready(1'b1),
            .s_axis_tstrb(),
            .s_axis_tvalid(a2rt_rts_o));

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






    //----------------------------------------------------------------
    // writing in a file
    //
    // WIP, experiment
    //----------------------------------------------------------------

//    always @* begin
//        if ( tb_reset_n ) begin
//            if (a2rt_rts_o) begin
//                $display(t, "%d", a2rt_pixel_o);
//            end
//            if ( a2rt_eow_o ) begin
//            #1;
//                              $fclose(t);
//                              $finish;
//                          end
//         end
//    end

   

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
