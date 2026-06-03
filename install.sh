#!/usr/bin/env bash
set -euo pipefail

# ═══════════════════════════════════════════════════════════
#  hermes-runtime-footer — 一键安装脚本
#
#  用法：
#    bash <(curl -fsSL https://raw.githubusercontent.com/fengr001/hermes-runtime-footer/main/install.sh)
#
#  或本地：
#    bash install.sh
# ═══════════════════════════════════════════════════════════

# ── 颜色 ──
RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; NC='\033[0m'
info()  { echo -e "${CYAN}ℹ${NC} $1"; }
ok()    { echo -e "${GREEN}✓${NC} $1"; }
warn()  { echo -e "${YELLOW}⚠${NC} $1"; }
err()   { echo -e "${RED}✗${NC} $1"; }

echo ""
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo -e "${CYAN}  hermes-runtime-footer 安装脚本${NC}"
echo -e "${CYAN}  消息小尾巴 — ⏰📋🎮🤖${NC}"
echo -e "${CYAN}═══════════════════════════════════════════${NC}"
echo ""

# ── 1. 检测环境 ──
HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
HERMES_AGENT_DIR="${HERMES_AGENT_DIR:-$HERMES_HOME/hermes-agent}"

if [ ! -d "$HERMES_HOME" ]; then
    err "未找到 Hermes 目录: $HERMES_HOME"
    err "请确保已安装 Hermes Agent"
    exit 1
fi
ok "Hermes 目录: $HERMES_HOME"

# ── 2. 放置脚本 ──
SCRIPT_DIR="$HERMES_HOME/scripts"
mkdir -p "$SCRIPT_DIR"
cp session_stats.py "$SCRIPT_DIR/session_stats.py"
chmod +x "$SCRIPT_DIR/session_stats.py"
ok "脚本已安装: $SCRIPT_DIR/session_stats.py"

# ── 3. 测试脚本能否运行 ──
if python3 "$SCRIPT_DIR/session_stats.py" > /dev/null 2>&1; then
    OUTPUT=$(python3 "$SCRIPT_DIR/session_stats.py" 2>/dev/null || echo "(no data)")
    ok "脚本测试通过 → $OUTPUT"
else
    warn "脚本可执行但部分字段无数据（正常，看板/GPU 可选）"
fi

# ── 4. 打 gateway 补丁 ──
if [ -d "$HERMES_AGENT_DIR/.git" ]; then
    PATCH_FILE="./patches/runtime-footer.patch"
    if [ -f "$PATCH_FILE" ]; then
        cd "$HERMES_AGENT_DIR"
        if git apply --check "$OLDPWD/$PATCH_FILE" 2>/dev/null; then
            git apply "$OLDPWD/$PATCH_FILE"
            ok "gateway 补丁已应用"
            cd - > /dev/null
        else
            # 检查是否已打过
            if grep -q "session_start" gateway/runtime_footer.py 2>/dev/null; then
                warn "补丁已应用，跳过"
            else
                warn "补丁无法直接应用（版本可能不同），请手动修改："
                warn "  $HERMES_AGENT_DIR/gateway/runtime_footer.py"
                warn "  $HERMES_AGENT_DIR/gateway/run.py"
                warn "参考: https://github.com/fengr001/hermes-runtime-footer"
            fi
            cd - > /dev/null
        fi
    else
        warn "补丁文件未找到 ($PATCH_FILE)，跳过 gateway 修改"
        warn "仅使用回退模式（⏰ 可能不精确但 📋🎮🤖 正常）"
    fi
else
    warn "hermes-agent 不是 git 仓库，跳过自动补丁"
    warn "请手动修改 gateway 代码（见 README.md）"
fi

# ── 5. 修改 config.yaml ──
CONFIG_FILE="$HERMES_HOME/config.yaml"
if [ -f "$CONFIG_FILE" ]; then
    # 检测是否已启用
    if grep -q "runtime_footer:" "$CONFIG_FILE" && grep -A2 "runtime_footer:" "$CONFIG_FILE" | grep "enabled: true" > /dev/null; then
        ok "runtime_footer 已在 config.yaml 中启用"
    else
        # 在 display: 段下追加（若无则创建）
        if grep -q "^display:" "$CONFIG_FILE"; then
            # 已有 display 段，追加到段内
            sed -i '/^display:/a\  runtime_footer:\n    enabled: true' "$CONFIG_FILE"
        else
            # 无 display 段，追加到文件末尾
            cat >> "$CONFIG_FILE" << 'EOF'

display:
  runtime_footer:
    enabled: true
EOF
        fi
        ok "config.yaml 已启用 runtime_footer"
    fi
else
    err "config.yaml 未找到: $CONFIG_FILE"
    exit 1
fi

# ── 6. 重启 gateway ──
echo ""
info "是否重启 gateway 使配置生效？(y/N)"
read -r RESTART
if [ "$RESTART" = "y" ] || [ "$RESTART" = "Y" ]; then
    if command -v hermes &>/dev/null; then
        hermes gateway restart 2>/dev/null || hermes restart 2>/dev/null || true
        ok "gateway 已重启"
    else
        warn "hermes 命令未找到，请手动重启 gateway"
    fi
else
    info "请手动重启 gateway 使配置生效"
fi

# ── 完成 ──
echo ""
ok "hermes-runtime-footer 安装完成！"
echo ""
echo -e "  下一条回复末尾将显示类似："
echo -e "  ${CYAN}⏰10:30 | 📋空闲 | 🎮42% | 🤖CS4${NC}"
echo ""
echo -e "  如需移除，运行:  ${YELLOW}rm -f $SCRIPT_DIR/session_stats.py${NC}"
echo -e "  在 config.yaml 中把 enabled 改回 false"
