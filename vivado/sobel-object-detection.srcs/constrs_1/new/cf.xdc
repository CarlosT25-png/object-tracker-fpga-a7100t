## This file is a general .xdc for the Nexys A7-100T
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

# Clock signal
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk_100mhz }]; #IO_L12P_T1_MRCC_35 Sch=clk100mhz
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports {clk_100mhz}];


##Switches

set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { color_sw }]; # SW0
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { scale_sw }]; # SW1
# set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { sw[0] }]; #IO_L24N_T3_RS0_15 Sch=sw[0]
# set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { sw[1] }]; #IO_L3N_T0_DQS_EMCCLK_14 Sch=sw[1]
#set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { SW[2] }]; #IO_L6N_T0_D08_VREF_14 Sch=sw[2]
#set_property -dict { PACKAGE_PIN R15   IOSTANDARD LVCMOS33 } [get_ports { SW[3] }]; #IO_L13N_T2_MRCC_14 Sch=sw[3]
#set_property -dict { PACKAGE_PIN R17   IOSTANDARD LVCMOS33 } [get_ports { SW[4] }]; #IO_L12N_T1_MRCC_14 Sch=sw[4]
#set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports { SW[5] }]; #IO_L7N_T1_D10_14 Sch=sw[5]
#set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports { SW[6] }]; #IO_L17N_T2_A13_D29_14 Sch=sw[6]
#set_property -dict { PACKAGE_PIN R13   IOSTANDARD LVCMOS33 } [get_ports { SW[7] }]; #IO_L5N_T0_D07_14 Sch=sw[7]
#set_property -dict { PACKAGE_PIN T8    IOSTANDARD LVCMOS18 } [get_ports { SW[8] }]; #IO_L24N_T3_34 Sch=sw[8]
#set_property -dict { PACKAGE_PIN U8    IOSTANDARD LVCMOS18 } [get_ports { SW[9] }]; #IO_25_34 Sch=sw[9]
#set_property -dict { PACKAGE_PIN R16   IOSTANDARD LVCMOS33 } [get_ports { SW[10] }]; #IO_L15P_T2_DQS_RDWR_B_14 Sch=sw[10]
#set_property -dict { PACKAGE_PIN T13   IOSTANDARD LVCMOS33 } [get_ports { SW[11] }]; #IO_L23P_T3_A03_D19_14 Sch=sw[11]
#set_property -dict { PACKAGE_PIN H6    IOSTANDARD LVCMOS33 } [get_ports { SW[12] }]; #IO_L24P_T3_35 Sch=sw[12]
#set_property -dict { PACKAGE_PIN U12   IOSTANDARD LVCMOS33 } [get_ports { SW[13] }]; #IO_L20P_T3_A08_D24_14 Sch=sw[13]
#set_property -dict { PACKAGE_PIN U11   IOSTANDARD LVCMOS33 } [get_ports { SW[14] }]; #IO_L19N_T3_A09_D25_VREF_14 Sch=sw[14]
#set_property -dict { PACKAGE_PIN V10   IOSTANDARD LVCMOS33 } [get_ports { SW[15] }]; #IO_L21P_T3_DQS_14 Sch=sw[15]


## LEDs

set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { init_led }];  # LED 0
set_property -dict { PACKAGE_PIN K15   IOSTANDARD LVCMOS33 } [get_ports { vsync_led }]; # LED 1
set_property -dict { PACKAGE_PIN J13   IOSTANDARD LVCMOS33 } [get_ports { href_led }];  # LED 2
set_property -dict { PACKAGE_PIN N14   IOSTANDARD LVCMOS33 } [get_ports { pclk_led }];  # LED 3
set_property -dict { PACKAGE_PIN R18   IOSTANDARD LVCMOS33 } [get_ports { ball_valid_led }];  # LED 4

##Pmod Header JA

set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33 } [get_ports { cam_scl }];     # JA1
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { cam_sda }];     # JA2
set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports { cam_vsync }];   # JA3
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { cam_href }];    # JA4
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports { cam_dclk }];    # JA7
set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports { cam_rst }];     # JA8
set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports { cam_pwdn }];    # JA9
set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { cam_xclk }];    # JA10

# fix clock src
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets -of_objects [get_ports cam_dclk]]
create_clock -period 41.667 -name cam_pixel_clock -waveform {0.000 20.834} [get_ports cam_dclk]
set_false_path -from [get_clocks sys_clk_pin] -to [get_clocks cam_pixel_clock]


##Pmod Header JB

set_property -dict { PACKAGE_PIN D14   IOSTANDARD LVCMOS33 } [get_ports { cam_data[0] }]; # JB1
set_property -dict { PACKAGE_PIN F16   IOSTANDARD LVCMOS33 } [get_ports { cam_data[1] }]; # JB2
set_property -dict { PACKAGE_PIN G16   IOSTANDARD LVCMOS33 } [get_ports { cam_data[2] }]; # JB3
set_property -dict { PACKAGE_PIN H14   IOSTANDARD LVCMOS33 } [get_ports { cam_data[3] }]; # JB4
set_property -dict { PACKAGE_PIN E16   IOSTANDARD LVCMOS33 } [get_ports { cam_data[4] }]; # JB7
set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33 } [get_ports { cam_data[5] }]; # JB8
set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { cam_data[6] }]; # JB9
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { cam_data[7] }]; # JB10


# PMOD JC (Top Row)
set_property -dict { PACKAGE_PIN K1    IOSTANDARD LVCMOS33 } [get_ports { servo_pan }];  # JC Pin 1 X axis
set_property -dict { PACKAGE_PIN F6    IOSTANDARD LVCMOS33 } [get_ports { servo_tilt }]; # JC Pin 2 Y axis
set_property -dict { PACKAGE_PIN J2    IOSTANDARD LVCMOS33 } [get_ports { laser_en }];   # JC Pin 3
# set_property -dict { PACKAGE_PIN G6    IOSTANDARD LVCMOS33 } [get_ports { ground_ref }]; # JC Pin 4 (Optional GND)

#Pmod Header JXADC

set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33     } [get_ports { vauxn3 }]; #IO_L9N_T1_DQS_AD3N_15 Sch=xa_n[1]
set_property -dict { PACKAGE_PIN A13   IOSTANDARD LVCMOS33     } [get_ports { vauxp3 }]; #IO_L9P_T1_DQS_AD3P_15 Sch=xa_p[1]
set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33     } [get_ports { vauxn10}]; #IO_L8N_T1_AD10N_15 Sch=xa_n[2]
set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33     } [get_ports { vauxp10 }]; #IO_L8P_T1_AD10P_15 Sch=xa_p[2]
set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS33     } [get_ports { vauxn2 }]; #IO_L7N_T1_AD2N_15 Sch=xa_n[3]
set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33     } [get_ports { vauxp2 }]; #IO_L7P_T1_AD2P_15 Sch=xa_p[3]
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33     } [get_ports { vauxn11 }]; #IO_L10N_T1_AD11N_15 Sch=xa_n[4]
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33     } [get_ports { vauxp11 }]; #IO_L10P_T1_AD11P_15 Sch=xa_p[4]


## VGA Connector

set_property -dict { PACKAGE_PIN A3    IOSTANDARD LVCMOS33 } [get_ports { vga_red[0] }]; 
set_property -dict { PACKAGE_PIN B4    IOSTANDARD LVCMOS33 } [get_ports { vga_red[1] }]; 
set_property -dict { PACKAGE_PIN C5    IOSTANDARD LVCMOS33 } [get_ports { vga_red[2] }]; 
set_property -dict { PACKAGE_PIN A4    IOSTANDARD LVCMOS33 } [get_ports { vga_red[3] }]; 

set_property -dict { PACKAGE_PIN C6    IOSTANDARD LVCMOS33 } [get_ports { vga_green[0] }]; 
set_property -dict { PACKAGE_PIN A5    IOSTANDARD LVCMOS33 } [get_ports { vga_green[1] }]; 
set_property -dict { PACKAGE_PIN B6    IOSTANDARD LVCMOS33 } [get_ports { vga_green[2] }]; 
set_property -dict { PACKAGE_PIN A6    IOSTANDARD LVCMOS33 } [get_ports { vga_green[3] }]; 

set_property -dict { PACKAGE_PIN B7    IOSTANDARD LVCMOS33 } [get_ports { vga_blue[0] }]; 
set_property -dict { PACKAGE_PIN C7    IOSTANDARD LVCMOS33 } [get_ports { vga_blue[1] }]; 
set_property -dict { PACKAGE_PIN D7    IOSTANDARD LVCMOS33 } [get_ports { vga_blue[2] }]; 
set_property -dict { PACKAGE_PIN D8    IOSTANDARD LVCMOS33 } [get_ports { vga_blue[3] }]; 

set_property -dict { PACKAGE_PIN B11   IOSTANDARD LVCMOS33 } [get_ports { vga_hsync }]; 
set_property -dict { PACKAGE_PIN B12   IOSTANDARD LVCMOS33 } [get_ports { vga_vsync }];

