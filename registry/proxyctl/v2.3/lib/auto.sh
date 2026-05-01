#!/usr/bin/env bash

BASE_DIR="$(dirname "$0")"
RESULT_FILE="$BASE_DIR/../state/results.json"

echo "🚀 proxyctl v2.3 FINAL PATCH"

# =========================
# 1. VPN 修复（稳定版）
# =========================
VPN_NAME=""

if ps aux | grep -i "clash" | grep -v grep >/dev/null; then
    VPN_NAME="ClashX"
elif ps aux | grep -i "veee" | grep -v grep >/dev/null; then
    VPN_NAME="Veee+"
elif ps aux | grep -i "warp" | grep -v grep >/dev/null; then
    VPN_NAME="Warp"
elif ifconfig | grep -q utun; then
    VPN_NAME="macOS VPN Tunnel"
else
    VPN_NAME="No VPN"
fi

echo "VPN: $VPN_NAME"

# =========================
# 2. scan fallback
# =========================
if [ ! -s "$RESULT_FILE" ]; then
    echo "🔍 scanning..."
    bash "$BASE_DIR/scan.sh"
fi

# =========================
# 3. 初始化（关键）
# =========================
best_proto=""
best_port=""
best_score=999
valid_found=0

# =========================
# 4. 关键修复：避免 pipe 子 shell
# =========================
while read item; do

    proto=$(echo "$item" | jq -r '.proto')
    port=$(echo "$item" | jq -r '.port')

    if [ -z "$proto" ] || [ -z "$port" ]; then
        continue
    fi

    latency=$(curl -x http://127.0.0.1:$port https://github.com \
        -o /dev/null -s -w "%{time_total}" --max-time 2)

    if [ -z "$latency" ]; then
        latency=999
    fi

    penalty=0
    if [ "$proto" != "socks5" ]; then
        penalty=0.05
    fi

    # ===== score 修复 =====
    score=$(echo "scale=6; $latency + $penalty" | bc)

    printf -v score "%.6f" "$score"

    echo "test $proto:$port => score:$score"

    valid_found=1

    cmp=$(echo "$score < $best_score" | bc)

    if [ "$cmp" -eq 1 ]; then
        best_score=$score
        best_proto=$proto
        best_port=$port
    fi

done < <(jq -c '.[]' "$RESULT_FILE")

# =========================
# 5. fallback 修复
# =========================
if [ "$valid_found" -eq 0 ] || [ -z "$best_port" ]; then
    echo "⚠️ fallback direct mode"
    unset http_proxy
    unset https_proxy
    unset ALL_PROXY
    exit 0
fi

# =========================
# 6. apply
# =========================
echo ""
echo "🏆 BEST: $best_proto:$best_port ($best_score)"

if [ "$best_proto" = "socks5" ]; then
    export ALL_PROXY="socks5://127.0.0.1:$best_port"
else
    export http_proxy="http://127.0.0.1:$best_port"
    export https_proxy="http://127.0.0.1:$best_port"
fi

echo "✔ applied"
env | grep -i proxy

