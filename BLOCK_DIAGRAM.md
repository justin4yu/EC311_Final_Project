# System Block Diagram

## Complete System Architecture

```
                    ┌─────────────────────────────────────────────┐
                    │         100MHz System Clock (FPGA)          │
                    └──────────────┬──────────────────────────────┘
                                   │
                    ┌──────────────┴──────────────┐
                    │                              │
         ┌──────────▼──────────┐      ┌──────────▼──────────┐
         │   Clock_Divider     │      │   Clock_Divider     │
         │   (÷50M → 1Hz)      │      │   (÷500k → 100Hz)   │
         └──────────┬──────────┘      └──────────┬──────────┘
                    │                              │
                    │                              │
    ┌───────────────┴───────────┐         ┌──────▼──────┐
    │                            │         │   LEDGen    │
    │  ┌──────────────────────┐ │         │  (Pattern   │
    │  │     Debouncer        │ │         │ Generator)  │
    │  │  (Count Enable)      │ │         └──────┬──────┘
    │  └──────────┬───────────┘ │                │
    │             │               │                │
    │  ┌──────────▼───────────┐ │                │
    │  │   Counter_16Bit      │ │         ┌──────▼──────┐
    │  │   (16-bit Counter)   │ │         │  LEDs [15:0]│
    │  └──────────┬───────────┘ │         │  (Output)   │
    │             │               │         └─────────────┘
    │             │               │
    │     count[15:0]           │
    │             │               │
    └─────────────┼───────────────┘
                  │
                  │
         ┌────────▼────────┐
         │ DisplayControl  │
         │  (Multiplexer)  │
         └────┬────────┬───┘
              │        │
      digit_select  digit_data[3:0]
        [3:0]        │
              │      │
         ┌────▼──────▼─────┐
         │  Encoder_7Seg   │
         │  (BCD→7-Seg)    │
         └────────┬─────────┘
                  │
            segments[6:0]
                  │
         ┌────────▼─────────┐
         │  7-Segment LEDs  │
         │    (Display)     │
         └──────────────────┘


  ┌─────────────────────────┐
  │   Button Inputs (Raw)   │
  └──────────┬──────────────┘
             │
    ┌────────┼────────┐
    │        │        │
 ┌──▼──┐ ┌──▼──┐ ┌──▼──┐
 │ DB1 │ │ DB2 │ │ DB3 │  (Debouncers)
 └──┬──┘ └──┬──┘ └──┬──┘
    │        │        │
    └────────┼────────┘
             │
  ┌──────────▼──────────┐
  │  Clean Button Signals│
  └─────────────────────┘

```

## Signal Flow Summary

### Input Path
1. **Raw Buttons** → Debouncer → **Clean Signals**
   - Removes mechanical bounce
   - Synchronizes to clock domain

### Clock Generation
2. **100MHz** → Clock_Divider → **1Hz** (Counter)
3. **100MHz** → Clock_Divider → **100Hz** (LEDs)

### Counter Path
4. **1Hz Clock + Enable** → Counter_16Bit → **count[15:0]**
   - Increments every second when enabled
   - 16-bit value (0x0000 to 0xFFFF)

### Display Path
5. **count[15:0]** → DisplayControl → **digit_select + digit_data**
   - Multiplexes 4 digits rapidly
   - One digit active at a time
   - Creates persistence of vision

6. **digit_data[3:0]** → Encoder_7Seg → **segments[6:0]**
   - Converts hex to 7-segment pattern
   - One digit at a time

### LED Pattern Path
7. **100Hz Clock + Mode** → LEDGen → **leds[15:0]**
   - Independent pattern generation
   - 4 selectable modes

## Timing Diagram

```
Clock (100MHz):  ↑↓↑↓↑↓↑↓↑↓↑↓↑↓↑↓↑↓↑↓↑↓↑↓↑↓↑↓...

Clock (1Hz):     ↑__________|↑__________|↑____...
                 
Counter:         0000 -----> 0001 -----> 0002 ...

Display Mux:     Dig0|Dig1|Dig2|Dig3|Dig0|Dig1...
                 (cycles ~1kHz per digit)

LED Pattern:     Pattern updates at 100Hz
```

## Module Dependencies

```
TopLevel_Example
├─ Clock_Divider (independent)
├─ Clock_Divider (independent)
├─ Debouncer (independent)
├─ Debouncer (independent)
├─ Debouncer (independent)
├─ Counter_16Bit (uses Clock_Divider output)
├─ LEDGen (uses Clock_Divider output)
├─ DisplayControl (independent)
└─ Encoder_7Seg (uses DisplayControl output)
```

**Note:** Most modules are independent and can be tested individually.

## Critical Connections

### For Counter Display:
```
counter.count[15:0] → display_value[15:0]
DisplayControl.digit_data → Encoder_7Seg.bcd
```

### For Button Control:
```
Raw Button → Debouncer.button_in
Debouncer.button_out → Counter.enable
```

### Clock Domains:
```
Main: 100MHz (all synchronous logic)
Derived: 1Hz (counter updates)
Derived: 100Hz (LED updates)
```

## Physical Board Connections

```
FPGA Pins               Internal Signal        Module
─────────────────────────────────────────────────────────
W5 (Clock Input)   →    clk                   All modules
U18 (Button)       →    reset                 All modules
T18 (Button)       →    btn_count_enable      Debouncer
W19 (Button)       →    btn_led_mode_0        Debouncer
T17 (Button)       →    btn_led_mode_1        Debouncer

U16-L1 (16 pins)   ←    leds[15:0]           LEDGen
U2-W4 (4 pins)     ←    digit_select[3:0]    DisplayControl
W7-U7 (7 pins)     ←    segments[6:0]        Encoder_7Seg
```

## Data Widths

| Signal | Width | Range/Values |
|--------|-------|--------------|
| clk | 1-bit | Clock signal |
| reset | 1-bit | Active high |
| count | 16-bit | 0x0000-0xFFFF |
| leds | 16-bit | LED states |
| digit_select | 4-bit | One-hot (active low) |
| digit_data | 4-bit | 0x0-0xF (hex) |
| segments | 7-bit | {g,f,e,d,c,b,a} |

## Design Notes

1. **Synchronous Design**: All registers clocked by main 100MHz clock
2. **Reset**: Asynchronous reset, synchronous release
3. **Clock Domains**: Properly managed with dividers
4. **Metastability**: Prevented with 2-stage synchronizers in Debouncer
5. **Multiplexing**: Display refresh fast enough for persistence (~4kHz total)

---
See ARCHITECTURE.md for more implementation details.
