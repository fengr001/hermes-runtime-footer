<div align="center">
  <h1>⟡ hermes-runtime-footer ⟡</h1>
  <p><strong>Hermes Agent 消息小尾巴</strong></p>
  <p>每条回复末尾自动显示 ⏰会话时间 · 📋看板任务 · 🎮GPU · 🤖模型</p>
  <p>
    <a href="#-安装"><img src="https://img.shields.io/badge/install-one_liner-blue" alt="Install"></a>
    <a href="LICENSE"><img src="https://img.shields.io/badge/license-MIT-green" alt="License"></a>
  </p>
</div>

---

## 🪄 效果

```text
⏰06:36 | 📋AI中🔒2 投资🔒2 | 🎮43% | 🤖DS-Flash
```

| 图标 | 含义 | 说明 |
|------|------|------|
| ⏰ | 会话开始时间 | 精确到分钟，gateway 传入或索引回退 |
| 📋 | 看板活跃任务 | 所有看板汇总，▶进行中 ⏳就绪 🔒堵塞 |
| 🎮 | GPU 显存占用率 | `nvidia-smi` 实时查询，含 WSL 路径回退 |
| 🤖 | 当前模型 | 自动简写，可自定义映射表 |

---

## 📦 安装

**一条命令安装：**

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/fengr001/hermes-runtime-footer/main/install.sh)
```

安装脚本会：
1. ✅ 检测 Hermes 环境
2. ✅ 复制 `session_stats.py` 到 `~/.hermes/scripts/`
3. ✅ 自动打 gateway 补丁（`git apply`）
4. ✅ 启用 `config.yaml` 中的 `runtime_footer`
5. ❓ 询问是否重启 gateway

**手动安装：**

```bash
# 1. 放脚本
cp session_stats.py ~/.hermes/scripts/
chmod +x ~/.hermes/scripts/session_stats.py

# 2. 打补丁
cd ~/.hermes/hermes-agent
git apply /path/to/patches/runtime-footer.patch

# 3. 启用配置（编辑 ~/.hermes/config.yaml）
# 加入：
# display:
#   runtime_footer:
#     enabled: true

# 4. 重启 gateway
hermes gateway restart
```

---

## 🔧 无需补丁（仅 CLI / 回退模式）

如果不想改 gateway 源码，`session_stats.py` 无参运行时自动读 `~/.hermes/sessions/sessions.json` 索引。缺点：
- ⏰ 时间可能不是当前会话（而是此聊天当天最早的那个会话）
- 但 📋🎮🤖 完全正常

适合快速试用。

---

## 🎨 自定义

### 增减显示字段

编辑 `session_stats.py` 的 `main` 段：

```python
# 注释掉不需要的字段
parts.append(get_kanban_stats())
# parts.append(get_gpu())    # 关闭 GPU 显示
# parts.append(get_model())  # 关闭模型显示
```

### 看板短名

```python
NAME_SHORT = {
    'investment': '投资',
    'ai-center': 'AI中',
    'erp-dev': 'ERP',
}
```

### 模型简写

```python
ALIASES = {
    'claude-sonnet-4': 'CS4',
    'gpt-4o': 'GPT4o',
    # 加你自己的
}
```

---

## 🏗 项目结构

```
hermes-runtime-footer/
├── session_stats.py          # 核心脚本（零依赖，可直接用）
├── install.sh                # 一键安装
├── patches/
│   └── runtime-footer.patch  # gateway 源码补丁
├── skills/
│   └── runtime-footer/
│       └── SKILL.md          # Hermes skill 定义
├── README.md
└── .gitignore
```

---

## 📄 License

MIT
