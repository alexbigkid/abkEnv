#!/bin/sh
# this script is collection of common function used in different scripts

# -----------------------------------------------------------------------------
# variables definitions
# -----------------------------------------------------------------------------
# abkEnv shell profile file names
ABK_LIB_FILE_DIR=$(dirname "$BASH_SOURCE")
ABK_ENV_FILE="$PWD/$ABK_LIB_FILE_DIR/env/abk_env.env"

#---------------------------
# vars definition
#---------------------------
local LCL_ABK_VARS="$ABK_LIB_FILE_DIR/env/abk_vars.env"
[ -f "$LCL_ABK_VARS" ] && source $LCL_ABK_VARS || echo "ERROR: vars definition file ($LCL_ABK_VARS) could not be found"

#---------------------------
# color definitions
#---------------------------
local LCL_ABK_COLORS="$ABK_LIB_FILE_DIR/env/abk_colors.env"
[ -f "$LCL_ABK_COLORS" ] && source $LCL_ABK_COLORS || echo "ERROR: colors definition file ($LCL_ABK_COLORS) could not be found"

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
    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "-> ${FUNCNAME[0]} ($@)"
    local LCL_FILE_TO_ADD_CONTENT_TO=$1
    local LCL_SETTING_FILE_TO_INCLUDE=$2
    local LCL_RESULT=$FALSE

    if [ -f "$LCL_FILE_TO_ADD_CONTENT_TO" ] && [ -f "$LCL_SETTING_FILE_TO_INCLUDE" ]; then
        LCL_RESULT=$TRUE

        if grep -q -e "$ABK_ENV_BEGIN" $LCL_FILE_TO_ADD_CONTENT_TO; then
            [ "$ABK_TRACE" -ge "$ABK_INFO_TRACE" ] && echo "   [ABK environment already added. Nothing to do here.]"
        else
            [ "$ABK_TRACE" -ge "$ABK_INFO_TRACE" ] && echo "   [adding ABK environment ...]"
            cat >>$LCL_FILE_TO_ADD_CONTENT_TO <<-TEXT_TO_ADD
$ABK_ENV_BEGIN
if [ -f "$LCL_SETTING_FILE_TO_INCLUDE" ]; then
    source $LCL_SETTING_FILE_TO_INCLUDE
fi
$ABK_ENV_END
TEXT_TO_ADD
        fi
    else
        echo -e "${RED}   One or both files do not exist: $LCL_FILE_TO_ADD_CONTENT_TO, $LCL_SETTING_FILE_TO_INCLUDE${NC}"
    fi

    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "<- ${FUNCNAME[0]}($LCL_RESULT)"
    return $LCL_RESULT
}

function AbkLib_IsParameterHelp() {
    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "-> ${FUNCNAME[0]} ($@)"
    local NUMBER_OF_PARAMETERS=$1
    local PARAMETER=$2
    if [ $NUMBER_OF_PARAMETERS -eq 1 ] && [ "$PARAMETER" == "--help" ]; then
        [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "<- ${FUNCNAME[0]} (TRUE)"
        return $TRUE
    else
        [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "<- ${FUNCNAME[0]} (FALSE)"
        return $FALSE
    fi
}

function AbkLib_IsStringInArray () {
    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "-> ${FUNCNAME[0]} ($@)"
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

    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "<- ${FUNCNAME[0]}($LCL_MATCH_FOUND)"
    return $LCL_MATCH_FOUND
}

function AbkLib_RemoveEnvironmentSettings () {
    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "-> ${FUNCNAME[0]} ($@)"
    local LCL_FILE_TO_REMOVE_CONTENT_FROM=$1
    local LCL_RESULT=$FALSE

    if [ -f "$LCL_FILE_TO_REMOVE_CONTENT_FROM" ]; then
        echo "   [File $LCL_FILE_TO_REMOVE_CONTENT_FROM exist ...]"
        LCL_RESULT=$TRUE
        if grep -q -e "$ABK_ENV_BEGIN" $LCL_FILE_TO_REMOVE_CONTENT_FROM; then
            [ "$ABK_TRACE" -ge "$ABK_INFO_TRACE" ] && echo "   [ABK environment found removing it...]"
            sed -i -e "/^$ABK_ENV_BEGIN$/,/^$ABK_ENV_END$/d" "$LCL_FILE_TO_REMOVE_CONTENT_FROM"
        else
            [ "$ABK_TRACE" -ge "$ABK_INFO_TRACE" ] && echo "   [ABK environment NOT found. Nothng to remove]"
        fi
    else
        echo "   [File: $LCL_FILE_TO_REMOVE_CONTENT_FROM does not exist.]"
    fi

    [ "$ABK_TRACE" -ge "$ABK_FUNCTION_TRACE" ] && echo "<- ${FUNCNAME[0]}($LCL_RESULT)"
    return $LCL_RESULT
}
