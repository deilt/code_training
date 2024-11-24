#冒泡排序算法
arr=(53 100 86 92 86 55 65 76 56 59)
n=${#arr[@]}
for ((i=0;i<$n-1;i++))
do
    for ((j=$i+1;j<$n;j++))
    do
        if [ ${arr[$j]} -gt ${arr[$i]} ];then
            temp=${arr[$i]}
            arr[$i]=${arr[$j]}
            arr[$j]=$temp
        else
            continue
        fi
    done
done
echo "Sorted array: ${arr[@]}"

# 声明一个关联数组
declare -A my_dict

