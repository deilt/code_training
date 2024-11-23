#将一个数组中的所有不够60的提到60

while true
do
    read  -p "do you want to input an array? (y/n): " switch
    if [ ${switch} == "y" ]; then
        read -p "请输入一个数组，用空格分隔：" arr
        arr=${arr}
    else
        break
    fi
done

echo "输入的数组为：${arr[*]}"

for i in ${arr[*]}
do
    if [ ${i} -lt 60 ]; then
        #arr_new[${#arr_new[@]}]=60
        arr_new+=(60)
    else
        #arr_new[${#arr_new[@]}]=$i
        arr_new+=($i)
    fi
done
echo "处理后的数组为：${arr_new[*]}"