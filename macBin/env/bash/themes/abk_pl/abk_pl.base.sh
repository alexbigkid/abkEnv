#!/usr/bin/env bash

source "$OSH/themes/powerline/powerline.base.sh"

function __powerline_last_status_prompt() {
    [[ "$1" -ne 0 ]] && echo "$(set_color ${LAST_STATUS_THEME_PROMPT_COLOR} -) ${1} ${normal}"
}

function __powerline_right_segment() {
    local OLD_IFS="${IFS}"
    IFS="|"
    local params=($1)
    IFS="${OLD_IFS}"
    local separator_char="${POWERLINE_RIGHT_SEPARATOR}"
    local padding=2
    local separator_color=""

    if [[ "${SEGMENTS_AT_RIGHT}" -eq 0 ]]; then
        separator_color="$(set_color ${params[1]} -)"
    else
        separator_color="$(set_color ${params[1]} ${LAST_SEGMENT_COLOR})"
        ((padding += 1))
    fi
    RIGHT_PROMPT+="${separator_color}${separator_char}${normal}$(set_color - ${params[1]}) ${params[0]} ${normal}$(set_color - ${COLOR})${normal}"
    RIGHT_PROMPT_LENGTH=$((${#params[0]} + RIGHT_PROMPT_LENGTH + padding))
    LAST_SEGMENT_COLOR="${params[1]}"
    ((SEGMENTS_AT_RIGHT += 1))
}

function __powerline_user_info_prompt() {
    local user_info=""
    local color=${USER_INFO_THEME_PROMPT_COLOR}

    if [[ "${THEME_CHECK_SUDO}" = true ]]; then
        if sudo -n uptime 2>&1 | grep -q "load"; then
            color=${USER_INFO_THEME_PROMPT_COLOR_SUDO}
        fi
    fi
    case "${POWERLINE_PROMPT_USER_INFO_MODE}" in
    "sudo")
        if [[ "${color}" == "${USER_INFO_THEME_PROMPT_COLOR_SUDO}" ]]; then
            user_info="!"
        fi
        ;;
    *)
        if [[ -n "${SSH_CLIENT}" ]]; then
            user_info="${USER_INFO_SSH_CHAR}${USER}@${HOSTNAME}"
        else
            user_info="${USER}@${HOSTNAME}"
        fi
        ;;
    esac
    [[ -n "${user_info}" ]] && echo "${user_info}|${color}"
}

function __powerline_cmd_history_prompt() {
    CMD_HISTORY=$(history 1)
    set -- $CMD_HISTORY
    [[ -n "${1}" ]] && echo "!${1}|${CMD_HISTORY_THEME_PROMPT_COLOR}"
}

function __powerline_prompt_command() {
    local last_status="$?" ## always the first
    local separator_char="${POWERLINE_LEFT_SEPARATOR}"
    local move_cursor_rightmost='\033[500C'

    LEFT_PROMPT=""
    RIGHT_PROMPT=""
    RIGHT_PROMPT_LENGTH=0
    SEGMENTS_AT_LEFT=0
    SEGMENTS_AT_RIGHT=0
    LAST_SEGMENT_COLOR=""

    ## left prompt ##
    for segment in $POWERLINE_LEFT_PROMPT; do
        local info="$(__powerline_${segment}_prompt)"
        [[ -n "${info}" ]] && __powerline_left_segment "${info}"
    done
    [[ -n "${LEFT_PROMPT}" ]] && LEFT_PROMPT+="$(set_color ${LAST_SEGMENT_COLOR} -)${separator_char}${normal}"

    ## right prompt ##
    if [[ -n "${POWERLINE_RIGHT_PROMPT}" ]]; then
        LEFT_PROMPT+="${move_cursor_rightmost}"
        for segment in $POWERLINE_RIGHT_PROMPT; do
            local info="$(__powerline_${segment}_prompt)"
            [[ -n "${info}" ]] && __powerline_right_segment "${info}"
        done
        LEFT_PROMPT+="\033[${RIGHT_PROMPT_LENGTH}D"
    fi

    PS1="${LEFT_PROMPT}${RIGHT_PROMPT}\n$(__powerline_last_status_prompt ${last_status})${PROMPT_CHAR} "

    ## cleanup ##
    unset LAST_SEGMENT_COLOR \
        LEFT_PROMPT RIGHT_PROMPT RIGHT_PROMPT_LENGTH \
        SEGMENTS_AT_LEFT SEGMENTS_AT_RIGHT
}
