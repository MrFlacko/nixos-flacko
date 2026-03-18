#!/usr/bin/env bash

set -euo pipefail

for cmd in yad nordvpn notify-send; do
    command -v "$cmd" >/dev/null 2>&1 || {
        echo "Missing required command: $cmd"
        exit 1
    }
done

APP_TITLE="NordVPN Quick Connect"
WIDTH=420
HEIGHT=260

run_cmd() {
    local msg="$1"
    shift
    if "$@"; then
        notify-send "$APP_TITLE" "$msg"
    else
        notify-send "$APP_TITLE" "Command failed: $*"
    fi
}

connect_specify() {
    local target
    target="$(yad \
        --entry \
        --title="$APP_TITLE" \
        --window-icon="network-vpn" \
        --center \
        --width=380 \
        --text="Enter a country, city, server, or group:" \
        --entry-text="Australia")" || return 0

    [[ -z "${target// }" ]] && return 0

    run_cmd "Connecting to $target" nordvpn connect "$target"
}

main_window() {
    while true; do
        local choice
        choice="$(
            yad \
                --list \
                --title="$APP_TITLE" \
                --window-icon="network-vpn" \
                --center \
                --width="$WIDTH" \
                --height="$HEIGHT" \
                --no-headers \
                --hide-column=1 \
                --column="id":NUM \
                --column="Action":TEXT \
                1 "Connect Australia" \
                2 "Connect Philippines" \
                3 "Connect Specify" \
                4 "Disconnect" \
                --button="Connect Australia:101" \
                --button="Connect Philippines:102" \
                --button="Connect Specify:103" \
                --button="Disconnect:104" \
                --button="Exit:0"
        )"
        rc=$?

        case "$rc" in
            0) exit 0 ;;
            101) run_cmd "Connecting to Australia" nordvpn connect Australia ;;
            102) run_cmd "Connecting to Philippines" nordvpn connect Philippines ;;
            103) connect_specify ;;
            104) run_cmd "Disconnecting NordVPN" nordvpn disconnect ;;
            *) exit 0 ;;
        esac
    done
}

main_window