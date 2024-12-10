set_top -module TOP1

####################### Create clocks #######################
create_clock -name clk2 [get_ports clk2];assign_clock_domain -domain domain2 -clock clk2
#clock -name clk2 -domain domain2
create_clock -name clk2 [get_ports clk2];assign_clock_domain -clock clk2 -domain domain2 
#clock -name clk2 -domain domain2
create_clock -name clk1 [get_ports clk1]
assign_clock_domain -domain domain1 -clock clk1
#clock -name clk1 -domain domain1

create_clock -name clka [get_ports clk3]
#clock -name clk3 -domain clka

create_clock -name clk[0] [get_ports clk[0]]
assign_clock_domain -domain clk_a -clock clk[0]
#clock -name clk[0] -domain clk_a
create_clock -name clk[1] [get_ports clk[1]]
assign_clock_domain -domain clk_b -clock clk[1]
#clock -name clk[1] -domain clk_b
create_clock -name clk[2] [get_ports clk[2]]
assign_clock_domain -domain clk_c -clock clk[2]
#clock -name clk[2] -domain clk_c

create_clock -name clk[0] [get_ports clk[0]] ;assign_clock_domain -domain clk_a -clock clk[0]
#clock -name clk[0] -domain clk_a

create_clock -name clka 
#clock -tag clka

####################### create resets #######################
create_reset -sync -name rst -sense low [get_ports rst1]
#reset -sync  -value 0 -name rst1
create_reset -sync -name rst[0] -sense low [get_ports rst[0]]
#reset -sync  -value 0 -name rst[0]
create_reset -sync -name rst[1] -sense low [get_ports rst[1]]
#reset -sync  -value 0 -name rst[1]

####################### set_abstract_port #######################
set_abstract_port -port [get_ports di_0] -clock clk[0]
#abstract_port -ports di_0 -clock clk[0]
set_abstract_port -port [get_ports di_1] -clock clk[0]
#abstract_port -ports di_1 -clock clk[1]
set_abstract_port -port [get_ports di_vld] -clock clk[0]
#abstract_port -ports di_vld -clock clk[0]
set_abstract_port  -clock clk[0] -port [get_ports di_0]
#abstract_port -ports di_0 -clock clk[0]
set_abstract_port  -clock clk[0] -port [get_ports di_0[0]]
#abstract_port -ports di_0[0] -clock clk[0]

####################### set_case_analysis #######################
set_case_analysis -objects [get_ports di_1] 1
#set_case_analysis -name di_1 -value 1
set_case_analysis -objects [get_ports din] 0
#set_case_analysis -name din -value 0

####################### create_static #######################
create_static aa
#quasi_static -name aa

####################### creatset_qualifiere_static #######################
set_qualifier dout -from_clk clk[0] -to_clk clk[1] -crossing
#qualifier -name dout -from_clk clk[0] -to_clk clk[1] -crossing

####################### set_sync_cell #######################
set_sync_cell TEST -from_clk clk[0] -to_clk clk[2]
#sync_cell -name TEST -from_clk clk[0] -to_clk clk[2]

####################### set_reset_synchronizer #######################
set_reset_synchronizer rst_out -clock clk[1] -reset rst[0] -value 1
#reset_synchronizer -name rst_out -clock clk[1] -reset rst[0] -value 1

####################### set_ip_block #######################
set_ip_block TEST
#ip_block -name TEST

####################### set_signal_relationship #######################
set_signal_relationship -exclusive X Y Z
#cdc_attribute -exclusive X Y Z

####################### create_generated_clock #######################
create_generated_clock -name gen_C1 -master C1 -divide_by 2 [get_ports out1]
#generated_clock -name out1 -source srcClk -master_clock C1 -divide_by 2
