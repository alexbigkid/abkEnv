#!/bin/bash

#---------------------------
# variables definitions
#---------------------------
TRACE=0
TOOL_EXE=parallel

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

function PrintUsage ()
{
    echo "$0 - runs jobs in concurrently depending on number of cores"
    echo "usage: $0 <list of jobs to run>"
    echo "  $0 --help   - display this info"
    echo "  <lis of jobs> - could be script files or piped through parameters"
    echo "  example: ls *.gz | parallel.sh 'zcat {} | bzip2 -9 >{.}.bz2'"
    echo "  example: ls LuxorBuild*.sh | parallel.sh"
    echo "errorExitCode = $1"
    exit $1
}

# homebrew installed?
if [[ $(command -v $TOOL_EXE) == "" ]]; then
    echo "ERROR: $TOOL_EXE is not installed, please install with:"
    echo "brew install $0"
    exit $ERROR_REQUIRED_TOOL_IS_NOT_INSTALLED
fi

# echo "\$@ = $@"
[ $TRACE != 0 ] && echo "\$@ = $@"

# time $TOOL_EXE -j+0 --eta $@
# ls *.zip | parallel 'mkdir {.} && cd {.} && unzip ../{}'
