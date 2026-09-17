# mydot

个人基础终端工具配置（Vim、Vifm）。

## 目录结构

```text
mydot/
├── dotfiles/
│   ├── vimrc                   # Vim 配置
│   └── vifm/
│       └── colors/
│           └── ph.vifm         # Vifm ph 配色方案
├── install.sh                  # 安装与初始化脚本
└── README.md
```

## 新机器一键安装

在目标机器上执行以下命令（将 `<username>` 替换为实际 GitHub 用户名）：

```bash
git clone https://github.com/cancanyou/mydot.git ~/.mydot && bash ~/.mydot/install.sh
```

或无需先手动 clone，直接单行执行：

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/cancanyou/mydot/main/install.sh)"
```

### 脚本执行内容

1. **Vim**:
   - 克隆 Vundle 至 `~/.vim/bundle/Vundle.vim`
   - 软链接 `~/.vimrc` 到仓库配置（若原配置存在则自动备份）
   - 调用 `vim +PluginInstall +qall` 静默安装配置内插件
2. **Vifm**:
   - 创建 `~/.vifm/colors` 并软链接 `ph.vifm`
   - 检查 `~/.vifm/vifmrc`，写入或追加 `colorscheme ph`

## 推送至 GitHub

在当前目录完成仓库初始化并推送到目标 GitHub 账号：

```bash
git remote add origin git@github.com:cancanyou/mydot.git
git push -u origin main
```
