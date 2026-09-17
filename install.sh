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

# 若通过 curl 管道直接执行，克隆仓库至本地
TARGET_DIR="${HOME}/.mydot"
if [ ! -f "${SCRIPT_DIR}/dotfiles/vimrc" ]; then
    REPO_URL="${1:-${REPO_URL:-https://github.com/cancanyou/mydot.git}}"
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

# 2. 配置 vifm
echo "[INFO] 配置 vifm..."
VIFM_DIR="${HOME}/.vifm"
VIFM_COLORS_DIR="${VIFM_DIR}/colors"
mkdir -p "$VIFM_COLORS_DIR"

PH_THEME_SOURCE="${DOTFILES_DIR}/vifm/colors/ph.vifm"
PH_THEME_TARGET="${VIFM_COLORS_DIR}/ph.vifm"

if [ -f "$PH_THEME_SOURCE" ]; then
    ln -sf "$PH_THEME_SOURCE" "$PH_THEME_TARGET"
    echo "[INFO] 已链接 $PH_THEME_TARGET -> $PH_THEME_SOURCE"
else
    echo "[INFO] 下载 ph.vifm..."
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL https://raw.githubusercontent.com/vifm/vifm-colors/master/ph.vifm -o "$PH_THEME_TARGET"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$PH_THEME_TARGET" https://raw.githubusercontent.com/vifm/vifm-colors/master/ph.vifm
    fi
fi

VIFMRC_FILE="${VIFM_DIR}/vifmrc"
if [ ! -f "$VIFMRC_FILE" ]; then
    echo "colorscheme ph" > "$VIFMRC_FILE"
    echo "[INFO] 创建 $VIFMRC_FILE 并设置 colorscheme ph"
else
    if ! grep -q "colorscheme ph" "$VIFMRC_FILE"; then
        echo "colorscheme ph" >> "$VIFMRC_FILE"
        echo "[INFO] 追加 colorscheme ph 至 $VIFMRC_FILE"
    else
        echo "[INFO] $VIFMRC_FILE 已包含 colorscheme ph"
    fi
fi

echo "[INFO] 安装完成。"
