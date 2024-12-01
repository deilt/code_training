#usage:
##tclsh sdc2sgdc.tcl .sdc文件 -P "P:primitive"在.sdc文件所在路径生成新文件
##tclsh sdc2sgdc.tcl .sdc文件 -L "L:local"在当前位置生成新文件
##tclsh sdc2sgdc.tcl 文件夹 -P 将指定文件夹下所有的.sdc文件转化为.sgdc。包括子文件夹

source D:/data/code/git_code/code_training/TCL/common.tcl
##get current dir of script
set current_dir [file dirname [info script]]
# source [file join $current_dir utils.tcl]
set folder_path [lindex $argv 0]

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

proc getObj {line} {
    set startIndex [string first "get_" $line]
    set bracketCount 1
    if {$startIndex != -1} {
        for {set i $startIndex} {$i < [string length $line]} {incr i} {
            if {[string index $line $i] == "\["} {
                incr bracketCount
            } elseif {[string index $line $i] == "\]"} {
                incr bracketCount -1
            }
            if {$bracketCount == 0} {
                    break
                }
            }
            set objStart [string first " " [string range $line $startIndex end]]
            set objList [string trim [string range $line [expr $startIndex + $objStart] [expr $i - 1]] ]
            if {[regexp {^\{|\}$} $objList]} {
                set objList [string map {"{" "" "}" "" } $objList]
            }
            if {[regexp {get_pins} $line ]} {
            set lastSlashIndex [string last "/" $objList]
            if {$lastSlashIndex != -1} {
                set objList [string range $objList 0 [expr $lastSlashIndex - 1 ]]
            }
        }
        ##Hierarch
        set objList [string map [list "/" "."] $objList]
        set pattern [string range $line [expr $startIndex - 1] $i]
        set objNum [llength [split $objList]]
        if {$objNum !=0} {
          for {set i 0} {$i < $objNum} {incr i} {
            set objName [lindex $objList $i]
            ##Wildcard character
            if {[regexp {\?} $objName ] || [regexp {\*} $objName ]} {
                set objName \"$objName\"
                }
            if {[regexp {create_reset} $line ]} {
                set line1 [string map [list $pattern "-name $objName"] $line]
            } elseif {[regexp {abstract_port} $line ]} {
                set line1 [string map [list $pattern "-ports $objName"] $line]
            } else {
                set line1 [string map [list $pattern "$objName"] $line]
            }
            if {$i == [expr {$objNum - 1}]} {
                append new_line "$line1"
                # incr i
            } else {
                append new_line "$line1\n"
            }
          }  
        } else {
            set new_line $line
             __puts_color_font__ -red "$line missing obj in $pattern"
        }
    } else {
        append new_line "$line"
    } 
    return $new_line
}

##parse create_generated_clock command
proc parseGeneratedClockCmd {line} {
    set pattern {get_(ports|pins|nets)\s+(\S+)}
    set clock_source [lindex [regexp -inline $pattern $line] 2]
    set clock_source [string map [list "]" ""] $clock_source]
    if {[regexp {\[} $clock_source]} {
        set clock_source "$clock_source]"
    }
    set key [regexp {\[(.*?)\]} $line matched content]
    set source "-source $clock_source"
    set line1 [string map {"create_generated_clock" "generated_clock" \
                               "-master" "-master_clock"} $line]
    set new_line [string map [list \[$content\] $source] $line1]
    return $new_line
}

#parse create_static|set_qualifier/set_sync_cell|set_reset_synchronizer command
proc parseQualiferSyncStaticCmd {line} {
    set line1 [getObj $line]
    if {![regexp "\-value" $line1]} {
        set rest_cmd "set_reset_synchronizer -value 0 -name"
    } else {
        set rest_cmd "set_reset_synchronizer -name"
    }
    regsub "set_reset_synchronizer" $line1 "$rest_cmd" line1
    set new_line [string map {"create_static" "quasi_static -name" \
                              "set_qualifier" "qualifier -name"  \
                              "set_sync_cell" "sync_cell -name" \
                              "set_ip_block" "ip_block -name" \
                              "set_cdc_false_path" "cdc_false_path" } $line1]
    return $new_line
}

#parse set_case_analysis command
proc parseAnalysisCmd {line} {
    set analysName [lindex [regexp -inline {get_+(\S+)\s+(\S+)} $line] 2]
    # set analysName [lindex [regexp -inline {get_ports\s+(\S+)} $line] 1]
    set analysName [string map [list "]" ""] $analysName]
    if {[regexp {\[} $analysName]} {
        set analysName "$analysName]"
    }
    set num [string index $line end]
    set new_line "set_case_analysis -name $analysName -value $num"
    return $new_line
}

#parse abstract_potr|set_input_delay|set_input_delay command
proc parseAbstractPortCmd {line} {
    set clock_id_list [lindex [regexp -inline {\-clock\s+(.*)} $line] 1]
    set clkNum [llength [split [lindex $clock_id_list 0] " "]]
    if {$clkNum !=0} {
        set clk_id ""
        for {set j 0} {$j < $clkNum} {incr j} {
            set clk_id [lindex [lindex $clock_id_list 0] $j]
            set line1 [string map {"set_abstract_port" "abstract_port" \
                                    "set_input_delay"
                                    "set_output_delay" "abstract_port" \
                                    " -port" ""} $line]
            set line1 [regsub {\-delay_value\s+\d} $line1 ""]
            set line1 [getObj $line1]
            set line1 [string map [list $clock_id_list $clk_id] $line1]
            if {$j == [expr {$clkNum - 1}]} {
                append new_line "$line1"
            } else {
                append new_line "$line1\n"
            }
        }
    } else {
        set new_line $line
        __puts_color_font__ -red "sdc line '$line' missing object in clock or ports"
    }
    return $new_line
}

#parse create_reset command
proc parseCreateResetCmd {line} {
    set line1 [regsub {\-name\s+\S+} $line ""]
    set line1 [getObj $line1]
    set new_line [string map {"sense" "value" "low" "0"  "high" "1" "create_reset" "reset"} $line1]
    return $new_line 
}

set Flag 0
proc parseCreateClockCmd {line} {
    global Flag
    if {$Flag == 0} {
        set Flag 1
        return $::combined_line
    } else {
        # return  
    }
}

# parse set_top command
proc parseSetTopCmd {line} {
    set newLine [regsub {^set_top\s+-module\s+} $line "current_design "]
    if {$newLine ne 0} {
        global top
        regexp {^set_top\s+-module\s+(\S+)} $line fullMatch top
        return $newLine
    } else {
        return "//$newLine"
    } 
}

# identify if the line is command or not
proc is_cmd_line {sdcFileLine} {
    ##get cmd
    global cmd
    if {$sdcFileLine eq ""} {
        return 1
    } elseif { [regexp {(^[a-z_]+)\s+} $sdcFileLine fullMatch cmd] } {
        return $cmd
    } else {
        return 0
    }
}

# get sgdc lines
proc get_sgdc_lines {fileName} {
    set fp [open $fileName r]
    set lineList {}
    ##gets $fp's content of each line,and give content to $line 
    while { [gets $fp line] != -1 } {
        # remove spaces/tabs/new lines...
        set newLine [string trim $line]
        if { [regexp {^#} $newLine] } {
            lappend lineList [regsub "#" $newLine "//"]
            continue
        } else {
            set ret [is_cmd_line $newLine]
            if { $ret eq 1} {
                lappend lineList "$newLine"
                continue
            } elseif {![dict exists $::command_dict $ret]} {
                lappend lineList "//$newLine"
                continue
            } else {
                set Dict [[dict get $::command_dict $ret] $newLine]
                if { ${Dict} eq {}} {
                    continue
                } 
                lappend lineList $Dict
            }
        }
    }
    return $lineList
}

proc sdc2sgdc {fileName} {
    set place [lindex $::argv 1]
    if {$place eq "\-P"} {
        set newFileName [regsub {\.sdc} $fileName {.sgdc}]
    } elseif {$place eq "\-L"} {
        set fileNameWithoutPath [file tail $fileName]
        set fileRootName [file rootname $fileNameWithoutPath]
        set newFileName "${fileRootName}.sgdc"
        set newFilePath [file join [file dirname [info script]] $newFileName]
    } else {
        puts "please specify the location of the new file add option \-P or \-L"
        puts "\-L means Generate a new file at the current location"
        puts "\-P means Generate a new file at the location of .sdc file"
    }
    puts "newFileName:$newFileName"
    set fp [open $newFileName w+]
    foreach line [get_sgdc_lines $fileName] {
        puts $fp $line
    }
    close $fp
}
proc dealclkinfo {fileName} {
    set fileID [open $fileName r]
    ###get clock info
    set tmp ""
    while {[gets $fileID line] != -1} {
        if {[regexp {(create_clock|assign_clock_domain)\s+.*$} $line ]} {
            lappend tmp "$line"
        }
    }
    close $fileID
    set clkName ""
    set clkPort ""
    global combined_line
    global clock_list
    set clock_list ""
    set combined_line ""
    ## deal clock info
    if {$tmp ne ""} {
    foreach line $tmp {
        set domainFlag 0
        set pattern {get_(ports|nets|pins)\s+(\S+)}
        set clkName [lindex [regexp -inline {\-name\s+(\S+)} $line] 1]
        set clock_port_name [lindex [regexp -inline $pattern $line] 2]
        set clock_port_name [string map [list "]" ""] $clock_port_name]
        if {[regexp {\[} $clock_port_name]} {
                set clock_port_name "$clock_port_name]"
            }
            if {"$clkName" ne "$clock_port_name"} {
                append clock_list "$clkName:$clock_port_name "
            }
            if {"$clock_port_name" ne ""} {
                foreach domain_line $tmp {
                    if {[regexp {\-domain \{} $domain_line]} {
                    set clkDomain [lindex [regexp -inline {\-domain\s+(.*\})} $domain_line] 1]
                    set clkDomain [string map [list "{" "" "}" ""] $clkDomain]
                    set domain_num [llength [split $clkDomain " "]]
                    if {$domain_num > 1} {
                        set clkDomain \"$clkDomain\"
                    }
                } else {
                    set clkDomain [lindex [regexp -inline {\-domain\s+(\S+)} $domain_line] 1]
                }
                if {[regexp {\-(clock|clocks) \{} $domain_line]} {
                    set clock_name [lindex [regexp -inline {\-(clock|clocks)\s+\{(.*?)\}} $domain_line] 2]
                } else {
                    set clock_name [lindex [regexp -inline {\-(clock|clocks)\s+(\S+)} $domain_line] 2]
                }
                set clkNum [llength $clock_name]
                for {set i 0} {$i < $clkNum} {incr i} {
                    set clock_name1 [lindex $clock_name $i]
                    if {$clkName eq $clock_name1} {
                    append combined_line "clock -name $clock_port_name -domain $clkDomain\n"
                    set domainFlag 1
                    }
                }
            }
            if {$domainFlag == 0} {
                append combined_line "clock -name $clock_port_name -domain $clkName\n"
            }
        } 
        if {$clkName ne "" && $clock_port_name eq ""} {
            append combined_line "clock -tag $clkName\n"
        }
    }
    } else {
        puts "file $fileName no clock"
    }
    sdc2sgdc $fileName
    set ::Flag 0
    set ::combined_line ""
    set ::clock_list ""
}

proc traverse_and_convert {folder_path} {
    # get file
    set files [glob -nocomplain -directory $folder_path *]
    foreach file $files {
        if {[file isdirectory $file]} {
            traverse_and_convert $file
        } elseif {[file isfile $file]} {
            set file_extension [file extension $file]
            if {$file_extension eq ".sdc"} {
                dealclkinfo $file
            }
        }
    }
}

if {[file isdirectory $folder_path]} {
    ##file folder
        traverse_and_convert $folder_path
    } elseif {[file isfile $folder_path] && [file extension $folder_path] eq ".sdc"} {
    # .sdc file
        dealclkinfo $folder_path
    } else {
        puts "Invalid input. Please provide a valid folder path or .sdc file."
}
