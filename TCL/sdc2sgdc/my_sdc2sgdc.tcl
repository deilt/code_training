source D:/data/code/git_code/code_training/TCL/common.tcl
#######################################################################
#Usage: my_sdc2sgdc.tcl <sdc_file> <-f>
#Usage: my_sdc2sgdc.tcl <sdc_file> <-d>
proc Usage {} {
   __puts_color_font__ -green "Usage: my_sdc2sgdc.tcl <sdc_file> <-f> or <-d>"
}
proc xxx {} {
    puts "###############################################################"
}

################### Scrpt path ###################
set scrpt_path [file dirname [info script]]
__puts_color_font__ -red "scrpt_path     : $scrpt_path"
#given sdc file path
set given_file_path [lindex $argv 0]
__puts_color_font__ -red "given_file_path: $given_file_path"

################### Dict to store the options ########################
dict set command_dict set_top parseSetTopCmd
dict set command_dict create_clock parseCreateClockCmd
dict set command_dict assign_clock_domain parseCreateClockCmd
dict set command_dict create_reset parseCreateResetCmd
dict set command_dict set_abstract_port parseAbstractPortCmd
dict set command_dict set_input_delay parseAbstractPortCmd
dict set command_dict set_output_delay parseAbstractPortCmd
dict set command_dict set_case_analysis parseAnalysisCmd
dict set command_dict create_static parseQualiferSyncStaticCmd
dict set command_dict set_qualifier parseQualiferSyncStaticCmd
dict set command_dict set_sync_cell parseQualiferSyncStaticCmd
dict set command_dict set_reset_synchronizer parseQualiferSyncStaticCmd
dict set command_dict set_ip_block parseQualiferSyncStaticCmd
dict set command_dict set_cdc_false_path parseQualiferSyncStaticCmd
dict set command_dict create_generated_clock parseGeneratedClockCmd
dict set command_dict set_signal_relationship parseSignalRelationshipCmd
######################################################################

################################# Proc of Dict ###############################
#TOP.a.b.c to top.a/b/c
proc convert_hierarchical_name {name} {
    set hierarchical_name ""
}

#get_ports、get_nets、get_pins to get signal name
#other ways is to regsub get []
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
        set first_right_bracket [string first "\]" $line [expr {$command_position + 1}]]
        if { $first_left_bracket == -1 || $first_left_bracket > $first_right_bracket } {
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

proc parseSetTopCmd {line} {
    #The 'set_top -module TOP' string is converted to 'current_design TOP', the name of the TOP is not necessarily TOP, and needs to be saved
    # Extract the module name from the input line
    puts "In parseSetTopCmd. Execute: --->> $line"
    set top_module_name [lindex $line 2]  ; # Let's assume the format is “set_top -module MODULE_NAME”
    # Outputs the current design command
    puts ">>> current_design $top_module_name"
    # Returns the converted rows
    return "current_design $top_module_name"
}


proc parseCreateClockCmd {line} {
    #create_clock -name clka [get_ports clk3]Convert to clock -name clk3 -domain clka
    puts "In parseCreateClockCmd. Execute: --->> $line"
    #Convert create_clock to clock
    set line [string map {"create_clock" "clock"} $line]
    #Get where -name is located, and get the first substring after -name until you encounter a space or line break
    # Find the location of -name and extract the following substring
    set name_position [string first "-name" $line]
    if {$name_position != -1} {
        set name_start [expr {$name_position + [string length "-name"] + 1}]
        set name_end [string first " " $line $name_start]
        if {$name_end == -1} {
            set name_end [string length $line]
        }
        set clock_name [string range $line $name_start [expr {$name_end - 1}]]
        puts "Extracted clock name: $clock_name"
    }
    # Find and extract [get_ports], [get_nets], or [get_pins].
    set variable_name [get_object_name $line]
    #Query whether the row has a assign_clock_domain, and if so, extract the substring domain2 after -domain
    set assign_clock_domain_position [string first "assign_clock_domain" $line]
    if {$assign_clock_domain_position != -1} {
        set domain_start [expr {$assign_clock_domain_position + [string length "assign_clock_domain"] + 1}]
        set domain_position [string first "-domain" $line $domain_start]
        set domain_start [string first " " $line [expr {$domain_position + [string length "-domain"]}]]
        set domain_end [string first " " $line [expr {$domain_start + 1}]]
        if {$domain_end == -1} {
            set clock_domain [string range $line $domain_start end]
        } else {
            set clock_domain [string range $line $domain_start $domain_end]
        }
        puts "Extracted clock domain: $clock_domain"
        set clock_name $clock_domain
    } else {
        set clock_name $clock_name
    }
    #
    # Outputs the converted lines
    return "clock -name $variable_name -domain $clock_name "
}

proc parseCreateResetCmd {line} {
    set line [string map {"create_reset" "reset"} $line]
    set line [string map {"sense" "value"} $line]
    set line [string map {"low" "0"} $line]
    set line [string map {"high" "1"} $line]
    set reset_name [get_object_name $line]
    #Get the location of -name, and get the first substring after -name until you encounter a space or line break
    # Found it-name and extract the following substring
    set name_position [string first "-name" $line]
    set name_start [expr {$name_position + [string length "-name"] + 1}]
    set name_end [string first " " $line $name_start]
    if {$name_end == -1} {
        set name_get [string range $line $name_start end]
    } else {
        set name_get [string range $line $name_start [expr {$name_end - 1}]]
    }
    set line [string map [list $name_get $reset_name] $line]
    #Remove the string at the beginning of [get_,] or the string in the middle of the end of ]]. For example, removal[get_ports rst11]
    set line [regsub -all {\[get_\w+\s.*\]$} $line ""]
    return $line
}

proc parseAbstractPortCmd {line} {
    set line [string map {"set_abstract_port" "abstract_port"} $line]
    #substring [get_ports] to get the port name
    set variable_name [get_object_name $line]
    set line [regsub -all {\[get_\w+\s\S+\](\s|\n){0,1}} $line "$variable_name "]
    #Outputs the converted lines
    return $line
}

proc parseAnalysisCmd {line} {
    set line [string map {"-object" "-name"} $line]
    set variable_name [get_object_name $line]
    set line [regsub -all {\[get_\w+\s\S+\](\s|\n){0,1}} $line "$variable_name "]
    #get digital of line
    set value [regexp {\s\d} $line]
    puts "value: $value"
    set line [regsub -all {\s\d} $line " -value $value"]
    puts "line: $line"
    return $line
}

proc parseQualiferSyncStaticCmd {line} {
    #add -name

    set line [string map {"create_static" "quasi_static"} $line]
    set line [string map {"set_qualifier" "qualifier"} $line]
    set line [string map {"set_sync_cell" "sync_cell"} $line]
    set line [string map {"set_ip_block" "ip_block"} $line]
    return $line
}

proc parseGeneratedClockCmd {line} {
}

proc parseSignalRelationshipCmd {line} {
    set line [string map {"set_signal_relationship" "cdc_attribute"} $line]
    return $line
}
############################# Main #############################
#1. Read the SDC file.
#2. Parse the content of the SDC file.
#3. Convert the SDC content to SGDC format.
#4. Write the converted content to the SGDC file.
#########################################################################

############################# Read sdc file #############################
proc sdc_to_sgdc {sdc_file} {
    # Preprocess SDC files
    set sdc_file_temp [preprocess_sdc_file $sdc_file]
    # Open the SDC file to read the contents
    set sdc_handle [open $sdc_file_temp r]
    # Generate the sgdc file and open the SGDC file to write the contents
    set sgdc_file [file join [file dirname $sdc_file_temp] [file rootname $sdc_file].sgdc]
    set sgdc_handle [open $sgdc_file w]
    # Read the SDC file line by line
    while {[gets $sdc_handle line] >= 0} {
        # Parse every line of the SDC file and remove the spaces at both ends
        set line [string trim $line]
        # Skip blank lines and comments
        if {[string equal $line ""]} {
            puts $sgdc_handle $line  ; # Write blank lines directly
            continue
        }
        # Work with comment lines
        if {[string match "#" [string index $line 0]]} {
            set modified_line [string map {"#" "//"} $line]
            puts $sgdc_handle $modified_line  ; # Write comments directly
            continue
        }
        xxx
        __puts_color_font__ -blue "In Process:-> $line"
        # Convert according to SDC syntax
        set sgdc_line [convert_sdc_to_sgdc $line]
        puts $sgdc_handle $sgdc_line
    }

    # Close the file handle
    close $sdc_handle
    close $sgdc_handle
    #Delete temporary file sdc_file
    file delete $sdc_file_temp
}

proc get_command_type {line} {
    # The command type that parses each line of the SDC file
    set command_type [lindex $line 0]
    return $command_type
}

proc convert_sdc_to_sgdc {line} {
    global command_dict
    set sgdc_line $line
    #Dictionary matching of the obtained sgdc_line
    set command_type [get_command_type $line]
    puts "Command_Type:-> $command_type"
    #Check whether the command type exists in the dictionary, and if so, execute the proc of the value value of the dictionary
    if { [dict exists $command_dict $command_type] } {
        puts "command type exists in dict"
        set command_dict_proc [dict get $command_dict $command_type]
        set sgdc_line [eval $command_dict_proc [list $line]]
        return $sgdc_line
    } else {
        #If this command type does not exist, the command type is returned to the original line
        puts "command type not exists in dict"
        return $sgdc_line
    }
}

#File preprocessing
proc preprocess_sdc_file {sdc_file} {
    set input_file $sdc_file        ;# Enter the SDC file
    set output_file [file join [file dirname $sdc_file] "temp.sdc"]      ;# Output the processed SDC file

    # Open the input file to read it
    set f_in [open $input_file r]
    # Open the output file to write
    set f_out [open $output_file w]

    # 初Initiation variables
    set previous_line ""
    set merge_flag 0

    # Read the input file line by line
    while {[gets $f_in line] != -1} {
        #Replaces multiple spaces in the current line with a single space
        set line [regsub -all {\s+} $line " "]
        # Check if it's a line that starts with create_clock
        if {[string match "create_clock*" $line]} {
            set previous_line $line
            set merge_flag 1
        } elseif {[string match "assign_clock_domain*" $line]} {
            # If the current behavior starts with assign_clock_domain, check to see if there is a previous line
            if {$merge_flag == 1} {
                # Merge the previous and current lines
                puts $f_out "$previous_line; $line"
                set merge_flag 0  ;# Reset the flag
            } else {
                # If there is no merge flag, the current line is output directly
                puts $f_out $line
            }
        } else {
            # If there are no matching rows, output directly
            if {$merge_flag == 1} {
                puts $f_out $previous_line
                set merge_flag 0  ;# Reset the flag
            }
            puts $f_out $line
        }
    }

    # Process the last line
    if {$merge_flag == 1} {
        puts $f_out $previous_line
    }
    # Close the file
    close $f_in
    close $f_out
    #Returns the path of the processed SDC file
    return $output_file
}

#Put Usages here and get the options
set argc_num [llength $argv]
if { $argc_num == 0 || [lindex $argv [expr $argc_num-1]] == "-h" || [lindex $argv [expr $argc_num-1]] == "-help" } {
    xxx
    Usage
    xxx
    exit 0
} elseif { [lindex $argv [expr $argc_num-1]] == "-f" } {
    #file mode
    #get the sdc file path
    set sdc_file $given_file_path
} elseif { [lindex $argv [expr $argc_num-1]] == "-d" } {
    #directory mode
    #get the sdc file path from given directory
    set sdc_file [glob -nocomplain $given_file_path/*.sdc]
} elseif { [lindex $argv [expr $argc_num-1]] == "-dd" } {
    #directory mode
    #get the sdc file path from given directory
    set sdc_file [glob -nocomplain $given_file_path/*/*.sdc]
} else {
    xxx
    Usage
    xxx
    exit 0
}

sdc_to_sgdc $sdc_file