#!/bin/bash

# enable trace here
TRACE=0

# define here installation directory
BIN_DIR=$HOME/bin
[ $TRACE != 0 ] && echo \$BIN_DIR = $BIN_DIR
ENV_DIR=$HOME/env
[ $TRACE != 0 ] && echo \$ENV_DIR = $ENV_DIR
SH_DIR=""
[ $TRACE != 0 ] && echo \$SH_DIR= $SH_DIR
SH_BIN_DIR="macBin"
[ $TRACE != 0 ] && echo \$SH_BIN_DIR= $SH_BIN_DIR
SH_ENV_DIR="macEnv"
[ $TRACE != 0 ] && echo \$SH_ENV_DIR= $SH_ENV_DIR

NEW_BASH_PROFILE="bash_profile.env"
ORG_BASH_PROFILE=".bash_profile"
ABK_BASH_PROFILE="bash_abk.env"

REFRESH=0


# exit error codes
ERROR_CODE_SUCCESS=0
ERROR_CODE_GENERAL_ERROR=1
ERROR_CODE_IS_INSTALLED_BUT_NO_LINK=2
ERROR_CODE_NOT_VALID_NUM_OF_PARAMETERS=3
ERROR_CODE_NOT_BASH_SHELL=4

function PrintUsage ()
{
    echo "$0 will create or refresh all links in $BIN_DIR, $ENV_DIR and brew packages"
    echo "the script $0 must be called without any parameters"
    echo "usage: $0"
    echo "  $0 --help           - display this info"
    echo "errorExitCode = $1"
    exit $1
}

function GetAbsolutePath ()
{
    local DIR_NAME=$(dirname $1)
    pushd "$DIR_NAME" > /dev/null
    local RESULT_PATH=$PWD
    popd > /dev/null
    echo $RESULT_PATH
}

function GetPathFromLink ()
{
    local RESULT_PATH=$(dirname $([ -L $1 ] && readlink -n $1))
    echo $RESULT_PATH
}

function CreateLink ()
{
    if [ $# -ne 2 ]; then
        echo "ERROR: invalid number of parameters"
        false
    fi
    [ $TRACE != 0 ] && echo "\$2 = $2"
    [ -L $2 ] && unlink $2
    ln -s $1 $2
    # LINK_RESULT=$([ $? == 0 ] && echo "SUCCESS" || echo "FAILED")
    LINK_RESULT=$([ $? == 0 ] && echo true || echo false )
    echo "[$LINK_RESULT]: $2 -> $1"
    $LINK_RESULT
}

function CreateNewBashProfile ()
{
    if [ -f $HOME/$ORG_BASH_PROFILE ]; then
        echo "[moving $HOME/$ORG_BASH_PROFILE to $ENV_DIR/$ORG_BASH_PROFILE]"
        mv $HOME/$ORG_BASH_PROFILE $ENV_DIR/$ORG_BASH_PROFILE
        cat > $1 << EOF_NEW_BASH_PROFILE_IF
# the original .bash_profile is MOVED to $ENV_DIR/$ORG_BASH_PROFILE
# in order to completely remove abk environment and restore the
# previous bash settings, please execute $BIN_DIR/uninstall_abkEnv.sh

#-------------------------
# setting previous environment
#-------------------------
if [ -f $ENV_DIR/$ORG_BASH_PROFILE ]; then
  source $ENV_DIR/$ORG_BASH_PROFILE
fi
EOF_NEW_BASH_PROFILE_IF
    else
        echo "[no original $HOME/$ORG_BASH_PROFILE found]"
        cat > $1 << EOF_NEW_BASH_PROFILE_ELSE
# there was no original .bash_profile so it was not MOVED to $ENV_DIR/$ORG_BASH_PROFILE
# in order to completely remove abk environment and restore the
# previous bash settings, please execute $BIN_DIR/uninstall_abkEnv.sh
EOF_NEW_BASH_PROFILE_ELSE
    fi

    cat >> $1 << EOF_NEW_BASH_PROFILE_COMMON
#-------------------------
# setting up abk environment
#-------------------------
if [ -f $ENV_DIR/$ABK_BASH_PROFILE ]; then
  source $ENV_DIR/$ABK_BASH_PROFILE
fi
EOF_NEW_BASH_PROFILE_COMMON

    CreateLink $ENV_DIR/$NEW_BASH_PROFILE $HOME/$ORG_BASH_PROFILE
}

#-------  main -------------
[ $TRACE != 0 ] && echo "\$# = $#, \$1 = $1"
[ $TRACE != 0 ] && echo \$SHELL = $SHELL

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
    SH_DIR=$(GetAbsolutePath $0)
    echo "[creating links ...]"
else
    SH_DIR=$(GetPathFromLink $BIN_INSTALL_FILE)
    echo "[refreshing links ...]"
fi
SH_BIN_DIR=$SH_DIR/$SH_BIN_DIR
SH_ENV_DIR=$SH_DIR/$SH_ENV_DIR
[ $TRACE != 0 ] && echo "\$SH_DIR    =$SH_DIR"
[ $TRACE != 0 ] && echo "\$SH_BIN_DIR=$SH_BIN_DIR"
[ $TRACE != 0 ] && echo "\$SH_ENV_DIR=$SH_ENV_DIR"


# if newly created
if [ $REFRESH == 0 ]; then
    CreateNewBashProfile $SH_ENV_DIR/$NEW_BASH_PROFILE
fi


# create/update links
echo ""
echo "[links in $BIN_DIR to $SH_DIR ...]"
FILES=$(find $SH_DIR -maxdepth 1 -type f -name '*.sh')
for FILE in ${FILES}
do
    CreateLink $FILE $BIN_DIR/$(basename $FILE)
done

# create/update links to macBin
echo ""
echo "[links in $BIN_DIR to $SH_BIN_DIR ...]"
FILES=$(find $SH_BIN_DIR -maxdepth 1 -type f -name '*.sh')
for FILE in ${FILES}
do
    CreateLink $FILE $BIN_DIR/$(basename $FILE)
done

# create/update links to macEnv
echo ""
echo "[links in $ENV_DIR to $SH_ENV_DIR ...]"
FILES=$(find $SH_ENV_DIR -maxdepth 1 -type f -name '*.env')
for FILE in ${FILES}
do
    CreateLink $FILE $ENV_DIR/$(basename $FILE)
done

#
# xargs brew install < ./macPackages/brews.txt
# xargs brew cask install < ./macPackages/casks.txt
# brew cleanup
