# unix cmds
alias ls="ls -G"
alias la="ls -lah"
alias ll="ls -a"
alias h="history"

alias cdg="cd $HOME/dev/git"

# alias rgrep="find . -type f | xargs grep "$1" 2>/dev/null"
alias rgrep="find_text.sh"
alias rfind="find_file.sh"

# apps aliases
alias code="/Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin/code"
alias dm="/Applications/abk_tools/DiffMerge/diffmerge.sh"
alias fm="/usr/bin/opendiff"

# 7z aliases
alias 7zp="7za a -r -t7z -m0=lzma2 -mx=9 -mfb=64 -md=32m -ms=on -mhe=on -p"
alias 7zl="7z l -slt"
alias 7ze="7z x"
#alias cryptodoc="cd ~/Desktop/ && 7z a -pSome_Pass -r ~/Desktop/$(date +%Y%m%d)_Documents_Backup.7z ~/Documents/* 2>/dev/null"

#brew aliases
alias brew_update="brew update && brew outdated && brew upgrade && brew cleanup"
alias brew_cu="brew update && brew cu"

# git aliases
alias gs="git status"
alias gpull="git pull"
alias snp="git push"
