---
name: runtime-footer
description: 运行时消息小尾巴 — 每条回复末尾自动附加 ⏰📋🎮🤖 状态行
---

# hermes-runtime-footer

每条回复末尾自动加一行紧凑状态：

```
⏰10:30 | 📋AI中🔒2 | 🎮42% | 🤖CS4
```

**GitHub 仓库**: 替换为你的仓库地址

## 安装

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/<你的用户名>/hermes-runtime-footer/main/install.sh)
```

## 字段说明

| 图标 | 含义 | 来源 |
|---|---|---|
| ⏰ | 会话开始时间 | sessions.json 索引或 gateway 传入 |
| 📋 | 看板活跃任务（▶进行中/⏳就绪/🔒堵塞） | hermes kanban 实时查询 |
| 🎮 | GPU 显存占用率 | nvidia-smi |
| 🤖 | 当前模型简写 | 环境变量或 webui 索引 |

详见 GitHub 仓库 README。
