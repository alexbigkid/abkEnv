#!/bin/bash

# exit error codes
ERROR_CODE_SUCCESS=0
ERROR_CODE_GENERAL_ERROR=1
ERROR_CODE_MISUSE_OF_SHELL_BUILT_INS=2
ERROR_CODE_NOT_VALID_NUM_OF_PARAMETERS=3
ERROR_CODE_NOT_VALID_PARAMETER=4
ERROR_FILE_DOES_NOT_EXIST=5
ERROR_FILE_NOT_IN_PNG_FORMAT=6
ERROR_REQUIRED_TOOL_IS_NOT_INSTALLED=7
ERROR_PARAMETER_IS_NOT_A_DIRECTORY=8
ERROR_CODE=$ERROR_CODE_SUCCESS


PrintUsage ()
{
    echo "$0 converts all png files to svg images in a given directory"
    echo "usage: $0 <DirWithPngFiles>"
    echo "  $0 --help   - display this info"
    echo "  DirWithPngFiles - directory with files in png format"
    echo "errorExitCode = $1"
    exit $1
}

#-------  main -------------
# if parameter is --help
if [ $# -eq 1 ] && [ $1 = "--help" ]; then
    PrintUsage $ERROR_CODE_SUCCESS
fi

# if not 1 parameters
if [ $# -ne 1 ]; then
    echo "ERROR: not valid number of parameters"
    echo "number of parametres passed in: $#"
    echo "parameters: $@"
    PrintUsage $ERROR_CODE_NOT_VALID_NUM_OF_PARAMETERS
fi

# parameter is not a directory
if [ ! -d $1 ]; then
    echo "ERROR: parameter \"$1\" is not a directory"
    PrintUsage $ERROR_PARAMETER_IS_NOT_A_DIRECTORY
fi

# homebrew installed?
if [[ $(command -v brew) == "" ]]; then
    echo "ERROR: Hombrew is not installed, please install with:"
    echo "/usr/bin/ruby -e \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\""
    PrintUsage $ERROR_REQUIRED_TOOL_IS_NOT_INSTALLED
fi

# is imagemagick installed?
if [[ $(command -v convert) == "" ]]; then
    echo "ERROR: imagemagick is not installed, please install with:"
    echo "brew install imagemagick"
    PrintUsage $ERROR_REQUIRED_TOOL_IS_NOT_INSTALLED
fi

# is potrace installed?
if [[ $(command -v potrace) == "" ]]; then
    echo "ERROR: potrace is not installed, please install with:"
    echo "brew install potrace"
    PrintUsage $ERROR_REQUIRED_TOOL_IS_NOT_INSTALLED
fi

# store current setting for $IFS 
OIFS="$IFS"
IFS=$'\n'

# prune directory name if there is is / on the end
PRUNED_DIR_NAME=${1%/*}

# create DATE_TIME stamp
DATE_TIME=$(date +%Y%m%d_%H%M%S)
# echo "date_time: $DATE_TIME"
SRC_DIR="$PRUNED_DIR_NAME/source/$DATE_TIME"
DST_DIR="$PRUNED_DIR_NAME/processed/$DATE_TIME"

# read the directory where png files suppose to be
echo ""
echo "[reading png files in $PRUNED_DIR_NAME directory ...]"
PNG_FILES=$(find $PRUNED_DIR_NAME -maxdepth 1 -type f -name '*.png')
# echo "\$PNG_FILES = $PNG_FILES"

if [[ $PNG_FILES == "" ]]; then
    echo "No png files found in directory: $PRUNED_DIR_NAME"
    exit $ERROR_CODE_SUCCESS
fi

echo "[creating $SRC_DIR. The source png files will be moved here]"
mkdir -pv -m 755 $SRC_DIR || exit $?
echo "[creating $DST_DIR. The processed svg files will be moved here]"
mkdir -pv -m 755 $DST_DIR || exit $?

for PNG_FILE in ${PNG_FILES}
do
    # echo "\$PNG_FILE = $PNG_FILE"
    if [ $(file -b --mime-type "$PNG_FILE") == "image/png" ]; then
        # echo "\$PNG_FILE = $PNG_FILE"
        PNG_F="${PNG_FILE%.png}"
        convert "$PNG_FILE" "$PNG_F.pnm"
        potrace "$PNG_F.pnm" -s -o "$PNG_F.svg"
        rm "$PNG_F.pnm"
        mv "$PNG_FILE" "$SRC_DIR/$(basename $PNG_FILE)"
        mv "$PNG_F.svg" "$DST_DIR/$(basename $PNG_F.svg)"
    fi
done

# resore $IFS
IFS="$OIFS"
