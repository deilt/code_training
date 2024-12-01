set_top -module TOP

create_clock -name clk1 [get_ports clk1]
assign_clock_domain -domain domain1 -clock clk1
create_clock -name clk2 [get_ports clk2];assign_clock_domain -domain domain2 -clock clk2

create_clock -name clk[0] [get_ports clk[0]]
assign_clock_domain -domain clk_a -clock clk[0]
create_clock -name clk[1] [get_ports clk[1]]
assign_clock_domain -domain clk_b -clock clk[1]
create_clock -name clk[2] [get_ports clk[2]]
assign_clock_domain -domain clk_c -clock clk[2]

create_reset -sync -name rst -sense low [get_ports rst]
create_reset -sync -name rst[0] -sense low [get_ports rst[0]]
create_reset -sync -name rst[1] -sense low [get_ports rst[1]]
#
#set_abstract_port -port [get_ports di_0] -clock clk[0]
#set_abstract_port -port [get_ports di_1] -clock clk[0]
#set_abstract_port -port [get_ports di_2] -clock clk[0]

#set_case_analysis -objects [get_ports di_1] 1
#set_qualifier do_1 -from_clk clk[0] -to_clk clk[1]
#set_sync_cell SYNC_CELL -from_clk clk[0] -to_clk clk[1]
#set_reset_synchronizer path_end[0] -reset rst[0] -clock clk[1] -value 0
#set_ip_block BB
#set_cdc_false_path -from di_0 -to do_0 -from_type data -to_type data



