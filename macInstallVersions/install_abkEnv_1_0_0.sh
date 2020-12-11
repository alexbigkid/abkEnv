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
function PrintUsage() {
    echo "$0 will create or refresh all links in $BIN_DIR, $ENV_DIR and brew packages"
    echo "the script $0 must be called without any parameters"
    echo "usage: $0"
    echo "  $0 --help           - display this info"
    echo "errorExitCode = $1"
    exit $1
}

function CreateNewBashProfile() {
    if [ -f $HOME/$ORG_BASH_PROFILE ]; then
        echo "[moving $HOME/$ORG_BASH_PROFILE to $ENV_DIR/$ORG_BASH_PROFILE]"
        mv $HOME/$ORG_BASH_PROFILE $ENV_DIR/$ORG_BASH_PROFILE
        cat >$1 <<EOF_NEW_BASH_PROFILE_IF
# the original .bash_profile is MOVED to \$HOME/env/$ORG_BASH_PROFILE
# in order to completely remove abk environment and restore the
# previous bash settings, please execute \$HOME/bin/uninstall_abkEnv.sh

#-------------------------
# setting previous environment
#-------------------------
if [ -f \$HOME/env/$ORG_BASH_PROFILE ]; then
  source \$HOME/env/$ORG_BASH_PROFILE
fi

EOF_NEW_BASH_PROFILE_IF
    else
        echo "[no original $HOME/$ORG_BASH_PROFILE found]"
        cat >$1 <<EOF_NEW_BASH_PROFILE_ELSE
# there was no original .bash_profile so it was not MOVED to \$HOME/env/$ORG_BASH_PROFILE
# in order to completely remove abk environment and restore the
# previous bash settings, please execute \$HOME/bin/uninstall_abkEnv.sh

EOF_NEW_BASH_PROFILE_ELSE
    fi

    cat >>$1 <<EOF_NEW_BASH_PROFILE_COMMON
#-------------------------
# setting up abk environment
#-------------------------
if [ -f \$HOME/env/$ABK_BASH_PROFILE ]; then
  source \$HOME/env/$ABK_BASH_PROFILE
fi

EOF_NEW_BASH_PROFILE_COMMON

    AbkLib_CreateLink $SH_ENV_DIR/$NEW_BASH_PROFILE $HOME/$ORG_BASH_PROFILE
}

#---------------------------
# main - old installation, should not be called
#---------------------------
function install_abkEnv_1_0_0_main() {

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
        echo \$SH_DIR = $SH_DIR
        echo ""
    fi

    # check if it is bash shell
    if [[ $SHELL != "/bin/bash" ]]; then
        PrintUsage $ERROR_CODE_NOT_BASH_SHELL
    fi

    # check if 1 parameter and it is --help
    if [[ $# -eq 1 && $1 == "--help" ]]; then
        PrintUsage $ERROR_CODE_SUCCESS
    fi

    # Check if there is any parameters
    if [ $# -ne 0 ]; then
        echo "ERROR: invalid number of parameters"
        PrintUsage $ERROR_CODE_NOT_VALID_NUM_OF_PARAMETERS
    fi

    # check for installation bin directory
    [ ! -d $BIN_DIR ] && echo "[creating $BIN_DIR directory ...]"
    mkdir -pv -m 755 $BIN_DIR || exit $?

    # check for installation env directory
    [ ! -d $ENV_DIR ] && echo "[creating $ENV_DIR directory ...]"
    mkdir -pv -m 755 $ENV_DIR || exit $?

    # check whether the scripts already installed or need to be refreshed
    BIN_INSTALL_FILE=$BIN_DIR/$(basename $0)
    if [ -f $BIN_INSTALL_FILE ]; then
        [ -L $BIN_INSTALL_FILE ] && REFRESH=1 || PrintUsage $ERROR_CODE_IS_INSTALLED_BUT_NO_LINK
    fi

    echo ""
    echo "[deleting broken links in bin ...]"
    find -L $BIN_DIR -type l -exec rm -- {} +
    echo "[deleting broken links in env ...]"
    find -L $ENV_DIR -type l -exec rm -- {} +

    # set script directory
    echo ""
    if [ $REFRESH == 0 ]; then
        SH_DIR=$(AbkLib_GetAbsolutePath $0)
        echo "[creating links ...]"
    else
        SH_DIR=$(AbkLib_GetPathFromLink $BIN_INSTALL_FILE)
        echo "[refreshing links ...]"
    fi
    SH_BIN_DIR=$SH_DIR/$SH_BIN_DIR
    SH_ENV_DIR=$SH_DIR/$SH_ENV_DIR

    if [ $TRACE != 0 ]; then
        echo "\$REFRESH   =$REFRESH"
        echo "\$SH_DIR    =$SH_DIR"
        echo "\$SH_BIN_DIR=$SH_BIN_DIR"
        echo "\$SH_ENV_DIR=$SH_ENV_DIR"
    fi

    # if installing, not refreshing
    if [ $REFRESH == 0 ]; then
        CreateNewBashProfile $SH_ENV_DIR/$NEW_BASH_PROFILE
    fi

    # create/update links in project dir
    echo ""
    echo "[links in $BIN_DIR to $SH_DIR ...]"
    FILES=$(find $SH_DIR -maxdepth 1 -type f -name '*.sh')
    for FILE in ${FILES}; do
        AbkLib_CreateLink $FILE $BIN_DIR/$(basename $FILE)
    done

    # create/update links to macBinBash
    echo ""
    echo "[links in $BIN_DIR to $SH_BIN_DIR ...]"
    FILES=$(find $SH_BIN_DIR -maxdepth 1 -type f -name '*.sh')
    for FILE in ${FILES}; do
        AbkLib_CreateLink $FILE $BIN_DIR/$(basename $FILE)
    done

    # create/update links to macEnv
    echo ""
    echo "[links in $ENV_DIR to $SH_ENV_DIR ...]"
    FILES=$(find $SH_ENV_DIR -maxdepth 1 -type f -name '*.env' -o -name '*.m4a' -o -name '*.mp3')
    for FILE in ${FILES}; do
        AbkLib_CreateLink $FILE $ENV_DIR/$(basename $FILE)
    done

    exit $ERROR_CODE
}
