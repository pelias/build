#!/bin/bash
set -euo pipefail # http://redsymbol.net/articles/unofficial-bash-strict-mode/

touch /tmp/.pelias-build-started

echo "building"
sleep 5
rm /tmp/.pelias-build-started
