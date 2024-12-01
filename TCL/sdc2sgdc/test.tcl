set line "create_clock -name clka \[get_ports clk3\]"
set command_position [string first "\[" $line]
puts "command_position: $command_position"
if {$command_position != -1} {
    set command_end [string first "\]" $line $command_position]
    puts "command_end: $command_end"
    if {$command_end != -1} {
        set command_content [string range $line $command_position [expr {$command_end}]]
        puts "command_content: $command_content"
        set variable_start [string last " " $command_content]
        puts "variable_start: $variable_start"
        set variable_name [string range $command_content [expr {$variable_start + 1}] [expr {$command_end - 1}]]
        puts "variable_name: $variable_name"
    }
}