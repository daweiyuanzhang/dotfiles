# Locale.
export LANG="en_US.UTF-8"
export LANGUAGE="en_US.UTF-8"

if [[ ${TERM} == 'linux' ]]; then
  export TERM=xterm-256color
fi

# MacOS HomeBrew
if [ "$(uname)" = "Darwin" ]; then
    # 修改Homebrew Bottles源
    export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles
    # brew 不自动更新
    export HOMEBREW_NO_AUTO_UPDATE=true
fi

# bat theme
export BAT_THEME="gruvbox-dark"
