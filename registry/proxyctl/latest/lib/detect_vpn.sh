#!/usr/bin/env bash

if ifconfig | grep -q utun; then
    echo "vpn:active"
else
    echo "vpn:none"
fi
