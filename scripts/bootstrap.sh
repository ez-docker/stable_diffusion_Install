#!/bin/bash

# 这个脚本将安装 git 和 conda（如果在 PATH 变量中找不到）
# 此脚本将使用 micromamba（一个8MB静态链接的单文件二进制程序，可以替代 conda）进行安装
# 如果用户已经安装了 git 和 conda，则此步骤将被跳过
# 这使得用户可以在不需要手动安装 conda 和 git 的情况下安装这个项目

source ./scripts/functions.sh

set -o pipefail

OS_NAME=$(uname -s)
case "${OS_NAME}" in
    Linux*)     OS_NAME="linux";;
    Darwin*)    OS_NAME="osx";;
    *)          echo "未知操作系统: $OS_NAME! 此脚本仅适用于 Linux 或 Mac" && exit
esac

OS_ARCH=$(uname -m)
case "${OS_ARCH}" in
    x86_64*)    OS_ARCH="64";;
    arm64*)     OS_ARCH="arm64";;
    aarch64*)     OS_ARCH="arm64";;
    *)          echo "未知的系统架构: $OS_ARCH! 此脚本仅适用于 x86_64 或 arm64 架构" && exit
esac

if ! which curl; then fail "'curl' 未找到. Please install curl."; fi
if ! which tar; then fail "'tar' 未找到. Please install tar."; fi
if ! which bzip2; then fail "'bzip2' 未找到. Please install bzip2."; fi

if pwd | grep ' '; then fail "安装目录的路径包含空格字符 Conda 安装将失败 请更改目录。."; fi

# https://mamba.readthedocs.io/en/latest/installation.html
if [ "$OS_NAME" == "linux" ] && [ "$OS_ARCH" == "arm64" ]; then OS_ARCH="aarch64"; fi

# config
export MAMBA_ROOT_PREFIX="$(pwd)/installer_files/mamba"
INSTALL_ENV_DIR="$(pwd)/installer_files/env"
LEGACY_INSTALL_ENV_DIR="$(pwd)/installer"
MICROMAMBA_DOWNLOAD_URL="https://micro.mamba.pm/api/micromamba/${OS_NAME}-${OS_ARCH}/latest"
umamba_exists="F"

# 弄清楚是否需要安装 Git 和 Conda
if [ -e "$INSTALL_ENV_DIR" ]; then export PATH="$INSTALL_ENV_DIR/bin:$PATH"; fi

PACKAGES_TO_INSTALL=""

if [ ! -e "$LEGACY_INSTALL_ENV_DIR/etc/profile.d/conda.sh" ] && [ ! -e "$INSTALL_ENV_DIR/etc/profile.d/conda.sh" ]; then PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL conda python=3.8.5"; fi
if ! hash "git" &>/dev/null; then PACKAGES_TO_INSTALL="$PACKAGES_TO_INSTALL git"; fi

if "$MAMBA_ROOT_PREFIX/micromamba" --version &>/dev/null; then umamba_exists="T"; fi

# (if necessary) 安装git和conda到一个独立的环境中
if [ "$PACKAGES_TO_INSTALL" != "" ]; then
    # 下载 micromamba
    if [ "$umamba_exists" == "F" ]; then
        echo "从micromamba下载 $MICROMAMBA_DOWNLOAD_URL 到 $MAMBA_ROOT_PREFIX/micromamba"

        mkdir -p "$MAMBA_ROOT_PREFIX"
        curl -L "$MICROMAMBA_DOWNLOAD_URL" | tar -xvj -O bin/micromamba > "$MAMBA_ROOT_PREFIX/micromamba"

        if [ "$?" != "0" ]; then
            echo
            echo "micromamba 下载失败"
            echo "如果上面的行包含'bzip2: Cannot exec', 则表示您的系统未安装 bzip2"
            echo "如果出现网络错误 请检查您的互联网设置"
            fail "micromamba 下载失败"
        fi

        chmod u+x "$MAMBA_ROOT_PREFIX/micromamba"

        # 测试 mamba 二进制文件
        echo "Micromamba 版本:"
        "$MAMBA_ROOT_PREFIX/micromamba" --version
    fi

    # 创建安装程序环境
    if [ ! -e "$INSTALL_ENV_DIR" ]; then
        "$MAMBA_ROOT_PREFIX/micromamba" create -y --prefix "$INSTALL_ENV_DIR" || fail "unable to create the install environment"
    fi
   
    if [ ! -e "$INSTALL_ENV_DIR" ]; then
        fail "使用 micromamba 安装 $PACKAGES_TO_INSTALL 时出现问题. 无法继续."
    fi

    echo "安装软件包:$PACKAGES_TO_INSTALL"

    "$MAMBA_ROOT_PREFIX/micromamba" install -y --prefix "$INSTALL_ENV_DIR" -c conda-forge $PACKAGES_TO_INSTALL
    if [ "$?" != "0" ]; then
        fail "安装软件包 '$PACKAGES_TO_INSTALL' 失败."
    fi
fi
