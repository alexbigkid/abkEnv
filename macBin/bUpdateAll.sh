#!/bin/sh

echo "-> $0"
brew update || exit $?
./bUpdateAllPkgs.sh || exit $?
./bUpdateAllCasks.sh || exit $?
echo "<- $0"
exit 0
