#!/bin/bash

echo '----- GIT alias configuration ------'
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage reset HEAD --
git config --global alias.last log -1 HEAD
git config --global alias.cob checkout -b
git config --global alias.alias config --get-regexp ^alias\.
git config --global alias.rtl reset --hard HEAD

exit 0
