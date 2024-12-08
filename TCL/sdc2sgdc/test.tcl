set line "create_reset -sync -name rst\[1\] -sense low \[get_ports rst\[1\]\]"
set line [regsub -all {\[get_\w+.*\]$} $line ""]
puts $line