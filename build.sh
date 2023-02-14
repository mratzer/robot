#!/bin/bash

RELOAD_TIME_IN_SECONDS=60
NUMBER_OF_TEAMS=6
ROBOT_CACHE_DIR=robots

#ROBOCODE_HOME=/c/Users/markus.ratzer/Desktop/robocode/robocode

HEADS=()

CHANGES_DETECTED=false

prepare () {
  echo "Preparing $NUMBER_OF_TEAMS teams ..."

  for ((i=1; i<=$NUMBER_OF_TEAMS; i++)) ; do
    HEADS+=(".")
  done

  mkdir -p $ROBOT_CACHE_DIR
  rm -f $ROBOT_CACHE_DIR/*

  echo "0" > $ROBOCODE_HOME/robocodePid.tmp

  echo "Prepared $NUMBER_OF_TEAMS teams"
}

check_and_build() {
  CHANGES_DETECTED=false
  git pull --all

  for i in ${!HEADS[@]}; do
    team=$(printf "team-%02d" $((i + 1)) )
    new_head=$(git rev-parse "$team")

    if [ $new_head = ${HEADS[$i]} ]; then
      echo "Nothing to do for $team"
    else
      echo "Build robot of $team"
      HEADS[$i]=$new_head
      CHANGES_DETECTED=true

      git checkout $team
      ./mvnw clean package

      cp target/robot-$team.jar $ROBOT_CACHE_DIR/robot-$team.jar
      ROBOT_NAME=$(cat target/project.properties | grep robot.name | cut -d "=" -f2)
      echo "com.bearingpoint.robocode.$ROBOT_NAME" > $ROBOT_CACHE_DIR/robot-$team.txt
    fi
  done

  if $CHANGES_DETECTED ; then
    git checkout main
    ./mvnw clean
    echo "Stop RoboCode, delete bots and relaunch RoboCode again"
  fi

}

execute () {
  (
    echo "Executing ..."

    robocodePid=$(cat $ROBOCODE_HOME/robocodePid.tmp)

    if [ $robocodePid != 0 ]
    then
      echo "Stopping RoboCode instance with PID $robocodePid ..."
      kill $(cat $ROBOCODE_HOME/robocodePid.tmp)
      rm $ROBOCODE_HOME/robocodePid.tmp
      echo "RoboCode stopped"
    fi

    echo "Creating battle file ..."

    ROBOT_CLASS_NAMES=$(cat $ROBOT_CACHE_DIR/robot-team*.txt | tr '\n' ',')

    sed "s/robotClassNames/$ROBOT_CLASS_NAMES/g" template.battle > $ROBOT_CACHE_DIR/bearingpoint.battle

    echo "Created battle file"

    echo "Clearing RocoCode files ..."
    rm -rf $ROBOCODE_HOME/robots/*
    rm -rf $ROBOCODE_HOME/battles/bearingpoint.battle
    echo "Cleared RocoCode files"

    echo "Copying files to RoboCode ..."
    cp $ROBOT_CACHE_DIR/*.jar $ROBOCODE_HOME/robots
    cp $ROBOT_CACHE_DIR/bearingpoint.battle $ROBOCODE_HOME/battles/bearingpoint.battle
    echo "Copied files to RoboCode"


    echo "Starting RoboCode ..."

    (
      cd $ROBOCODE_HOME
      pwd
      ./robocode.bat -battle battles/bearingpoint.battle -tps 30 & echo $! > robocodePid.tmp
    )

    echo "RoboCode started ($(cat $ROBOCODE_HOME/robocodePid.tmp))"

    echo "Executed"
  )
}



prepare

while True; do

  check_and_build

  if $CHANGES_DETECTED ; then
    execute
  else
    echo "No changes, keep on rumbling"
  fi

  sleep $RELOAD_TIME_IN_SECONDS
done

