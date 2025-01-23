# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias .3='cd ../../..'
alias .4='cd ../../../..'
alias .5='cd ../../../../..'
alias ~='cd ~'
alias --='cd -'


# Folders Shortcuts
[ -d ~/Downloads ]            && alias dl='cd ~/Downloads'
[ -d ~/Desktop ]              && alias dt='cd ~/Desktop'

# Shortcuts
alias dud='du -d 1 -h'
alias duf='du -sh *'
alias fdir='find . -type d -name'
alias ff='find . -type f -name'
alias h='history'
alias hgrep='history | grep'
alias lgrep='ls -l | grep'
alias lagrep='ls -lA | grep'
alias cp='cp -iv'
alias mv='mv -iv'
# alias ln='ln -iv'
alias mkdir='mkdir -v'
alias rm='rm -i'
alias rmf='rm -rf'
alias p='ps axo pid,user,pcpu,comm'
# alias uptime='uptime -p'
alias free='free -h'
alias disk='df -h | grep sd \
    | sed -e "s_/dev/sda[1-9]_\x1b[34m&\x1b[0m_" \
    | sed -e "s_/dev/sd[b-z][1-9]_\x1b[33m&\x1b[0m_" \
    | sed -e "s_[,0-9]*[MG]_\x1b[36m&\x1b[0m_" \
    | sed -e "s_[0-9]*%_\x1b[32m&\x1b[0m_" \
    | sed -e "s_9[0-9]%_\x1b[31m&\x1b[0m_" \
    | sed -e "s_/mnt/[-_A-Za-z0-9]*_\x1b[34;1m&\x1b[0m_"'

alias c='clear'
alias q="~ && clear"
# Show $PATH in readable view
alias path='echo -e ${PATH//:/\\n}'

command -v bat &> /dev/null && alias cat='bat'
command -v bat &> /dev/null && alias catp='bat --style=plain'

command -v git-open &> /dev/null && alias gopen="git-open"

# alias ch='echo > ~/.bash_history && echo > ~/.zsh_history'
# alias cz='echo > ~/.z'
alias x='echo "Goodbye! 👋" ; sleep 0.2; exit'

alias reloadzsh='source ~/.zshrc'
