set_top -module TOP1

#create_clock -name clk1 [get_ports clk1]
assign_clock_domain -domain domain1 -clock clk1

create_clock -name clka [get_ports clk3]

create_clock -name clka [get_ports clk3]
assign_clock_domain -domain domain1 -clock clk1