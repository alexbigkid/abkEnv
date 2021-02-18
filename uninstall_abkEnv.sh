#!/bin/sh

#---------------------------
# functions
#---------------------------
function PrintUsageAndExitWithCode() {
    echo "$0 will unlink directory $BIN_DIR from $SH_BIN_DIR"
    echo "the script $0 must be called without any parameters"
    echo "usage: $0"
    echo "  $0 --help           - display this info"
    echo
    echo $2
    echo "errorExitCode = $1"
    exit $1
}

function __uninstall_abkEnv_common() {
    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "-> ${FUNCNAME[0]} ($@)"

    # remove abk environment to the shell profile
    AbkLib_RemoveEnvironmentSettings "$HOME/$ABK_USER_SHELL_CONFIG_FILE" || PrintUsageAndExitWithCode $ERROR_CODE_NEED_FILE_DOES_NOT_EXIST "${RED}ERROR: $HOME/$ABK_USER_SHELL_CONFIG_FILE file does not exist${NC}"

    # remove the abkEnv directory from user's home dir
    if [ -d $HOME_BIN_DIR ]; then
        echo "   [Deleting $HOME_BIN_DIR link ...]"
        rm $HOME_BIN_DIR
    fi

    # refresh the profile
    source $HOME/$ABK_USER_SHELL_CONFIG_FILE

    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "<- ${FUNCNAME[0]} (0)"
    return 0
}

function __uninstall_abkEnv_bash() {
    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "-> ${FUNCNAME[0]} ($@)"
    __uninstall_abkEnv_common
    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "<- ${FUNCNAME[0]} (0)"
    return 0
}

function __uninstall_abkEnv_zsh() {
    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "-> ${FUNCNAME[0]} ($@)"
    __uninstall_abkEnv_common
    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "<- ${FUNCNAME[0]} (0)"
    return 0
}

#---------------------------
# main
#---------------------------
function uninstall_abkEnv_main() {
    local LCL_RED='\033[0;31m'
    local LCL_NC='\033[0m' # No Color
    local LCL_ABK_SCRIPT_TO_EXECUTE="__uninstall_abkEnv"
    local LCL_ABK_LIB_FILE="macBin/AbkLib.sh"
    [ -f $LCL_ABK_LIB_FILE ] && source $LCL_ABK_LIB_FILE || PrintUsageAndExitWithCode 1 "${LCL_RED}ERROR:${LCL_NC} $LCL_ABK_LIB_FILE could not be found."

    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "-> ${FUNCNAME[0]} ($@)"
    [ "$ABK_TRACE" -ge "$ABK_INFO_TRACE" ] && echo "   [BIN_DIR           = $BIN_DIR]"
    [ "$ABK_TRACE" -ge "$ABK_INFO_TRACE" ] && echo "   [HOME_BIN_DIR      = $HOME_BIN_DIR]"
    [ "$ABK_TRACE" -ge "$ABK_INFO_TRACE" ] && echo "   [SH_BIN_DIR        = $SH_BIN_DIR]"
    [ "$ABK_TRACE" -ge "$ABK_INFO_TRACE" ] && echo "   [SH_PACKAGES_DIR   = $SH_PACKAGES_DIR]"
    [ "$ABK_TRACE" -ge "$ABK_INFO_TRACE" ] && echo "   [ABK_ENV_FILE      = $ABK_ENV_FILE]"
    [ "$ABK_TRACE" -ge "$ABK_INFO_TRACE" ] && echo "   [HOME              = $HOME]"
    [ "$ABK_TRACE" -ge "$ABK_INFO_TRACE" ] && echo

    # Is parameter --help?
    [ "$#" -eq 1 ] && [ "$1" == "--help" ] && PrintUsageAndExitWithCode $ERROR_CODE_SUCCESS
    # Is number of parameters ok
    [ "$#" -ne 0 ] && PrintUsageAndExitWithCode $ERROR_CODE_GENERAL_ERROR "${RED}ERROR: invalid number of parameters${NC}"
    # is $SHELL supported
    AbkLib_IsStringInArray $ABK_SHELL ${ABK_SUPPORTED_SHELLS[@]} || PrintUsageAndExitWithCode $? "${RED}ERROR:${NC} $ABK_SHELL is not supported.\nPlease consider using one of those shells: ${ABK_SUPPORTED_SHELLS[*]}"
    # run shell specific install
    ${LCL_ABK_SCRIPT_TO_EXECUTE}_${ABK_SHELL} || PrintUsageAndExitWithCode $? "${RED}ERROR:${NC} ${LCL_ABK_SCRIPT_TO_EXECUTE}_${ABK_SHELL} failed"

    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "<- ${FUNCNAME[0]} (0)"
    return 0
}

echo ""
echo "-> $0 ($@)"

export ABK_SHELL="${SHELL##*/}"
uninstall_abkEnv_main $@
LCL_EXIT_CODE=$?

echo "<- $0 (0)"
exit $LCL_EXIT_CODE
