#!/bin/bash

# CCS Banner Display Script
# 为Claude Code Configuration Switcher显示启动横幅
# 支持彩色输出和多种显示模式

# 颜色定义 (ANSI Color Codes)
readonly CYAN='\033[0;36m'
readonly BRIGHT_CYAN='\033[1;36m'
readonly WHITE='\033[1;37m'
readonly GRAY='\033[0;37m'
readonly RESET='\033[0m'
readonly BOLD='\033[1m'

# 版本信息
readonly CCS_VERSION="2.0.0"
readonly PROJECT_URL="https://github.com/bahayonghang/ccs"

# 显示CCS Banner
show_banner() {
    local show_colors="${1:-true}"
    
    # 如果禁用颜色，清空颜色变量
    if [[ "$show_colors" == "false" ]] || [[ "$NO_COLOR" == "1" ]] || [[ "$CCS_DISABLE_COLORS" == "true" ]]; then
        local CYAN=""
        local BRIGHT_CYAN=""
        local WHITE=""
        local GRAY=""
        local RESET=""
        local BOLD=""
    fi
    
    echo ""
    echo -e "${BRIGHT_CYAN}██████╗ ██████╗ ███████╗${RESET}"
    echo -e "${BRIGHT_CYAN}██╔════╝██╔════╝██╔════╝${RESET}"
    echo -e "${BRIGHT_CYAN}██║     ██║     ███████╗${RESET}"
    echo -e "${BRIGHT_CYAN}██║     ██║          ██║${RESET}"
    echo -e "${BRIGHT_CYAN}╚██████╗╚██████╗███████║${RESET}"
    echo -e "${BRIGHT_CYAN} ╚═════╝ ╚═════╝╚══════╝${RESET}"
    echo ""
    echo -e "${WHITE}${BOLD}Claude Code Configuration Switcher${RESET}"
    echo ""
    echo -e "${GRAY}Version: ${WHITE}${CCS_VERSION}${GRAY}  |  ${WHITE}${PROJECT_URL}${RESET}"
    echo ""
}

# 显示简化版Banner（用于脚本集成）
show_mini_banner() {
    local show_colors="${1:-true}"
    
    if [[ "$show_colors" == "false" ]] || [[ "$NO_COLOR" == "1" ]] || [[ "$CCS_DISABLE_COLORS" == "true" ]]; then
        local CYAN=""
        local WHITE=""
        local RESET=""
    fi
    
    echo -e "${CYAN}██████╗ ██████╗ ███████╗${RESET}"
    echo -e "${CYAN}██╔════╝██╔════╝██╔════╝${RESET}"
    echo -e "${CYAN}██║     ██║     ███████╗${RESET}"
    echo -e "${CYAN}██║     ██║          ██║${RESET}"
    echo -e "${CYAN}╚██████╗╚██████╗███████║${RESET}"
    echo -e "${CYAN} ╚═════╝ ╚═════╝╚══════╝${RESET}"
    echo -e "${WHITE}Claude Code Configuration Switcher v${CCS_VERSION}${RESET}"
    echo ""
}

# 显示纯文本Banner（无颜色）
show_plain_banner() {
    echo ""
    echo "██████╗ ██████╗ ███████╗"
    echo "██╔════╝██╔════╝██╔════╝"
    echo "██║     ██║     ███████╗"
    echo "██║     ██║          ██║"
    echo "╚██████╗╚██████╗███████║"
    echo " ╚═════╝ ╚═════╝╚══════╝"
    echo ""
    echo "Claude Code Configuration Switcher"
    echo ""
    echo "Version: ${CCS_VERSION}  |  ${PROJECT_URL}"
    echo ""
}

# 显示帮助信息
show_help() {
    echo "CCS Banner Display Script"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  --full, -f        显示完整banner（默认）"
    echo "  --mini, -m        显示简化版banner"
    echo "  --plain, -p       显示纯文本banner（无颜色）"
    echo "  --no-color        禁用颜色输出"
    echo "  --help, -h        显示此帮助信息"
    echo ""
    echo "Environment Variables:"
    echo "  NO_COLOR          设置为1禁用颜色输出"
    echo "  CCS_DISABLE_COLORS 设置为true禁用颜色输出"
    echo ""
}

# 主函数
main() {
    local mode="full"
    local use_colors="true"
    
    # 解析命令行参数
    while [[ $# -gt 0 ]]; do
        case $1 in
            --full|-f)
                mode="full"
                shift
                ;;
            --mini|-m)
                mode="mini"
                shift
                ;;
            --plain|-p)
                mode="plain"
                shift
                ;;
            --no-color)
                use_colors="false"
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                echo "未知选项: $1" >&2
                echo "使用 --help 查看帮助信息" >&2
                exit 1
                ;;
        esac
    done
    
    # 根据模式显示相应的banner
    case $mode in
        "full")
            show_banner "$use_colors"
            ;;
        "mini")
            show_mini_banner "$use_colors"
            ;;
        "plain")
            show_plain_banner
            ;;
    esac
}

# 如果脚本被直接执行，运行主函数
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi