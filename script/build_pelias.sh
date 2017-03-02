#!/bin/bash
set -euo pipefail # http://redsymbol.net/articles/unofficial-bash-strict-mode/

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
PATH="${PATH}:$DIR/../bin" # make it easier to run scripts

# function to be called on any exit
handle_exit () {
	exit_code=$? # capture exit code for script
	elapsed_time=$(( $SECONDS - $start_time ))
	friendly_elapsed_time=`echo $((elapsed_time/86400))" days "$(date -d "1970-01-01 + $elapsed_time seconds" "+%H hours %M minutes %S seconds")` # calculate elapsed time from http://unix.stackexchange.com/questions/27013/displaying-seconds-as-days-hours-mins-seconds

	if [[ "$exit_code" -ne "0" ]]; then # check if exit-code is non-zero (which means the script failed)
		notify_slack "a build has failed! time taken: $friendly_elapsed_time"
		exit $exit_code # exit with that same error code
	else
		notify_slack "a build has finished! time taken: $friendly_elapsed_time"
		rm $PELIAS_BUILD_TRACKING_FILE # remove tracking file, signifying a successfully completed build
	fi
}

trap handle_exit EXIT

# use a file to mark that a build has started
touch $PELIAS_BUILD_TRACKING_FILE

start_time=$SECONDS
notify_slack "a pelias build is starting"

# set any required variables
PELIAS_BUILD_PARALLEL_JOBS=${PELIAS_BUILD_PARALLEL_JOBS:-"2"}

# do the build
# step 1: download any data required before the build starts
# this is done by running each script in `download_scripts` in parallel
ls $DIR/download_scripts | parallel -j $PELIAS_BUILD_PARALLEL_JOBS --halt 2 $DIR/download_scripts/{}

# step 2: start the build with gnu parallel
# this is done by running each script in `build_scripts` in parallel
# (they manage whether or not anything shouild be done themselves)
ls $DIR/build_scripts | parallel -j $PELIAS_BUILD_PARALLEL_JOBS --halt 2 $DIR/build_scripts/{}
