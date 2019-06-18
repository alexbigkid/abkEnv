#!/bin/sh

#---------------------------
# variables definitions
#---------------------------
TRACE=0
EXIT_CODE=$ERROR_CODE_SUCCESS
EXPECTED_NUMBER_OF_PARAMETERS=0
EXECUTED_FROM_BIN=0
BIN_DIR=$HOME/bin
ABK_FUNCTION_LIB_FILE="abk_lib.sh"
SCRIPT_NAME=$(basename $0)
SCRIPT_PATH=$(dirname $0)

#---------------------------
# functions
#---------------------------
PrintUsageAndExitWithCode ()
{
    echo ""
    echo "-> PrintUsageAndExitWithCode ($@)"
    echo "$0 - updates all brew packages"
    echo "usage: $0"
    echo "  $0 --help   - display this info"
    echo "<- PrintUsageAndExitWithCode ($1)"
    exit $1
}

UpdateBrewPackages ()
{
    echo "-> UpdateBrewPackages ($@)"
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
        [ $LCL_EXIT_CODE -eq $ERROR_CODE_SUCCESS ] && LCL_EXIT_CODE=$?
    done
    echo "<- UpdateBrewPackages ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}

UpdateBrewCaskPackages ()
{
    echo "-> UpdateBrewCaskPackages ($@)"
    local LCL_EXIT_CODE=$EXIT_CODE_SUCCESS
    local LCL_EXCEPT_FASTLANE_PACKAGE="fastlane"
    local LCL_EXCEPT_SAFE_IN_CLOUD_PACKAGE="safeincloud-password-manager"
    local LCL_BREW_CASK_PACKAGES=$(brew cask outdated --greedy)
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
            local LCL_FAST_LANE_UPDATE_STRING="fastlane update_fastlane"
            local LCL_FASTLANE_OUTPUT=$($LCL_EXCEPT_FASTLANE_PACKAGE --version)
            if [[ $LCL_FASTLANE_OUTPUT =~ $LCL_FAST_LANE_UPDATE_STRING ]]; then
                $LCL_FAST_LANE_UPDATE_STRING
                [ $LCL_EXIT_CODE -eq $ERROR_CODE_SUCCESS ] && LCL_EXIT_CODE=$?
            fi
        elif [ $LCL_BREW_CASK_PACKAGE == $LCL_EXCEPT_SAFE_IN_CLOUD_PACKAGE ]; then
            echo "do not update: $LCL_EXCEPT_SAFE_IN_CLOUD_PACKAGE"
            echo "------------------------------------"
        else
            echo "updating brew package: $LCL_BREW_CASK_PACKAGE"
            echo "------------------------------------"
            bInstall.sh $LCL_BREW_CASK_PACKAGE cask
            [ $LCL_EXIT_CODE -eq $ERROR_CODE_SUCCESS ] && LCL_EXIT_CODE=$?
        fi
    done   
    echo "<- UpdateBrewCaskPackages ($LCL_EXIT_CODE)"
    return $LCL_EXIT_CODE
}


#---------------------------
# main
#---------------------------

echo "-> $0"
[ $TRACE != 0 ] && echo "\$BIN_DIR = $BIN_DIR"
[ $TRACE != 0 ] && echo "\$ABK_FUNCTION_LIB_FILE = $ABK_FUNCTION_LIB_FILE"
[ $TRACE != 0 ] && echo "\$SCRIPT_NAME = $SCRIPT_NAME"
[ $TRACE != 0 ] && echo "\$SCRIPT_PATH = $SCRIPT_PATH"

# installed in user/bin directory?
if [ -f $BIN_DIR/$ABK_FUNCTION_LIB_FILE ]; then
    echo "$ABK_FUNCTION_LIB_FILE sourced from $BIN_DIR"
    source $BIN_DIR/$ABK_FUNCTION_LIB_FILE
else
    if [ -f $SCRIPT_PATH/../$ABK_FUNCTION_LIB_FILE ]; then
        echo "$ABK_FUNCTION_LIB_FILE sourced from $SCRIPT_PATH/../$ABK_FUNCTION_LIB_FILE"
        source $SCRIPT_PATH/../$ABK_FUNCTION_LIB_FILE
    else
        echo "ERROR: cannot find library: $ABK_FUNCTION_LIB_FILE"
        echo "Make sure you installed abk environment: $SCRIPT_PATH/../install_abkEnv.sh"
        echo "All binaries, shell scripts are going to be located in ~/bin"
        echo "<- $0 (1)"
        exit 1
    fi
fi

IsParameterHelp $# $1 && PrintUsageAndExitWithCode $ERROR_CODE_SUCCESS
CheckNumberOfParameters $EXPECTED_NUMBER_OF_PARAMETERS $@ || PrintUsageAndExitWithCode $?

brew update

UpdateBrewPackages
[ $EXIT_CODE -eq $ERROR_CODE_SUCCESS ] && EXIT_CODE=$?

UpdateBrewCaskPackages
[ $EXIT_CODE -eq $ERROR_CODE_SUCCESS ] && EXIT_CODE=$?

brew cleanup

EXIT_CODE=$?
echo "<- $0 ($EXIT_CODE)"
exit $EXIT_CODE
