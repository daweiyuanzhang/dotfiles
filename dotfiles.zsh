for script in ${0:A:h}/plugins/*.zsh; do
    [[ -f $script ]] && source $script
done
