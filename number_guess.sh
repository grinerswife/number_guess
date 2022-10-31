#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t -Ac"

THE_NUMBER=$[$RANDOM % 1000 + 1]
#echo $THE_NUMBER
tries=0

echo Enter your username:
read USERNAME

#check database for username
CHECK_NAME=$($PSQL "SELECT name FROM users WHERE name='$USERNAME'")

#if no username, add to database
if [[ -z $CHECK_NAME ]]
then
  echo -e "Welcome, $USERNAME! It looks like this is your first time here."
  ADD_USER=$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")
  USER_NAME=$($PSQL "SELECT name FROM users WHERE name='$USERNAME'")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")

#greet user and tell game history
else
  USER_NAME=$($PSQL "SELECT name FROM users WHERE name='$USERNAME'")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
  GAMES_RESULT=$($PSQL "SELECT COUNT(game_id) FROM games WHERE user_id=$USER_ID")
  #GAMES_PLAYED=${#GAMES_RESULT[@]}
  BEST_GAME=$($PSQL "SELECT MIN(num_guesses) FROM games WHERE user_id=$USER_ID")
  echo Welcome back, $USER_NAME! You have played $GAMES_RESULT games, and your best game took $BEST_GAME guesses.
fi

#guess the secret number
echo Guess the secret number between 1 and 1000:

while read THE_GUESS
do
  ((tries++))
    if [[ ! $THE_GUESS =~ ^[0-9]+$ ]]; then
      echo -e "That is not an integer, guess again:";
    continue
  fi

  if [[ $THE_NUMBER -lt $THE_GUESS ]]; then
    echo -e "It's lower than that, guess again:"
    continue
  fi

  if [[ $THE_NUMBER -gt $THE_GUESS ]]; then
    echo -e "It's higher than that, guess again:";
    continue
  fi

  if [[ $THE_GUESS -eq $THE_NUMBER ]]; then
    break
  fi

done

#correct guess
echo You guessed it in $tries tries. The secret number was $THE_NUMBER. Nice job!

#add game to database
ADD_GAME=$($PSQL "INSERT INTO games(user_id, num_guesses, secret_num) VALUES($USER_ID, $tries, $THE_NUMBER)")
