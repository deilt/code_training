set line "set_abstract_port -port \[get_ports di_0\] -clock clk\[0\]"
set line [regsub -all {\[get_\w+\s\S+\](\s|\n){0,1}} $line "111 "]
puts $line