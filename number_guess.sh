#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"


echo -e "\n~~~ Welcome to Number Guessing Game ~~~\n"
echo Enter your username:
read USERNAME
#GET USER ID
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")
GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name='$USERNAME'")
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name='$USERNAME'")
#IF NOT FOUND
if [[ -z $USER_ID ]]
then
  #INSERT USER
  INSERT_USER=$($PSQL "INSERT INTO users(name, games_played, best_game) VALUES('$USERNAME', 0, 0)")
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
else
  #IF FOUND
  echo -e "\nWelcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

#START THE GAME
#PREPARATION
RAN_NUM=$[ $RANDOM % 1000 + 1 ]
TRIES_COUNT=0
echo -e "\nGuess the secret number between 1 and 1000:"

GAME() {
  read INPUT
  TRIES_COUNT=$(( TRIES_COUNT + 1 ))
  if [[ $INPUT =~ ^[0-9]+$ ]]
  then
    if [[ $INPUT > $RAN_NUM ]]
    then
      echo -e "\nIt's lower than that, guess again:"
      GAME
    elif [[ $INPUT < $RAN_NUM ]]
    then 
      echo -e "\nIt's higher than that, guess again:"
      GAME
    elif [[ $INPUT == $RAN_NUM ]]
    then
      echo You guessed it in $TRIES_COUNT tries. The secret number was $RAN_NUM. Nice job!
    fi
  else 
    echo -e "\nThat is not an integer, guess again:"
    TRIES_COUNT=$(( TRIES_COUNT - 1 ))
  fi
}
GAME
#UPDATE DATA
GAMES_PLAYED=$(( GAMES_PLAYED + 1 ))
if [[ $BEST_GAME > $TRIES_COUNT || -z $BEST_GAME ]]
then
  UPDATE1=$($PSQL "UPDATE users SET games_played='$GAMES_PLAYED' WHERE name='$USERNAME'")
  UPDATE2=$($PSQL "UPDATE users SET best_game='$TRIES_COUNT' WHERE name='$USERNAME'")
else
  UPDATE=$($PSQL "UPDATE users SET games_played='$GAMES_PLAYED' WHERE name='$USERNAME'")
fi

#done
