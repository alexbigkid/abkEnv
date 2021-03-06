#!/bin/bash

#---------------------------
# variables definitions
#---------------------------
TRACE=0
REFRESH=0
ABK_LIB_FILE="AbkLib.sh"
[ $TRACE != 0 ] && echo \$ABK_LIB_FILE = $ABK_LIB_FILE

#---------------------------
# functions
#---------------------------
PrintUsage ()
{
    echo "$0 will uninstall brew / brew packages"
    echo "the script $0 must be called without any parameters"
    echo "usage: $0"
    echo "  $0 --help           - display this info"
    echo "errorExitCode = $1"
    exit $1
}


#---------------------------
# main
#---------------------------
if [ -f ./$ABK_LIB_FILE ]; then
    . ./$ABK_LIB_FILE
else
    echo "ERROR: ./$ABK_LIB_FILE does not exist"
    echo "Make sure you installed abk environment: ./install_abkEnv.sh"
    echo "All binaries, shell scripts are going to be located in ~/bin"
    exit 1
fi

if [ $TRACE != 0 ]; then
    echo "\$# = $#, \$0 = $0, \$1 = $1"
    echo \$SHELL   = $SHELL
    echo \$BIN_DIR = $BIN_DIR
    echo \$ENV_DIR = $ENV_DIR
    echo \$SH_DIR  = $SH_DIR
    echo ""
fi
