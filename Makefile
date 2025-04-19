# ==============================================================================
# Project Configuration
# ==============================================================================

TOP         := blinky
DEVICE      := hx1k
PACKAGE     := vq100

SRC_DIR     := src
BUILD_DIR   := build
CONSTR_DIR  := constr
SIM_DIR     := sim
FORMAL_DIR  := formal

FILELIST    := filelist.txt
SRC_LIST    := $(shell cat $(FILELIST) 2>/dev/null)
TB          := $(SIM_DIR)/$(TOP)_tb.v
PCF         := $(CONSTR_DIR)/Go_Board_Constraints.pcf

JSON        := $(BUILD_DIR)/$(TOP).json
ASC         := $(BUILD_DIR)/$(TOP).asc
BIN         := $(BUILD_DIR)/$(TOP).bin
VCD         := $(SIM_DIR)/$(TOP).vcd

# ==============================================================================
# Build Targets
# ==============================================================================

all: $(BIN)

$(BUILD_DIR):
	mkdir -p $@

$(SIM_DIR):
	mkdir -p $@

# Synthesis
$(JSON): $(FILELIST) | $(BUILD_DIR)
	@if [ ! -f $(FILELIST) ]; then \
		echo "Missing filelist.txt! Please list your Verilog sources."; \
		exit 1; \
	fi
	yosys -p "synth_ice40 -top $(TOP) -json $@" $(SRC_LIST)

# Place & Route
$(ASC): $(JSON) $(PCF)
	nextpnr-ice40 --$(DEVICE) --package $(PACKAGE) \
		--json $< --asc $@ --pcf $(PCF) > $(BUILD_DIR)/$(TOP).log 2>&1

# Bitstream Generation
$(BIN): $(ASC)
	icepack $< $@

# ==============================================================================
# Programming
# ==============================================================================

prog: $(BIN)
	iceprog $<

# ==============================================================================
# Simulation
# ==============================================================================

sim: $(TB) $(FILELIST) | $(SIM_DIR)
	iverilog -g2012 -o $(SIM_DIR)/$(TOP)_tb $(TB) $(SRC_LIST)
	vvp $(SIM_DIR)/$(TOP)_tb

gtkwave:
	gtkwave $(VCD) &

# ==============================================================================
# Formal Verification (SymbiYosys)
# ==============================================================================

formal:
	cd $(FORMAL_DIR) && sby -f $(TOP)_sby.sby

formal-clean:
	rm -rf $(FORMAL_DIR)/$(TOP)_sby

# ==============================================================================
# Debugging & Inspection
# ==============================================================================

# Generate debug synthesis artifacts
synthdbg: | $(BUILD_DIR)
	yosys -p "\
		read_verilog $(SRC_LIST); \
		hierarchy -top $(TOP); \
		proc; opt; techmap; opt; stat; \
		write_verilog $(BUILD_DIR)/$(TOP)_synth.v; \
		write_rtlil $(BUILD_DIR)/$(TOP).il; \
		write_json $(BUILD_DIR)/$(TOP)_debug.json; \
		show -prefix $(BUILD_DIR)/$(TOP)_graph -colors 1 -stretch -format svg $(TOP)"

# Open synthesized design visualization
synthview: synthdbg
	xdg-open $(BUILD_DIR)/$(TOP)_graph.svg

# Post-PNR inspection
pnrdbg: $(ASC)
	icebox_vlog $< > $(BUILD_DIR)/$(TOP)_pnr.v
	icebox_explain $< > $(BUILD_DIR)/$(TOP)_pnr.txt

# ==============================================================================
# Quality Tools
# ==============================================================================

lint: | $(BUILD_DIR)
	verilator --lint-only -Wall -Wno-fatal $(SRC_LIST) 2>&1 | tee $(BUILD_DIR)/lint.log

# ==============================================================================
# Cleanup
# ==============================================================================

clean:
	rm -rf $(BUILD_DIR)
	rm -f $(SIM_DIR)/*.vcd $(SIM_DIR)/*.out $(SIM_DIR)/$(TOP)_tb
	rm -rf $(FORMAL_DIR)/$(TOP)_sby

# ==============================================================================
# Declare Phony Targets
# ==============================================================================

.PHONY: all prog sim gtkwave formal formal-clean clean \
        synthdbg synthview pnrdbg lint
