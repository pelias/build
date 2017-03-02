#!/bin/bash
set -euo pipefail # http://redsymbol.net/articles/unofficial-bash-strict-mode/

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );

if [[ ! -v PELIAS_BUILD_DIR ]]; then
	echo "PELIAS_BUILD_DIR must be set"
	exit 1
fi

export PELIAS_BUILD_TRACKING_FILE="$PELIAS_BUILD_DIR/.pelias-build-started"

# no temp file exists, so no build is running or crashed. just start a build
if [[ ! -f $PELIAS_BUILD_TRACKING_FILE ]]; then
	echo "no running build found"
	exit 0
fi

# a build is running or crashed. determine which one
if pgrep 'build_pelias.sh' > /dev/null ; then #check if a process with the name of the script is currently running
  echo "killing build"
  killall -g 'build_pelias.sh'
else
  echo "no running build found, but the last one appears to have crashed"
fi
