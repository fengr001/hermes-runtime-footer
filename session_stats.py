#!/usr/bin/env python3
"""
hermes-runtime-footer — Hermes Agent 消息小尾巴

每条回复末尾自动输出一行紧凑状态，显示：
  ⏰会话开始时间 · 📋看板活跃任务 · 🎮GPU占用 · 🤖当前模型

特点：
  - 零外部依赖（只用 Python 标准库）
  - 每个字段独立 try/except，一个挂了不影响其他
  - 看板无活跃时显示「空闲」而非空行

用法：
  # 无参：从 sessions.json 索引读取最新 feishu 会话时间
  python3 session_stats.py

  # 传参：gateway 传入当前会话精确开始时间
  python3 session_stats.py --start 2026-06-03T10:30:00.000000
"""
import subprocess, json, os, re
from datetime import datetime


def get_session_start():
    """从 sessions.json 索引读取最新 feishu 会话的开始时间"""
    indexPath = os.path.expanduser("~/.hermes/sessions/sessions.json")
    if not os.path.isfile(indexPath):
        return None
    try:
        with open(indexPath) as f:
            idx = json.load(f)

        best_ts = None
        for key, s in idx.items():
            if s.get("platform") != "feishu":
                continue
            start_str = s.get("created_at", "")
            if not start_str:
                continue
            try:
                dt = datetime.fromisoformat(start_str.replace("Z", ""))
                if best_ts is None or dt > best_ts:
                    best_ts = dt
            except Exception:
                continue

        if best_ts:
            return best_ts.strftime("%H:%M")
        return None
    except Exception:
        return None


def get_kanban_stats():
    """汇总所有看板的活跃任务数"""
    r = subprocess.run(
        ["hermes", "kanban", "boards", "list"],
        capture_output=True, text=True, timeout=10,
    )
    boards = re.findall(r'^(?:[│●]| {4})\s*([a-z][a-z0-9_-]+)\s{2,}', r.stdout, re.M)
    if not boards:
        boards = ['default']

    NAME_SHORT = {
        'default': '默认',
    }

    active = {}
    for slug in set(boards):
        r2 = subprocess.run(
            ["hermes", "kanban", "--board", slug, "list", "--json"],
            capture_output=True, text=True, timeout=8,
        )
        try:
            data = json.loads(r2.stdout)
            tasks = data if isinstance(data, list) else data.get('tasks', [])
            ip = sum(1 for t in tasks if t.get('status') in ('claimed', 'in_progress'))
            rd = sum(1 for t in tasks if t.get('status') == 'ready')
            bl = sum(1 for t in tasks if t.get('status') == 'blocked')
            if ip or rd or bl:
                short = NAME_SHORT.get(slug, slug[:2])
                subs = []
                if ip: subs.append(f"▶{ip}")
                if rd: subs.append(f"⏳{rd}")
                if bl: subs.append(f"🔒{bl}")
                active[short] = ' '.join(subs)
        except Exception:
            pass

    if not active:
        return "📋空闲"
    return "📋" + " ".join(f"{k}{v}" for k, v in active.items())


def get_gpu():
    """GPU 显存占用率"""
    try:
        # 标准 nvidia-smi 路径
        r = subprocess.run(
            ["nvidia-smi", "--query-gpu=memory.used,memory.total",
             "--format=csv,noheader,nounits"],
            capture_output=True, text=True, timeout=5,
        )
        if r.returncode != 0:
            # WSL 路径
            r = subprocess.run(
                ["/usr/lib/wsl/lib/nvidia-smi", "--query-gpu=memory.used,memory.total",
                 "--format=csv,noheader,nounits"],
                capture_output=True, text=True, timeout=5,
            )
        if r.returncode != 0:
            return None
        line = r.stdout.strip().split('\n')[0]
        used, total = line.split(', ')
        pct = int(int(used) / int(total) * 100)
        return f"🎮{pct}%"
    except Exception:
        return None


def get_model():
    """当前模型简写"""
    m = os.environ.get('HERMES_MODEL', '')
    if not m:
        index_path = os.path.expanduser('~/.hermes/webui/sessions/_index.json')
        try:
            with open(index_path) as f:
                idx = json.load(f)
            for s in sorted(idx, key=lambda x: x.get('created_at', 0), reverse=True):
                if s.get('model'):
                    m = s['model']
                    break
        except Exception:
            pass
    if not m:
        return None
    m = m.split('/')[-1]
    # 常见模型简写映射（按需添加）
    ALIASES = {
        'deepseek-v4-flash': 'DS-Flash',
        'deepseek-v3-': 'DS-V3-',
        'claude-sonnet-4': 'CS4',
        'claude-': 'Claude-',
        'gpt-4o': 'GPT4o',
        'gpt-5.4': 'GPT5.4',
    }
    for old, new in ALIASES.items():
        m = m.replace(old, new)
    return f"🤖{m}"


if __name__ == '__main__':
    import sys
    parts = []

    # 解析 --start 参数（gateway 传入当前会话开始时间）
    session_start_arg = None
    for i, arg in enumerate(sys.argv[1:]):
        if arg == '--start' and i + 1 < len(sys.argv[1:]):
            session_start_arg = sys.argv[1:][i + 1]
            break

    if session_start_arg:
        try:
            dt = datetime.fromisoformat(session_start_arg.replace("Z", ""))
            parts.append(f"⏰{dt.strftime('%H:%M')}")
        except Exception:
            start = get_session_start()
            if start:
                parts.append(f"⏰{start}")
    else:
        start = get_session_start()
        if start:
            parts.append(f"⏰{start}")

    parts.append(get_kanban_stats())

    gpu = get_gpu()
    if gpu:
        parts.append(gpu)

    model = get_model()
    if model:
        parts.append(model)

    print(" | ".join(parts))
