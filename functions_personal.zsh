#!/bin/zsh

# 定义颜色
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 定义提示信息
INFO="[${GREEN}信息${NC}]"
ERROR="[${RED}错误${NC}]"
TIP="[${YELLOW}注意${NC}]"

# 切换环境
switch(){
  echo -e "${INFO}开始切换到 $1 环境"
  env="$1"
  shift
  case "$env" in
    cn)     export QUICK_FLASH_UNIT=cn        QUICK_FLASH_ENV=online  ;;
    boe)    export QUICK_FLASH_UNIT=boecn     QUICK_FLASH_ENV=staging ;;
    cicd)   export QUICK_FLASH_UNIT=ka8lark   QUICK_FLASH_ENV=online  ;;
    va)     export QUICK_FLASH_UNIT=va        QUICK_FLASH_ENV=online  ;;
    sg)     export QUICK_FLASH_UNIT=larksgaws QUICK_FLASH_ENV=online  ;;
    jp)     export QUICK_FLASH_UNIT=larkjpaws QUICK_FLASH_ENV=online  ;;
    *)      echo -e "${ERROR}不支持的环境配置: '$env'" >&2; return 1 ;;
  esac
  common_env
}

# 输出环境变量
function common_env(){
    echo -e "${INFO}切换完成，当前环境变量如下：\n"
    [[ $QUICK_FLASH_ENV ]]   && echo -e "${TIP}QUICK_FLASH_ENV=${QUICK_FLASH_ENV}"
    [[ $QUICK_FLASH_UNIT ]]  && echo -e "${TIP}QUICK_FLASH_UNIT=${QUICK_FLASH_UNIT}"
    [[ $QUICK_FLASH_MULTI ]] && echo -e "${TIP}QUICK_FLASH_MULTI=${QUICK_FLASH_MULTI}"
    [[ $DATA_TEST_SCHEMA ]]  && echo -e "${TIP}DATA_TEST_SCHEMA=${DATA_TEST_SCHEMA}"
    [[ $TEST_SCHEMA ]]  && echo -e "${TIP}TEST_SCHEMA=${TEST_SCHEMA}"
    [[ $CONSUL_HTTP_HOST ]]  && echo -e "${TIP}CONSUL_HTTP_HOST=${CONSUL_HTTP_HOST}"
}

# 登录开发机
function devboxcn(){
    kinit jiangyufeng.007@BYTEDANCE.COM
    ssh jiangyufeng.007@10.37.18.186
}
function devboxva(){
    # kinit jiangyufeng.007@BYTEDANCE.COM
    ssh jiangyufeng.007@10.36.172.44
}

# 切换环境前的提示信息
function prompt(){
    echo -ne "${TIP}如需切换开发机 IP，请输入 IP，否则直接回车 [默认: 10.37.18.186]: "
    read -rA ip
    export CONSUL_HTTP_HOST=${ip:-"10.37.18.186"}

    echo -ne "${TIP}如需切换泳道，请输入泳道名称，否则直接回车: "
    read -rA wave
    [[ -n $wave ]] && export QUICK_FLASH_MULTI=$wave || unset QUICK_FLASH_MULTI

    echo -ne "${TIP}如需切换 schema，请输入 schema 名称，否则直接回车: "
    read -rA schema
    [[ -n $schema ]] && export DATA_TEST_SCHEMA=$schema TEST_SCHEMA=$schema || unset DATA_TEST_SCHEMA TEST_SCHEMA
}

# 主函数
function sw(){
    unset TENANT_ID QUICK_FLASH_BRAND QUICK_FLASH_MULTI QUICK_FLASH_UNIT QUICK_FLASH_ENV DATA_TEST_SCHEMA TEST_SCHEMA
    prompt
    echo -e "${INFO}请选择要切换的环境："
    echo -e "${TIP}1. cn"
    echo -e "${TIP}2. boe"
    echo -e "${TIP}3. cicd"
    echo -e "${TIP}4. va"
    echo -e "${TIP}5. sg"
    echo -e "${TIP}6. jp"
    echo -ne "${TIP}请输入数字 [1-6]: "
    read -rA num
    case "$num" in
        1) switch cn ;;
        2) switch boe ;;
        3) switch cicd ;;
        4) switch va ;;
        5) switch sg ;;
        6) switch jp ;;
        *) echo -e "${ERROR}输入有误，请重新运行脚本" ;;
    esac
}
