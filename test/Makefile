# Makefile
# See https://docs.cocotb.org/en/stable/quickstart.html for more info

SIM ?= icarus
FST ?= -fst
TOPLEVEL_LANG ?= verilog

SRC_DIR = $(PWD)/../src
PROJECT_SOURCES = project.v tiny8_top.v sram_bb.v

# IHP SG13G2 SRAM behavioural model
SRAM_MODEL = $(PWD)/models/RM_IHPSG13_1P_core_behavioral_bm_bist.v
SRAM_WRAPPER = $(SRC_DIR)/RM_IHPSG13_1P_256x8_c3_bm_bist.v

ifneq ($(GATES),yes)

# RTL simulation
SIM_BUILD = sim_build/rtl

COMPILE_ARGS += -DFUNCTIONAL -DSIM

VERILOG_SOURCES += $(SRAM_MODEL)
VERILOG_SOURCES += $(SRAM_WRAPPER)
VERILOG_SOURCES += $(addprefix $(SRC_DIR)/,$(PROJECT_SOURCES))

else

# IHP SG13G2 gate-level simulation
SIM_BUILD = sim_build/gl

COMPILE_ARGS += -DGL_TEST
COMPILE_ARGS += -DFUNCTIONAL
COMPILE_ARGS += -DSIM

# IHP SG13G2 standard-cell and IO simulation models
VERILOG_SOURCES += $(PDK_ROOT)/ihp-sg13g2/libs.ref/sg13g2_io/verilog/sg13g2_io.v
VERILOG_SOURCES += $(PDK_ROOT)/ihp-sg13g2/libs.ref/sg13g2_stdcell/verilog/sg13g2_stdcell.v

# SRAM behavioural model for gate-level simulation
VERILOG_SOURCES += $(SRAM_MODEL)
VERILOG_SOURCES += $(SRAM_WRAPPER)

# Gate-level netlist copied in by the GDS action workflow
VERILOG_SOURCES += $(PWD)/gate_level_netlist.v

endif

# Include project source directory
COMPILE_ARGS += -I$(SRC_DIR)

# Testbench
VERILOG_SOURCES += $(PWD)/tb.v

TOPLEVEL = tb
COCOTB_TEST_MODULES = test

include $(shell cocotb-config --makefiles)/Makefile.sim
