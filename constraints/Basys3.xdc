## Basys 3 Board Constraints Template
## Uncomment and modify as needed for your specific board

## Clock signal (100MHz)
#set_property PACKAGE_PIN W5 [get_ports clk]
#set_property IOSTANDARD LVCMOS33 [get_ports clk]
#create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk]

## Reset button (center button)
#set_property PACKAGE_PIN U18 [get_ports reset]
#set_property IOSTANDARD LVCMOS33 [get_ports reset]

## Control buttons
#set_property PACKAGE_PIN T18 [get_ports btn_count_enable]
#set_property IOSTANDARD LVCMOS33 [get_ports btn_count_enable]
#set_property PACKAGE_PIN W19 [get_ports btn_led_mode_0]
#set_property IOSTANDARD LVCMOS33 [get_ports btn_led_mode_0]
#set_property PACKAGE_PIN T17 [get_ports btn_led_mode_1]
#set_property IOSTANDARD LVCMOS33 [get_ports btn_led_mode_1]

## LEDs (16 LEDs on Basys 3)
#set_property PACKAGE_PIN U16 [get_ports {leds[0]}]
#set_property PACKAGE_PIN E19 [get_ports {leds[1]}]
#set_property PACKAGE_PIN U19 [get_ports {leds[2]}]
#set_property PACKAGE_PIN V19 [get_ports {leds[3]}]
#set_property PACKAGE_PIN W18 [get_ports {leds[4]}]
#set_property PACKAGE_PIN U15 [get_ports {leds[5]}]
#set_property PACKAGE_PIN U14 [get_ports {leds[6]}]
#set_property PACKAGE_PIN V14 [get_ports {leds[7]}]
#set_property PACKAGE_PIN V13 [get_ports {leds[8]}]
#set_property PACKAGE_PIN V3 [get_ports {leds[9]}]
#set_property PACKAGE_PIN W3 [get_ports {leds[10]}]
#set_property PACKAGE_PIN U3 [get_ports {leds[11]}]
#set_property PACKAGE_PIN P3 [get_ports {leds[12]}]
#set_property PACKAGE_PIN N3 [get_ports {leds[13]}]
#set_property PACKAGE_PIN P1 [get_ports {leds[14]}]
#set_property PACKAGE_PIN L1 [get_ports {leds[15]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {leds[*]}]

## 7-Segment Display (digit select - active low)
#set_property PACKAGE_PIN U2 [get_ports {digit_select[0]}]
#set_property PACKAGE_PIN U4 [get_ports {digit_select[1]}]
#set_property PACKAGE_PIN V4 [get_ports {digit_select[2]}]
#set_property PACKAGE_PIN W4 [get_ports {digit_select[3]}]
#set_property IOSTANDARD LVCMOS33 [get_ports {digit_select[*]}]

## 7-Segment Display segments (a-g)
#set_property PACKAGE_PIN W7 [get_ports {segments[0]}]  ; # segment a
#set_property PACKAGE_PIN W6 [get_ports {segments[1]}]  ; # segment b
#set_property PACKAGE_PIN U8 [get_ports {segments[2]}]  ; # segment c
#set_property PACKAGE_PIN V8 [get_ports {segments[3]}]  ; # segment d
#set_property PACKAGE_PIN U5 [get_ports {segments[4]}]  ; # segment e
#set_property PACKAGE_PIN V5 [get_ports {segments[5]}]  ; # segment f
#set_property PACKAGE_PIN U7 [get_ports {segments[6]}]  ; # segment g
#set_property IOSTANDARD LVCMOS33 [get_ports {segments[*]}]

## Additional timing constraints
#set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets clk_IBUF]
