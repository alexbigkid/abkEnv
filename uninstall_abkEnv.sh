 #!/bin/bash

# enable trace here
TRACE=0

# define here installation directory
BIN_DIR=$HOME/bin
[ $TRACE != 0 ] && echo \$BIN_DIR = $BIN_DIR
ENV_DIR=$HOME/env
[ $TRACE != 0 ] && echo \$ENV_DIR = $ENV_DIR
SH_DIR=""
[ $TRACE != 0 ] && echo \$SH_DIR = $SH_DIR
SH_BIN_DIR="macBin"
[ $TRACE != 0 ] && echo \$SH_BIN_DIR = $SH_BIN_DIR
SH_ENV_DIR="macEnv"
[ $TRACE != 0 ] && echo \$SH_ENV_DIR = $SH_ENV_DIR

NEW_BASH_PROFILE="bash_profile.sh"
ORG_BASH_PROFILE=".bash_profile"

EXECUTED_FROM_BIN=0

# exit error codes
ERROR_CODE_SUCCESS=0
ERROR_CODE_GENERAL_ERROR=1
ERROR_CODE_IS_INSTALLED_BUT_NO_LINK=2
ERROR_CODE_NOT_VALID_NUM_OF_PARAMETERS=3

function PrintUsage ()
{
    echo "$0 will unlink all installed script files in $BIN_DIR and $ENV_DIR and brew packages"
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

function DeleteLink ()
{
    if [ $# -ne 2 ]; then
        echo "ERROR: invalid number of parameters"
        false
    fi
    # [ $TRACE != 0 ] && echo "\$2 = $2"
    #delete previous link association if needed
    [ -L $2 ] && unlink $2
    LINK_RESULT=$([ $? == 0 ] && echo true || echo false )
    echo "[$LINK_RESULT]: $2 -> $1"
    $LINK_RESULT
}

function RestoreOldBashProfile ()
{
    DeleteLink $ENV_DIR/$NEW_BASH_PROFILE $HOME/$ORG_BASH_PROFILE
    if [ -f $ENV_DIR/$ORG_BASH_PROFILE ]; then
        echo ""
        echo "[restore the original $ENV_DIR/$ORG_BASH_PROFILE]"
        mv $ENV_DIR/$ORG_BASH_PROFILE $HOME/$ORG_BASH_PROFILE
    fi
}


#-------  main -------------
[ $TRACE != 0 ] && echo "\$# = $#, \$0 = $0, \$1 = $1"

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
    SH_DIR=$(GetAbsolutePath $0)
else
    SH_DIR=$(GetPathFromLink $BIN_UNINSTALL_FILE)
fi
SH_BIN_DIR=$SH_DIR/$SH_BIN_DIR
SH_ENV_DIR=$SH_DIR/$SH_ENV_DIR
[ $TRACE != 0 ] && echo "\$SH_DIR    =$SH_DIR"
[ $TRACE != 0 ] && echo "\$SH_BIN_DIR=$SH_BIN_DIR"
[ $TRACE != 0 ] && echo "\$SH_ENV_DIR=$SH_ENV_DIR"

echo ""
echo "[uninstalling links in $ENV_DIR to $SH_ENV_DIR ...]"
FILES=$(find $SH_ENV_DIR -maxdepth 1 -type f -name '*.env')
for FILE in ${FILES}
do
    DeleteLink $FILE $ENV_DIR/$(basename $FILE)
done

echo ""
echo "[uninstalling links in $BIN_DIR to $SH_BIN_DIR ...]"
FILES=$(find $SH_BIN_DIR -maxdepth 1 -type f -name '*.sh')
for FILE in ${FILES}
do
    DeleteLink $FILE $BIN_DIR/$(basename $FILE)
done

echo ""
echo "[uninstalling links in $BIN_DIR to $SH_DIR ...]"
FILES=$(find $SH_DIR -maxdepth 1 -type f -name '*.sh')
for FILE in ${FILES}
do
    DeleteLink $FILE $BIN_DIR/$(basename $FILE)
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
