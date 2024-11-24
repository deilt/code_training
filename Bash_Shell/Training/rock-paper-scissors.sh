#generate rock/paper/scissors
RPS=(rock paper scissors)
computer_choice=${RPS[$((RANDOM%3))]}
echo "Computer choice: $computer_choice"

#get user input
echo "Enter your choice (rock/paper/scissors):"
read user_choice
echo "You chose: $user_choice"

#determine winner
case $user_choice in
    rock)
        if [ $computer_choice == "scissors" ]; then
            echo "You win!"
        elif [ $computer_choice == "paper" ]; then
            echo "Computer wins!"
        else
            echo "Tie!"
        fi
        ;;
    paper)
        if [ $computer_choice == "rock" ]; then
            echo "You win!"
        elif [ $computer_choice == "scissors" ]; then
            echo "Computer wins!"
        else
            echo "Tie!"
        fi
        ;;
    scissors)
        if [ $computer_choice  == "paper" ]; then
            echo "You win!"
        elif [ $computer_choice == "rock" ]; then
            echo "Computer wins!"
        else
            echo "Tie!"
        fi
        ;;
    *)
        echo "Invalid choice. Please try again."
        ;;
esac