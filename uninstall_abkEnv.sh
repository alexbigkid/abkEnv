#!/bin/sh

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
    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "-> ${FUNCNAME[0]} ($@)"

    # remove the abkEnv directory from user's home dir
    if [ -d $HOME_BIN_DIR ]; then
        echo "   [Deleting $HOME_BIN_DIR link ...]"
        rm $HOME_BIN_DIR
    fi

    AbkLib_UninstallCascadiaFonts

    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "<- ${FUNCNAME[0]} (0)"
    return 0
}


__uninstall_abkEnv_for_shell() {
    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "-> ${FUNCNAME[0]} ($@)"

    local LCL_USER_SHELL_CONFIG_FILE=$HOME/$1
    AbkLib_RemoveEnvironmentSettings "$LCL_USER_SHELL_CONFIG_FILE" || PrintUsageAndExitWithCode $ERROR_CODE_NEEDED_FILE_DOES_NOT_EXIST "${RED}ERROR: $HOME/$LCL_USER_SHELL_CONFIG_FILE file does not exist${NC}"

    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "<- ${FUNCNAME[0]} (0)"
    return 0
}


__uninstall_oh_my_bash() {
    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "-> ${FUNCNAME[0]} ($@)"

    local LCL_RETURN_VAL=0
    local LCL_INSTALL_DIR="$HOME/.oh-my-bash"
    if [ -d "$LCL_INSTALL_DIR" ]; then
        rm -Rf $LCL_INSTALL_DIR
        LCL_RETURN_VAL=$?
    fi

    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "<- ${FUNCNAME[0]} ($LCL_RETURN_VAL)"
    return $LCL_RETURN_VAL
}


__uninstall_oh_my_zsh() {
    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "-> ${FUNCNAME[0]} ($@)"

    local LCL_RETURN_VAL=0
    local LCL_INSTALL_DIR="$HOME/.oh-my-zsh"
    if [ -d "$LCL_INSTALL_DIR" ]; then
        rm -Rf $LCL_INSTALL_DIR
        LCL_RETURN_VAL=$?
    fi

    local LCL_PL10K_CONFIG_DST_FILE="~/.p10.zsh"
    if [ "$LCL_RETURN_VAL" -eq 0 ] && [ -f "$LCL_PL10K_CONFIG_DST_FILE" ]; then
        rm $LCL_PL10K_CONFIG_DST_FILE
        LCL_RETURN_VAL=$?
    fi

    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "<- ${FUNCNAME[0]} (0)"
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

    for LCL_SUPPORTED_SHELL in "${ABK_SUPPORTED_SHELLS[@]}"; do
        ${LCL_ABK_UNINSTALL_OH_MY}_${LCL_SUPPORTED_SHELL} || PrintUsageAndExitWithCode $? "${RED}ERROR:${NC} ${LCL_ABK_UNINSTALL_OH_MY}_${LCL_SUPPORTED_SHELL} failed"
    done

    for USER_SHELL_CONFIG_FILE in "${ABK_USER_SHELL_CONFIG_FILES[@]}"; do
        __uninstall_abkEnv_for_shell $USER_SHELL_CONFIG_FILE || PrintUsageAndExitWithCode $? "${RED}ERROR:${NC} __uninstall_abkEnv_for_shell $USER_SHELL_CONFIG_FILE failed"
    done

    __uninstall_abkEnv_common

    AbkLib_SourceEnvironment $HOME/$ABK_USER_SHELL_CONFIG_FILE

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
