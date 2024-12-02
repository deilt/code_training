set input_file "D:\\data\\code\\git_code\\code_training\\TCL\\sdc2sgdc\\input.sdc"        ;# 输入SDC文件
set output_file "output.sdc"      ;# 输出处理后的SDC文件

# 打开输入文件进行读取
set f_in [open $input_file r]
# 打开输出文件进行写入
set f_out [open $output_file w]

# 初始化变量
set previous_line ""
set merge_flag 0

# 逐行读取输入文件
while {[gets $f_in line] != -1} {
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
