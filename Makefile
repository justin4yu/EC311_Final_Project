# Makefile for EC311 Final Project
# Requires Icarus Verilog (iverilog) and VVP simulator

# Directories
SRC_DIR = src
TB_DIR = testbench
BUILD_DIR = build

# Verilog compiler
IVERILOG = iverilog
VVP = vvp

# Modules to test
MODULES = Clock_Divider Debouncer Encoder_7Seg Counter_16Bit LEDGen DisplayControl

# Default target
.PHONY: all
all: help

# Help target
.PHONY: help
help:
	@echo "EC311 Final Project - Makefile"
	@echo "=============================="
	@echo ""
	@echo "Available targets:"
	@echo "  make test           - Run all testbenches"
	@echo "  make test_<module>  - Run specific module testbench"
	@echo "  make clean          - Clean build artifacts"
	@echo ""
	@echo "Available modules:"
	@echo "  Clock_Divider, Debouncer, Encoder_7Seg,"
	@echo "  Counter_16Bit, LEDGen, DisplayControl"
	@echo ""
	@echo "Example: make test_Clock_Divider"

# Create build directory
$(BUILD_DIR):
	mkdir -p $(BUILD_DIR)

# Generic test target
.PHONY: test
test: $(BUILD_DIR)
	@echo "Running all testbenches..."
	@for module in $(MODULES); do \
		echo ""; \
		echo "=== Testing $$module ==="; \
		$(MAKE) test_$$module || exit 1; \
	done
	@echo ""
	@echo "All tests completed successfully!"

# Individual module test targets
.PHONY: test_Clock_Divider
test_Clock_Divider: $(BUILD_DIR)
	@echo "Compiling Clock_Divider testbench..."
	$(IVERILOG) -o $(BUILD_DIR)/tb_Clock_Divider.vvp \
		$(SRC_DIR)/Clock_Divider.v \
		$(TB_DIR)/tb_Clock_Divider.v
	@echo "Running simulation..."
	$(VVP) $(BUILD_DIR)/tb_Clock_Divider.vvp

.PHONY: test_Debouncer
test_Debouncer: $(BUILD_DIR)
	@echo "Compiling Debouncer testbench..."
	$(IVERILOG) -o $(BUILD_DIR)/tb_Debouncer.vvp \
		$(SRC_DIR)/Debouncer.v \
		$(TB_DIR)/tb_Debouncer.v
	@echo "Running simulation..."
	$(VVP) $(BUILD_DIR)/tb_Debouncer.vvp

.PHONY: test_Encoder_7Seg
test_Encoder_7Seg: $(BUILD_DIR)
	@echo "Compiling Encoder_7Seg testbench..."
	$(IVERILOG) -o $(BUILD_DIR)/tb_Encoder_7Seg.vvp \
		$(SRC_DIR)/Encoder_7Seg.v \
		$(TB_DIR)/tb_Encoder_7Seg.v
	@echo "Running simulation..."
	$(VVP) $(BUILD_DIR)/tb_Encoder_7Seg.vvp

.PHONY: test_Counter_16Bit
test_Counter_16Bit: $(BUILD_DIR)
	@echo "Compiling Counter_16Bit testbench..."
	$(IVERILOG) -o $(BUILD_DIR)/tb_Counter_16Bit.vvp \
		$(SRC_DIR)/Counter_16Bit.v \
		$(TB_DIR)/tb_Counter_16Bit.v
	@echo "Running simulation..."
	$(VVP) $(BUILD_DIR)/tb_Counter_16Bit.vvp

.PHONY: test_LEDGen
test_LEDGen: $(BUILD_DIR)
	@echo "Compiling LEDGen testbench..."
	$(IVERILOG) -o $(BUILD_DIR)/tb_LEDGen.vvp \
		$(SRC_DIR)/LEDGen.v \
		$(TB_DIR)/tb_LEDGen.v
	@echo "Running simulation..."
	$(VVP) $(BUILD_DIR)/tb_LEDGen.vvp

.PHONY: test_DisplayControl
test_DisplayControl: $(BUILD_DIR)
	@echo "Compiling DisplayControl testbench..."
	$(IVERILOG) -o $(BUILD_DIR)/tb_DisplayControl.vvp \
		$(SRC_DIR)/DisplayControl.v \
		$(TB_DIR)/tb_DisplayControl.v
	@echo "Running simulation..."
	$(VVP) $(BUILD_DIR)/tb_DisplayControl.vvp

# Clean build artifacts
.PHONY: clean
clean:
	@echo "Cleaning build artifacts..."
	rm -rf $(BUILD_DIR)
	rm -f *.vcd *.vvp *.log
	@echo "Clean complete!"

# Phony targets
.PHONY: all test clean help
