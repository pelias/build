#!/bin/bash
set -euo pipefail # http://redsymbol.net/articles/unofficial-bash-strict-mode/

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );
PATH="${PATH}:$DIR/../bin" # make it easier to run scripts

# use a file to mark that a build has started
touch $PELIAS_BUILD_TRACKING_FILE

start_time=$SECONDS
notify_slack "a pelias build is starting"

# do the build
sleep 5

# remove tracking file, signifying a successfully completed build
rm $PELIAS_BUILD_TRACKING_FILE

# report on success
elapsed_time=$(( $SECONDS - $start_time ))
friendly_elapsed_time=`echo $((elapsed_time/86400))" days "$(date -d "1970-01-01 + $elapsed_time seconds" "+%H hours %M minutes %S seconds")` # calculate elapsed time from http://unix.stackexchange.com/questions/27013/displaying-seconds-as-days-hours-mins-seconds
notify_slack "a build has finished! time taken: $friendly_elapsed_time"
