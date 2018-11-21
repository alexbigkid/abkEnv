#!/bin/bash

#---------------------------
# variables definitions
#---------------------------
TRACE=0
EXECUTED_FROM_BIN=0
ABK_FUNCTION_LIB_FILE="abk_lib.sh"
[ $TRACE != 0 ] && echo \$ABK_FUNCTION_LIB_FILE = $ABK_FUNCTION_LIB_FILE

#---------------------------
# functions
#---------------------------
function PrintUsage ()
{
    echo "$0 will create link in $GOCD_INSTALLATION_DIR to $GOCD_OVERRIDE_FILE"
    echo "the script $0 must be called without any parameters"
    echo "usage: $0"
    echo "  $0 --help           - display this info"
    echo "errorExitCode = $1"
    exit $1
}

#---------------------------
# main
#---------------------------
if [ -f ./$ABK_FUNCTION_LIB_FILE ]; then
    source ./$ABK_FUNCTION_LIB_FILE
else
    echo "ERROR: ./$ABK_FUNCTION_LIB_FILE does not exist"
    echo "Make sure you installed abk environment: ./install_abkEnv.sh"
    echo "All binaries, shell scripts are going to be located in ~/bin"
    exit 1
fi

if [ $TRACE != 0 ]; then
    echo "\$# = $#, \$0 = $0, \$1 = $1"
    echo \$SHELL = $SHELL
    echo \$GOCD_INSTALLATION_DIR = $GOCD_INSTALLATION_DIR
    echo \$GOCD_OVERRIDE_FILE = $GOCD_OVERRIDE_FILE
    echo \$ABK_FUNCTION_LIB_FILE = $ABK_FUNCTION_LIB_FILE
fi

# check if it is bash shell
if [[ $SHELL != "/bin/bash" ]]; then
    PrintUsage $ERROR_CODE_NOT_BASH_SHELL
fi

# check if 1 parameter and it is --help
if [[ $# -eq 1 && $1 == "--help" ]]; then
    PrintUsage $ERROR_CODE_SUCCESS
fi

[ $TRACE != 0 ] && echo "\$# = $#"
# check if there is any parameters
if [ "$#" -ne 0 ]; then
    echo "ERROR: invalid number of parameters"
    PrintUsage $ERROR_CODE_NOT_VALID_NUM_OF_PARAMETERS
fi

# check whether the scripts executed from bin directory
BIN_INSTALL_FILE=$BIN_DIR/$(basename $0)
if [ -L $(basename $0) ]; then
    EXECUTED_FROM_BIN=1
fi
[ $TRACE != 0 ] && echo "\$EXECUTED_FROM_BIN = $EXECUTED_FROM_BIN"

# set the GoCD env directory
echo ""
if [ $EXECUTED_FROM_BIN -eq 1 ]; then
    SH_DIR=$(GetPathFromLink $BIN_INSTALL_FILE)
    echo "[$0 executed from $BIN_DIR ...]"
else
    SH_DIR=$(GetAbsolutePath $0)
    echo "[$0 executed from $SH_DIR ...]"
fi
ABS_ENV_DIR=$SH_DIR/$SH_ENV_DIR
[ $TRACE != 0 ] && echo "\$ABS_ENV_DIR = $ABS_ENV_DIR"

echo ""
# check if file $GOCD_OVERRIDE_FILE exist in $GOCD_INSTALLATION_DIR
ABS_GOCD_OVERRIDE_FILE="$GOCD_INSTALLATION_DIR/$GOCD_OVERRIDE_FILE"
[ $TRACE != 0 ] && echo "\$ABS_GOCD_OVERRIDE_FILE = $ABS_GOCD_OVERRIDE_FILE"
if [ -f "$ABS_GOCD_OVERRIDE_FILE" ]; then
    if [ -L "$ABS_GOCD_OVERRIDE_FILE" ]; then
        echo "WARNING: the link $GOCD_OVERRIDE_FILE already exist in $GOCD_INSTALLATION_DIR, link not created"
    else
        echo "WARNING: the file $GOCD_OVERRIDE_FILE already exist in $GOCD_INSTALLATION_DIR, link not created"
    fi
    ERROR_CODE=$ERROR_CODE_GENERAL_ERROR
else
    echo "[link in $ABS_GOCD_OVERRIDE_FILE to $ABS_ENV_DIR/$GOCD_OVERRIDE_FILE ...]"
    CreateLink $ABS_ENV_DIR/$GOCD_OVERRIDE_FILE "$ABS_GOCD_OVERRIDE_FILE"
    # [ $TRACE != 0 ] && echo "\$? = $?"
    ERROR_CODE=$([ $? -eq 0 ] && echo $ERROR_CODE_SUCCESS || echo $ERROR_CODE_GENERAL_ERROR )
fi

[ $TRACE != 0 ] && echo "\$ERROR_CODE = $ERROR_CODE"
exit $ERROR_CODE
