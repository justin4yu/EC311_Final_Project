# Quick Reference Guide

## Module Quick Reference

### Clock_Divider
```verilog
Clock_Divider #(.DIVIDER(100000000)) inst (
    .clk(clk_in),
    .reset(reset),
    .clk_out(clk_out)
);
```
**Use:** Generate slower clock from fast system clock

### Debouncer
```verilog
Debouncer #(.DEBOUNCE_TIME(1000000)) inst (
    .clk(clk),
    .reset(reset),
    .button_in(btn_raw),
    .button_out(btn_clean)
);
```
**Use:** Clean up mechanical button noise

### LEDGen
```verilog
LEDGen #(.NUM_LEDS(16)) inst (
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .mode(mode),        // 2'b00 to 2'b11
    .leds(leds)        // [15:0]
);
```
**Use:** Create LED patterns
- Mode 0: Running light
- Mode 1: Binary counter
- Mode 2: Alternating/blinking
- Mode 3: Knight Rider

### Counter_16Bit
```verilog
Counter_16Bit inst (
    .clk(clk),
    .reset(reset),
    .enable(enable),
    .up_down(1'b1),         // 1=up, 0=down
    .load(load),
    .load_value(value),     // [15:0]
    .count(count),          // [15:0]
    .carry_out(carry),
    .zero(zero)
);
```
**Use:** Count events, implement timers

### DisplayControl
```verilog
DisplayControl #(
    .NUM_DIGITS(4),
    .REFRESH_RATE(100000)
) inst (
    .clk(clk),
    .reset(reset),
    .display_value(value),  // [31:0]
    .digit_select(sel),     // [3:0] active low
    .digit_data(data)       // [3:0]
);
```
**Use:** Multiplex 7-segment displays

### Encoder_7Seg
```verilog
Encoder_7Seg #(.COMMON_ANODE(0)) inst (
    .bcd(digit),           // [3:0] 0-F
    .enable(enable),
    .segments(seg)         // [6:0] {g,f,e,d,c,b,a}
);
```
**Use:** Convert hex to 7-segment
- Set COMMON_ANODE=0 for common cathode
- Set COMMON_ANODE=1 for common anode

## Common Parameter Values

### Clock Divider
| Target Freq | From 100MHz | DIVIDER Value |
|-------------|-------------|---------------|
| 1 Hz | ÷100M | 100000000 |
| 10 Hz | ÷10M | 10000000 |
| 100 Hz | ÷1M | 1000000 |
| 1 kHz | ÷100k | 100000 |
| 10 kHz | ÷10k | 10000 |

### Debounce Time
| Duration | @ 100MHz | DEBOUNCE_TIME |
|----------|----------|---------------|
| 1 ms | | 100000 |
| 10 ms | (typical) | 1000000 |
| 20 ms | | 2000000 |

### Display Refresh
| Per Digit | Total (4) | REFRESH_RATE |
|-----------|-----------|--------------|
| 1 kHz | 4 kHz | 100000 |
| 2 kHz | 8 kHz | 50000 |
| 4 kHz | 16 kHz | 25000 |

## Common Connections

### Button to Counter
```verilog
Debouncer db (.button_in(btn), .button_out(btn_clean), ...);
Counter_16Bit cnt (.enable(btn_clean), ...);
```

### Counter to Display
```verilog
Counter_16Bit cnt (.count(count_val), ...);
DisplayControl dc (.display_value({16'h0, count_val}), ...);
Encoder_7Seg enc (.bcd(dc.digit_data), .segments(seg), ...);
```

### Full System
See `src/TopLevel_Example.v` for complete integration.

## Testing Commands

```bash
# Test all modules
make test

# Test specific module
make test_Clock_Divider
make test_Debouncer
make test_LEDGen
make test_Counter_16Bit
make test_DisplayControl
make test_Encoder_7Seg

# Clean build files
make clean
```

## Typical Issues & Solutions

### Display not visible
- Check COMMON_ANODE parameter matches your board
- Try both 0 and 1 if unsure
- Verify refresh rate (25000-100000 works for most)

### Button not working
- Increase DEBOUNCE_TIME if too sensitive
- Check button is active-high in constraints
- Add pull-up/pull-down in XDC file

### Counter too fast/slow
- Adjust DIVIDER parameter
- Formula: DIVIDER = clk_freq / (2 × target_freq)
- Example: 100MHz to 1Hz = 100000000 / 2 = 50000000

### LEDs not updating
- Check enable signal is high
- Verify clock is connected
- Try different mode values

## File Organization

```
src/              - All Verilog modules
testbench/        - All testbenches
constraints/      - Pin constraints for FPGA
README.md         - Full documentation
ARCHITECTURE.md   - Design details
PROJECT_SUMMARY.md - Overview
Makefile          - Build automation
```

## Resources

- **Verilog Syntax:** IEEE 1364-2001 standard
- **Board:** Basys 3 / Nexys A7 / similar Artix-7
- **Clock:** 100 MHz typical
- **Tools:** Xilinx Vivado, Icarus Verilog

## Quick Start

1. Clone repository
2. Review `README.md`
3. Simulate: `make test`
4. Synthesize in Vivado with `TopLevel_Example.v`
5. Use `constraints/Basys3.xdc` (uncomment lines)
6. Program FPGA

---
For detailed information, see README.md and ARCHITECTURE.md
