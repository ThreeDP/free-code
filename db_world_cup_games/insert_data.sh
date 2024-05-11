#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

function insert_team {
  local TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$1'")
  if [[ -z $TEAM_ID ]]
  then
    local INSERT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$1')")
    local TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name = '$1'")
    if [[ $INSERT_RESULT == "INSERT 0 1" ]]
    then
      local TEAM_ID=$TEAM_ID";Insert Team: '$1'"
    fi
  fi
  echo $TEAM_ID
}

echo "$($PSQL "TRUNCATE games, teams")"

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WIN_GOALS OPPO_GOALS
do
  if [[ YEAR -ne "year" ]]
  then
    WINNER_RESPONSE=$(insert_team "$WINNER"); IFS=";" read -a WINNER_ID <<< $WINNER_RESPONSE; echo ${WINNER_ID[1]}
    OPPONENT_RESPONSE=$(insert_team "$OPPONENT"); IFS=";" read -a OPPONENT_ID <<< $OPPONENT_RESPONSE; echo ${OPPONENT_ID[1]}

    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', ${WINNER_ID[0]}, ${OPPONENT_ID[0]}, $WIN_GOALS, $OPPO_GOALS)")
    if [[ $INSERT_GAME_RESULT = "INSERT 0 1" ]]
    then
      echo "Insert Game: $WINNER $WIN_GOALS X $OPPO_GOALS $OPPONENT at round: $ROUND $YEAR"
    fi
  fi
done
