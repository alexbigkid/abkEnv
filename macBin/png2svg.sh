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
ERROR_CODE=$ERROR_CODE_SUCCESS

# echo "\$0 = $0"
# echo "\$1 = $1"
# echo "\$@ = $@"

function PrintUsage ()
{
    echo "$0 converts png to svg image"
    echo "usage: $0 <PngFileName>"
    echo "  $0 --help   - display this info"
    echo "  PngFileName - image file in png format"
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

# check if file exist
if [ ! -f $1 ]; then
    echo "ERROR: file $1 does not exist!"
    PrintUsage $ERROR_FILE_DOES_NOT_EXIST
fi

# check for file is image/png format
DIR_NAME=$(dirname $1)
BASE_NAME=$(basename $1)
FILE_NAME=${BASE_NAME%.*}
EXT_NAME=${BASE_NAME##*.}
# echo "input file = $1"
# echo "\$DIR_NAME  = $DIR_NAME"
# echo "\$BASE_NAME = $BASE_NAME"
# echo "\$FILE_NAME = $FILE_NAME"
# echo "\$EXT_NAME  = $EXT_NAME"
if [ $EXT_NAME != "png" ] || [ $(file -b --mime-type $1) != "image/png" ]; then
    echo "ERROR: file $1 is NOT png file!"
    PrintUsage $ERROR_FILE_NOT_IN_PNG_FORMAT
fi

# execute png to svg conversion
PNM_FILE=$DIR_NAME/$FILE_NAME.pnm
SVG_FILE=$DIR_NAME/$FILE_NAME.svg
# echo \$PNM_FILE = $PNM_FILE
# echo \$SVG_FILE = $SVG_FILE
convert $1 $PNM_FILE
potrace $PNM_FILE -s -o $SVG_FILE
rm $PNM_FILE
