#!/bin/sh

# enable trace here
TRACE=1

# define here installation directory
BIN_DIR=$HOME/bin2
[ $TRACE != 0 ] && echo \$BIN_DIR = $BIN_DIR
ENV_DIR=$HOME/env2
[ $TRACE != 0 ] && echo \$ENV_DIR = $ENV_DIR
SH_DIR=""
[ $TRACE != 0 ] && echo \$SH_DIR= $SH_DIR
SH_BIN_DIR="macBin"
[ $TRACE != 0 ] && echo \$SH_BIN_DIR= $SH_BIN_DIR
SH_ENV_DIR="macEnv"
[ $TRACE != 0 ] && echo \$SH_ENV_DIR= $SH_ENV_DIR
# echo "dirname/readlink: $(dirname $(path -n $0))"
REFRESH=0


# exit error codes
ERROR_CODE_SUCCESS=0
ERROR_CODE_GENERAL_ERROR=1
ERROR_CODE_IS_INSTALLED_BUT_NO_LINK=2
ERROR_CODE_NOT_VALID_NUM_OF_PARAMETERS=3

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

#-------  main -------------
[ $TRACE != 0 ] && echo "\$# = $#, \$1 = $1"

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


# create/update links
echo ""
echo "[links in $BIN_DIR to $SH_DIR ...]"
FILES=$(find $SH_DIR -maxdepth 1 -type f -name '*.sh')
for FILE in ${FILES}
do
    SH_BIN_FULL_NAME=$BIN_DIR/$(basename $FILE)
    [ $TRACE != 0 ] && echo "\$SH_BIN_FULL_NAME = $SH_BIN_FULL_NAME"
    #delete previous link association if needed
    [ -L $SH_BIN_FULL_NAME ] && unlink $SH_BIN_FULL_NAME
    ln -s $FILE $SH_BIN_FULL_NAME
    LINK_RESULT=$([ $? == 0 ] && echo "SUCCESS" || echo "FAILED")
    echo "[$LINK_RESULT]: $SH_BIN_FULL_NAME -> $FILE"
done

# create/update links in macBin
echo ""
echo "[links in $BIN_DIR to $SH_BIN_DIR ...]"
FILES=$(find $SH_BIN_DIR -maxdepth 1 -type f -name '*.sh')
for FILE in ${FILES}
do
    SH_BIN_FULL_NAME=$BIN_DIR/$(basename $FILE)
    [ $TRACE != 0 ] && echo "\$SH_BIN_FULL_NAME = $SH_BIN_FULL_NAME"
    #delete previous link association if needed
    [ -L $SH_BIN_FULL_NAME ] && unlink $SH_BIN_FULL_NAME
    ln -s $FILE $SH_BIN_FULL_NAME
    LINK_RESULT=$([ $? == 0 ] && echo "SUCCESS" || echo "FAILED")
    echo "[$LINK_RESULT]: $SH_BIN_FULL_NAME -> $FILE"
done

# create/update links in macEnv
echo ""
echo "[links in $ENV_DIR to $SH_ENV_DIR ...]"
FILES=$(find $SH_ENV_DIR -maxdepth 1 -type f -name '*.sh')
for FILE in ${FILES}
do
    SH_ENV_FULL_NAME=$ENV_DIR/$(basename $FILE)
    [ $TRACE != 0 ] && echo "\$SH_ENV_FULL_NAME = $SH_ENV_FULL_NAME"
    #delete previous link association if needed
    [ -L $SH_ENV_FULL_NAME ] && unlink $SH_ENV_FULL_NAME
    ln -s $FILE $SH_ENV_FULL_NAME
    LINK_RESULT=$([ $? == 0 ] && echo "SUCCESS" || echo "FAILED")
    echo "[$LINK_RESULT]: $SH_ENV_FULL_NAME -> $FILE"
done
