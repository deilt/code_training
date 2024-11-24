arry=(1 2 3 4 5 6 7 8 9 10)
tmp=${arry[0]}
for i in ${arry[@]}
do
    if [ $i -gt $tmp ];then
        tmp=$i
    fi
done
echo "The biggest element in the array is: $tmp"



# Another way to do it is using a for loop and the ${#arry[*]} variable to get the length of the array.
for ((i=0;i<${#arry[*]};i++))
do
    if [ ${arry[$i]} -gt $tmp ];then
        tmp=${arry[$i]}
    fi
done
echo "The biggest element in the array is: $tmp"