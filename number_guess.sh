#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER=$(($RANDOM % 1000 + 1))

echo "Enter your username:"
read NAME

USER=$($PSQL "SELECT * FROM users WHERE name = '$NAME'")
echo $USER

if [[ -z $USER ]]
then
  echo "Welcome, $NAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name = '$NAME'")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name = '$NAME'")

  echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS
COUNT=1

until [ $GUESS = $NUMBER ]
do
  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif [ $GUESS -le $NUMBER ]
  then
    echo "It's higher than that, guess again:"
  elif [ $GUESS -gt $NUMBER ]
  then
    echo "It's lower than that, guess again:"
  fi
  read GUESS
  (( COUNT++ ))
done

echo "You guessed it in $COUNT tries. The secret number was $NUMBER. Nice job!"

if [[ -z $USER ]]
then
  INSERT_RESULT=$($PSQL "INSERT INTO users(name, games_played, best_game) VALUES('$NAME', 1, $COUNT)")
else
  (( GAMES_PLAYED++ ))
  if [ $COUNT -le $BEST_GAME
  then
    BEST_GAME=$COUNT
  fi
  UPDATE_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $BEST_GAME WHERE name = '$NAME'")
fi
