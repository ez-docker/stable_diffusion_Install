#
# utility functions for all scripts
#

fail() {
    echo
    echo "EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE"
    echo
    if [ "$1" != "" ]; then
        echo ERROR: $1
    else
        echo An error occurred.
    fi
    cat <<EOF

下载 Stable Diffusion UI 出错.很抱歉, 请尝试:
 1. 再次运行此安装程序.
 2. 如果还无法解决问题, 请尝试 https://github.com/cmdr2/stable-diffusion-ui/wiki/Troubleshooting 上尝试常见的故障排除步骤
 3. 如果这些步骤无法帮助，请复制此窗口中的 所有 错误消息，并在 https://discord.com/invite/u9yhsFmEkB 上询问社区
 4. 如果这不能解决问题，请在 https://github.com/cmdr2/stable-diffusion-ui/issues 上报告问题

Thanks!


EOF
    read -p "按任意键继续"
    exit 1

}

filesize() {
    case "$(uname -s)" in
        Linux*)     stat -c "%s" $1;;
        Darwin*)    stat -f "%z" $1;;
        *)          echo "未知的操作系统: $OS_NAME! 此脚本仅适用于 Linux 或 Mac" && exit
    esac
}


