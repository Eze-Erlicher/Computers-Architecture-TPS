## Constraints for basys 3 FPGA

## Clock
set_property -dict { PACKAGE_PIN W5 IOSTANDARD LVCMOS33 } [get_ports { I_clk }];
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports { I_clk }];

## Reset
set_property -dict { PACKAGE_PIN T18 IOSTANDARD LVCMOS33 } [get_ports { reset_button }];

## Leds
set_property -dict { PACKAGE_PIN U16 IOSTANDARD LVCMOS33 } [get_ports { O_led[0] }];
set_property -dict { PACKAGE_PIN E19 IOSTANDARD LVCMOS33 } [get_ports { O_led[1] }];
set_property -dict { PACKAGE_PIN U19 IOSTANDARD LVCMOS33 } [get_ports { O_led[2] }];
set_property -dict { PACKAGE_PIN V19 IOSTANDARD LVCMOS33 } [get_ports { O_led[3] }];
set_property -dict { PACKAGE_PIN W18 IOSTANDARD LVCMOS33 } [get_ports { O_led[4] }];
set_property -dict { PACKAGE_PIN U15 IOSTANDARD LVCMOS33 } [get_ports { O_led[5] }];
set_property -dict { PACKAGE_PIN U14 IOSTANDARD LVCMOS33 } [get_ports { O_led[6] }];
set_property -dict { PACKAGE_PIN V14 IOSTANDARD LVCMOS33 } [get_ports { O_led[7] }];

## Overflow and Zero Leds
set_property -dict { PACKAGE_PIN W3 IOSTANDARD LVCMOS33 } [get_ports { O_overflow }];
set_property -dict { PACKAGE_PIN U3 IOSTANDARD LVCMOS33 } [get_ports { O_zero }];

## Buttons
set_property -dict { PACKAGE_PIN W19 IOSTANDARD LVCMOS33 } [get_ports { I_button[0] }];
set_property -dict { PACKAGE_PIN U18 IOSTANDARD LVCMOS33 } [get_ports { I_button[1] }];
set_property -dict { PACKAGE_PIN T17 IOSTANDARD LVCMOS33 } [get_ports { I_button[2] }];

## Switches
set_property -dict { PACKAGE_PIN V17 IOSTANDARD LVCMOS33 } [get_ports { I_sw[0] }];
set_property -dict { PACKAGE_PIN V16 IOSTANDARD LVCMOS33 } [get_ports { I_sw[1] }];
set_property -dict { PACKAGE_PIN W16 IOSTANDARD LVCMOS33 } [get_ports { I_sw[2] }];
set_property -dict { PACKAGE_PIN W17 IOSTANDARD LVCMOS33 } [get_ports { I_sw[3] }];
set_property -dict { PACKAGE_PIN W15 IOSTANDARD LVCMOS33 } [get_ports { I_sw[4] }];
set_property -dict { PACKAGE_PIN V15 IOSTANDARD LVCMOS33 } [get_ports { I_sw[5] }];
set_property -dict { PACKAGE_PIN W14 IOSTANDARD LVCMOS33 } [get_ports { I_sw[6] }];
set_property -dict { PACKAGE_PIN W13 IOSTANDARD LVCMOS33 } [get_ports { I_sw[7] }];
