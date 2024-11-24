random_num=$((RANDOM % 100 + 1))
echo "The random number is: $random_num"
while true
do
    read -p "there is generate a random number between 1 and 100, guess it: " num
    if [ $num -eq $random_num ];then
        echo "Congratulations, you guess the number!"
        break
    elif [ $num -gt $random_num ];then
        echo "The number is smaller than $num"
    else
        echo "The number is larger than $num"
    fi
done

