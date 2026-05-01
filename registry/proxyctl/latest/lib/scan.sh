#!/usr/bin/env bash

HOST="127.0.0.1"
TIMEOUT=1

PORTS=(7890 7891 1080 1081 1086 15235 6152 7000 5000 63908)

OUT_FILE="$(dirname "$0")/../state/results.json"
TMP_FILE="/tmp/proxyctl.tmp"

mkdir -p "$(dirname "$OUT_FILE")"
> "$TMP_FILE"

echo "🔍 scanning..."

scan_port() {
    port=$1

    nc -z -w $TIMEOUT $HOST $port >/dev/null 2>&1 || return

    if echo -ne "\x05\x01\x00" | nc -w $TIMEOUT $HOST $port 2>/dev/null | grep -q $'\x05'; then
        echo "socks5:$port:unknown" >> "$TMP_FILE"
        return
    fi

    if echo -e "GET / HTTP/1.1\r\nHost: test\r\n\r\n" \
        | nc -w $TIMEOUT $HOST $port 2>/dev/null | grep -q "HTTP"; then
        echo "http:$port:unknown" >> "$TMP_FILE"
        return
    fi
}

export -f scan_port

for p in "${PORTS[@]}"; do
    scan_port $p
done

echo "[" > "$OUT_FILE"

i=0
while IFS=: read proto port name; do

    [ $i -gt 0 ] && echo "," >> "$OUT_FILE"

    echo "  {\"index\":$i,\"proto\":\"$proto\",\"port\":$port,\"name\":\"$name\"}" >> "$OUT_FILE"
    i=$((i+1))

done < "$TMP_FILE"

echo "]" >> "$OUT_FILE"

echo "✅ scan done"
