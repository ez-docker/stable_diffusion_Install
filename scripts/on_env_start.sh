#!/bin/bash

source ./scripts/functions.sh

printf "\n\nEasy Diffusion\n\n"

if [ -f "scripts/config.sh" ]; then
    source scripts/config.sh
fi

if [ "$update_branch" == "" ]; then
    export update_branch="main"
fi

if [ -f "scripts/install_status.txt" ] && [ `grep -c sd_ui_git_cloned scripts/install_status.txt` -gt "0" ]; then
    echo "Easy Diffusion 的 Git 仓库已经安装. 正在更新自 $update_branch.."

    cd sd-ui-files

    git reset --hard
    git -c advice.detachedHead=false checkout "$update_branch"
    git pull

    cd ..
else
    printf "\n\下载 Easy Diffusion..\n\n"
    printf "使用 $update_branch 通道\n\n"

    if git clone -b "$update_branch" https://github.com/cmdr2/stable-diffusion-ui.git sd-ui-files ; then
        echo sd_ui_git_cloned >> scripts/install_status.txt
    else
        fail "git clone 失败"
    fi
fi

rm -rf ui
cp -Rf sd-ui-files/ui .
cp sd-ui-files/scripts/on_sd_start.sh scripts/
cp sd-ui-files/scripts/bootstrap.sh scripts/
cp sd-ui-files/scripts/check_modules.py scripts/
cp sd-ui-files/scripts/start.sh .
cp sd-ui-files/scripts/developer_console.sh .
cp sd-ui-files/scripts/functions.sh scripts/

exec ./scripts/on_sd_start.sh
