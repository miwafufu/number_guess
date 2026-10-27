#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_game -t --no-align -c"
NUMBER="$((1 + RANDOM % 1000))"
echo "Enter your username:"
read USERNAME
#check if he already exists in the system
USER_INFO=$($PSQL "SELECT name, number_of_games, personal_record FROM users WHERE name = '$USERNAME';")
if [[ -z $USER_INFO ]]
#if doesn't
then echo "Welcome, $USERNAME! It looks like this is your first time here."
INSERT_USER_RESULT=$($PSQL "INSERT INTO users(name, number_of_games, personal_record) VALUES('$USERNAME', 0, 0);")
GAMES_PLAYED=0
BEST_GAME=0
#if does
else 
IFS="|" read DB_USERNAME GAMES_PLAYED BEST_GAME <<< "$USER_INFO"
echo "Welcome back, $DB_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
#suggest guessing
echo "Guess the secret number between 1 and 1000:"
GUESS_COUNT=0
while read GUESS
do
  ((GUESS_COUNT++))
  #is not a number
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  #is right -> finish
  elif [[ $GUESS -eq $NUMBER ]]
  then
    echo "You guessed it in $GUESS_COUNT tries. The secret number was $NUMBER. Nice job!"
    break
  #is lower
  elif [[ $GUESS -lt $NUMBER ]]
  then
    echo "It's higher than that, guess again:"
  else
    echo "It's lower than that, guess again:"
  fi
done
NEW_GAMES_PLAYED=$((GAMES_PLAYED + 1))
UPDATE_GAMES_RESULT=$($PSQL "UPDATE users SET number_of_games = $NEW_GAMES_PLAYED WHERE name = '$USERNAME';")
if [[ -z "$BEST_GAME" || "$BEST_GAME" -eq 0 || "$GUESS_COUNT" -lt "$BEST_GAME" ]]
then
  UPDATE_BEST_RESULT=$($PSQL "UPDATE users SET personal_record = $GUESS_COUNT WHERE name = '$USERNAME';")
fi