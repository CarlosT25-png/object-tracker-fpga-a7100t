set_property SRC_FILE_INFO {cfile:C:/Projects/VivadoProjects/sobel-object-detection/sobel-object-detection.srcs/constrs_1/new/cf.xdc rfile:../../../sobel-object-detection.srcs/constrs_1/new/cf.xdc id:1} [current_design]
set_property src_info {type:XDC file:1 line:7 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN E3    IOSTANDARD LVCMOS33 } [get_ports { clk_100mhz }]; #IO_L12P_T1_MRCC_35 Sch=clk100mhz
set_property src_info {type:XDC file:1 line:96 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN C17   IOSTANDARD LVCMOS33 } [get_ports { cam_scl }];     # JA1
set_property src_info {type:XDC file:1 line:97 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { cam_sda }];     # JA2
set_property src_info {type:XDC file:1 line:98 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN E18   IOSTANDARD LVCMOS33 } [get_ports { cam_vsync }];   # JA3
set_property src_info {type:XDC file:1 line:99 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN G17   IOSTANDARD LVCMOS33 } [get_ports { cam_href }];    # JA4
set_property src_info {type:XDC file:1 line:100 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN D17   IOSTANDARD LVCMOS33 } [get_ports { cam_dclk }];    # JA7
set_property src_info {type:XDC file:1 line:101 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN E17   IOSTANDARD LVCMOS33 } [get_ports { cam_rst }];     # JA8
set_property src_info {type:XDC file:1 line:102 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN F18   IOSTANDARD LVCMOS33 } [get_ports { cam_pwdn }];    # JA9
set_property src_info {type:XDC file:1 line:103 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN G18   IOSTANDARD LVCMOS33 } [get_ports { cam_xclk }];    # JA10
set_property src_info {type:XDC file:1 line:106 export:INPUT save:INPUT read:READ} [current_design]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets cam_dclk_IBUF]
set_property src_info {type:XDC file:1 line:113 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN D14   IOSTANDARD LVCMOS33 } [get_ports { cam_data[0] }]; # JB1
set_property src_info {type:XDC file:1 line:114 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN F16   IOSTANDARD LVCMOS33 } [get_ports { cam_data[1] }]; # JB2
set_property src_info {type:XDC file:1 line:115 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN G16   IOSTANDARD LVCMOS33 } [get_ports { cam_data[2] }]; # JB3
set_property src_info {type:XDC file:1 line:116 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN H14   IOSTANDARD LVCMOS33 } [get_ports { cam_data[3] }]; # JB4
set_property src_info {type:XDC file:1 line:117 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN E16   IOSTANDARD LVCMOS33 } [get_ports { cam_data[4] }]; # JB7
set_property src_info {type:XDC file:1 line:118 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN F13   IOSTANDARD LVCMOS33 } [get_ports { cam_data[5] }]; # JB8
set_property src_info {type:XDC file:1 line:119 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN G13   IOSTANDARD LVCMOS33 } [get_ports { cam_data[6] }]; # JB9
set_property src_info {type:XDC file:1 line:120 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN H16   IOSTANDARD LVCMOS33 } [get_ports { cam_data[7] }]; # JB10
set_property src_info {type:XDC file:1 line:125 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN K1    IOSTANDARD LVCMOS33 } [get_ports { spi_cs }]; #IO_L23N_T3_35 Sch=jc[1]
set_property src_info {type:XDC file:1 line:126 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN F6    IOSTANDARD LVCMOS33 } [get_ports { spi_sclk }]; #IO_L19N_T3_VREF_35 Sch=jc[2]
set_property src_info {type:XDC file:1 line:127 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN J2    IOSTANDARD LVCMOS33 } [get_ports { spi_mosi }]; #IO_L22N_T3_35 Sch=jc[3]
set_property src_info {type:XDC file:1 line:149 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33     } [get_ports { vauxn3 }]; #IO_L9N_T1_DQS_AD3N_15 Sch=xa_n[1]
set_property src_info {type:XDC file:1 line:150 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN A13   IOSTANDARD LVCMOS33     } [get_ports { vauxp3 }]; #IO_L9P_T1_DQS_AD3P_15 Sch=xa_p[1]
set_property src_info {type:XDC file:1 line:151 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN A16   IOSTANDARD LVCMOS33     } [get_ports { vauxn10}]; #IO_L8N_T1_AD10N_15 Sch=xa_n[2]
set_property src_info {type:XDC file:1 line:152 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN A15   IOSTANDARD LVCMOS33     } [get_ports { vauxp10 }]; #IO_L8P_T1_AD10P_15 Sch=xa_p[2]
set_property src_info {type:XDC file:1 line:153 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN B17   IOSTANDARD LVCMOS33     } [get_ports { vauxn2 }]; #IO_L7N_T1_AD2N_15 Sch=xa_n[3]
set_property src_info {type:XDC file:1 line:154 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN B16   IOSTANDARD LVCMOS33     } [get_ports { vauxp2 }]; #IO_L7P_T1_AD2P_15 Sch=xa_p[3]
set_property src_info {type:XDC file:1 line:155 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN A18   IOSTANDARD LVCMOS33     } [get_ports { vauxn11 }]; #IO_L10N_T1_AD11N_15 Sch=xa_n[4]
set_property src_info {type:XDC file:1 line:156 export:INPUT save:INPUT read:READ} [current_design]
set_property -dict { PACKAGE_PIN B18   IOSTANDARD LVCMOS33     } [get_ports { vauxp11 }]; #IO_L10P_T1_AD11P_15 Sch=xa_p[4]
