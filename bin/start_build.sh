#!/bin/bash
set -euo pipefail # http://redsymbol.net/articles/unofficial-bash-strict-mode/

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );

if [[ ! -v PELIAS_BUILD_DIR ]]; then
	echo "PELIAS_BUILD_DIR must be set"
	exit 1
fi

export PELIAS_BUILD_TRACKING_FILE="$PELIAS_BUILD_DIR/.pelias-build-started"

# set up logging
export PELIAS_LOG_DIR="$PELIAS_BUILD_DIR/logs"
export PELIAS_CURRENT_LOG_DIR="$PELIAS_LOG_DIR/`date -Iseconds`"
mkdir -p $PELIAS_CURRENT_LOG_DIR

# function to kick off a the build script as a separate process that will not prevent this one from finishing
start_build () {
	nohup $DIR/../script/build_pelias.sh > $PELIAS_CURRENT_LOG_DIR/build.log 2>$PELIAS_CURRENT_LOG_DIR/build.err &
}

# no temp file exists, so no build is running or crashed. just start a build
if [[ ! -f $PELIAS_BUILD_TRACKING_FILE ]]; then
	echo "starting new build"
	start_build
	exit 0
fi

# a build is running or crashed. determine which one
if pgrep 'build_pelias.sh' > /dev/null ; then #check if a process with the name of the script is currently running
	echo "a build is currently running. another will not be started"
else
	echo "build not currently running, but tmp file present, so it probably crashed"
	if [[ ! -v ABORT_IF_LAST_BUILD_FAILED ]]; then
		echo "not starting a new build"
	else
		echo "starting a new build anyway"
		start_build
	fi
fi
