# mydot

个人基础终端工具配置（Vim、Vifm）。

## 目录结构

```text
mydot/
├── dotfiles/
│   ├── vimrc                   # Vim 配置
│   └── vifm/
│       ├── colors/
│       │   └── ph.vifm         # Vifm ph 配色方案
│       └── vifmrc              # Vifm 完备配置（含常用快捷键及 ph 配色）
├── install.sh                  # 安装与初始化脚本
└── README.md
```

## 新机器一键安装

在目标机器上执行以下命令：

```bash
git clone https://github.com/cancan6616/mydot.git ~/.mydot && bash ~/.mydot/install.sh
```

或无需先手动 clone，直接单行执行：

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/cancan6616/mydot/main/install.sh)"
```

### 脚本执行内容

1. **环境依赖检测与自动安装**:
   - 自动检测并安装缺失的 `git` 和 `vifm`（支持 apt / dnf / yum / pacman / apk / brew）
2. **Vim**:
   - 克隆 Vundle 至 `~/.vim/bundle/Vundle.vim`
   - 软链接 `~/.vimrc` 到仓库配置（若原配置存在则自动备份）
   - 调用 `vim +PluginInstall +qall` 静默安装配置内插件
3. **Vifm**:
   - 创建 `~/.vifm/colors` 并软链接 `ph.vifm`
   - 若不存在 `~/.vifm/vifmrc`，直接软链接仓库内完备配置（避免只写一行导致基础快捷键丢失）；若已有 `~/.vifm/vifmrc` 则追加 `colorscheme ph`

## 推送至 GitHub

在当前目录完成仓库初始化并推送到目标 GitHub 账号：

```bash
git remote add origin git@github.com:cancan6616/mydot.git
git push -u origin main
```
