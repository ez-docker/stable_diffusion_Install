#!/bin/bash

cd "$(dirname "${BASH_SOURCE[0]}")"

if [ -f "on_sd_start.bat" ]; then
    echo ================================================================================
    echo
    echo !!!! 警告 !!!!
    echo
    echo 看起来你\'正在尝试从源代码运行安装脚本
    echo 下载源代码是不可行的.
    echo
    echo 建议: 请关闭此窗口并从以下网址下载安装程序
    echo https://stable-diffusion-ui.github.io/docs/installation/
    echo
    echo ================================================================================
    echo
    read
    exit 1
fi


# 如果存在旧版安装程序，则设置其路径
if [ -e "installer" ]; then export PATH="$(pwd)/installer/bin:$PATH"; fi

# 设置安装程序所需的软件包
scripts/bootstrap.sh || exit 1

# 如果下载了任何软件包，则设置新版本安装程序的路径
if [ -e "installer_files/env" ]; then export PATH="$(pwd)/installer_files/env/bin:$PATH"; fi

# 测试启动程序
which git
git --version || exit 1

which conda
conda --version || exit 1

# 下载剩余部分的安装程序和用户界面
chmod +x scripts/*.sh
scripts/on_env_start.sh
