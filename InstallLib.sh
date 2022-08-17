#!/bin/sh

ABK_ALL_VERSIONS=0
ABK_MAJOR_VERSION=1
ABK_MINOR_VERSION=2
ABK_PATCH_VERSION=3

InstallLib_GetVersion () {
    echo "-> ${FUNCNAME[0]} ($@)"
    local LCL_RETURN_VAR=$1
    local LCL_VERSION_TYPE=$2
    local LCL_RETURN_VAL="0"
    local LCL_VERSION_FILE="version"
    local LCL_EXIT_CODE=1

    if [ -f $LCL_VERSION_FILE ]; then
        local LCL_VERSION_STR=$(<$LCL_VERSION_FILE)
        echo "LCL_VERSION_STR = $LCL_VERSION_STR"
        if [ "$LCL_VERSION_TYPE" -le "$ABK_PATCH_VERSION" ] && [ "$LCL_VERSION_TYPE" -gt "$ABK_ALL_VERSIONS" ]; then
            LCL_RETURN_VAL=$(cut -d'.' -f$LCL_VERSION_TYPE <<<$LCL_VERSION_STR)
        else
            LCL_RETURN_VAL=$LCL_VERSION_STR
        fi
        LCL_EXIT_CODE=1
    fi

    eval $LCL_RETURN_VAR=\$LCL_RETURN_VAL
    echo "<- ${FUNCNAME[0]} (0 $LCL_RETURN_VAL)"
    return $LCL_EXIT_CODE
}
