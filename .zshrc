#!/bin/zsh
# declare -A Zap
if [[ ! -f $HOME/.local/share/zap/zap.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}zap-zsh%F{220} Initiative Plugin Manager (%F{33}zap%F{220})…%f"
    command rm -rf $HOME/.local/share/zap && command mkdir -p "$HOME/.local/share/zap" && command chmod g-rwX "$HOME/.local/share/zap"
    command git clone --depth=1 ${GH_PROXY}https://github.com/zap-zsh/zap "$HOME/.local/share/zap" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi
source "$HOME/.local/share/zap/zap.zsh"
# End of Zap's installer chunk

# history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=500000
SAVEHIST=500000
HIST_STAMPS="yyyy-mm-dd"


export STARSHIP_CONFIG="$HOME/.starship.toml"

plug "wintermi/zsh-brew"
# plug "mattberther/zsh-pyenv"
plug "AndydeCleyre/zpy"
plug "wintermi/zsh-starship"
plug "zsh-users/zsh-autosuggestions"
plug "MichaelAquilina/zsh-you-should-use"
plug "zap-zsh/fzf"
plug "Aloxaf/fzf-tab"
plug "zap-zsh/sudo"
plug "zap-zsh/completions"
plug "zpm-zsh/ls"
plug "kjhaber/tm.zsh"

# autoload -Uz compinit
# compinit

# personal
plug "daweiyuanzhang/dotfiles"
