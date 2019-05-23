#!/bin/sh

#---------------------------
# variables definitions
#---------------------------
TRACE=0
EXECUTED_FROM_BIN=0
BIN_DIR=$HOME/bin
ABK_FUNCTION_LIB_FILE="abk_lib.sh"
[ $TRACE != 0 ] && echo "\$ABK_FUNCTION_LIB_FILE = $ABK_FUNCTION_LIB_FILE"
SCRIPT_NAME=$(basename $0)
SCRIPT_PATH=$(dirname $0)
[ $TRACE != 0 ] && echo "\$SCRIPT_NAME = $SCRIPT_NAME"
[ $TRACE != 0 ] && echo "\$SCRIPT_PATH = $SCRIPT_PATH"

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

TOOL_EXE=brew
BREW_PACKAGE=$1
BREW_CASK=$2

PrintUsage ()
{
    echo "$0 - installs brew package and logs in bi_<package name>.txt file"
    echo "usage: $0 <brew package name> [cask]"
    echo "  $0 --help   - display this info"
    echo "  <brew package name> - name of the brew package to install"
    echo "  [cask]              - optional: if the package is cask"
    echo "errorExitCode = $1"
    exit $1
}

UpdateBrewAndWriteHeader ()
{
    local LCL_BREW_PACKAGE=$1
    local LCL_LOG_FILE=$2

    [ $TRACE != 0 ] && echo "-> UpdateBrewAndWriteHeader"
    [ $TRACE != 0 ] && echo "\$LCL_BREW_PACKAGE = $LCL_BREW_PACKAGE"
    [ $TRACE != 0 ] && echo "\$LCL_LOG_FILE  = $LCL_LOG_FILE"

    echo "updating brew installation"
    $TOOL_EXE update
    echo "$LCL_BREW_PACKAGE package installation or update is logged in $LCL_LOG_FILE"
    echo "" 2>&1 | tee -a $LCL_LOG_FILE
    echo "--------------------------------------------------------------------------------" 2>&1 | tee -a $LCL_LOG_FILE
    date 2>&1 | tee -a $LCL_LOG_FILE
    echo "--------------------------------------------------------------------------------" 2>&1 | tee -a $LCL_LOG_FILE
    [ $TRACE != 0 ] && echo "<- UpdateBrewAndWriteHeader"
}

InstallOrUpdate ()
{
    local LCL_BREW_PACKAGE=$1
    local LCL_LOG_FILE=$2
    local LCL_CASK=$3
    local LCL_UPDATE=0

    [ $TRACE != 0 ] && echo "-> InstallOrUpdate ($@)"
    [ $TRACE != 0 ] && echo "\$LCL_BREW_PACKAGE = $LCL_BREW_PACKAGE"
    [ $TRACE != 0 ] && echo "\$LCL_LOG_FILE  = $LCL_LOG_FILE"
    [ $TRACE != 0 ] && echo "\$LCL_CASK         = $LCL_CASK"

    # is package installed?
    # if [[ $($TOOL_EXE list --versions $LCL_BREW_PACKAGE) == "" ]]; then
    if ! $TOOL_EXE $LCL_CASK list $BREW_PACKAGE &>/dev/null; then
        echo "--------------------------------------------------------------------------------" 2>&1 | tee -a $LCL_LOG_FILE
        echo "$LCL_BREW_PACKAGE $LCL_CASK installation log" 2>&1 | tee -a $LCL_LOG_FILE
        echo "--------------------------------------------------------------------------------" 2>&1 | tee -a $LCL_LOG_FILE
        UpdateBrewAndWriteHeader $LCL_BREW_PACKAGE $LCL_LOG_FILE
        $TOOL_EXE $LCL_CASK install $LCL_BREW_PACKAGE 2>&1 | tee -a $LCL_LOG_FILE
    else
        if [[ $# -eq 3 ]]; then
            if [[ $($TOOL_EXE $LCL_CASK outdated $LCL_BREW_PACKAGE --greedy) != "" ]]; then
                LCL_UPDATE=1
            fi
        else
            if [[ $($TOOL_EXE outdated $LCL_BREW_PACKAGE) != "" ]]; then
                LCL_UPDATE=1
            fi
        fi

        if [[ $LCL_UPDATE -eq 1 ]]; then
            echo "updating $LCL_BREW_PACKAGE $LCL_CASK"
            UpdateBrewAndWriteHeader $LCL_BREW_PACKAGE $LCL_LOG_FILE
            [ $TRACE != 0 ] && echo "$TOOL_EXE $LCL_CASK upgrade $LCL_BREW_PACKAGE 2>&1 | tee -a $LCL_LOG_FILE"
            $TOOL_EXE $LCL_CASK upgrade $LCL_BREW_PACKAGE 2>&1 | tee -a $LCL_LOG_FILE
            # $TOOL_EXE unlink $LCL_BREW_PACKAGE 2>&1 | tee -a $LCL_LOG_FILE
            # $TOOL_EXE link $LCL_BREW_PACKAGE 2>&1 | tee -a $LCL_LOG_FILE
            # $TOOL_EXE cleanup
        else
            echo "$LCL_BREW_PACKAGE installed and up to date!"
        fi
    fi
    [ $TRACE != 0 ] && echo "<- InstallOrUpdate"
}

#-------  main -------------
# installed in user/bin directory?
if [ -f $BIN_DIR/$ABK_FUNCTION_LIB_FILE ]; then
    source $BIN_DIR/$ABK_FUNCTION_LIB_FILE
else
    if [ -f $SCRIPT_PATH/../$ABK_FUNCTION_LIB_FILE ]; then
        source $SCRIPT_PATH/../$ABK_FUNCTION_LIB_FILE
    else
        echo "ERROR: cannot find library: $ABK_FUNCTION_LIB_FILE"
        echo "Make sure you installed abk environment: $SCRIPT_PATH/../install_abkEnv.sh"
        echo "All binaries, shell scripts are going to be located in ~/bin"
        exit 1
    fi
fi

if [ $TRACE != 0 ]; then
    echo "\$# = $#, \$0 = $0, \$1 = $1"
    echo \$SHELL   = $SHELL
    echo \$BIN_DIR = $BIN_DIR
    echo \$ENV_DIR = $ENV_DIR
    echo \$SH_DIR  = $SH_DIR
    echo ""
fi

# check if it is bash shell
if [[ $SHELL != "/bin/bash" ]]; then
    PrintUsage $ERROR_CODE_NOT_BASH_SHELL
fi

# if parameter is --help
if [ $# -eq 1 ] && [ $1 = "--help" ]; then
    PrintUsage $ERROR_CODE_SUCCESS
fi

# if not 1 parameters
if [[ ( $# -ne 1 ) && ! ( $# -eq 2 && "$2" == "cask" ) ]]; then
    echo "number of parametres passed in: $#"
    echo "parameters: $@"
    PrintUsage $ERROR_CODE_NOT_VALID_NUM_OF_PARAMETERS
fi

# is brew installed?
if [[ $(command -v $TOOL_EXE) == "" ]]; then
    echo "ERROR: $TOOL_EXE is not installed, please install $TOOL_EXE first"
    PrintUsage $ERROR_CODE_TOOL_NOT_INSTALLED
fi

# check whether the scripts executed from bin directory
SCRIPT_FULL_NAME=$SCRIPT_PATH/$SCRIPT_NAME
if [ -L $0 ]; then
    EXECUTED_FROM_BIN=1
fi
[ $TRACE != 0 ] && echo "\$EXECUTED_FROM_BIN = $EXECUTED_FROM_BIN"

# set the GoCD env directory
echo ""
if [ $EXECUTED_FROM_BIN -eq 1 ]; then
    SH_DIR=$(GetPathFromLink $SCRIPT_FULL_NAME)
    [ $TRACE != 0 ] && echo "[$0 executed from $BIN_DIR]"
else
    SH_DIR=$(GetAbsolutePath $0)
    [ $TRACE != 0 ] && echo "[$0 executed from $SH_DIR]"
fi
ABS_PACKAGE_DIR="$SH_DIR/../$SH_PACKAGES_DIR"
[ $TRACE != 0 ] && echo "\$ABS_PACKAGE_DIR = $ABS_PACKAGE_DIR"

BI_LOG_FILE="$ABS_PACKAGE_DIR/bi_$BREW_PACKAGE.txt"
BCI_LOG_FILE="$ABS_PACKAGE_DIR/bci_$BREW_PACKAGE.txt"


# is package available?
if [[ $($TOOL_EXE search $BREW_PACKAGE | grep -w "$BREW_PACKAGE") == "" ]]; then
    echo "ERROR: $BREW_PACKAGE brew package not found"
    PrintUsage $ERROR_CODE_BREW_PACKAGE_NOT_FOUND
fi

if [ $# -eq 1 ]; then
    InstallOrUpdate $BREW_PACKAGE $BI_LOG_FILE
else
    InstallOrUpdate $BREW_PACKAGE $BCI_LOG_FILE $BREW_CASK
fi

exit $ERROR_CODE_SUCCESS
