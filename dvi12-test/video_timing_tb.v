`timescale 1ns / 100ps

module video_timing_tb;

	reg clk;
	wire hsync, vsync, data_en;

    video_timing video_timing_inst (
        .clk(clk),
        .hsync(hsync),
        .vsync(vsync),
        .data_en(data_en)
    );

	initial begin
		$dumpfile("video_timing_tb.vcd");
		$dumpvars(0, video_timing_inst);

		clk = 0;
		#10000000
		$finish;
	end

	always
		# 13
		clk = ~clk;

endmodule
