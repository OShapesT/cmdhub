#!/usr/bin/env bash

FILE="$(dirname "$0")/../state/results.json"

mode=$1

case "$mode" in
    json)
        i=0
        echo "["
        first=1

        while read line; do
            proto=$(echo $line | grep -o '"proto":"[^"]*' | cut -d'"' -f4)
            port=$(echo $line | grep -o '"port":[0-9]*' | cut -d: -f2)

            if [ $first -eq 1 ]; then
                first=0
            else
                echo ","
            fi

            echo "  {\"index\":$i,\"proto\":\"$proto\",\"port\":$port}"
            i=$((i+1))
        done < "$FILE"

        echo "]"
        ;;
    md)
        echo "| idx | proto | port |"
        echo "|----|------|------|"

        i=0
        while read line; do
            proto=$(echo $line | grep -o '"proto":"[^"]*' | cut -d'"' -f4)
            port=$(echo $line | grep -o '"port":[0-9]*' | cut -d: -f2)
            echo "| $i | $proto | $port"
            i=$((i+1))
        done < "$FILE"
        ;;
    *)
        cat "$FILE"
        ;;
esac
