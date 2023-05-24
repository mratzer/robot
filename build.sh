#!/bin/bash

RELOAD_TIME_IN_SECONDS=60
ROBOT_CACHE_DIR=robots

#ROBOCODE_TEAMS=6
#ROBOCODE_HOME=/c/Users/markus.ratzer/Desktop/robocode/robocode

CHANGES_DETECTED=false
FIRST_TIME=true

if [ -z "${ROBOCODE_HOME}" ]; then
	echo "You need to set environment variable ROBOCODE_HOME !"
	exit 1
fi

if [ -z "${ROBOCODE_TEAMS}" ]; then
	echo "You need to set environment variable ROBOCODE_TEAMS - the number of participating teams (1 - 8)!"
	exit 1
fi

prepare () {
  echo "Preparing $ROBOCODE_TEAMS teams ..."

  mkdir -p $ROBOT_CACHE_DIR
  rm -f $ROBOT_CACHE_DIR/*

  echo "0" > $ROBOCODE_HOME/robocodePid.tmp

  echo "Prepared $ROBOCODE_TEAMS teams"
}

check_and_build() {
  CHANGES_DETECTED=false
  git fetch --all

#  for i in ${!HEADS[@]}; do
#    team=$(printf "team-%02d" $((i + 1)) )
  for ((i=1; i<=$ROBOCODE_TEAMS; i++)) ; do
    team=$(printf "team-%02d" $i )
    local_head=$(git rev-parse "$team")
    remote_head=$(git rev-parse "origin/$team")
	
	if $FIRST_TIME || [ $local_head != $remote_head ]; then
		git checkout $team
		CHANGES_DETECTED=true
		
		if [ $local_head != $remote_head ]; then
			git pull
		fi

		echo "Build robot of $team"
		./mvnw clean package

		cp target/robot-$team.jar $ROBOT_CACHE_DIR/robot-$team.jar
		ROBOT_NAME=$(cat target/project.properties | grep robot.name | cut -d "=" -f2)
		echo "com.bearingpoint.robocode.$ROBOT_NAME" > $ROBOT_CACHE_DIR/robot-$team.txt
	else
		echo "Nothing to do for $team"
	fi
  done

  if $CHANGES_DETECTED ; then
    git checkout main
    ./mvnw clean
    echo "Stop RoboCode, delete bots and relaunch RoboCode again"
  fi

  FIRST_TIME=false
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
      ./robocode.bat -battle battles/bearingpoint.battle -tps 25 & echo $! > robocodePid.tmp
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

