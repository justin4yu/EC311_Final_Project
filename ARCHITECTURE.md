# EC311 Final Project - Module Architecture

## System Overview

This project implements a complete digital system designed for FPGA development boards (such as Basys 3 or Nexys A7). The system demonstrates fundamental digital design concepts including clock management, user input handling, display control, and pattern generation.

## Module Hierarchy

```
TopLevel_Example (Top-level integration)
├── Clock_Divider (1Hz) ──────┐
├── Clock_Divider (100Hz) ────┤
│                              │
├── Debouncer (x3) ───────────┤── Clock & Input Management
│   ├── Count Enable Button   │
│   ├── LED Mode 0 Button     │
│   └── LED Mode 1 Button     │
│                              │
├── Counter_16Bit ────────────┤── Core Logic
├── LEDGen ───────────────────┤
│                              │
├── DisplayControl ───────────┤── Display System
└── Encoder_7Seg ─────────────┘
```

## Data Flow

1. **Input Processing**
   - Raw button inputs → Debouncer → Clean digital signals
   - Eliminates mechanical bounce noise
   - Prevents false triggering

2. **Clock Generation**
   - 100MHz system clock → Clock_Divider → 1Hz for counter
   - 100MHz system clock → Clock_Divider → 100Hz for LED patterns
   - Different clock domains for different update rates

3. **Counting Logic**
   - 1Hz clock enables Counter_16Bit
   - Button controls count enable
   - 16-bit value increments every second when enabled

4. **LED Pattern Display**
   - 100Hz clock updates LED patterns
   - Mode buttons select pattern type (4 modes)
   - Independent from counting logic

5. **7-Segment Display**
   - Counter value fed to DisplayControl
   - DisplayControl multiplexes 4 digits
   - Each digit sent to Encoder_7Seg for segment encoding
   - Rapid switching creates persistent display

## Module Interface Specifications

### Clock_Divider
```verilog
Input:  clk (fast), reset
Output: clk_out (slow)
Parameter: DIVIDER (division factor)
```
- Divides input clock by DIVIDER
- Output toggles at reduced frequency
- Use for creating human-perceptible timing

### Debouncer
```verilog
Input:  clk, reset, button_in
Output: button_out
Parameter: DEBOUNCE_TIME (stability required)
```
- Two-stage synchronizer prevents metastability
- Counter-based stability detection
- Typical debounce time: 10ms

### Counter_16Bit
```verilog
Input:  clk, reset, enable, up_down, load, load_value[15:0]
Output: count[15:0], carry_out, zero
```
- Synchronous up/down counter
- Load capability for preset values
- Flags for overflow/underflow and zero detection

### LEDGen
```verilog
Input:  clk, reset, enable, mode[1:0]
Output: leds[15:0]
Parameter: NUM_LEDS
```
- Mode 0: Running light (sequential)
- Mode 1: Binary counter
- Mode 2: Alternating pattern (blinking)
- Mode 3: Knight Rider effect

### DisplayControl
```verilog
Input:  clk, reset, display_value[31:0]
Output: digit_select[3:0], digit_data[3:0]
Parameters: NUM_DIGITS, REFRESH_RATE
```
- Time-multiplexed display control
- Cycles through digits at refresh rate
- Outputs which digit is active and its value
- Refresh rate typically 1-4kHz per digit

### Encoder_7Seg
```verilog
Input:  bcd[3:0], enable
Output: segments[6:0]
Parameter: COMMON_ANODE
```
- Converts 4-bit hex to 7-segment encoding
- Supports 0-9, A-F
- Configurable for common anode/cathode
- Enable for blanking

## Timing Considerations

### Clock Domains
1. **System Clock (100MHz)**
   - DisplayControl refresh
   - Debouncer operation
   - Clock dividers

2. **Slow Clock (1Hz)**
   - Counter updates
   - Human-observable counting

3. **Medium Clock (100Hz)**
   - LED pattern updates
   - Smooth animation

### Critical Paths
- Debouncer synchronizer (CDC crossing)
- Display multiplexer switching
- Counter increment logic

### Timing Constraints
```tcl
# System clock
create_clock -period 10.0 [get_ports clk]

# Derived clocks (informational)
# 1Hz clock: period 1000ms
# 100Hz clock: period 10ms
```

## Resource Usage Estimates (Basys 3)

| Module | LUTs | FFs | Notes |
|--------|------|-----|-------|
| Clock_Divider (1Hz) | 35 | 33 | 32-bit counter |
| Clock_Divider (100Hz) | 25 | 23 | Smaller counter |
| Debouncer | 40 | 35 | Per instance (x3) |
| Counter_16Bit | 25 | 17 | 16-bit register + logic |
| LEDGen | 60 | 50 | Pattern logic + counter |
| DisplayControl | 45 | 40 | Multiplexer + counter |
| Encoder_7Seg | 25 | 0 | Combinational only |
| **Total (approx)** | **375** | **316** | Very small for modern FPGAs |

*Basys 3 has 20,800 LUTs available - this design uses ~1.8%*

## Testing Strategy

Each module has a dedicated testbench that validates:
1. Reset functionality
2. Normal operation
3. Edge cases (overflow, underflow, mode changes)
4. Enable/disable behavior

Run tests with:
```bash
make test              # All modules
make test_<module>     # Specific module
```

## Extension Ideas

1. **Add more counting modes**
   - Down counting
   - Count by 2, 5, 10
   - BCD counting

2. **Enhanced LED patterns**
   - Custom patterns from switches
   - Brightness control (PWM)
   - Color control (RGB LEDs)

3. **Display enhancements**
   - Decimal points
   - Scrolling text
   - Time display (HH:MM:SS)

4. **Additional features**
   - Alarm/timer functionality
   - Stop watch mode
   - Score keeper

## Debugging Tips

### Simulation
- Use waveform viewer (GTKWave) to visualize signals
- Add $display statements for key events
- Test one module at a time before integration

### On Hardware
- Start with LED patterns (easy to see)
- Verify clock dividers with LEDs blinking
- Check button debouncing with counter response
- Display often needs polarity adjustment (anode/cathode)

### Common Issues
1. **Display doesn't show anything**
   - Check COMMON_ANODE parameter
   - Verify refresh rate isn't too slow/fast
   - Confirm digit_select polarity

2. **Buttons not responding**
   - Check debounce time (may need adjustment)
   - Verify button pull-up/down in constraints
   - Test with longer button press

3. **Counter not counting**
   - Verify clock divider is working
   - Check enable signal
   - Confirm reset is released

## References

- EC311 Course Materials
- Xilinx Basys 3 Reference Manual
- Verilog HDL Quick Reference
- FPGA Design Best Practices

## Authors

Justin Yu (justin4yu)
EC311 Digital Logic Design
