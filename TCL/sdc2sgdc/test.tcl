proc get_object_name {line} {
    # Extract the object name from the input line
    puts "In get_object_name. Execute: --->> $line"
    set command_position [string first "\[get_" $line]
    puts "command_position: $command_position"
    set variable_name ""
    if {$command_position != -1} {
        set first_left_bracket [string first "\[" $line [expr {$command_position + 1}]]
        puts "first_left_bracket: $first_left_bracket"
        set last_left_bracket [string last "\[" $line]
        puts "last_left_bracket: $last_left_bracket"
        if { $first_left_bracket == -1 } {
            set command_end [string first "\]" $line $command_position]
            set command_content [string range $line $command_position [expr {$command_end}]]
            puts "command_content: $command_content"
            set variable_start [string first " " $command_content]
            puts "variable_start: $variable_start"
            set variable_name [string range $command_content [expr {$variable_start + 1}] [expr {[string length $command_content] - 2 }]]
            puts "variable_name: $variable_name"
        } elseif { $first_left_bracket != -1 && $last_left_bracket != -1 && $first_left_bracket != $last_left_bracket } {
            set string_bracket_range [string range $line $first_left_bracket $last_left_bracket]
            puts "string_bracket_range: $string_bracket_range"
            set last_right_bracket [string last "\]" $string_bracket_range]
            puts "last_right_bracket: $last_right_bracket"
            set end_of_bracket [expr {$first_left_bracket + $last_right_bracket + 1}]
            puts "end_of_bracket: $end_of_bracket"
            set command_content [string range $line $command_position $end_of_bracket]
            puts "command_content: $command_content"
            set variable_start [string first " " $command_content]
            puts "variable_start: $variable_start"
            set variable_name [string range $command_content [expr {$variable_start + 1}] [expr {[string length $command_content] - 3 }]]
            puts "variable_name: $variable_name"
        } elseif { $first_left_bracket == $last_left_bracket } {
            set command_end [string last "\]" $line]
            puts "command_end: $command_end"
            set command_content [string range $line $command_position $command_end]
            puts "command_content2: $command_content"
            set variable_start [string first " " $command_content]
            puts "variable_start: $variable_start"
            set variable_name [string range $command_content [expr {$variable_start + 1}] [expr {[string length $command_content] - 2 }]]
            puts "variable_name2: $variable_name"
        }
    }
    return $variable_name
}
set line "create_clock -name clk2 \[get_ports clk2\];assign_clock_domain -domain domain2 -clock clk2"
puts "line: $line"
set object_name [get_object_name $line]
puts "object_name: $object_name"