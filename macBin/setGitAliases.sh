#!/bin/bash

ABK_COLOR_FILE="env/abk_colors.env"
[ -f $ABK_COLOR_FILE ] && . $ABK_COLOR_FILE

echo -e "${YELLOW}-> $0${NC}"
echo '----- GIT alias configuration ------'

git config --global alias.alias "config --get-regexp ^alias\."
git config --global alias.br branch
git config --global alias.brr "!git fetch -p && git branch -r"
git config --global alias.ci commit
git config --global alias.co checkout
git config --global alias.dbranch "!git checkout master && git branch -D $1 && git push origin --delete $1"
git config --global alias.drbranch "!git checkout master && git push origin --delete $1"
git config --global alias.cob "checkout -b"
git config --global alias.hist "log --pretty=format:'%h %ad | %s%d [%an]' --graph --date=short"
git config --global alias.last "log -1 HEAD"
git config --global alias.logg 'log --pretty=format:"%h %s" --graph'
git config --global alias.rtl "reset --hard HEAD"
git config --global alias.sinceYesterday "log --pretty=format:'%Cred%h %Cgreen%cd%Creset | %s%C(auto)%d %Cgreen[%an]%Creset' --date=local --since=yesterday.midnight"
git config --global alias.st status
git config --global alias.today "log --pretty=format:'%Cred%h %Cgreen%cd%Creset | %s%C(auto)%d %Cgreen[%an]%Creset' --date=local --since=midnight"
git config --global alias.unstage "reset HEAD --"
git config --global alias.yesterday "log --pretty=format:'%Cred%h %Cgreen%cd%Creset | %s%C(auto)%d %Cgreen[%an]%Creset' --date=local --since=yesterday.midnight --until=midnight"

# git config --global alias.bclean "!f() { git branch --merged ${1-master} | grep -v " ${1-master}$" | xargs -r git branch -d; }; f"
# git config --global alias.mbr "!f() { git branch --merged ${1-master} | grep -v " ${1-master}$" }; f"
git config --global alias.sinceDate "!git log --pretty=format:'%Cred%h %Cgreen%cd%Creset | %s%C(auto)%d %Cgreen[%an]%Creset' --date=local --since=\"$1\""
# git config --global alias.sinceDate "log --pretty=format:'%Cred%h %Cgreen%cd%Creset | %s%C(auto)%d %Cgreen[%an]%Creset' --date=local --since='$1'"

echo -e "${YELLOW}<- $0${NC}"
exit 0
