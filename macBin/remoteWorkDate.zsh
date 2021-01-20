#!/bin/zsh

ABK_DATE_STR=$(date "+%F week:%V %a")
if [ "$ABK_UNIX_TYPE" = "mac" ]; then
    echo "Copying to clipboard the date: $ABK_DATE_STR"
    echo $ABK_DATE_STR | tr -d '\n' | pbcopy
else
    if [ "$(command -v xclip)" == "" ]; then
        echo $ABK_DATE_STR
    else
        echo "Copying to clipboard the date: $ABK_DATE_STR"
        echo $ABK_DATE_STR | xclip
        echo $ABK_DATE_STR | xclip -sel clip
    fi
fi

exit 0
