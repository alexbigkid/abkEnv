#!/bin/sh

#---------------------------
# functions
#---------------------------
function PrintUsageAndExitWithCode() {
    echo "$0 will create abk environment with aliases and prompt setup"
    echo "the script $0 must be called without any parameters"
    echo "usage: $0"
    echo "  $0 --help           - display this info"
    echo
    echo $2
    echo "errorExitCode = $1"
    exit $1
}

function __install_abkEnv_uninstall_old() {
    echo "-> ${FUNCNAME[0]} ($@)"
    if [ -d "$HOME/env" ]; then
        # looks like legacy installation, deleting previous version
        local LCL_UNINSTALL_1_0_0="macInstallVersions/uninstall_abkEnv_1_0_0.sh"
        if [ -f "$LCL_UNINSTALL_1_0_0" ]; then
            source $LCL_UNINSTALL_1_0_0
            uninstall_abkEnv_1_0_0_main
        fi
    fi
    echo "<- ${FUNCNAME[0]} (0)"
}


function __install_abkEnv_bash() {
    echo "-> ${FUNCNAME[0]} ($@)"
    echo "   [BIN_DIR           = $BIN_DIR]"
    echo "   [HOME_BIN_DIR      = $HOME_BIN_DIR]"
    echo "   [SH_BIN_DIR        = $SH_BIN_DIR]"
    echo "   [SH_PACKAGES_DIR   = $SH_PACKAGES_DIR]"
    echo "   [ABK_ENV_FILE      = $ABK_ENV_FILE]"
    echo "   [HOME              = $HOME]"
    echo

    # uninstall old installations
    __install_abkEnv_uninstall_old

    #-----------------
    # new installation
    #-----------------
    # add abk config file to the users .bash_profile
    # Figure out what directory this script is executed from
    CURRENT_DIR=$PWD
    # echo "CURRENT_DIR = $CURRENT_DIR"
    # if $HOME/$BIN_DIR directory does not exist -> create it
    if [ ! -d $HOME_BIN_DIR ]; then
        echo "   [Creating $HOME_BIN_DIR directory link to $CURRENT_DIR/$SH_BIN_DIR ...]"
        ln -s "$CURRENT_DIR/$SH_BIN_DIR"  $HOME_BIN_DIR
    fi

    # create user .bash_profile if it does not exist yet
    if [ ! -f "$HOME/$CONFIG_FILE_BASH" ]; then
        echo "   [Creating user profile: $HOME/$CONFIG_FILE_BASH ...]"
        touch "$HOME/$CONFIG_FILE_BASH"
    fi

    # add abk environment to the shell profile
    AbkLib_AddEnvironmentSettings "$HOME/$CONFIG_FILE_BASH" "$ABK_ENV_FILE" || PrintUsageAndExitWithCode $ERROR_CODE_NEED_FILE_DOES_NOT_EXIST "${RED}ERROR: one of the files do not exist${NC}"

    source $HOME/$CONFIG_FILE_BASH

    echo "<- ${FUNCNAME[0]} (0)"
    return 0
}

function __install_abkEnv_zsh() {
    echo "-> ${FUNCNAME[0]} ($@)"
    echo "<- ${FUNCNAME[0]} (0)"
}

#---------------------------
# main
#---------------------------
function install_abkEnv_main() {
    # echo "-> ${FUNCNAME[0]} ($@)"
    # vars
    local LCL_RED='\033[0;31m'
    local LCL_NC='\033[0m' # No Color
    declare -a LCL_ABK_SUPPORTED_SHELLS=(
        "bash"
        "zsh"
    )
    local LCL_ABK_SCRIPT_TO_EXECUTE="__install_abkEnv"
    local LCL_ABK_LIB_FILE="macBinBash/AbkLib.sh"
    [ -f $LCL_ABK_LIB_FILE ] && source $LCL_ABK_LIB_FILE || PrintUsageAndExitWithCode 1 "${LCL_RED}ERROR:${LCL_NC} $LCL_ABK_LIB_FILE could not be found."

    # Is parameter --help?
    [ "$#" -eq 1 ] && [ "$1" == "--help" ] && PrintUsageAndExitWithCode $ERROR_CODE_SUCCESS
    # Is number of parameters ok
    [ "$#" -ne 0 ] && PrintUsageAndExitWithCode $ERROR_CODE_GENERAL_ERROR "${LCL_RED}ERROR: invalid number of parameters${NC}"
    # is $SHELL supported
    AbkLib_IsStringInArray $ABK_SHELL "${LCL_ABK_SUPPORTED_SHELLS[@]}" || PrintUsageAndExitWithCode $? "${LCL_RED}ERROR:${LCL_NC} $ABK_SHELL is not supported.\n Please consider using one of those shells: ${LCL_ABK_SUPPORTED_SHELLS[*]}"
    # run shell specific install
    __install_abkEnv_${ABK_SHELL} || PrintUsageAndExitWithCode $? "${RED}ERROR:${NC} __install_abkEnv_${ABK_SHELL} failed"
    echo "<- ${FUNCNAME[0]} (0)"
exit 0
    return 0
}

echo ""
echo "-> $0 ($@)"

install_abkEnv_main $@

echo "<- $0 (0)"
exit 0
