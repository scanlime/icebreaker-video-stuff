PROJ = dvi12-test

PCF = icebreaker.pcf
TOP_SRC = top.v
EXTRA_SRC = video_timing.v

IVERILOG_LIB=$(HOME)/.apio/packages/toolchain-iverilog/lib/ivl
IVERILOG_CELLS=$(HOME)/.apio/packages/toolchain-iverilog/vlib/cells_sim.v

all: $(PROJ).rpt $(PROJ).bin

$(PROJ).json: $(TOP_SRC) $(EXTRA_SRC)
	yosys -ql $(PROJ).log -p 'synth_ice40 -top top -json $@' $(TOP_SRC) $(EXTRA_SRC)

$(PROJ).asc: $(PCF) $(PROJ).json
	nextpnr-ice40 --up5k --json $(PROJ).json --pcf $(PCF) --asc $@

$(PROJ).bin: $(PROJ).asc
	icepack $< $@

$(PROJ).rpt: $(PROJ).asc
	icetime -d up5k -mtr $@ $<

%_tb: %_tb.v %.v
	iverilog -B $(IVERILOG_LIB) -o $@ $(IVERILOG_CELLS) $^

%_tb.vcd: %_tb
	vvp -M $(IVERILOG_LIB) -N $< +vcd=$@

prog: $(PROJ).bin
	iceprog $<

clean:
	rm -f $(PROJ).json $(PROJ).asc $(PROJ).bin $(PROJ).rpt

.PHONY: all prog clean
