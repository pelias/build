#!/bin/bash
set -euo pipefail # http://redsymbol.net/articles/unofficial-bash-strict-mode/

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd );

#ABORT_IF_LAST_BUILD_FAILED=true

if [[ -f /tmp/.pelias-build-started ]]; then # check if build temp file exists
	if pgrep 'build_pelias.sh' > /dev/null ; then #check if a process with the name of the script is currently running
		echo "a build is currently running. another will not be started"
	else
		echo "build not currently running, but tmp file present, so it probably crashed"
		if [[ -v ABORT_IF_LAST_BUILD_FAILED ]]; then
			echo "not starting a new build"
		else
			echo "starting a new build anyway"
			nohup $DIR/../script/build_pelias.sh > /tmp/pelias-log.log 2>/tmp/pelias-err.log &
		fi
	fi
else
	echo "starting new build"
	nohup $DIR/../script/build_pelias.sh > /tmp/pelias-log.log 2>/tmp/pelias-err.log &
fi

