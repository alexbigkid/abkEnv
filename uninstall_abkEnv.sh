#!/bin/bash

#---------------------------
# functions
#---------------------------
PrintUsageAndExitWithCode() {
    echo "$0 will unlink directory $BIN_DIR from $SH_BIN_DIR"
    echo "the script $0 must be called without any parameters"
    echo "usage: $0"
    echo "  $0 --help           - display this info"
    echo
    echo $2
    echo "errorExitCode = $1"
    exit $1
}

__uninstall_abkEnv_common() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"
    local LCL_BREW_INSTALLED=$1

    # remove the abkEnv directory from user's home dir
    if [ -d $HOME_BIN_DIR ]; then
        echo "   [Deleting $HOME_BIN_DIR link ...]"
        rm $HOME_BIN_DIR
    fi

    if [ $LCL_BREW_INSTALLED -eq $TRUE ]; then
        AbkLib_UninstallCascadiaFonts
    fi

    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
    return 0
}

__uninstall_abkEnv_for_shell() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"

    local LCL_USER_SHELL_CONFIG_FILE=$HOME/$1
    AbkLib_RemoveEnvironmentSettings "$ABK_ENV_NAME" "$LCL_USER_SHELL_CONFIG_FILE" || PrintUsageAndExitWithCode $ERROR_CODE_NEEDED_FILE_DOES_NOT_EXIST "${RED}ERROR: $HOME/$LCL_USER_SHELL_CONFIG_FILE file does not exist${NC}"

    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
    return 0
}

__uninstall_oh_my_bash() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"

    local LCL_RETURN_VAL=0
    local LCL_INSTALL_DIR="$HOME/.oh-my-bash"
    if [ -d "$LCL_INSTALL_DIR" ]; then
        rm -Rf $LCL_INSTALL_DIR
        LCL_RETURN_VAL=$?
    fi

    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_RETURN_VAL)"
    return $LCL_RETURN_VAL
}

__uninstall_oh_my_zsh() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"

    local LCL_RETURN_VAL=0
    local LCL_INSTALL_DIR="$HOME/.oh-my-zsh"
    if [ -d "$LCL_INSTALL_DIR" ]; then
        rm -Rf $LCL_INSTALL_DIR
        LCL_RETURN_VAL=$?
    fi

    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
    return 0
}

#---------------------------
# main
#---------------------------
uninstall_abkEnv_main() {
    local LCL_RED='\033[0;31m'
    local LCL_NC='\033[0m' # No Color
    local LCL_ABK_UNINSTALL_OH_MY="__uninstall_oh_my"
    local LCL_ABK_LIB_FILE="./macBin/AbkLib.sh"
    [ -f $LCL_ABK_LIB_FILE ] && . $LCL_ABK_LIB_FILE || PrintUsageAndExitWithCode 1 "${LCL_RED}ERROR:${LCL_NC} $LCL_ABK_LIB_FILE could not be found."
    local LCL_BREW_INSTALLED=$FALSE
    [ "$(command -v brew)" != "" ] && LCL_BREW_INSTALLED=$TRUE

    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"
    AbkLib_PrintTrace $TRACE_INFO "   [BIN_DIR           = $BIN_DIR]"
    AbkLib_PrintTrace $TRACE_INFO "   [HOME_BIN_DIR      = $HOME_BIN_DIR]"
    AbkLib_PrintTrace $TRACE_INFO "   [SH_BIN_DIR        = $SH_BIN_DIR]"
    AbkLib_PrintTrace $TRACE_INFO "   [SH_PACKAGES_DIR   = $SH_PACKAGES_DIR]"
    AbkLib_PrintTrace $TRACE_INFO "   [ABK_ENV_FILE      = $ABK_ENV_FILE]"
    AbkLib_PrintTrace $TRACE_INFO "   [HOME              = $HOME]"
    AbkLib_PrintTrace $TRACE_INFO

    # Is parameter --help?
    [ "$#" -eq 1 ] && [ "$1" == "--help" ] && PrintUsageAndExitWithCode $ERROR_CODE_SUCCESS
    # Is number of parameters ok
    [ "$#" -ne 0 ] && PrintUsageAndExitWithCode $ERROR_CODE_GENERAL_ERROR "${RED}ERROR: invalid number of parameters${NC}"
    # is $SHELL supported
    AbkLib_IsStringInArray $ABK_SHELL ${ABK_SUPPORTED_SHELLS[@]} || PrintUsageAndExitWithCode $? "${RED}ERROR:${NC} $ABK_SHELL is not supported.\nPlease consider using one of those shells: ${ABK_SUPPORTED_SHELLS[*]}"

    for LCL_SUPPORTED_SHELL in "${ABK_SUPPORTED_SHELLS[@]}"; do
        ${LCL_ABK_UNINSTALL_OH_MY}_${LCL_SUPPORTED_SHELL} || PrintUsageAndExitWithCode $? "${RED}ERROR:${NC} ${LCL_ABK_UNINSTALL_OH_MY}_${LCL_SUPPORTED_SHELL} failed"
    done

    for USER_SHELL_CONFIG_FILE in "${ABK_USER_SHELL_CONFIG_FILES[@]}"; do
        __uninstall_abkEnv_for_shell $USER_SHELL_CONFIG_FILE || PrintUsageAndExitWithCode $? "${RED}ERROR:${NC} __uninstall_abkEnv_for_shell $USER_SHELL_CONFIG_FILE failed"
    done

    __uninstall_abkEnv_common $LCL_BREW_INSTALLED

    AbkLib_SourceEnvironment $HOME/$ABK_USER_SHELL_CONFIG_FILE

    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
    return 0
}

echo ""
echo "-> $0 ($@)"

export ABK_SHELL="${SHELL##*/}"
uninstall_abkEnv_main $@
LCL_EXIT_CODE=$?

echo "<- $0 (0)"
exit $LCL_EXIT_CODE
