 #!/bin/sh

# exit error codes
ERROR_CODE_SUCCESS=0
ERROR_CODE_GENERAL_ERROR=1
ERROR_CODE_MISUSE_OF_SHELL_BUILT_INS=2
ERROR_CODE_NOT_VALID_NUM_OF_PARAMETERS=3
ERROR_CODE_NOT_VALID_PARAMETER=4
ERROR_CODE=$ERROR_CODE_SUCCESS

# echo "\$0 = $0"
# echo "\$1 = $1"
# echo "\$2 = $2"
# echo "\$3 = $3"
# echo "\$4 = $4"
# echo "\$@ = $@"

PrintUsage ()
{
    echo "$0 - searches for string in all files"
    echo "usage: $0 <fileName>"
    echo "  $0 --help   - display this info"
    echo "  string - to search for in all files and sub directories"
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
    echo "number of parametres passed in: $#"
    echo "parameters: $@"
    PrintUsage $ERROR_CODE_NOT_VALID_NUM_OF_PARAMETERS
fi

# execute find command
# find . -type f | xargs grep "$1" 2>/dev/null
# grep . -Rsil "$1" -print 2>/dev/null
grep -sinr "$1" . --color 2>/dev/null
