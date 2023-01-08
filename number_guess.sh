#!/bin/bash

PSQL="psql -U freecodecamp -d number_guessing_game --quiet --no-align --tuples-only -c"

NUMBER=$(( $RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

QUERY_NAME_RESULT=$($PSQL "select games_played, best_game from users where name='$USERNAME'")
if [[ -z $QUERY_NAME_RESULT ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "insert into users(name) values('$USERNAME')"
  GAMES_PLAYED=0
  BEST_GAME=9999
else
  read GAMES_PLAYED BEST_GAME <<< $(echo $QUERY_NAME_RESULT | sed 's/|/ /g')
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

NUM_GUESSES=0
echo "Guess the secret number between 1 and 1000:"

while true; do
  read GUESS
  NUM_GUESSES=$(( $NUM_GUESSES + 1 ))

  if [[ ! $GUESS =~ ^[0-9]+$ ]]
  then
    echo "That is not an integer, guess again:"
  elif (( $GUESS < $NUMBER ))
  then
    echo "It's higher than that, guess again:"
  elif (( $GUESS > $NUMBER ))
  then
    echo "It's lower than that, guess again:"
  else
    echo "You guessed it in $NUM_GUESSES tries. The secret number was $NUMBER. Nice job!"
    break
  fi
done

$PSQL "update users set games_played=$(( $GAMES_PLAYED + 1 )) where name='$USERNAME'"

if (( $NUM_GUESSES < $BEST_GAME ))
then
  $PSQL "update users set best_game=$NUM_GUESSES where name='$USERNAME'"
fi
