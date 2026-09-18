#!/usr/bin/env bash
set -e

# 获取脚本所在目录
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
    DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"
    SOURCE="$(readlink "$SOURCE")"
    [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
SCRIPT_DIR="$(cd -P "$(dirname "$SOURCE")" && pwd)"

# 获取提升权限命令前缀
get_sudo() {
    if [ "$(id -u)" -ne 0 ]; then
        if command -v sudo >/dev/null 2>&1; then
            echo "sudo"
        else
            echo ""
        fi
    else
        echo ""
    fi
}

# 自动检测并安装缺失软件包
install_package() {
    local PKG="$1"
    if command -v "$PKG" >/dev/null 2>&1; then
        return 0
    fi
    echo "[INFO] 未检测到 $PKG，尝试自动安装..."
    local SUDO
    SUDO="$(get_sudo)"
    if [ "$(id -u)" -ne 0 ] && [ -z "$SUDO" ]; then
        echo "警告: 系统未安装 $PKG 且无 sudo 权限，跳过自动安装。"
        return 1
    fi

    if command -v apt-get >/dev/null 2>&1; then
        $SUDO apt-get update -y && $SUDO apt-get install -y "$PKG"
    elif command -v dnf >/dev/null 2>&1; then
        $SUDO dnf install -y "$PKG"
    elif command -v yum >/dev/null 2>&1; then
        if [ "$PKG" = "vifm" ]; then
            $SUDO yum install -y epel-release || true
        fi
        $SUDO yum install -y "$PKG"
    elif command -v pacman >/dev/null 2>&1; then
        $SUDO pacman -Sy --noconfirm "$PKG"
    elif command -v apk >/dev/null 2>&1; then
        $SUDO apk add --no-cache "$PKG"
    elif command -v brew >/dev/null 2>&1; then
        brew install "$PKG"
    else
        echo "警告: 未识别的包管理器，无法自动安装 $PKG。"
        return 1
    fi
}

# 确保 git 可用
install_package git

# 若通过 curl 管道直接执行，克隆仓库至本地
TARGET_DIR="${HOME}/.mydot"
if [ ! -f "${SCRIPT_DIR}/dotfiles/vimrc" ]; then
    REPO_URL="${1:-${REPO_URL:-https://github.com/cancan6616/mydot.git}}"
    if [ ! -d "$TARGET_DIR" ]; then
        echo "[INFO] 克隆配置仓库到 $TARGET_DIR..."
        git clone "$REPO_URL" "$TARGET_DIR"
    else
        echo "[INFO] 更新现有仓库 $TARGET_DIR..."
        git -C "$TARGET_DIR" pull --ff-only || true
    fi
    SCRIPT_DIR="$TARGET_DIR"
fi

DOTFILES_DIR="${SCRIPT_DIR}/dotfiles"

# 1. 配置 Vim
echo "[INFO] 配置 Vim..."
VUNDLE_DIR="${HOME}/.vim/bundle/Vundle.vim"
if [ ! -d "$VUNDLE_DIR" ]; then
    echo "[INFO] 安装 Vundle.vim..."
    mkdir -p "$(dirname "$VUNDLE_DIR")"
    git clone https://github.com/VundleVim/Vundle.vim.git "$VUNDLE_DIR"
else
    echo "[INFO] Vundle.vim 已存在，跳过克隆。"
fi

VIMRC_TARGET="${HOME}/.vimrc"
VIMRC_SOURCE="${DOTFILES_DIR}/vimrc"
if [ -f "$VIMRC_TARGET" ] && [ ! -L "$VIMRC_TARGET" ]; then
    BACKUP="${VIMRC_TARGET}.bak.$(date +%Y%m%d%H%M%S)"
    echo "[INFO] 备份现有 .vimrc 至 $BACKUP"
    mv "$VIMRC_TARGET" "$BACKUP"
fi
ln -sf "$VIMRC_SOURCE" "$VIMRC_TARGET"
echo "[INFO] 已链接 $VIMRC_TARGET -> $VIMRC_SOURCE"

if command -v vim >/dev/null 2>&1; then
    echo "[INFO] 执行 Vim 插件安装 (PluginInstall)..."
    vim -E -s -u "$VIMRC_TARGET" +PluginInstall +qall || true
fi

# 2. 检查并配置 vifm
echo "[INFO] 检查并配置 vifm..."
install_package vifm || true

VIFM_DIRS=("${HOME}/.vifm" "${XDG_CONFIG_HOME:-${HOME}/.config}/vifm")
PH_THEME_SOURCE="${DOTFILES_DIR}/vifm/colors/ph.vifm"
VIFMRC_SOURCE="${DOTFILES_DIR}/vifm/vifmrc"

for DIR in "${VIFM_DIRS[@]}"; do
    mkdir -p "${DIR}/colors"
    PH_THEME_TARGET="${DIR}/colors/ph.vifm"
    if [ -f "$PH_THEME_SOURCE" ]; then
        ln -sf "$PH_THEME_SOURCE" "$PH_THEME_TARGET"
        echo "[INFO] 已链接 $PH_THEME_TARGET -> $PH_THEME_SOURCE"
    elif [ ! -f "$PH_THEME_TARGET" ]; then
        echo "[INFO] 下载 ph.vifm..."
        if command -v curl >/dev/null 2>&1; then
            curl -fsSL https://raw.githubusercontent.com/vifm/vifm-colors/master/ph.vifm -o "$PH_THEME_TARGET"
        elif command -v wget >/dev/null 2>&1; then
            wget -qO "$PH_THEME_TARGET" https://raw.githubusercontent.com/vifm/vifm-colors/master/ph.vifm
        fi
    fi

    VIFMRC_TARGET="${DIR}/vifmrc"
    if [ -f "$VIFMRC_SOURCE" ]; then
        if [ -f "$VIFMRC_TARGET" ] && [ ! -L "$VIFMRC_TARGET" ]; then
            BACKUP="${VIFMRC_TARGET}.bak.$(date +%Y%m%d%H%M%S)"
            echo "[INFO] 备份现有 vifmrc 至 $BACKUP"
            mv "$VIFMRC_TARGET" "$BACKUP"
        fi
        ln -sf "$VIFMRC_SOURCE" "$VIFMRC_TARGET"
        echo "[INFO] 已链接 $VIFMRC_TARGET -> $VIFMRC_SOURCE"
    elif [ ! -f "$VIFMRC_TARGET" ]; then
        echo "colorscheme ph" > "$VIFMRC_TARGET"
        echo "[INFO] 创建 $VIFMRC_TARGET 并设置 colorscheme ph"
    fi
done

echo "[INFO] 安装完成。"
