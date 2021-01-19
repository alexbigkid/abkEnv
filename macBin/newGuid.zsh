#!/bin/zsh

NEW_GUID=$(uuidgen | tr "[:upper:]" "[:lower:]")
echo $NEW_GUID | tr -d '\n' | pbcopy
echo $NEW_GUID

exit 0
