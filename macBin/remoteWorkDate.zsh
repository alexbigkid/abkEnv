#!/bin/zsh

YEAR_MONTH_DAY=$(date +%F)
WEEK_DAY=$(date +%a)
WEEK_NUMBER=$(date +%U)

echo $YEAR_MONTH_DAY week:$WEEK_NUMBER $WEEK_DAY
