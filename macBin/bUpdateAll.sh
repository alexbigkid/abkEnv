#!/bin/sh

#---------------------------
# variables definitions
#---------------------------
TRACE=1
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
    echo "$0 - updates all brew packages"
    echo "usage: $0"
    echo "  $0 --help   - display this info"
    echo "errorExitCode = $1"
    exit $1
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

BREW_PACKAGES=$(brew outdated)
echo "BREW_PACKAGES = $BREW_PACKAGES"
for BREW_PACKAGE in ${BREW_PACKAGES[@]}; do
    echo "updating brew package: $BREW_PACKAGE"
    echo "------------------------------------"
    ./bInstall.sh $BREW_PACKAGE
done

FASTLANE_PACKAGE="fastlane"
SAFE_IN_CLOUD_PACKAGE="safeincloud-password-manager"
BREW_CASK_PACKAGES=$(brew cask outdated --greedy)
for BREW_CASK_PACKAGE in ${BREW_CASK_PACKAGES[@]}; do
    echo ""
    if [ $BREW_CASK_PACKAGE == $FASTLANE_PACKAGE ]; then
        echo "do not update: $FASTLANE_PACKAGE"
        echo "------------------------------------"
        $FASTLANE_PACKAGE --version
    elif [ $BREW_CASK_PACKAGE == $SAFE_IN_CLOUD_PACKAGE ]; then
        echo "do not update: $SAFE_IN_CLOUD_PACKAGE"
        echo "------------------------------------"
    else
        echo "updating brew package: $BREW_CASK_PACKAGE"
        echo "------------------------------------"
        ./bInstall.sh $BREW_CASK_PACKAGE cask
    fi
done

brew cleanup

EXIT_CODE=$?
echo "<- $0 ($EXIT_CODE)"
exit $EXIT_CODE
