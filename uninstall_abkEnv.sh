 #!/bin/sh

# enable trace here
TRACE=1

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

# find where the scripts is installed
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
FILES=$(find $SH_ENV_DIR -maxdepth 1 -type f -name '*.sh')
for FILE in ${FILES}
do
    SH_ENV_FULL_NAME=$ENV_DIR/$(basename $FILE)
    [ $TRACE != 0 ] && echo "\$SH_ENV_FULL_NAME = $SH_ENV_FULL_NAME"
    #delete previous link association if needed
    [ -L $SH_ENV_FULL_NAME ] && unlink $SH_ENV_FULL_NAME
    LINK_RESULT=$([ $? == 0 ] && echo "SUCCESS" || echo "FAILED")
    echo "[$LINK_RESULT]: $SH_ENV_FULL_NAME -> $FILE"
done

echo ""
echo "[uninstalling links in $BIN_DIR to $SH_BIN_DIR ...]"
FILES=$(find $SH_BIN_DIR -maxdepth 1 -type f -name '*.sh')
for FILE in ${FILES}
do
    SH_BIN_FULL_NAME=$BIN_DIR/$(basename $FILE)
    [ $TRACE != 0 ] && echo "\$SH_BIN_FULL_NAME = $SH_BIN_FULL_NAME"
    #delete previous link association if needed
    [ -L $SH_BIN_FULL_NAME ] && unlink $SH_BIN_FULL_NAME
    LINK_RESULT=$([ $? == 0 ] && echo "SUCCESS" || echo "FAILED")
    echo "[$LINK_RESULT]: $SH_BIN_FULL_NAME -> $FILE"
done

echo ""
echo "[uninstalling links in $BIN_DIR to $SH_DIR ...]"
FILES=$(find $SH_DIR -maxdepth 1 -type f -name '*.sh')
for FILE in ${FILES}
do
    SH_BIN_FULL_NAME=$BIN_DIR/$(basename $FILE)
    [ $TRACE != 0 ] && echo "\$SH_BIN_FULL_NAME = $SH_BIN_FULL_NAME"
    #delete previous link association if needed
    [ -L $SH_BIN_FULL_NAME ] && unlink $SH_BIN_FULL_NAME
    LINK_RESULT=$([ $? == 0 ] && echo "SUCCESS" || echo "FAILED")
    echo "[$LINK_RESULT]: $SH_BIN_FULL_NAME -> $FILE"
done

echo ""
echo "[deleting directory $BIN_DIR if empty ...]"
rmdir $BIN_DIR
echo "[deleting directory $ENV_DIR if empty ...]"
rmdir $ENV_DIR
