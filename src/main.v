`default_nettype none

module main( // match io names to the values found in the lpf file
    input clk_25mhz,
    output [3:0] gpdi_dp, 
    output [3:0] gpdi_dn,
    output wifi_gpio0
);

    assign wifi_gpio0 = 1'b1;

    wire clk_25MHz, clk_250MHz;

    clock clock_inst(
        .clkin_25MHz(clk_25mhz),
        .clk_25MHz(clk_25MHz),
        .clk_250MHz(clk_250MHz)
    );

    wire [7:0] red, grn, blu;
    wire [23:0] pixel;
    assign red = pixel[23:16];
    assign grn = pixel[15:8];
    assign blu = pixel[7:0];

    wire o_red, o_grn, o_blu;
    wire o_rd, o_newline, o_newframe;

    wire rst;

    ppu ppu_inst(
        .clk(clk_25mhz),
        .i_rd(o_rd),
        .o_pixel(pixel),
        .o_rst(rst)
    );

    llhdmi hdimi_inst(
        .i_tmdsclk(clk_250MHz), .i_pixclk(clk_25mhz),
        .i_reset(rst), .i_red(red), .i_grn(grn), .i_blu(blu),
        .o_rd(o_rd), .o_newline(o_newline), .o_newframe(o_newframe),
        .o_red(o_red), .o_grn(o_grn), .o_blu(o_blu)
    );



    // MAYBE CHANGE NAMES
    cpu cpu(.clk(clk),      // input, clock
            .reset(reset),  // input, reset 
            .AB(AB),        // output, reg, address bus, 15:0
            .DI(DI),        // input, data in, read bus, 7:0
            .DO(DO),        // output, data out, write bus, 7:0
            .WE(WE),        // output, write enable
            .IRQ(IRQ),      // input, interrupt request
            .NMI(NMI),      // input, non-maskable interrupt request
            .RDY(RDY) );    // input, ready signal, pauses CPU when RDY=0

    // MAYBE MOVE THIS TO cpu.v and MAYBE CHANGE NAMES
    cpu_ram cpu_ram(.clk(clk),  // input, clock
                    .address(address),  // input, address, 10:0
                    .write_enable(write_enable),    // input write_enable
                    .write_data(write_data),    // input, write_data [7:0]
                    .read_data(read_data) );    // output, read_data [7:0]


    // replace
    /* 
    vgatestsrc #(.BITS_PER_COLOR(8))
    vgatestsrc_inst(
        .i_pixclk(clk_25MHz), .i_reset(rst),
        .i_width(640), .i_height(480),
        .i_rd(o_rd), .i_newline(o_newline), .i_newframe(o_newframe),
        .o_pixel(pixel)
    );
    */
    

    OBUFDS OBUFDS_red(.I(o_red), .O(gpdi_dp[2]), .OB(gpdi_dn[2]));
    OBUFDS OBUFDS_grn(.I(o_grn), .O(gpdi_dp[1]), .OB(gpdi_dn[1]));
    OBUFDS OBUFDS_blu(.I(o_blu), .O(gpdi_dp[0]), .OB(gpdi_dn[0]));
    OBUFDS OBUFDS_clock(.I(clk_25MHz), .O(gpdi_dp[3]), .OB(gpdi_dn[3]));

endmodule