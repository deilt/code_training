
 #创建任意数字及长度的数组，根据客户的需求加入元素
i=0
while true
do
    read -p "would you like to input elements? (y/n): " input_elements
    if [ $input_elements == "y" ] ; then
        #获取输入，数组长度
        read -p "please input the array elements: " elements
        array[$i]=$elements
        #i=$[($i+1)]
        let i++
    else
        break
    fi
done

echo "The array is: ${array[*]}"