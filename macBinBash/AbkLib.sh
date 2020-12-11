#!/bin/sh
# this script is collection of common function used in different scripts

# -----------------------------------------------------------------------------
# external variables definitions
# -----------------------------------------------------------------------------
declare -r TRUE=0
declare -r FALSE=1

# exit error codes
ERROR_CODE_SUCCESS=0
ERROR_CODE_GENERAL_ERROR=1
ERROR_CODE_NEED_FILE_DOES_NOT_EXIST=2
ERROR_CODE=$ERROR_CODE_SUCCESS

ABK_SHELL="${SHELL##*/}"
ABK_SHELL_1ST_UPPER=$(tr '[:lower:]' '[:upper:]' <<< ${ABK_SHELL:0:1})${ABK_SHELL:1}
# echo "ABK_SHELL_1ST_UPPER = $ABK_SHELL_1ST_UPPER"
BIN_DIR="abkBin$ABK_SHELL_1ST_UPPER"
SH_BIN_DIR="macBin$ABK_SHELL_1ST_UPPER"
HOME_BIN_DIR="$HOME/$BIN_DIR"
SH_PACKAGES_DIR="macPackages"

CONFIG_FILE_BASH=".bash_profile"
CONFIG_FILE_ZSH=".zshrc"

# abkEnv bash profile file names
ABK_LIB_FILE_DIR=$(dirname "$BASH_SOURCE")
echo "ABK_LIB_FILE_DIR = $ABK_LIB_FILE_DIR"
echo "PWD = $PWD"
ABK_ENV_FILE="$PWD/$ABK_LIB_FILE_DIR/env/abk_env.env"
echo "ABK_ENV_FILE = $ABK_ENV_FILE"


#---------------------------
# color definitions
#---------------------------
local LCL_ABK_COLORS="$ABK_LIB_FILE_DIR/env/abk_colors.env"
[ -f "$LCL_ABK_COLORS" ] && source $LCL_ABK_COLORS || echo "ERROR: colors definition file could not be found"

# -----------------------------------------------------------------------------
# internal variables definitions
# -----------------------------------------------------------------------------
# for here document to add to the profile
ABK_ENV_BEGIN="# >>>>>> DO_NOT_REMOVE >>>>>> ABK_ENV >>>> BEGIN"
ABK_ENV_END="# <<<<<< DO_NOT_REMOVE <<<<<< ABK_ENV <<<< END"

#---------------------------
# functions
#---------------------------
function AbkLib_AddEnvironmentSettings() {
    echo "-> ${FUNCNAME[0]} ($@)"
    local LCL_FILE_TO_ADD_CONTENT_TO=$1
    local LCL_SETTING_FILE_TO_ADD=$2
    local LCL_RESULT=$FALSE

    if [ -f "$LCL_FILE_TO_ADD_CONTENT_TO" ] && [ -f "$LCL_SETTING_FILE_TO_ADD" ]; then
        LCL_RESULT=$TRUE

        if grep -q $LCL_SETTING_FILE_TO_ADD $LCL_FILE_TO_ADD_CONTENT_TO; then
            echo "   [ABK environment already added. Nothing to do here.]"
        else
            echo "   [adding ABK environment ...]"
            cat >>$LCL_FILE_TO_ADD_CONTENT_TO <<-TEXT_TO_ADD

$ABK_ENV_BEGIN
if [ -f "$LCL_SETTING_FILE_TO_ADD" ]; then
    source $LCL_SETTING_FILE_TO_ADD
fi
$ABK_ENV_END

TEXT_TO_ADD
        fi
    else
        echo -e "${RED}   One or both files do not exist: $LCL_FILE_TO_ADD_CONTENT_TO, $LCL_SETTING_FILE_TO_ADD${NC}"
    fi

    echo "<- ${FUNCNAME[0]} ($LCL_RESULT)"
    return $LCL_RESULT
}

function AbkLib_IsParameterHelp() {
    echo "-> ${FUNCNAME[0]} ($@)"
    local NUMBER_OF_PARAMETERS=$1
    local PARAMETER=$2
    if [[ $NUMBER_OF_PARAMETERS -eq 1 && $PARAMETER == "--help" ]]; then
        echo "<- ${FUNCNAME[0]} (TRUE)"
        return $TRUE
    else
        echo "<- ${FUNCNAME[0]} (FALSE)"
        return $FALSE
    fi
}

function AbkLib_IsStringInArray() {
    echo "-> ${FUNCNAME[0]} ($@)"
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

    echo "<- ${FUNCNAME[0]} ($LCL_MATCH_FOUND)"
    return $LCL_MATCH_FOUND
}
