#!/usr/bin/env bash

HOST="127.0.0.1"

test_proxy() {
    proto=$1
    port=$2

    start=$(python3 -c 'import time; print(time.time())')

    if [ "$proto" = "socks5" ]; then
        curl -x socks5://$HOST:$port https://github.com -I -s --max-time 2 >/dev/null
    else
        curl -x http://$HOST:$port https://github.com -I -s --max-time 2 >/dev/null
    fi

    if [ $? -ne 0 ]; then
        echo "999"
        return
    fi

    end=$(python3 -c 'import time; print(time.time())')

    echo "$end - $start" | bc
}
