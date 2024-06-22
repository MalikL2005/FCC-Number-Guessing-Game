#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
RANDOM_NUM=$((1+ $RANDOM % 1000))

handle_numbers (){
  echo "Guess the secret number between 1 and 1000:"
  COUNT=0
  while [[ TRUE ]]; do
    COUNT=$(($COUNT + 1))
    read NUM
    if [[ $NUM =~ [a-z] ]]; then 
      echo "That is not an integer, guess again:"
    elif [[ $NUM == $RANDOM_NUM ]]; then 
      echo "You guessed it in $COUNT tries. The secret number was $RANDOM_NUM. Nice job!"
      CURRENT_GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username='$USERNAME'")
      BEST=$($PSQL "SELECT best_game FROM players WHERE username='$USERNAME'")
      if [[ $(($COUNT < $BEST)) ]]; then
        UPDATE_BEST_GAME=$($PSQL "UPDATE players SET best_game = $(($COUNT)) WHERE username='$USERNAME'")
      fi
      UPDATE_GAMES_PLAYED=$($PSQL "UPDATE players SET games_played = $(($CURRENT_GAMES_PLAYED + 1)) WHERE username='$USERNAME'")
      break
    elif [[ $NUM < $RANDOM_NUM ]]; then 
      echo "It's higher than that, guess again:"
    elif [[ $NUM > $RANDOM_NUM ]]; then
      echo "It's lower than that, guess again:"
    fi
  done
}

#application functionality 
echo "Enter your username:"
read USERNAME 
if [[ -z $($PSQL "SELECT * FROM players WHERE username='$USERNAME'") ]]
then 
echo "Welcome, $USERNAME! It looks like this is your first time here."
INSERT_USER=$($PSQL "INSERT INTO players(username, games_played, best_game) VALUES('$USERNAME', 0, 1000)")
handle_numbers
else 
GAMES_PLAYED=$($PSQL "SELECT games_played FROM players WHERE username='$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM players WHERE username='$USERNAME'")
echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
#Welcome back, <username>! You have played <games_played> games, and your best game took <best_game> guesses.
handle_numbers
fi 

