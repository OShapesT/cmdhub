#!/usr/bin/env bash

echo "🔍 checking dependencies..."

check_cmd() {
    cmd=$1
    pkg=$2

    if ! command -v $cmd >/dev/null 2>&1; then
        echo "❌ missing: $cmd"

        echo "👉 install with:"
        echo "   brew install $pkg"
        return 1
    else
        echo "✔ $cmd OK"
        return 0
    fi
}

# =========================
# required deps
# =========================
check_cmd curl curl
check_cmd jq jq
check_cmd bc bc
check_cmd nc netcat

echo ""
echo "✅ dependency check complete"
