# 初始字符串
set line "reset -sync -name rst -value 0 \[get_ports rst1\]"

# 需要替换的变量
set name_get "rst"
set reset_name "rst1"

# 使用string map进行替换
set modified_line [string map [list $name_get $reset_name] $line]
# 输出替换后的字符串
puts $modified_line
