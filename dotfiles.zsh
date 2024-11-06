#!/bin/zsh

# 获取脚本所在的绝对路径
SCRIPT_PATH="${0:A}"

# 获取脚本所在的文件夹路径
SCRIPT_DIR="${SCRIPT_PATH:h}"

# 定义要 source 的脚本文件列表
scripts=("aliases.zsh" "exports.zsh" "functions.zsh" "linker.zsh")

# 循环遍历并 source 每个脚本
for script in "${scripts[@]}"; do
    # 检查文件是否存在并且是可读的
    if [[ -r "$SCRIPT_DIR/$script" ]]; then
        source "$SCRIPT_DIR/$script"
    else
        echo "Warning: Cannot read $SCRIPT_DIR/$script"
    fi
done
