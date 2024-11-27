source D:/data/code/git_code/code_training/TCL/common.tcl

#Usage: my_sdc2sgdc.tcl <sdc_file> <-f>
#Usage: my_sdc2sgdc.tcl <sdc_file> <-d>
proc Usage {} {
   __puts_color_font__ -green "Usage: my_sdc2sgdc.tcl <sdc_file> <-f> or <-d>"
}
proc xxx {} {
    puts "###############################################################"
}

#scrpt path
set scrpt_path [file dirname [info script]]
__puts_color_font__ -red "scrpt_path     : $scrpt_path"
#given sdc file path
set given_file_path [lindex $argv 0]
__puts_color_font__ -red "given_file_path: $given_file_path"

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
