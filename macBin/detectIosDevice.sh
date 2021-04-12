#!/bin/bash

EXIT_CODE=0
EXPECTED_NUMBER_OF_PARAMS=0
ABK_LIB_FILE="AbkLib.sh"

declare -a VALID_IOS_DEVICE=("iPhone"
                             "iPad"
                             "iPod")


PrintUsageAndExitWithCode ()
{
    echo ""
    echo "$0 detects iOS devices connected via USB to Mac"
    echo "This script ($0) can be called with 0 to ${#VALID_IOS_DEVICE[@]} parameters."
    echo "  Valid parameters are: ${VALID_IOS_DEVICE[@]} or no parameters at all."
    echo "  If no parameters are passed to the $0 script, it will search for all iOS devices connected to USB."
    echo ""
    echo "$0 --help           - display this info"
    exit $1
}



# ----------
# main
# ----------
echo ""
echo "-> $0 ($@)"

# include common library, fail if does not exist
if [ -f "../$ABK_LIB_FILE" ]; then
    echo "sourcing from ../$ABK_LIB_FILE"
    . "../$ABK_LIB_FILE"
elif [ -f "$HOME/bin/$ABK_LIB_FILE" ]; then
    echo "sourcing from $HOME/bin/$ABK_LIB_FILE"
    . "$HOME/bin/$ABK_LIB_FILE"
else
    echo "ERROR: $ABK_LIB_FILE does not exist in the local directory."
    echo "  $ABK_LIB_FILE contains common definitions and functions"
    exit 1
fi

AbkLib_IsParameterHelp $# $1 && PrintUsageAndExitWithCode $EXIT_CODE_SUCCESS

echo "number of parameters $#"
if [[ $# -eq 0 ]]; then
    SEARCH_STRING=$(echo ${VALID_IOS_DEVICE[@]} | sed 's/\ /\\|/g')
elif [[ $# -le ${#VALID_IOS_DEVICE[@]} ]]; then
    VALID_PARAMETER_ARRAY=()
    for PARAMETER in "$@";
    do
        AbkLib_IsPredefinedParameterValid $PARAMETER "${VALID_IOS_DEVICE[@]}" || PrintUsageAndExitWithCode $EXIT_CODE_NOT_VALID_PARAMETER
        VALID_PARAMETER_ARRAY+=($PARAMETER)
    done
    echo "VALID_PARAMETER_ARRAY = ${#VALID_PARAMETER_ARRAY[@]}"
    SEARCH_STRING=$(echo ${VALID_PARAMETER_ARRAY[@]} | sed 's/\ /\\|/g')
else
    PrintUsageAndExitWithCode $ERROR_CODE_NOT_VALID_PARAMETER
fi

# execute command with valid devices names
echo "\$SEARCH_STRING = \"$SEARCH_STRING\""
system_profiler SPUSBDataType | grep -A 11 -w $SEARCH_STRING


echo "<- $0 ($EXIT_CODE)"
echo ""
exit $EXIT_CODE
