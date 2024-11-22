for ((i=0;i<=100;i++))
do
    #if (( i % 2 == 1 )); then     (()) used to do arithmetic operations
    #if [ $[$i%2] -eq 1 ]; then     $[] used to do arithmetic operations
    if (( i % 2 == 1 )); then
        arr[(((i-1)/2))]=$i
        echo ${arr[(((i-1)/2))]}
    fi
done    
echo "The odd numbers are: ${arr[*]}"

