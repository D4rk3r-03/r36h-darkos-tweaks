#!/bin/bash
# Applies and undoes the tweaks on a stock-like config and checks the result. No handheld needed.
set -eu
cd "$(dirname "$0")/.."
tmp=$(mktemp -d); trap 'rm -rf "$tmp"' EXIT
for d in retroarch retroarch32; do mkdir -p "$tmp/.config/$d"; cp tests/stock.cfg "$tmp/.config/$d/retroarch.cfg"; done
run() { TWEAKS_ROOT="$tmp" TWEAKS_SCREEN=/dev/null bash "R36H Tweaks.sh" > /dev/null; }
value() { sed -n "s/^$2 = \"\(.*\)\"/\1/p" "$tmp/.config/$1/retroarch.cfg"; }
fail() { echo "FAIL: $*"; exit 1; }

run
for d in retroarch retroarch32; do
    [ "$(value $d input_menu_toggle_btn)" = 2 ] || fail "$d menu"
    [ "$(value $d input_state_slot_increase_btn)" = 9 ] || fail "$d slot"
    [ "$(value $d audio_latency)" = 32 ] || fail "$d latency"
    cmp -s tests/stock.cfg "$tmp/.config/$d/retroarch.cfg.before-r36h-tweaks" || fail "$d backup"
done
[ -e "$tmp/.config/retroarch/.r36h-tweaks" ] || fail "mark"

run
for d in retroarch retroarch32; do
    cmp -s tests/stock.cfg "$tmp/.config/$d/retroarch.cfg" || fail "$d not back to stock"
done
[ ! -e "$tmp/.config/retroarch/.r36h-tweaks" ] || fail "mark left behind"

echo "ok: apply and undo"
