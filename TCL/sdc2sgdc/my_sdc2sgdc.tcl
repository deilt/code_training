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
dict set command_dict create_static parseQualiferSyncStati
dict set command_dict set_qualifier parseQualiferSyncStaticCmd
dict set command_dict set_sync_cell parseQualiferSyncStaticCmd
dict set command_dict set_reset_synchronizer parseQualiferSyncStaticCmd
dict set command_dict set_ip_block parseQualiferSyncStaticCmd
dict set command_dict set_cdc_false_path parseQualiferSyncStaticCmd
dict set command_dict create_generated_clock parseGeneratedClockCmd
######################################################################

################################# Proc of Dict ###############################
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
    set line [string map {"set_case_analysis" "analysis"} $line]
}

proc parseQualiferSyncStaticCmd {line} {
}

proc parseQualiferSyncStati {line} {
}

proc parseGeneratedClockCmd {line} {
}

############################# Main #############################
#1. Read the SDC file.
#2. Parse the content of the SDC file.
#3. Convert the SDC content to SGDC format.
#4. Write the converted content to the SGDC file.
#########################################################################

############################# Read sdc file #############################
proc sdc_to_sgdc {sdc_file} {
    # 预处理SDC文件
    set sdc_file_temp [preprocess_sdc_file $sdc_file]
    # 打开SDC文件读取内容
    set sdc_handle [open $sdc_file_temp r]
    # 生成sgdc文件并打开SGDC文件写入内容
    set sgdc_file [file join [file dirname $sdc_file_temp] [file rootname $sdc_file].sgdc]
    set sgdc_handle [open $sgdc_file w]
    # 逐行读取SDC文件
    while {[gets $sdc_handle line] >= 0} {
        # 解析SDC文件的每一行,并去除两端的空格
        set line [string trim $line]
        # 跳过空行和注释
        if {[string equal $line ""]} {
            puts $sgdc_handle $line  ; # 直接写入空行
            continue
        }
        # 处理注释行
        if {[string match "#" [string index $line 0]]} {
            set modified_line [string map {"#" "//"} $line]
            puts $sgdc_handle $modified_line  ; # 直接写入注释
            continue
        }
        xxx
        __puts_color_font__ -blue "In Process:-> $line"
        # 根据SDC语法进行转换
        set sgdc_line [convert_sdc_to_sgdc $line]
        puts $sgdc_handle $sgdc_line
    }

    # 关闭文件句柄
    close $sdc_handle
    close $sgdc_handle
    #删除临时文件sdc_file
    file delete $sdc_file_temp
}

proc get_command_type {line} {
    # 解析SDC文件每一行的命令类型
    set command_type [lindex $line 0]
    return $command_type
}

proc convert_sdc_to_sgdc {line} {
    global command_dict
    set sgdc_line $line
    #将获取的sgdc_line 进行字典匹配
    set command_type [get_command_type $line]
    puts "Command_Type:-> $command_type"
    #判断字典中是否存在该命令类型，有的话执行该字典的value值的proc
    if { [dict exists $command_dict $command_type] } {
        puts "command type exists in dict"
        set command_dict_proc [dict get $command_dict $command_type]
        set sgdc_line [eval $command_dict_proc [list $line]]
        return $sgdc_line
    } else {
        #不存在该命令类型，则直接返回原行
        puts "command type not exists in dict"
        return $sgdc_line
    }
}

#文件预处理
proc preprocess_sdc_file {sdc_file} {
    set input_file $sdc_file        ;# 输入SDC文件
    set output_file [file join [file dirname $sdc_file] "temp.sdc"]      ;# 输出处理后的SDC文件

    # 打开输入文件进行读取
    set f_in [open $input_file r]
    # 打开输出文件进行写入
    set f_out [open $output_file w]

    # 初始化变量
    set previous_line ""
    set merge_flag 0

    # 逐行读取输入文件
    while {[gets $f_in line] != -1} {
        #将当前行中存在多个空格替换成一个空格
        set line [regsub -all {\s+} $line " "]
        # 检查是否为以 create_clock 开头的行
        if {[string match "create_clock*" $line]} {
            set previous_line $line
            set merge_flag 1
        } elseif {[string match "assign_clock_domain*" $line]} {
            # 如果当前行为以 assign_clock_domain 开头，检查是否有前一行
            if {$merge_flag == 1} {
                # 合并前一行和当前行
                puts $f_out "$previous_line; $line"
                set merge_flag 0  ;# 重置标志
            } else {
                # 如果没有合并标志，则直接输出当前行
                puts $f_out $line
            }
        } else {
            # 如果没有匹配的行，直接输出
            if {$merge_flag == 1} {
                puts $f_out $previous_line
                set merge_flag 0  ;# 重置标志
            }
            puts $f_out $line
        }
    }

    # 处理最后一行
    if {$merge_flag == 1} {
        puts $f_out $previous_line
    }
    # 关闭文件
    close $f_in
    close $f_out
    #返回处理后的SDC文件路径
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