#!/bin/bash

#---------------------------
# variables definitions
#---------------------------
TRACE=0
EXECUTED_FROM_BIN=0
SCRIPT_NAME=$(basename $0)
SCRIPT_PATH=$(dirname $0)
ABK_LIB_FILE="$SCRIPT_PATH/AbkLib.sh"
[ $TRACE != 0 ] && echo "\$SCRIPT_NAME = $SCRIPT_NAME"
[ $TRACE != 0 ] && echo "\$SCRIPT_PATH = $SCRIPT_PATH"
[ $TRACE != 0 ] && echo "\$ABK_LIB_FILE = $ABK_LIB_FILE"

# exit error codes
ERROR_CODE_TOOL_NOT_INSTALLED=101
ERROR_CODE_BREW_PACKAGE_NOT_FOUND=102
ERROR_CODE=$ERROR_CODE_SUCCESS

# echo "\$0 = $0"
# echo "\$1 = $1"
# echo "\$2 = $2"
# echo "\$3 = $3"
# echo "\$4 = $4"
# echo "\$@ = $@"

BREW_PACKAGE=$1
BREW_CASK=$2

PrintUsageAndExitWithCode ()
{
    echo "$0 - installs brew package and logs in bi_<package name>.txt file"
    echo "usage: $0 <brew package name> [cask]"
    echo "  $0 --help   - display this info"
    echo "  <brew package name> - name of the brew package to install"
    echo "  [cask]              - optional: if the package is cask"
    echo "errorExitCode = $1"
    echo
    echo $2
    exit $1
}

UpdateBrewAndWriteHeader ()
{
    local LCL_BREW_PACKAGE=$1
    local LCL_LOG_FILE=$2

    [ $TRACE != 0 ] && echo "-> ${FUNCNAME[0]}"
    [ $TRACE != 0 ] && echo "\$LCL_BREW_PACKAGE = $LCL_BREW_PACKAGE"
    [ $TRACE != 0 ] && echo "\$LCL_LOG_FILE  = $LCL_LOG_FILE"

    echo "$LCL_BREW_PACKAGE package installation or update is logged in $LCL_LOG_FILE"
    echo "" 2>&1 | tee -a $LCL_LOG_FILE
    echo "--------------------------------------------------------------------------------" 2>&1 | tee -a $LCL_LOG_FILE
    date 2>&1 | tee -a $LCL_LOG_FILE
    echo "--------------------------------------------------------------------------------" 2>&1 | tee -a $LCL_LOG_FILE
    [ $TRACE != 0 ] && echo "<- ${FUNCNAME[0]}"
}

InstallOrUpdate ()
{
    local LCL_BREW_PACKAGE=$1
    local LCL_LOG_FILE=$2
    local LCL_CASK=$3
    local LCL_UPDATE=0

    [ $TRACE != 0 ] && echo "-> ${FUNCNAME[0]} ($@)"
    [ $TRACE != 0 ] && echo "\$LCL_BREW_PACKAGE = $LCL_BREW_PACKAGE"
    [ $TRACE != 0 ] && echo "\$LCL_LOG_FILE  = $LCL_LOG_FILE"
    [ $TRACE != 0 ] && echo "\$LCL_CASK         = $LCL_CASK"
    [ "$LCL_CASK" = "cask" ] && LCL_CASK="--cask"
    [ "$LCL_CASK" != "--cask" ] && [ "$LCL_CASK" != "" ] && exit 1

    # is package installed?
    # if [[ $(brew list --versions $LCL_BREW_PACKAGE) == "" ]]; then
    if ! brew list $BREW_PACKAGE $LCL_CASK &>/dev/null; then
        echo "--------------------------------------------------------------------------------" 2>&1 | tee -a $LCL_LOG_FILE
        echo "$LCL_BREW_PACKAGE $LCL_CASK installation log" 2>&1 | tee -a $LCL_LOG_FILE
        echo "--------------------------------------------------------------------------------" 2>&1 | tee -a $LCL_LOG_FILE
        UpdateBrewAndWriteHeader $LCL_BREW_PACKAGE $LCL_LOG_FILE
        brew install $LCL_BREW_PACKAGE $LCL_CASK 2>&1 | tee -a $LCL_LOG_FILE
    else
        if [[ $# -eq 3 ]]; then
            if [[ $(brew outdated $LCL_BREW_PACKAGE $LCL_CASK --greedy) != "" ]]; then
                LCL_UPDATE=1
            fi
        else
            if [[ $(brew outdated $LCL_BREW_PACKAGE) != "" ]]; then
                LCL_UPDATE=1
            fi
        fi

        if [[ $LCL_UPDATE -eq 1 ]]; then
            echo "updating $LCL_BREW_PACKAGE $LCL_CASK"
            UpdateBrewAndWriteHeader $LCL_BREW_PACKAGE $LCL_LOG_FILE
            [ $TRACE != 0 ] && echo "brew upgrade $LCL_BREW_PACKAGE $LCL_CASK 2>&1 | tee -a $LCL_LOG_FILE"
            brew upgrade $LCL_BREW_PACKAGE $LCL_CASK 2>&1 | tee -a $LCL_LOG_FILE
            # brew unlink $LCL_BREW_PACKAGE 2>&1 | tee -a $LCL_LOG_FILE
            # brew link $LCL_BREW_PACKAGE 2>&1 | tee -a $LCL_LOG_FILE
            # brew cleanup
        else
            echo "$LCL_BREW_PACKAGE installed and up to date!"
        fi
    fi
    [ $TRACE != 0 ] && echo "<- ${FUNCNAME[0]}"
}

#-------  main -------------
# installed in user/bin directory?
[ -f $ABK_LIB_FILE ] && . $ABK_LIB_FILE || PrintUsageAndExitWithCode 1 "ERROR: cannot find library: $ABK_LIB_FILE"

if [ $TRACE != 0 ]; then
    echo "\$# = $#, \$0 = $0, \$1 = $1"
    echo \$SHELL   = $SHELL
    echo \$ENV_DIR = $ENV_DIR
    echo \$SH_DIR  = $SH_DIR
    echo ""
fi

# check if it is bash shell
ABK_SHELL="${SHELL##*/}"
if [ "$ABK_SHELL" != "bash" ] && [ "$ABK_SHELL" != "zsh" ]; then
    PrintUsageAndExitWithCode $ERROR_CODE_NOT_BASH_SHELL
fi

# if parameter is --help
if [ $# -eq 1 ] && [ $1 = "--help" ]; then
    PrintUsageAndExitWithCode $ERROR_CODE_SUCCESS
fi

# if not 1 parameters
if [[ ( $# -ne 1 ) && ! ( $# -eq 2 && "$2" == "cask" ) ]]; then
    echo "number of parametres passed in: $#"
    echo "parameters: $@"
    PrintUsageAndExitWithCode $ERROR_CODE_NOT_VALID_NUM_OF_PARAMETERS
fi

# is brew installed?
if [[ $(command -v brew) == "" ]]; then
    echo "ERROR: brew is not installed, please install brew first"
    PrintUsage $ERROR_CODE_TOOL_NOT_INSTALLED
fi

# check whether the scripts executed from bin directory
SCRIPT_FULL_NAME=$SCRIPT_PATH/$SCRIPT_NAME
if [ -L $0 ]; then
    EXECUTED_FROM_BIN=1
fi
[ $TRACE != 0 ] && echo "\$EXECUTED_FROM_BIN = $EXECUTED_FROM_BIN"

echo ""
if [ $EXECUTED_FROM_BIN -eq 1 ]; then
    SH_DIR=$(AbkLib_GetPathFromLink $SCRIPT_FULL_NAME)
    [ $TRACE != 0 ] && echo "[$0 executed from $SCRIPT_PATH]"
else
    SH_DIR=$(AbkLib_GetAbsolutePath $0)
    [ $TRACE != 0 ] && echo "[$0 executed from $SH_DIR]"
fi
ABS_PACKAGE_DIR="$SH_DIR/../$SH_PACKAGES_DIR"
[ $TRACE != 0 ] && echo "\$ABS_PACKAGE_DIR = $ABS_PACKAGE_DIR"

BI_LOG_FILE="$ABS_PACKAGE_DIR/bi_$BREW_PACKAGE.txt"
BCI_LOG_FILE="$ABS_PACKAGE_DIR/bci_$BREW_PACKAGE.txt"


# is package available?
if [[ $(brew search $BREW_PACKAGE | grep -w "$BREW_PACKAGE") == "" ]]; then
    echo "ERROR: $BREW_PACKAGE brew package not found"
    PrintUsage $ERROR_CODE_BREW_PACKAGE_NOT_FOUND
fi

if [ $# -eq 1 ]; then
    InstallOrUpdate $BREW_PACKAGE $BI_LOG_FILE
else
    InstallOrUpdate $BREW_PACKAGE $BCI_LOG_FILE $BREW_CASK
fi

exit $ERROR_CODE_SUCCESS
