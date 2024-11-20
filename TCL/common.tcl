#This is a common file for all Tcl scripts in the project.

#color print proc
#Usage: __put_color__ <color> <text>
proc __put_color__ {color text} {
    case $color {
        -red {
            puts "\033\[31m$text\033\[0m"
        }
        -green {
            puts "\033\[32m$text\033\[0m"
        }
        -yellow {
            puts "\033\[33m$text\033\[0m"
        }
        -blue {
            puts "\033\[34m$text\033\[0m"
        }
        -magenta {
            puts "\033\[35m$text\033\[0m"
        }
        -default {
            puts $text
        }
    }
}

set dict(key1) value1
set dict(key2) value2


set my_dict [dict create key1 value1 key2 value2 key3 value3]

puts $dict(key1)
puts $my_dict
puts [dict get $my_dict key2] 