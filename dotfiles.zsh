for script in ${0:A:h}/{aliases.zsh,exports.zsh,functions.zsh,linker.zsh}; do
    source "$script"
done
