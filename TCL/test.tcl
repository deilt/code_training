set a 19
puts a

生成一个1到10输出的for循环：

for {set i 1} {$i <= 10} {incr i} {
    puts $i
}

生成一个1到10输出的while循环：

set i 1
while {$i <= 10} {
    puts $i
    incr i
}   

# 尝试打开文件并处理可能的错误
if {[catch {open "d:\data\code\test.txt" r} file]} {
    puts "无法打开文件: $file"
    return
}

# 使用foreach循环替代while循环，简化代码
set lineNumber 0
foreach line [split [read $file] \n] {
    if {[string match *had* $line]} {
        puts "$lineNumber: $line"
    }
    incr lineNumber
}

# 关闭文件
close $file


