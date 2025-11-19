# EC311 Final Project - Digital Logic Design Modules

This repository contains a collection of essential Verilog modules for FPGA-based digital logic design projects, typically used with development boards featuring 7-segment displays, LEDs, and buttons.

## Project Structure

```
EC311_Final_Project/
├── src/                    # Source files (Verilog modules)
│   ├── Clock_Divider.v     # Clock frequency divider
│   ├── Debouncer.v         # Button debouncer
│   ├── LEDGen.v            # LED pattern generator
│   ├── Counter_16Bit.v     # 16-bit up/down counter
│   ├── DisplayControl.v    # 7-segment display multiplexer
│   └── Encoder_7Seg.v      # 7-segment encoder
└── testbench/              # Testbench files
    ├── tb_Clock_Divider.v
    ├── tb_Debouncer.v
    ├── tb_LEDGen.v
    ├── tb_Counter_16Bit.v
    ├── tb_DisplayControl.v
    └── tb_Encoder_7Seg.v
```

## Modules Description

### 1. Clock_Divider
**Purpose:** Divides the input clock frequency by a programmable factor.

**Features:**
- Parameterizable divider ratio
- Generates slower clock signals from fast system clocks
- Common use: Creating 1Hz clock from 100MHz for displays

**Parameters:**
- `DIVIDER`: Clock division factor (default: 100000000)

**Ports:**
- `clk`: Input system clock
- `reset`: Asynchronous reset
- `clk_out`: Divided clock output

### 2. Debouncer
**Purpose:** Eliminates mechanical switch bounce noise from button inputs.

**Features:**
- Counter-based debouncing algorithm
- Two-stage synchronizer to prevent metastability
- Configurable debounce time
- Typical use: 10ms debounce time for mechanical buttons

**Parameters:**
- `DEBOUNCE_TIME`: Number of clock cycles for stable detection (default: 1000000 = 10ms @ 100MHz)

**Ports:**
- `clk`: System clock
- `reset`: Asynchronous reset
- `button_in`: Raw button input
- `button_out`: Debounced button output

### 3. LEDGen
**Purpose:** Generates various LED display patterns.

**Features:**
- Multiple display modes (4 modes)
- Mode 0: Running light (single LED moves across)
- Mode 1: Binary counter
- Mode 2: Alternating/blinking pattern
- Mode 3: Knight Rider effect
- Enable control for pattern generation

**Parameters:**
- `NUM_LEDS`: Number of LEDs (default: 16)

**Ports:**
- `clk`: System clock
- `reset`: Asynchronous reset
- `enable`: Enable pattern generation
- `mode`: 2-bit pattern mode selection
- `leds`: LED outputs

### 4. Counter_16Bit
**Purpose:** 16-bit counter with up/down counting and load capability.

**Features:**
- Up or down counting
- Synchronous load
- Carry out flag for overflow/underflow detection
- Zero flag
- Common use: Event counting, timers, display updates

**Ports:**
- `clk`: System clock
- `reset`: Asynchronous reset
- `enable`: Counter enable
- `up_down`: Count direction (1=up, 0=down)
- `load`: Load enable
- `load_value`: 16-bit value to load
- `count`: Current count value
- `carry_out`: Overflow/underflow flag
- `zero`: Zero detection flag

### 5. DisplayControl
**Purpose:** Controls multiplexed multi-digit 7-segment displays.

**Features:**
- Time-multiplexed digit display
- Supports up to 4 digits (expandable)
- Automatic digit cycling for persistence of vision
- Configurable refresh rate
- Displays 32-bit hex values

**Parameters:**
- `NUM_DIGITS`: Number of digits (default: 4)
- `REFRESH_RATE`: Clock cycles per digit refresh (default: 100000)

**Ports:**
- `clk`: System clock
- `reset`: Asynchronous reset
- `display_value`: 32-bit value to display
- `digit_select`: Active digit selection (typically active-low)
- `digit_data`: 4-bit BCD data for current digit

### 6. Encoder_7Seg
**Purpose:** Converts 4-bit BCD/hex values to 7-segment display encoding.

**Features:**
- Supports all hex digits (0-F)
- Configurable for common anode or common cathode displays
- Enable control for blanking
- Segment mapping: {g,f,e,d,c,b,a}

**Parameters:**
- `COMMON_ANODE`: Display type (0=common cathode, 1=common anode)

**Ports:**
- `bcd`: 4-bit input value
- `enable`: Display enable (blanks when low)
- `segments`: 7-bit segment outputs

## Usage Example

### Basic Integration
```verilog
// Clock divider for 1Hz refresh
Clock_Divider #(.DIVIDER(100000000)) clk_div (
    .clk(clk_100MHz),
    .reset(reset),
    .clk_out(clk_1Hz)
);

// Button debouncer
Debouncer #(.DEBOUNCE_TIME(1000000)) btn_db (
    .clk(clk_100MHz),
    .reset(reset),
    .button_in(btn_raw),
    .button_out(btn_clean)
);

// 16-bit counter
Counter_16Bit counter (
    .clk(clk_1Hz),
    .reset(reset),
    .enable(1'b1),
    .up_down(1'b1),
    .load(1'b0),
    .load_value(16'h0000),
    .count(count_value),
    .carry_out(),
    .zero()
);

// Display control
DisplayControl #(.NUM_DIGITS(4), .REFRESH_RATE(100000)) disp_ctrl (
    .clk(clk_100MHz),
    .reset(reset),
    .display_value({16'h0000, count_value}),
    .digit_select(digit_sel),
    .digit_data(digit_data)
);

// 7-segment encoder
Encoder_7Seg #(.COMMON_ANODE(0)) seg_enc (
    .bcd(digit_data),
    .enable(1'b1),
    .segments(seg_out)
);
```

## Testing

Each module includes a comprehensive testbench in the `testbench/` directory. To simulate:

1. Using Icarus Verilog:
```bash
iverilog -o sim src/Module_Name.v testbench/tb_Module_Name.v
vvp sim
```

2. Using Xilinx Vivado:
- Add source files from `src/` directory
- Add testbench files from `testbench/` directory
- Run behavioral simulation

## Target Platforms

These modules are designed for FPGA development boards with:
- System clock (typically 100MHz)
- 7-segment displays (multiplexed)
- LEDs
- Push buttons/switches
- Common boards: Basys 3, Nexys A7, Arty boards

## Synthesis Notes

- All modules use synchronous design practices
- Reset signals are asynchronous but properly synchronized
- Clock domain crossing is handled where necessary
- Modules are parameterizable for different configurations
- Timing constraints should be applied based on target clock frequency

## License

Educational use for EC311 Digital Logic Design course.

## Authors

EC311 Final Project Team