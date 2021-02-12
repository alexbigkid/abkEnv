#!/bin/bash

#---------------------------
# variables definitions
#---------------------------
TRACE=1
EXIT_CODE=0
EXPECTED_NUMBER_OF_PARAMETERS=0
SCRIPT_NAME=$(basename $0)
SCRIPT_PATH=$(dirname $0)
ABK_LIB_FILE="$SCRIPT_PATH/AbkLib.sh"

#---------------------------
# functions
#---------------------------
PrintUsageAndExitWithCode ()
{

    echo "-> PrintUsageAndExitWithCode ($@)"
    echo "$0 - updates all brew packages"
    echo "usage: $0"
    echo "  $0 --help   - display this info"
    echo "<- PrintUsageAndExitWithCode ($1)"
    echo
    echo $2
    exit $1
}

UpdateBrewPackages ()
{
    echo "-> ${FUNCNAME[0]} ($@)"
    local LCL_EXIT_CODE=$EXIT_CODE_SUCCESS
    local LCL_BREW_PACKAGES=$(brew outdated)
    echo ""
    echo "===================================="
    echo "brew packages to update"
    echo "===================================="
    echo "$LCL_BREW_PACKAGES"
    for BREW_PACKAGE in ${LCL_BREW_PACKAGES[@]}; do
        echo ""
        echo "updating brew package: $BREW_PACKAGE"
        echo "------------------------------------"
        bInstall.sh $BREW_PACKAGE
        [[ $LCL_EXIT_CODE -eq $ERROR_CODE_SUCCESS ]] && LCL_EXIT_CODE=$?
    done
    echo "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}

UpdateBrewCaskPackages ()
{
    echo "-> ${FUNCNAME[0]} ($@)"
    local LCL_EXIT_CODE=$EXIT_CODE_SUCCESS
    local LCL_EXCEPT_FASTLANE_PACKAGE="fastlane"
    local LCL_BREW_CASK_PACKAGES=$(brew outdated --cask --greedy)
    echo ""
    echo "===================================="
    echo "brew cask packages to update"
    echo "===================================="
    echo "$LCL_BREW_CASK_PACKAGES"
    for LCL_BREW_CASK_PACKAGE in ${LCL_BREW_CASK_PACKAGES[@]}; do
        echo ""
        if [ $LCL_BREW_CASK_PACKAGE == $LCL_EXCEPT_FASTLANE_PACKAGE ]; then
            echo "do not update: $LCL_EXCEPT_FASTLANE_PACKAGE"
            echo "------------------------------------"
        else
            echo "updating brew package: $LCL_BREW_CASK_PACKAGE"
            echo "------------------------------------"
            bInstall.sh $LCL_BREW_CASK_PACKAGE cask
            [[ $LCL_EXIT_CODE -eq $ERROR_CODE_SUCCESS ]] && LCL_EXIT_CODE=$?
        fi
    done   
    echo "<- ${FUNCNAME[0]} ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}


#---------------------------
# main
#---------------------------

echo "-> $0"
[ $TRACE != 0 ] && echo "\$SCRIPT_NAME = $SCRIPT_NAME"
[ $TRACE != 0 ] && echo "\$SCRIPT_PATH = $SCRIPT_PATH"
[ $TRACE != 0 ] && echo "\$ABK_LIB_FILE = $ABK_LIB_FILE"

[ -f "$ABK_LIB_FILE" ] && source $ABK_LIB_FILE || PrintUsageAndExitWithCode 1 "ERROR: cannot find library: $ABK_LIB_FILE"

AbkLib_IsParameterHelp $# $1 && PrintUsageAndExitWithCode $ERROR_CODE_SUCCESS
# AbkLib_CheckNumberOfParameters $EXPECTED_NUMBER_OF_PARAMETERS $@ || PrintUsageAndExitWithCode $?
[ "$#" -ne $EXPECTED_NUMBER_OF_PARAMETERS ] && PrintUsageAndExitWithCode 1 "ERROR: invalid number of parameters, expected: $EXPECTED_NUMBER_OF_PARAMETERS"

brew update

UpdateBrewPackages
[[ $EXIT_CODE -eq $ERROR_CODE_SUCCESS ]] && EXIT_CODE=$?

UpdateBrewCaskPackages
[[ $EXIT_CODE -eq $ERROR_CODE_SUCCESS ]] && EXIT_CODE=$?

brew cleanup

EXIT_CODE=$?
echo "<- $0 ($EXIT_CODE)"
exit $EXIT_CODE
