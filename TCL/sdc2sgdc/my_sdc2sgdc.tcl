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
proc get_object_name {line} {
    # 从输入行中提取对象名称
}

proc parseSetTopCmd {line} {
    #'set_top -module TOP'字符串转换为'current_design TOP',TOP的名字不一定是TOP，需要保存
    # 从输入行中提取模块名称
    puts "In parseSetTopCmd. Execute: --->> $line"
    set top_module_name [lindex $line 2]  ; # 假设格式为 "set_top -module MODULE_NAME"
    # 输出当前设计命令
    puts ">>> current_design $top_module_name"
    # 返回转换后的行
    return "current_design $top_module_name"
}


proc parseCreateClockCmd {line} {
    #将create_clock -name clka [get_ports clk3]转换为clock -name clk3 -domain clka
    puts "In parseCreateClockCmd. Execute: --->> $line"
    #将create_clock 转换为clock
    set line [string map {"create_clock" "clock"} $line]
    #获取-name所在的位置，并获取-name后面的第一个子字符串直至遇到空格或者换行
    # 找到-name的位置并提取后面的子字符串
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
    # 查找[get_ports]、[get_nets]或[get_pins]并提取相应内容
    set command_position [string first "\[" $line]
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
    return "clock -name $clock_name -domain $variable_name"
}

proc parseCreateResetCmd {line} {
}

proc parseAbstractPortCmd {line} {
}

proc parseAnalysisCmd {line} {
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
    # 打开SDC文件读取内容
    set sdc_handle [open $sdc_file r]
    # 生成sgdc文件并打开SGDC文件写入内容
    set sgdc_file [file join [file dirname $sdc_file] [file rootname $sdc_file].sgdc]
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
        set command_dict [dict get $command_dict $command_type]
        set sgdc_line [eval $command_dict [list $line]]
        return $sgdc_line
    } else {
        #不存在该命令类型，则直接返回原行
        puts "command type not exists in dict"
        return $sgdc_line
    }
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