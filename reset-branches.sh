#!/bin/bash

ROBOCODE_TEAMS=8

MAIN_HEAD=$(git rev-parse main)

for ((i=1; i<=$ROBOCODE_TEAMS; i++)) ; do
	team=$(printf "team-%02d" $i )

	git checkout $team

	ONE_REVISION_AFTER_MAIN=$(git rev-list --topo-order --reverse $MAIN_HEAD..HEAD | head -1)

  echo "Reset branch [${team}] to one revision after latest main revision [${MAIN_HEAD::7}]: [${ONE_REVISION_AFTER_MAIN::7}]"
	git reset --hard $ONE_REVISION_AFTER_MAIN
	git rebase main
	git push --force
done

git checkout main
