module top(
    input CLK,

    output P1A1,
    output P1A2,
    output P1A3,
    output P1A4,
    output P1A7,
    output P1A8,
    output P1A9,
    output P1A10,

    output P1B1,
    output P1B2,
    output P1B3,
    output P1B4,
    output P1B7,
    output P1B8,
    output P1B9,
    output P1B10,
);

    ////////////////////////////
    // pmod

    assign P1A1  = vid_r[7];
    assign P1A2  = vid_r[5];
    assign P1A3  = vid_g[7];
    assign P1A4  = vid_g[5];
    assign P1A7  = vid_r[6];
    assign P1A8  = vid_r[4];
    assign P1A9  = vid_g[6];
    assign P1A10 = vid_g[4];

    assign P1B1  = vid_b[7];
    assign P1B2  = vid_clk;
    assign P1B3  = vid_b[4];
    assign P1B4  = vid_hs;
    assign P1B7  = vid_b[6];
    assign P1B8  = vid_b[5];
    assign P1B9  = vid_de;
    assign P1B10 = vid_vs;

    ////////////////////////////
    // clocking

    /*
     * Given input frequency:        12.000 MHz
     * Requested output frequency:   74.250 MHz
     * Achieved output frequency:    73.500 MHz
     */
    wire pixclk;
    SB_PLL40_PAD #(
        .FEEDBACK_PATH("SIMPLE"),
        .DIVR(4'b0000),         // DIVR =  0
        .DIVF(7'b0110000),      // DIVF = 48
        .DIVQ(3'b011),          // DIVQ =  3
        .FILTER_RANGE(3'b001)   // FILTER_RANGE = 1
    ) pll (
        .RESETB(1'b1),
        .BYPASS(1'b0),
        .PACKAGEPIN(CLK),
        .PLLOUTCORE(pixclk)
    );

    // DDR output buffer to repeat pixel clock
    wire vid_clk;
    SB_IO #(
        // DDR output, regular input
        .PIN_TYPE(6'b010001)
    ) pixclk_buf (
        .PACKAGE_PIN(vid_clk),
        .LATCH_INPUT_VALUE(1'b0),
        .CLOCK_ENABLE(1'b1),
        .INPUT_CLK(pixclk),
        .OUTPUT_CLK(pixclk),
        .OUTPUT_ENABLE(1'b1),
        .D_OUT_0(1'b1),
        .D_OUT_1(1'b0)
    );

    ////////////////////////////
    // video timing

    wire hsync;
    wire vsync;
    wire data_en;

    video_timing video_timing_inst (
        .clk(pixclk),
        .hsync(hsync),
        .vsync(vsync),
        .data_en(data_en)
    );

    ////////////////////////////
    // output & test pattern

    reg [7:4] vid_r;
    reg [7:4] vid_g;
    reg [7:4] vid_b;
    reg vid_hs;
    reg vid_vs;
    reg vid_de;

    reg [7:0] frame = 0;
    reg [7:0] xpos = 0;
    reg [7:0] ypos = 0;

    reg hsync_prev = 0;
    reg vsync_prev = 0;

    always @(posedge pixclk) begin
        hsync_prev <= hsync;
        vsync_prev <= vsync;

        if (vsync && !vsync_prev) begin
            ypos <= frame;
            frame <= frame + 1;
        end
        else if (hsync && !hsync_prev) begin
            xpos <= frame;
            ypos <= ypos + 1;
        end
        else if (data_en)
            xpos <= xpos + 1;

        vid_hs <= hsync;
        vid_vs <= vsync;
        vid_de <= data_en;

        vid_r[7:4] <= ypos[7:4];
        vid_g[7:4] <= xpos[7:4];
        vid_b[7:4] <= xpos[3:0];
    end

endmodule
