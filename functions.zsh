# Clean Debian packages

if command -v apt-get >/dev/null 2>&1; then
    apt-clean() {
    sudo apt-get clean
    sudo apt-get autoclean
    sudo apt-get autoremove
    }
fi
# Create a new directory and enter it
mkd() {
    mkdir -p "$@" && cd "$@"
}

# Print README file
readme() {
    for readme in {readme,README}.{md,MD,markdown,mkd,txt,TXT}; do
        if [[ -x "$(command -v glow)" ]] && [[ -f "$readme" ]]; then
            mdv "$readme"
        elif [[ -f "$readme" ]]; then
            cat "$readme"
        fi
    done
}

# Get an information of IP address
ip-address() {
    curl -s -H "Accept: application/json" "https://ipinfo.io/${1:-}" | jq "del(.loc, .postal, .readme)"
}

# Remove all commit in Git
git-remove-all-commit() {
    local branch
    branch=$(git symbolic-ref --short HEAD)
    echo -e "\nDo you want to remove all your commit in \033[1m$branch\033[0m branch? [Y/n] "
    read -r response
    case "$response" in
        [yY][eE][sS]|[yY])
            git checkout --orphan latest_branch
            git add -A
            git commit -am "Initial commit"
            git branch -D "$branch"
            git branch -m "$branch"
            echo -e "\nTo force update your repository, run this command:\n\n    git push -fu origin $branch"
            ;;
        *)
            echo "Cancelled."
            ;;
    esac
}
gs() { git status -sb }
gsclone() { git clone --depth 1 }
gco() { git checkout }
glog() { git log --graph --abbrev-commit --decorate --date=relative --all }
glg() { git log --graph --abbrev-commit --decorate --format=format:'%C(bold yellow)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(auto)%d%C(reset)%n''%C(white)%s%C(reset) %C(dim white)- %an%C(reset)' }
gc() { # usage : gc fix "commit message"
  type="$1"
  detail="$2"
  shift
  case "$type" in
    init)    git commit -m "🎉 Init: $detail" ;;
    improve) git commit -m "👌 Improve: $detail" ;;
    feature) git commit -m "✨ Feature: $detail" ;;
    release) git commit -m "🚀 Release: $detail" ;;
    test)    git commit -m "✅ Test: $detail" ;;
    wip)     git commit -m "🚧 Wip: $detail" ;;
    fix)     git commit -m "🐛 Fix: $detail" ;;
    doc)     git commit -m "📖 Doc: $detail" ;;
    add)     git commit -m "📦 Add: $detail" ;;
    perf)    git commit -m "⚡️ Perf: $detail" ;;
    break)   git commit -m "💥 Break: $detail" ;;
    remove)  git commit -m "🔥 Remove: $detail" ;;
    secure)  git commit -m "🔒 Secure: $detail" ;;
    docker)  git commit -m "🐳 Docker: $detail" ;;
    format)  git commit -m "🎨 Format: $detail" ;;
    config)  git commit -m "🔧 Config: $detail" ;;
    backup)  git commit -m "💾 Backup: $detail" ;;
    merge)   git commit -m "🔀 Merge: $detail" ;;
    *) echo "Unrecognized commit type: '$type'" >&2; ;;
  esac
  echo $commit
}
ga() { git add . }
gac() { git add . && gc $1 $2 }
gacp() { git add . && gc $1 $2 && git push }
# gm() { git merge $1 --no-commit }
# gls() { curl "https://api.github.com/users/$YOUR_GITHUB_USERNAME/repos" -s | jq '[.[].svn_url]' }
# gh() {
#   xdg-open "https://github.com/$YOUR_GITHUB_USERNAME/$1" 2>/dev/null ||
#   gnome-open "https://github.com/$YOUR_GITHUB_USERNAME/$1" 2>/dev/null ||
#   open "https://github.com/$YOUR_GITHUB_USERNAME/$1" 2>/dev/null ||
#   echo "You need xdg-open, gnome-open or open to use this alias..."
# }
