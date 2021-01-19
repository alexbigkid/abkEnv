#!/bin/zsh

NEW_GUID=$(uuidgen | tr "[:upper:]" "[:lower:]")
echo $NEW_GUID | pbcopy
echo $NEW_GUID

exit 0