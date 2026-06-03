<div align="center">
  <h1>⟡ hermes-runtime-footer ⟡</h1>
  <p><strong>Hermes Agent 运行时消息小尾巴</strong></p>
  <p>每条回复末尾自动显示 ⏰会话时间 · 📋看板任务 · 🎮GPU占用 · 🤖当前模型</p>
  <p>
    <a href="#-安装"><img src="https://img.shields.io/badge/install-一行命令-blue" alt="Install"></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="License"></a>
  </p>
</div>

---

## 🪄 效果

```text
⏰10:30 | 📋AI中🔒2 | 🎮42% | 🤖CS4
```

| 图标 | 含义 | 来源 |
|------|------|------|
| ⏰ | 当前会话开始时间 | gateway 传入或 sessions.json 索引回退 |
| 📋 | 看板活跃任务汇总 | `hermes kanban` 实时查询 |
| 🎮 | GPU 显存占用率 | `nvidia-smi`，含 WSL 路径回退 |
| 🤖 | 当前模型简写 | 环境变量或 webui 索引，可自定义映射 |

---

## 📦 安装

### 一行命令安装

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/你的用户名/hermes-runtime-footer/main/install.sh)
```

安装脚本自动完成四步：
1. ✅ 检测 Hermes 环境
2. ✅ 复制脚本到 `~/.hermes/scripts/`
3. ✅ 自动打 gateway 补丁（`git apply`）
4. ✅ 启用 `config.yaml` 中的 `runtime_footer`

### 手动安装

```bash
# 1. 放脚本
cp session_stats.py ~/.hermes/scripts/
chmod +x ~/.hermes/scripts/session_stats.py

# 2. 打补丁
cd ~/.hermes/hermes-agent
git apply /path/to/patches/runtime-footer.patch

# 3. 启用配置
# 编辑 ~/.hermes/config.yaml，加入：
# display:
#   runtime_footer:
#     enabled: true

# 4. 重启 gateway
hermes gateway restart
```

---

## 🔧 无需补丁模式

若不想修改 gateway 源码，脚本在没有 `--start` 参数时会自动回退读 `sessions.json` 索引。此模式下：

- ⏰ 时间为该聊天当日最早会话的开始时间（非精确当前会话）
- 📋🎮🤖 完全正常
- 适合快速试用

---

## 🎨 自定义

### 增减显示字段

编辑 `session_stats.py` 的 `main` 段，注释不需要的行：

```python
parts.append(get_kanban_stats())     # 看板
# parts.append(get_gpu())            # GPU（取消注释以隐藏）
# parts.append(get_model())          # 模型（取消注释以隐藏）
```

### 看板短名映射

```python
NAME_SHORT = {
    'my-board-1': '板1',
    'my-board-2': '板2',
}
```

### 模型简写映射

```python
ALIASES = {
    'claude-sonnet-4': 'CS4',
    'gpt-4o': 'GPT4o',
    # 添加你自己的模型映射
}
```

### 不显示「空闲」

若希望看板无活跃任务时不显示 `📋空闲`，可在 `get_kanban_stats()` 中将 `return "📋空闲"` 改为 `return ""`。

---

## 🏗 项目结构

```
hermes-runtime-footer/
├── session_stats.py          # 核心脚本，零外部依赖
├── install.sh                # 一键安装脚本
├── patches/
│   └── runtime-footer.patch  # gateway 源码补丁
├── skills/
│   └── runtime-footer/       # Hermes Agent skill 定义
└── README.md
```

## 卸载

```bash
rm -f ~/.hermes/scripts/session_stats.py
# 编辑 ~/.hermes/config.yaml：runtime_footer.enabled 改为 false
# gateway 重启生效
```

---

## 📄 开源协议

MIT
