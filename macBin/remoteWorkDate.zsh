#!/bin/zsh

ABK_DATE_STR=$(date "+%F week:%V %a")
echo $ABK_DATE_STR | tr -d '\n' | pbcopy
echo $ABK_DATE_STR

exit 0
