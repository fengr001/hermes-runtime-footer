---
name: runtime-footer
description: 运行时消息小尾巴 — 每条回复末尾自动附加 ⏰📋🎮🤖 状态行
---

# hermes-runtime-footer

每条回复末尾加一条紧凑状态行：

```
⏰06:36 | 📋AI中🔒2 投资🔒2 | 🎮43% | 🤖DS-Flash
```

GitHub 仓库: https://github.com/fengr001/hermes-runtime-footer

## 安装

一条命令（需 hermes-agent 已安装、git 仓库存在）：

```bash
bash <(curl -fsSL https://raw.githubusercontent.com/fengr001/hermes-runtime-footer/main/install.sh)
```

## 组成

| 文件 | 位置 |
|---|---|
| `session_stats.py` | `~/.hermes/scripts/session_stats.py` |
| `patches/runtime-footer.patch` | gateway 源码补丁 (`git apply`) |
| `config.yaml` | `display.runtime_footer.enabled: true` |

## 字段说明

| 图标 | 含义 | 来源 |
|---|---|---|
| ⏰10:30 | 当前会话开始时间 | `sessions.json` 索引或 gateway 传入 |
| 📋AI中🔒2 | 看板活跃任务（▶进行中/⏳就绪/🔒堵塞） | `hermes kanban --json` |
| 🎮42% | GPU 显存占用率 | `nvidia-smi` |
| 🤖DS-Flash | 当前模型简写 | 环境变量或 webui 索引 |

## 自定义

编辑 `session_stats.py` 的 `if __name__ == '__main__':` 段，注释不需要的字段行即可。
