#!/bin/bash

#---------------------------
# variables definitions
#---------------------------
TRACE=0
EXECUTED_FROM_BIN=0
ABK_LIB_DIR=$(dirname $BASH_SOURCE)
echo "ABK_LIB_DIR = $ABK_LIB_DIR"
ABK_LIB_FILE="./$ABK_LIB_DIR/abk_lib.sh"
[ $TRACE != 0 ] && echo \$ABK_LIB_FILE = $ABK_LIB_FILE

#---------------------------
# functions
#---------------------------
PrintUsage() {
    echo "$0 will unlink all installed script files in $BIN_DIR and $ENV_DIR and brew packages"
    echo "the script $0 must be called without any parameters"
    echo "usage: $0"
    echo "  $0 --help           - display this info"
    echo "errorExitCode = $1"
    exit $1
}

RestoreOldBashProfile() {
    AbkLib_DeleteLink $HOME/$ORG_BASH_PROFILE
    if [ -f $ENV_DIR/$ORG_BASH_PROFILE ]; then
        echo ""
        echo "[restore the original $ENV_DIR/$ORG_BASH_PROFILE]"
        mv $ENV_DIR/$ORG_BASH_PROFILE $HOME/$ORG_BASH_PROFILE
    fi
}

#---------------------------
# main
#---------------------------
uninstall_abkEnv_1_0_0_main() {

    if [ -f ./$ABK_LIB_FILE ]; then
        source ./$ABK_LIB_FILE
    else
        echo "ERROR: ./$ABK_LIB_FILE does not exist"
        echo "Make sure you installed abk environment: ./install_abkEnv.sh"
        echo "All binaries, shell scripts are going to be located in ~/bin"
        exit 1
    fi

    if [ $TRACE != 0 ]; then
        echo "\$# = $#, \$0 = $0, \$1 = $1"
        echo \$SHELL = $SHELL
        echo \$BIN_DIR = $BIN_DIR
        echo \$ENV_DIR = $ENV_DIR
        echo \$SH_DIR= $SH_DIR
        echo ""
    fi

    if [[ $# -eq 1 && $1 == "--help" ]]; then
        PrintUsage $ERROR_CODE_SUCCESS
    fi

    # Check for the parameter
    if [ $# -ne 0 ]; then
        echo "ERROR: invalid number of parameters"
        PrintUsage $ERROR_CODE_NOT_VALID_NUM_OF_PARAMETERS
    fi

    # find where the scripts are installed
    BIN_UNINSTALL_FILE=$PWD/$(dirname $0)/$(basename $0)
    [ $TRACE != 0 ] && echo "\$BIN_UNINSTALL_FILE = $BIN_UNINSTALL_FILE"
    if [ -f $BIN_UNINSTALL_FILE ]; then
        [ ! -L $BIN_UNINSTALL_FILE ] || EXECUTED_FROM_BIN=1
    fi
    [ $TRACE != 0 ] && echo "\$EXECUTED_FROM_BIN = $EXECUTED_FROM_BIN"

    echo ""
    echo "[deleting broken links in bin ...]"
    find -L $BIN_DIR -type l -exec rm -- {} +
    echo "[deleting broken links in env ...]"
    find -L $ENV_DIR -type l -exec rm -- {} +

    if [ $EXECUTED_FROM_BIN == 0 ]; then
        SH_DIR=$(AbkLib_GetAbsolutePath $0)
    else
        SH_DIR=$(AbkLib_GetPathFromLink $BIN_UNINSTALL_FILE)
    fi
    SH_BIN_DIR=$SH_DIR/$SH_BIN_DIR
    SH_ENV_DIR=$SH_DIR/$SH_ENV_DIR

    if [ $TRACE != 0 ]; then
        echo "\$EXECUTED_FROM_BIN   =$EXECUTED_FROM_BIN"
        echo "\$SH_DIR              =$SH_DIR"
        echo "\$SH_BIN_DIR          =$SH_BIN_DIR"
        echo "\$SH_ENV_DIR          =$SH_ENV_DIR"
    fi

    echo ""
    echo "[uninstalling links in $ENV_DIR to $SH_ENV_DIR ...]"
    FILES=$(find $SH_ENV_DIR -maxdepth 1 -type f -name '*.env' -o -name '*.m4a' -o -name '*.mp3')
    for FILE in ${FILES}; do
        AbkLib_DeleteLink $ENV_DIR/$(basename $FILE)
    done

    echo ""
    echo "[uninstalling links in $BIN_DIR to $SH_BIN_DIR ...]"
    FILES=$(find $SH_BIN_DIR -maxdepth 1 -type f -name '*.sh')
    for FILE in ${FILES}; do
        AbkLib_DeleteLink $BIN_DIR/$(basename $FILE)
    done

    echo ""
    echo "[uninstalling links in $BIN_DIR to $SH_DIR ...]"
    FILES=$(find $SH_DIR -maxdepth 1 -type f -name '*.sh')
    for FILE in ${FILES}; do
        AbkLib_DeleteLink $BIN_DIR/$(basename $FILE)
    done

    echo ""
    echo "[deleting generated file $SH_ENV_DIR/$NEW_BASH_PROFILE]"
    rm $SH_ENV_DIR/$NEW_BASH_PROFILE

    RestoreOldBashProfile

    echo ""
    echo "[deleting directory $BIN_DIR if empty ...]"
    rmdir $BIN_DIR
    [ $? == 0 ] && echo "$BIN_DIR deleted" || echo "$BIN_DIR failed to delete"
    echo "[deleting directory $ENV_DIR if empty ...]"
    rmdir $ENV_DIR
    [ $? == 0 ] && echo "$BIN_ENV_DIRDIR deleted" || echo "$ENV_DIR failed to delete"
}
