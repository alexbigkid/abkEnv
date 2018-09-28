#-------------------------
#prompt config
#-------------------------
fill="--------------------------------------------------------------------- "
reset_style='\[\e[00m\]'
status_style=$reset_style'\[\e[0;90m\]' # gray color; use 0;37m for lighter color
prompt_style=$reset_style
command_style=$reset_style'\[\e[1;31m\]' # bold black

PS1="$status_style"'$fill \t\n'"$prompt_style"'\u@\h:\w 🖖$ '"$command_style "

#-------------------------
# Reset color for command output
# (this one is invoked every time before a command is executed):
#-------------------------
trap 'echo -ne "\033[0m"' DEBUG

function prompt_command {
  # create a $fill of all screen width minus the time string and a space:
  let fillsize=${COLUMNS}-9
  fill=""

  while [ "$fillsize" -gt "0" ]
  do
    fill="-${fill}" # fill with underscores to work on
    let fillsize=${fillsize}-1
  done
}
PROMPT_COMMAND=prompt_command

#-------------------------
# file for abk environment
#-------------------------
if [ -f ~/env/git_prompt.sh ]; then
    . ~/env/git_prompt.sh
fi

PROMPT_COMMAND='__posh_git_ps1 "$status_style$fill \t\n$prompt_style\u@\h:\w " "🖖$ $command_style";'$PROMPT_COMMAND