#!/bin/bash

EXPECTED_NUMBER_OF_PARAMS=0
COMMON_LIB_FILE="./abkLib.sh"
EXIT_CODE=0

TOOLS_TO_INSTALL=(
    # aws
    cmake
    direnv
    git
    gnupg
    jq
    parallel
    # serverless
    # terraform
    yq
)
PACKAGES_TO_INSTALL=(
    # awscli
    cmake
    direnv
    git
    gnupg
    jq
    parallel
    # serverless
    # terraform
    yq
)

# -----------------------------------------------------------------------------
# functions
# -----------------------------------------------------------------------------
PrintUsageAndExitWithCode() {
    echo "$0 will install defailt apps on MacOS and some linux distros"
    echo "the script $0 must be called without any parameters"
    echo "usage: $0"
    echo "  $0 --help           - display this info"
    echo
    echo $2
    echo "errorExitCode = $1"
    exit $1
}

InstallRequiredToolsUsingBrew() {
    echo
    PrintTrace $TRACE_FUNCTION "----------------------------------------------------------------------"
    PrintTrace $TRACE_FUNCTION "| ${FUNCNAME[0]} ($@)"
    PrintTrace $TRACE_FUNCTION "----------------------------------------------------------------------"

    for ((i = 0; i < ${#LCL_TOOL[@]}; i++)); do
        PrintTrace $TRACE_INFO "\n------------------------\n${LCL_TOOL[$i]} - INSTALL AND CHECK\n------------------------"
        [ "$(command -v ${LCL_TOOL[$i]})" == "" ] && brew install ${LCL_PACKAGE[$i]} || which ${LCL_TOOL[$i]}
        PrintTrace $TRACE_INFO "\n------------------------\n${LCL_TOOL[$i]} - VERSION\n------------------------"
        ${LCL_TOOL[$i]} --version || exit $?
        PrintTrace $TRACE_INFO "${YLW}----------------------------------------------------------------------${NC}"
        echo
    done
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
}

InstallRequiredToolsUsingApt() {
    LCL_TOOL=(
        aws
        jq
        parallel
        terraform
        yq
    )
    LCL_PACKAGE=(
        awscli
        jq
        parallel
        terraform
        yq
    )

    echo
    PrintTrace $TRACE_FUNCTION "----------------------------------------------------------------------"
    PrintTrace $TRACE_FUNCTION "| ${FUNCNAME[0]} ($@)"
    PrintTrace $TRACE_FUNCTION "----------------------------------------------------------------------"

    for ((i = 0; i < ${#LCL_TOOL[@]}; i++)); do
        PrintTrace $TRACE_INFO "\n------------------------\n${LCL_TOOL[$i]} - INSTALL AND CHECK\n------------------------"
        [ "$(command -v ${LCL_TOOL[$i]})" == "" ] && sudo apt install -y ${LCL_PACKAGE[$i]} || which ${LCL_TOOL[$i]}
        PrintTrace $TRACE_INFO "\n------------------------\n${LCL_TOOL[$i]} - VERSION\n------------------------"
        ${LCL_TOOL[$i]} --version || exit $?
        PrintTrace $TRACE_INFO "${YLW}----------------------------------------------------------------------${NC}"
        echo
    done
    PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
}

# -----------------------------------------------------------------------------
# main
# -----------------------------------------------------------------------------
# include common library, fail if does not exist
if [ -f $COMMON_LIB_FILE ]; then
    source $COMMON_LIB_FILE
else
    echo "ERROR: $COMMON_LIB_FILE does not exist in the local directory."
    echo "  $COMMON_LIB_FILE contains common definitions and functions"
    exit 1
fi

echo
PrintTrace $TRACE_FUNCTION "-> $0 ($@)"

if [ "$AAI_UNIX_TYPE" = "mac" ]; then
    InstallRequiredToolsUsingBrew || exit $?
elif [ "$AAI_UNIX_TYPE" = "linux" ]; then
    InstallRequiredToolsUsingApt || exit $?
fi
InstallRequiredToolsUsingNpm || exit $?

PrintTrace $TRACE_FUNCTION "<- $0 ($EXIT_CODE)"
echo
exit $EXIT_CODE

#-------  main -------------
# does lib file exist?
[ -f $ABK_LIB_FILE ] && . $ABK_LIB_FILE || PrintUsageAndExitWithCode 1 "ERROR: cannot find library: $ABK_LIB_FILE"

AbkLib_IsParameterHelp $# $1 && PrintUsageAndExitWithCode $EXIT_CODE_SUCCESS "---- Help displayed ----"

# check if it is bash shell
ABK_SHELL="${SHELL##*/}"
[ "$ABK_SHELL" != "bash" ] && [ "$ABK_SHELL" != "zsh" ] && PrintUsageAndExitWithCode $ERROR_CODE_NOT_BASH_SHELL

# is brew installed?
if [ $(command -v brew) != "" ]; then
    InstallRequiredToolsUsingBrew || AbkLib_PrintUsage $ERROR_CODE_TOOL_NOT_INSTALLED
# is apt installed?
elif [ $(command -v apt) != "" ]; then
    InstallRequiredToolsUsingApt || AbkLib_PrintUsage $ERROR_CODE_TOOL_NOT_INSTALLED
else
    echo "ERROR: not able to install apps"
    AbkLib_PrintUsage $ERROR_CODE_TOOL_NOT_INSTALLED
fi


exit $ERROR_CODE_SUCCESS
