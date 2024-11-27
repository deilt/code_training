#This is a common file for all Tcl scripts in the project.

#color print proc
#Usage: __puts_color_font__ <color> <text>
proc __puts_color_font__ {color text} {
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