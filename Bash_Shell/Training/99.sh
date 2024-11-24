# 9*9 乘法表(编写 shell 脚本,打印 9*9 乘法表) 
for ((i=1;i<=9;i++))
do
    for ((j=1;j<=i;j++))
    do
        echo -n "$i*$j=$((i*j)) "
    done
    echo 
done

