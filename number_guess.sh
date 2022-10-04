#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

#Generate a random number
MYNUMBER=$(( $RANDOM % 1000 +1 ))
echo $MYNUMBER
#reguest a username
echo "Enter your username:"
read USERNAME
#get the username from the DB
USERNAME_RESULT="$($PSQL "SELECT username FROM users WHERE username='$USERNAME';")"
#if it is in the DB...
if [[ -z $USERNAME_RESULT ]]
then
   #add new user to DB
  INSERT_NEW_USER="$($PSQL "INSERT INTO users(username) VALUES('$USERNAME');")"
  #welcome new user
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  GAMES_PLAYED=0
else
  #get exisitng user data
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE username='$USERNAME';")
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE username='$USERNAME';")
  #echo "BG: $BEST_GAME GP: $GAMES_PLAYED"
  #welcome existing user
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
GUESS_NO=0
GUESS_GAME(){
  GUESS_NO=$(( $GUESS_NO + 1 ))
  #echo "Guess Number: $GUESS_NO"
  read GUESS
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    #if the guess is an interger
    if [[ $GUESS == $MYNUMBER ]]
    then
      echo "You guessed it in $GUESS_NO tries. The secret number was $MYNUMBER. Nice job!"
      #update DB with games played and high score
      NEW_GAMES_PLAYED=$(( $GAMES_PLAYED +1 ))
      GAMES_PLAYED_UPDATE="$($PSQL "UPDATE users SET games_played=$NEW_GAMES_PLAYED WHERE username='$USERNAME';")"

      #echo "Your previous best game was $BEST_GAME and this game was $GUESS_NO"
      if [[ (-z $BEST_GAME) || ($GUESS_NO < $BEST_GAME) ]]
      then
        #echo "New High Score!"
        BEST_GAME_UPDATE="$($PSQL "UPDATE users SET best_game=$GUESS_NO WHERE username='$USERNAME';")"
        #echo "Your best score was $BEST_GAME but now it is $GUESS_NO"
      fi

    else
      if [[ $GUESS -lt $MYNUMBER ]]
      then
        echo "It's higher than that, guess again:"
      else
        echo "It's lower than that, guess again:"
      fi
      #Guess again
      GUESS_GAME
    fi
  else
    #if the guess is not an int
    echo That is not an integer, guess again:
    #Guess again
    GUESS_GAME
  fi
}
GUESS_GAME
