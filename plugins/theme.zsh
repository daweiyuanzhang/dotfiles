# 修改自https://github.com/zthxxx/jovial/blob/master/jovial.zsh-theme
# 删除了一些注释和功能

# 加载必要模块
autoload -Uz add-zsh-hook
zmodload zsh/datetime
setopt prompt_subst

# 禁用一些可能影响性能的功能
export DISABLE_MAGIC_FUNCTIONS=true
export VIRTUAL_ENV_DISABLE_PROMPT=true

# 修复终端颜色
if [[ ${TERM} == 'linux' || ${TERM} == 'xterm' ]]; then
    export TERM=xterm-256color
fi

# 重置颜色
typeset -g sgr_reset="%{\e[00m%}"

# 符号配置
typeset -gA SYMBOL=(
    corner.top    '╭─'
    corner.bottom '╰─'
    arrow         '─➤'
    arrow.git-clean '(๑˃̵ᴗ˂̵)و'
    arrow.git-dirty '(ﾉ˚Д˚)ﾉ'
)

# 颜色配置
typeset -gA PALETTE=(
    host    '%F{157}'
    user    '%F{253}'
    root    '%B%F{203}'
    path    '%B%F{228}'
    git     '%F{159}'
    venv    '%F{159}'
    python  '%F{123}'
    time    '%F{254}'
    elapsed '%F{222}'
    exit.mark '%F{246}'
    exit.code '%B%F{203}'
    conj.   '%F{102}'
    typing  '%F{252}'
    normal  '%F{252}'
    error   '%F{203}'
)

# 执行时间阈值
typeset -gi EXEC_THRESHOLD_SECONDS=4

# ============================================================================
# GITSTATUS 集成（简化版）
# ============================================================================

if ! typeset -f gitstatus_query > /dev/null; then
  echo "需要 gitstatus 插件才能使用当前prompt"
  return 0
fi

typeset -g GITSTATUS_PROMPT=''
typeset -gi GITSTATUS_PROMPT_LEN=0
typeset -g is_git_dirty=false

@jov.gitstatus-prompt-update() {
    emulate -L zsh
    GITSTATUS_PROMPT=''
    GITSTATUS_PROMPT_LEN=0

    gitstatus_query 'PROMPT' || return 1
    [[ $VCS_STATUS_RESULT == 'ok-sync' ]] || return 0

    local clean='%5F' modified='%3F' untracked='%4F' conflicted='%1F'
    [[ "$TERM" != "linux" ]] && local git_icon=" "
    local p="%B${clean}${git_icon}"

    # 分支名称
    local where
    if [[ -n $VCS_STATUS_LOCAL_BRANCH ]]; then
        where=$VCS_STATUS_LOCAL_BRANCH
    elif [[ -n $VCS_STATUS_TAG ]]; then
        p+='#'; where=$VCS_STATUS_TAG
    else
        p+='@'; where=${VCS_STATUS_COMMIT[1,8]}
    fi

    (( $#where > 32 )) && where[13,-13]="…"
    p+="${where//\%/%%}%b"

    # 状态指示器
    (( VCS_STATUS_COMMITS_BEHIND )) && p+=" ${clean}⇣${VCS_STATUS_COMMITS_BEHIND}"
    (( VCS_STATUS_COMMITS_AHEAD && !VCS_STATUS_COMMITS_BEHIND )) && p+=" "
    (( VCS_STATUS_COMMITS_AHEAD )) && p+="${clean}⇡${VCS_STATUS_COMMITS_AHEAD}"
    (( VCS_STATUS_STASHES )) && p+=" ${clean}*${VCS_STATUS_STASHES}"
    [[ -n $VCS_STATUS_ACTION ]] && p+=" ${conflicted}${VCS_STATUS_ACTION}"
    (( VCS_STATUS_NUM_CONFLICTED )) && p+=" ${conflicted}~${VCS_STATUS_NUM_CONFLICTED}"
    (( VCS_STATUS_NUM_STAGED )) && p+=" ${modified}+${VCS_STATUS_NUM_STAGED}"
    (( VCS_STATUS_NUM_UNSTAGED )) && p+=" ${modified}!${VCS_STATUS_NUM_UNSTAGED}"
    (( VCS_STATUS_NUM_UNTRACKED )) && p+=" ${untracked}?${VCS_STATUS_NUM_UNTRACKED}"

    GITSTATUS_PROMPT="${p}%f"
    GITSTATUS_PROMPT_LEN="${(m)#${${${GITSTATUS_PROMPT//\%\%/x}//\%(f|<->F)}//\%[Bb]}}"

    # 判断 git 是否 dirty
    if (( VCS_STATUS_NUM_CONFLICTED || VCS_STATUS_NUM_STAGED || VCS_STATUS_NUM_UNSTAGED || VCS_STATUS_NUM_UNTRACKED )); then
        is_git_dirty=true
    else
        is_git_dirty=false
    fi
}

gitstatus_stop 'PROMPT' && gitstatus_start -s -1 -u -1 -c -1 -d -1 'PROMPT'
add-zsh-hook precmd @jov.gitstatus-prompt-update

# ============================================================================
# 核心功能
# ============================================================================

# 检查命令是否存在
@jov.iscommand() { [[ -e ${commands[$1]} ]] }

# 查找文件（向上递归）
@jov.rev-parse-find() {
    local target="$1"
    local current_path="${2:-${PWD}}"
    
    while [[ ${current_path} != "/" && ${current_path} != "${HOME}" ]]; do
        if [[ -e ${current_path}/${target} ]]; then
            return 0
        fi
        current_path="${current_path:h}"  # 等同于 dirname
    done
    return 1
}

# 计算字符串长度（去除样式）
@jov.unstyle-len() {
    local str="${(%)1}"
    local unstyle_regex="\[[0-9;]*[a-zA-Z]"
    local unstyled
    
    while [[ -n ${str} ]]; do
        if [[ ${str} =~ ${unstyle_regex} ]]; then
            unstyled+=${str[1,MBEGIN-1]}
            str=${str[MEND+1,-1]}
        else
            break
        fi
    done
    unstyled+=${str}
    
    eval $2=${#unstyled}
}

# 右对齐
@jov.align-right() {
    local str="$1" len=$2 store_var="$3"
    local align_site=$(( ${COLUMNS} - ${len} + 1 ))
    local result="%{\e[${align_site}G%}${str}"
    eval ${store_var}=${(q)result}
}

# 全局变量
typeset -gi exec_timestamp=0
typeset -gA parts=()

# 执行时间记录
@jov.exec-timestamp() {
    exec_timestamp=${EPOCHSECONDS}
}
add-zsh-hook preexec @jov.exec-timestamp

# Python 版本检测
@jov.get-python-version() {
    local python_info=""
    
    # 如果虚拟环境已激活，显示虚拟环境中的python版本
    if [[ -n ${VIRTUAL_ENV} ]]; then
        if [[ -x "${VIRTUAL_ENV}/bin/python" ]]; then
            python_info=$(${VIRTUAL_ENV}/bin/python --version 2>&1)
        fi
    # 如果在conda环境中
    elif [[ -n ${CONDA_DEFAULT_ENV} && ${CONDA_DEFAULT_ENV} != "base" ]]; then
        if @jov.iscommand python; then
            python_info=$(python --version 2>&1)
        fi
    # 检查当前目录或父目录中是否有Python项目文件
    elif @jov.rev-parse-find "requirements.txt" || @jov.rev-parse-find "pyproject.toml" || @jov.rev-parse-find "setup.py" || @jov.rev-parse-find "Pipfile"; then
        if @jov.iscommand python; then
            python_info=$(python --version 2>&1)
        elif @jov.iscommand python3; then
            python_info=$(python3 --version 2>&1)
        else
            python_info="need Python"
        fi
    fi
    
    echo "${python_info}"
}

# 设置各个组件
@jov.set-host() {
    local hostname="${(%):-%m}"
    parts[host]="${PALETTE[normal]}[${PALETTE[host]}${hostname}${PALETTE[normal]}] ${PALETTE[conj.]}as"
}

@jov.set-user() {
    local username="${(%):-%n}"
    local color="${PALETTE[user]}"
    [[ ${UID} == 0 || ${USER} == 'root' ]] && color="${PALETTE[root]}"
    parts[user]=" ${color}${username} ${PALETTE[conj.]}in"
}

@jov.set-path() {
    local current_dir="${(%):-%~}"
    parts[path]=" ${PALETTE[path]}${current_dir}"
}

@jov.set-python() {
    local python_version="$(@jov.get-python-version)"
    
    if [[ -n ${python_version} ]]; then
        if [[ ${python_version} == "need Python" ]]; then
            parts[python]=" ${PALETTE[normal]}[${PALETTE[error]}${python_version}${PALETTE[normal]}]"
        else
            parts[python]=" ${PALETTE[conj.]}using ${PALETTE[python]}${python_version}"
        fi
    else
        parts[python]=''
    fi
}

@jov.set-git() {
    if [[ -n ${GITSTATUS_PROMPT} ]]; then
        parts[git-info]=" ${PALETTE[conj.]}on${GITSTATUS_PROMPT}"
    else
        parts[git-info]=''
    fi
}

@jov.set-venv() {
    local venv_name=""
    if [[ -n ${CONDA_DEFAULT_ENV} && ${CONDA_DEFAULT_ENV} != "base" ]]; then
        venv_name="${CONDA_DEFAULT_ENV:t}"
    elif [[ -n ${VIRTUAL_ENV} && ${VIRTUAL_ENV} != "base" ]]; then
        venv_name="${VIRTUAL_ENV:t}"
    fi
    
    if [[ -n ${venv_name} ]]; then
        parts[venv]=" ${PALETTE[normal]}(${PALETTE[venv]}${venv_name}${PALETTE[normal]})"
    else
        parts[venv]=''
    fi
}

@jov.set-time() {
    local current_time="${(%):-%D{%H:%M:%S\}}"
    local time_str="${PALETTE[time]}${current_time}"
    local -i time_len=${#current_time}
    @jov.align-right "${time_str}" ${time_len} 'parts[time]'
}

@jov.set-typing() {
    parts[typing]="${PALETTE[typing]}"
    if [[ -n ${GITSTATUS_PROMPT} ]]; then
        if [[ ${is_git_dirty} == false ]]; then
            parts[typing]+="${SYMBOL[arrow.git-clean]}"
        else
            parts[typing]+="${SYMBOL[arrow.git-dirty]}"
        fi
    else
        parts[typing]+="${SYMBOL[arrow]}"
    fi
}

# 显示执行信息
@jov.pin-execute-info() {
    local -i exec_seconds="${1:-0}" exit_code="${2:-0}"
    local pin_message=""
    
    # 执行时间
    if (( exec_seconds >= EXEC_THRESHOLD_SECONDS )); then
        local -i hours=$(( exec_seconds / 3600 ))
        local -i minutes=$(( exec_seconds / 60 % 60 ))
        local -i seconds=$(( exec_seconds % 60 ))
        local -a time_parts=()
        
        (( hours > 0 )) && time_parts+="${hours}h"
        (( minutes > 0 )) && time_parts+="${minutes}m"
        (( seconds > 0 )) && time_parts+="${seconds}s"
        
        local elapsed="${(j.:.)time_parts}"
        pin_message+="${PALETTE[elapsed]}~${elapsed} "
    fi
    
    # 退出码
    if (( exit_code != 0 )); then
        pin_message+="${PALETTE[exit.mark]}exit:${PALETTE[exit.code]}${exit_code} "
    fi
    
    if [[ -n ${pin_message} ]]; then
        local -i pin_len
        @jov.unstyle-len "${pin_message}" pin_len
        local aligned_pin
        @jov.align-right "${pin_message}" ${pin_len} aligned_pin
        print -P "\e[1F${aligned_pin}"
    fi
}

# 主要的 prompt 准备函数
@jov.prompt-prepare() {
    local -i exit_code=$? exec_seconds=0
    
    if (( exec_timestamp > 0 )); then
        exec_seconds=$(( EPOCHSECONDS - exec_timestamp ))
        exec_timestamp=0
    fi
    
    @jov.pin-execute-info ${exec_seconds} ${exit_code}
    @jov.set-host
    @jov.set-user
    @jov.set-path
    @jov.set-python
    @jov.set-git
    @jov.set-venv
    @jov.set-time
    @jov.set-typing
}

add-zsh-hook precmd @jov.prompt-prepare

# 主 prompt 函数
@prompt() {
    local corner_top="${PALETTE[normal]}${SYMBOL[corner.top]}"
    local corner_bottom="${PALETTE[normal]}${SYMBOL[corner.bottom]}"
    
    # 构建第一行
    local line1="${corner_top}${parts[host]}${parts[user]}${parts[path]}${parts[python]}${parts[venv]}${parts[git-info]}${parts[time]}"
    
    # 构建第二行
    local line2="${corner_bottom}${parts[typing]} ${sgr_reset}"
    
    echo "${sgr_reset}\n${line1}"
    echo "${line2}"
}

PROMPT='$(@prompt)'
