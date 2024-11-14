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

# Enabling the Zsh Completion System
autoload bashcompinit && bashcompinit
autoload -Uz compinit && compinit


# history
HISTFILE="$HOME/.zsh_history"
HISTSIZE=500000
SAVEHIST=500000
HIST_STAMPS="yyyy-mm-dd"


export STARSHIP_CONFIG="$HOME/.starship.toml"

# plugins
# plug "wintermi/zsh-brew"
plug "zimfw/homebrew"
# plug "mattberther/zsh-pyenv"
plug "davidparsson/zsh-pyenv-lazy"
# plug "AndydeCleyre/zpy"
plug "MichaelAquilina/zsh-autoswitch-virtualenv"
plug "wintermi/zsh-starship"
plug "zsh-users/zsh-autosuggestions"
plug "zsh-users/zsh-syntax-highlighting"
plug "zsh-users/zsh-completions"
plug "MichaelAquilina/zsh-you-should-use"
plug "Aloxaf/fzf-tab"
plug "zap-zsh/fzf"
plug "Freed-Wu/fzf-tab-source"
plug "zap-zsh/sudo"
plug "zap-zsh/exa"
plug "kjhaber/tm.zsh"
plug "hlissner/zsh-autopair"

# personal
plug "daweiyuanzhang/dotfiles"

# local
plug "$HOME/.config/local_function.zsh"




