#!/bin/bash

#---------------------------
# functions
#---------------------------
PrintUsageAndExitWithCode() {
    echo "$0 will create abk environment with aliases and prompt setup"
    echo "the script $0 must be called without any parameters"
    echo "usage: $0"
    echo "  $0 --help           - display this info"
    echo
    echo $2
    echo "errorExitCode = $1"
    exit $1
}

__install_abkEnv_uninstall_old() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"
    if [ -d "$HOME/env" ]; then
        # looks like legacy installation, deleting previous version
        local LCL_UNINSTALL_1_0_0="macInstallVersions/uninstall_abkEnv_1_0_0.sh"
        if [ -f "$LCL_UNINSTALL_1_0_0" ]; then
            . $LCL_UNINSTALL_1_0_0
            uninstall_abkEnv_1_0_0_main
        fi
    fi
    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
}

__install_abkEnv_common() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"
    local LCL_BREW_INSTALLED=$1
    local LCL_RETURN_VAL=0

    # Figure out what directory this script is executed from
    local LCL_CURRENT_DIR=$PWD
    # echo "LCL_CURRENT_DIR = $LCL_CURRENT_DIR"
    if [ ! -d $HOME_BIN_DIR ]; then
        echo "   [Creating $HOME_BIN_DIR directory link to $LCL_CURRENT_DIR/$SH_BIN_DIR ...]"
        ln -s "$LCL_CURRENT_DIR/$SH_BIN_DIR" $HOME_BIN_DIR
        LCL_RETURN_VAL=$?
    fi

    if [ $LCL_BREW_INSTALLED -eq $TRUE ]; then
        AbkLib_InstallCascadiaFonts || PrintUsageAndExitWithCode $? "${YELLOW}WARNING:${NC} Cascadia fonts cannot be installed"
    fi

    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_RETURN_VAL)"
    return $LCL_RETURN_VAL
}

__install_abkEnv_for_shell() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"
    local LCL_USER_SHELL_CONFIG_FILE=$HOME/$1
    local LCL_CONTENT_TO_ADD_ARRAY=(
        "if [ -f $ABK_ENV_FILE ]; then"
        "    . $ABK_ENV_FILE"
        "fi"
    )

    if [ ! -f "$LCL_USER_SHELL_CONFIG_FILE" ]; then
        echo "   [Creating user profile: $LCL_USER_SHELL_CONFIG_FILE ...]"
        touch "$LCL_USER_SHELL_CONFIG_FILE"
    fi

    AbkLib_AddEnvironmentSettings "$ABK_ENV_NAME" "$LCL_USER_SHELL_CONFIG_FILE" "${LCL_CONTENT_TO_ADD_ARRAY[@]}" || PrintUsageAndExitWithCode $ERROR_CODE_NEEDED_FILE_DOES_NOT_EXIST "${RED}ERROR: failed update environment in $LCL_USER_SHELL_CONFIG_FILE${NC}"

    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
    return 0
}

__install_oh_my_bash() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"

    local LCL_RETURN_VAL=0
    local LCL_INSTALL_DIR="$HOME/.oh-my-bash"
    if [ ! -d "$LCL_INSTALL_DIR" ]; then
        git clone https://github.com/ohmybash/oh-my-bash.git $LCL_INSTALL_DIR
        # git clone https://github.com/ohmybash/ohmybash.github.io.git $LCL_INSTALL_DIR
        # git clone git@github.com:ohmybash/oh-my-bash.git $LCL_INSTALL_DIR
        # curl -fsSL https://raw.githubusercontent.com/ohmybash/oh-my-bash/master/tools/install.sh
        LCL_RETURN_VAL=$?
    fi

    # copy custom theme
    if [ "$LCL_RETURN_VAL" -eq 0 ]; then
        local LCL_CUSTOM_THEME_SRC_FILE="./macBin/env/bash/custom/themes/abk_pl"
        local LCL_CUSTOM_THEME_DST_DIR="$LCL_INSTALL_DIR/custom/themes/"
        mkdir -p $LCL_CUSTOM_THEME_DST_DIR
        cp -r $LCL_CUSTOM_THEME_SRC_FILE $LCL_CUSTOM_THEME_DST_DIR
        LCL_RETURN_VAL=$?
    fi

    # overwrite the history.sh since it has a bug
    # if [ "$LCL_RETURN_VAL" -eq 0 ]; then
    #     local LCL_CUSTOM_THEME_SRC_FILE="./macBin/env/bash/lib/history.sh"
    #     local LCL_CUSTOM_THEME_DST_DIR="$LCL_INSTALL_DIR/lib/"
    #     mkdir -p $LCL_CUSTOM_THEME_DST_DIR
    #     cp -f $LCL_CUSTOM_THEME_SRC_FILE $LCL_CUSTOM_THEME_DST_DIR
    #     LCL_RETURN_VAL=$?
    # fi

    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_RETURN_VAL)"
    return $LCL_RETURN_VAL
}

__install_oh_my_zsh() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"

    local LCL_RETURN_VAL=0
    local LCL_INSTALL_DIR="$HOME/.oh-my-zsh"

    # install oh-my-zsh
    if [ ! -d "$LCL_INSTALL_DIR" ]; then
        git clone https://github.com/ohmyzsh/ohmyzsh.git $LCL_INSTALL_DIR
        LCL_RETURN_VAL=$?
    fi

    # install powerlevel10k custom theme for oh-my-zsh
    local LCL_PL10K_THEME_DIR="${ZSH_CUSTOM:-$LCL_INSTALL_DIR/custom}/themes/powerlevel10k"
    if [ "$LCL_RETURN_VAL" -eq 0 ] && [ ! -d "$LCL_PL10K_THEME_DIR" ]; then
        # git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $LCL_INSTALL_DIR/custom/themes/powerlevel10k
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $LCL_PL10K_THEME_DIR
        LCL_RETURN_VAL=$?
    fi

    # install zsh-autosuggestion custom plugin
    local LCL_ZSH_AUTOSUGGESTION_PLUGIN_DIR="${ZSH_CUSTOM:-$LCL_INSTALL_DIR/custom}/plugins/zsh-autosuggestions"
    if [ "$LCL_RETURN_VAL" -eq 0 ] && [ ! -d "$LCL_ZSH_AUTOSUGGESTION_PLUGIN_DIR" ]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions $LCL_ZSH_AUTOSUGGESTION_PLUGIN_DIR
        LCL_RETURN_VAL=$?
    fi

    # install zsh-syntax-highlighting custom plugin
    local LCL_ZSH_SYNTAX_HIGHLIGHTING_PLUGIN_DIR="${ZSH_CUSTOM:-$LCL_INSTALL_DIR/custom}/plugins/zsh-syntax-highlighting"
    if [ "$LCL_RETURN_VAL" -eq 0 ] && [ ! -d "$LCL_ZSH_SYNTAX_HIGHLIGHTING_PLUGIN_DIR" ]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $LCL_ZSH_SYNTAX_HIGHLIGHTING_PLUGIN_DIR
        LCL_RETURN_VAL=$?
    fi

    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} ($LCL_RETURN_VAL)"
    return $LCL_RETURN_VAL
}

#---------------------------
# main
#---------------------------
install_abkEnv_main() {
    local LCL_RED='\033[0;31m'
    local LCL_NC='\033[0m' # No Color
    local LCL_ABK_INSTALL_OH_MY="__install_oh_my"
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
    AbkLib_IsStringInArray $ABK_SHELL "${ABK_SUPPORTED_SHELLS[@]}" || PrintUsageAndExitWithCode $? "${RED}ERROR:${NC} $ABK_SHELL is not supported.\nPlease consider using one of those shells: ${ABK_SUPPORTED_SHELLS[*]}"

    __install_abkEnv_uninstall_old
    __install_abkEnv_common $LCL_BREW_INSTALLED

    for USER_SHELL_CONFIG_FILE in "${ABK_USER_SHELL_CONFIG_FILES[@]}"; do
        __install_abkEnv_for_shell $USER_SHELL_CONFIG_FILE || PrintUsageAndExitWithCode $? "${RED}ERROR:${NC} __install_abkEnv_for_shell $USER_SHELL_CONFIG_FILE failed"
    done

    for LCL_SUPPORTED_SHELL in "${ABK_SUPPORTED_SHELLS[@]}"; do
        ${LCL_ABK_INSTALL_OH_MY}_${LCL_SUPPORTED_SHELL} || PrintUsageAndExitWithCode $? "${RED}ERROR:${NC} ${LCL_ABK_INSTALL_OH_MY}_${LCL_SUPPORTED_SHELL} failed"
    done

    AbkLib_SourceEnvironment $HOME/$ABK_USER_SHELL_CONFIG_FILE

    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (0)"
    return 0
}

echo ""
echo "-> $0 ($@)"

export ABK_SHELL="${SHELL##*/}"
install_abkEnv_main $@
LCL_EXIT_CODE=$?

echo "<- $0 (0)"
exit $LCL_EXIT_CODE
