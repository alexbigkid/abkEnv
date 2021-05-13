#!/bin/bash
# this script is collection of common function used in different scripts

# -----------------------------------------------------------------------------
# variables definitions
# -----------------------------------------------------------------------------
export TRUE=0
export FALSE=1

ABK_LIB_FILE_DIR=$(dirname "$BASH_SOURCE")
# echo "ABK_LIB_FILE_DIR = $ABK_LIB_FILE_DIR"
ABK_ENV_FILE="$PWD/$ABK_LIB_FILE_DIR/env/abk_env.env"
# echo "ABK_ENV_FILE = $ABK_ENV_FILE"

# echo "pwd: $(pwd)"
# echo "\$0: $0"
# echo "basename: $(basename $0)"
# echo "dirname: $(dirname $0)"
# echo "dirname/readlink: $(dirname $(readlink -f $0))"

#---------------------------
# vars definition
#---------------------------
LCL_ABK_VARS="$ABK_LIB_FILE_DIR/env/abk_vars.env"
# echo "LCL_ABK_VARS = $LCL_ABK_VARS"
[ -f "$LCL_ABK_VARS" ] && . $LCL_ABK_VARS || echo "ERROR: vars definition file ($LCL_ABK_VARS) could not be found"

#---------------------------
# Trace configuration
#---------------------------
TRACE_NONE=0
TRACE_CRITICAL=1
TRACE_FUNCTION=2
TRACE_INFO=3
TRACE_DETAILED=4
TRACE_ALL=5
TRACE_LEVEL=$TRACE_ALL

#---------------------------
# color definitions
#---------------------------
LCL_ABK_COLORS="$ABK_LIB_FILE_DIR/env/abk_colors.env"
# echo "LCL_ABK_COLORS = $LCL_ABK_COLORS"
[ -f "$LCL_ABK_COLORS" ] && . $LCL_ABK_COLORS || echo "ERROR: colors definition file ($LCL_ABK_COLORS) could not be found"

# -----------------------------------------------------------------------------
# internal variables definitions
# -----------------------------------------------------------------------------
# for here document to add to the profile
ABK_ENV_BEGIN="# BEGIN >>>>>> DO_NOT_REMOVE >>>>>>"
ABK_ENV_END="# END <<<<<< DO_NOT_REMOVE <<<<<<"
ABK_ENV_NAME="ABK_ENV"
ABK_FONTS=(
    "font-cascadia-code"
    "font-cascadia-code-pl"
    "font-cascadia-mono"
    "font-cascadia-mono-pl"
    "font-caskaydia-cove-nerd-font"
    "font-droid-sans-mono-nerd-font"
)

#---------------------------
# functions
#---------------------------
AbkLib_PrintTrace() {
    local LCL_TRACE_LEVEL=$1
    shift
    local LCL_PRINT_STRING=("$@")
    if [ "$LCL_TRACE_LEVEL" -eq "$TRACE_FUNCTION" ]; then
        [ "$TRACE_LEVEL" -ge "$LCL_TRACE_LEVEL" ] && echo -e "${CYAN}${LCL_PRINT_STRING[@]}${NC}"
    else
        [ "$TRACE_LEVEL" -ge "$LCL_TRACE_LEVEL" ] && echo -e "${LCL_PRINT_STRING[@]}"
    fi
}

AbkLib_AddEnvironmentSettings() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"
    local LCL_ENV_NAME=$1
    local LCL_FILE_TO_ADD_CONTENT_TO=$2
    shift
    shift
    local LCL_SETTINGS_TO_ADD=("$@")
    local LCL_RESULT=$FALSE

    if [ "$LCL_ENV_NAME" != "" ] && [ -f "$LCL_FILE_TO_ADD_CONTENT_TO" ] && [ ${#LCL_SETTINGS_TO_ADD[@]} -ne 0 ]; then
        LCL_RESULT=$TRUE

        if grep -q -e "$IROBOT_ENV_BEGIN $LCL_ENV_NAME" $LCL_FILE_TO_ADD_CONTENT_TO; then
            AbkLib_PrintTrace $TRACE_INFO "\t[Environment already added. Nothing to do here.]"
        else
            AbkLib_PrintTrace $TRACE_INFO "\t[Adding $LCL_ENV_NAME environment ...]"
            cat >>$LCL_FILE_TO_ADD_CONTENT_TO <<-TEXT_TO_ADD
$ABK_ENV_BEGIN $LCL_ENV_NAME
$(printf "%s\n" "${LCL_SETTINGS_TO_ADD[@]}")
$ABK_ENV_END $LCL_ENV_NAME
TEXT_TO_ADD
        fi
    else
        AbkLib_PrintTrace $TRACE_CRITICAL "${RED}\tInvalid parameters passed in${NC}"
    fi

    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]}($LCL_RESULT)"
    return $LCL_RESULT
}

AbkLib_RemoveEnvironmentSettings() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"
    local LCL_ENV_NAME=$1
    local LCL_FILE_TO_REMOVE_CONTENT_FROM=$2
    local LCL_RESULT=$FALSE

    if [ -f "$LCL_FILE_TO_REMOVE_CONTENT_FROM" ]; then
        echo "   [File $LCL_FILE_TO_REMOVE_CONTENT_FROM exist ...]"
        LCL_RESULT=$TRUE
        if grep -q -e "$ABK_ENV_BEGIN $LCL_ENV_NAME" $LCL_FILE_TO_REMOVE_CONTENT_FROM; then
            AbkLib_PrintTrace $TRACE_INFO "   [ABK environment found removing it...]"
            sed -i -e "/^$ABK_ENV_BEGIN $LCL_ENV_NAME$/,/^$ABK_ENV_END $LCL_ENV_NAME$/d" "$LCL_FILE_TO_REMOVE_CONTENT_FROM"
        else
            AbkLib_PrintTrace $TRACE_INFO "   [ABK environment NOT found. Nothng to remove]"
        fi
    else
        echo "   [File: $LCL_FILE_TO_REMOVE_CONTENT_FROM does not exist.]"
    fi

    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]}($LCL_RESULT)"
    return $LCL_RESULT
}

AbkLib_IsParameterHelp() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"
    local NUMBER_OF_PARAMETERS=$1
    local PARAMETER=$2
    if [ $NUMBER_OF_PARAMETERS -eq 1 ] && [ "$PARAMETER" == "--help" ]; then
        AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (TRUE)"
        return $TRUE
    else
        AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (FALSE)"
        return $FALSE
    fi
}

AbkLib_GetAbsolutePath() {
    local DIR_NAME=$(dirname "$1")
    pushd "$DIR_NAME" >/dev/null
    local RESULT_PATH=$PWD
    popd >/dev/null
    echo $RESULT_PATH
}

AbkLib_GetPathFromLink() {
    local RESULT_PATH=$(dirname $([ -L "$1" ] && readlink -n "$1"))
    echo $RESULT_PATH
}

AbkLib_IsStringInArray() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"
    local LCL_STRING_TO_SEARCH_FOR=$1
    shift
    local LCL_ARRAY_TO_SEARCH_IN=("$@")
    local LCL_MATCH_FOUND=$FALSE

    for element in "${LCL_ARRAY_TO_SEARCH_IN[@]}"; do
        if [ "$LCL_STRING_TO_SEARCH_FOR" = "$element" ]; then
            LCL_MATCH_FOUND=$TRUE
            break
        fi
    done

    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]}($LCL_MATCH_FOUND)"
    return $LCL_MATCH_FOUND
}

AbkLib_IsBrewInstalled() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"
    local LCL_RESULT=$TRUE
    # homebrew installed?
    if [[ $(command -v brew) == "" ]]; then
        LCL_RESULT=$FALSE
        echo "WARNING: Hombrew is not installed, please install with:"
        echo "/usr/bin/ruby -e \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)\""
    fi
    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]}($LCL_RESULT)"
    return $LCL_RESULT
}

AbkLib_BrewInstallPackage() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"
    local LCL_BREW_INSTALLATION_TYPE=$1
    local LCL_BREW_PACKAGE=$2
    local LCL_INSTALL=""
    local LCL_IS_BREW_PACKAGE_INSTALLED=""
    local LCL_RESULT=$TRUE

    if [ "$LCL_BREW_INSTALLATION_TYPE" != "tap" ]; then
        LCL_IS_BREW_PACKAGE_INSTALLED=$(brew list | grep $LCL_BREW_PACKAGE)
        LCL_INSTALL="install"
    else
        # echo "$(brew tap-info --installed | grep $LCL_BREW_PACKAGE)"
        LCL_IS_BREW_PACKAGE_INSTALLED=$(brew tap-info "--installed" | grep $LCL_BREW_PACKAGE)
    fi

    if [ "$LCL_IS_BREW_PACKAGE_INSTALLED" == "" ]; then
        echo "   [brew $LCL_INSTALL $LCL_BREW_INSTALLATION_TYPE $LCL_BREW_PACKAGE ...]"
        brew $LCL_INSTALL $LCL_BREW_INSTALLATION_TYPE $LCL_BREW_PACKAGE
        LCL_RESULT=$?
    fi

    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]}($LCL_RESULT)"
    return $LCL_RESULT
}

AbkLib_BrewUninstallPackage() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"
    local LCL_BREW_UNINSTALLATION_TYPE=$1
    local LCL_BREW_PACKAGE=$2
    local LCL_UNINSTALL=""
    local LCL_IS_BREW_PACKAGE_INSTALLED=""
    local LCL_RESULT=$TRUE

    if [ "$LCL_BREW_UNINSTALLATION_TYPE" != "untap" ]; then
        LCL_IS_BREW_PACKAGE_INSTALLED=$(brew list | grep $LCL_BREW_PACKAGE)
        LCL_UNINSTALL="uninstall"
    else
        echo "$(brew tap-info --installed | grep $LCL_BREW_PACKAGE)"
        LCL_IS_BREW_PACKAGE_INSTALLED=$(brew tap-info "--installed" | grep $LCL_BREW_PACKAGE)
    fi

    if [ "$LCL_IS_BREW_PACKAGE_INSTALLED" != "" ]; then
        echo "   [brew $LCL_UNINSTALL $LCL_BREW_UNINSTALLATION_TYPE $LCL_BREW_PACKAGE ...]"
        brew $LCL_UNINSTALL $LCL_BREW_UNINSTALLATION_TYPE $LCL_BREW_PACKAGE
        LCL_RESULT=$?
    fi

    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]}($LCL_RESULT)"
    return $LCL_RESULT
}

AbkLib_InstallCascadiaFonts() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"
    local LCL_RESULT=$TRUE

    if [ AbkLib_IsBrewInstalled == $FALSE ]; then
        "${RED}ERROR:${NC} The homebrew tool is not installed, the required Cascadia fonts cannot be installed"
        LCL_RESULT=$FALSE
    fi

    if [ "$LCL_RESULT" == $TRUE ]; then
        AbkLib_BrewInstallPackage "tap" "homebrew/cask-fonts"
        LCL_RESULT=$?
    fi
    for LCL_FONT in "${ABK_FONTS[@]}"; do
        if [ "$LCL_RESULT" == $TRUE ]; then
            AbkLib_BrewInstallPackage "--cask" $LCL_FONT
            LCL_RESULT=$?
        fi
    done

    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]}($LCL_RESULT)"
    return $LCL_RESULT
}

AbkLib_UninstallCascadiaFonts() {
    AbkLib_PrintTrace $TRACE_FUNCTION "-> ${FUNCNAME[0]} ($@)"
    local LCL_RESULT=$TRUE

    if [ AbkLib_IsBrewInstalled == $FALSE ]; then
        "${RED}ERROR:${NC} The homebrew tool is not installed, the required Cascadia fonts cannot be uninstalled"
        LCL_RESULT=$FALSE
    fi

    for LCL_FONT in "${ABK_FONTS[@]}"; do
        if [ "$LCL_RESULT" == $TRUE ]; then
            AbkLib_BrewUninstallPackage "--cask" $LCL_FONT
            LCL_RESULT=$?
        fi
    done
    if [ "$LCL_RESULT" == $TRUE ]; then
        AbkLib_BrewUninstallPackage "untap" "homebrew/cask-fonts"
        LCL_RESULT=$?
    fi

    AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]}($LCL_RESULT)"
    return $LCL_RESULT
}

AbkLib_SourceEnvironment() {
    local LCL_USER_SHELL_CONFIG_FILE=$1
    # todo: find a way to re-fresh environment from the shell script. As of now it does not work for zsh
    # source $LCL_USER_SHELL_CONFIG_FILE
}

AbkLib_CheckNumberOfParameters() {
    AbkLib_PrintTrace $TRACE_FUNCTION "\n-> ${FUNCNAME[0]} ($@)"
    local LCL_EXPECTED_NUMBER_OF_PARAMS=$1
    shift
    local LCL_PARAMETERS_PASSED_IN=("$@")

    if [ $LCL_EXPECTED_NUMBER_OF_PARAMS -ne ${#LCL_PARAMETERS_PASSED_IN[@]} ]; then
        AbkLib_PrintTrace $TRACE_CRITICAL "${RED}ERROR: invalid number of parameters.${NC}"
        AbkLib_PrintTrace $TRACE_INFO "\texpected number:\t$LCL_EXPECTED_NUMBER_OF_PARAMS"
        AbkLib_PrintTrace $TRACE_INFO "\tpassed in number:\t${#LCL_PARAMETERS_PASSED_IN[@]}"
        AbkLib_PrintTrace $TRACE_INFO "\tparameters passed in:\t${LCL_PARAMETERS_PASSED_IN[@]}"
        AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (FALSE)"
        return $FALSE
    else
        AbkLib_PrintTrace $TRACE_FUNCTION "<- ${FUNCNAME[0]} (TRUE)"
        return $TRUE
    fi
}
