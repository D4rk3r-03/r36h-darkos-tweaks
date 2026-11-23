#!/bin/bash
# R36H Tweaks for dArkOSRE-R36: RetroArch menu on SELECT+X and lower audio latency (32 ms).
# Copy to EASYROMS/ports/ and run it from Ports. Running it again undoes it (back to the stock values).
# The first run keeps a copy of each file as retroarch.cfg.before-r36h-tweaks.
# https://github.com/D4rk3r-03/r36h-darkos-tweaks · MIT
SCREEN=${TWEAKS_SCREEN:-/dev/tty1}
say() { printf '%s\n' "$*" | tee -a "$SCREEN" 2>/dev/null; }
printf '\033c' > "$SCREEN" 2>/dev/null

ROOT=${TWEAKS_ROOT:-/home/ark}     # TWEAKS_ROOT: only for testing off the handheld
CFGS=("$ROOT/.config/retroarch/retroarch.cfg" "$ROOT/.config/retroarch32/retroarch.cfg")
MARK=$ROOT/.config/retroarch/.r36h-tweaks

set_key() {   # file key value
    if grep -q "^$2 = " "$1"; then sed -i "s|^$2 = .*|$2 = \"$3\"|" "$1"; else printf '%s = "%s"\n' "$2" "$3" >> "$1"; fi
}

if [ -e "$MARK" ]; then
    for f in "${CFGS[@]}"; do              # stock values; anything else changed since is left alone
        [ -f "$f" ] || continue
        set_key "$f" input_menu_toggle_btn 16
        set_key "$f" input_state_slot_increase_btn 2
        set_key "$f" audio_latency 128
        say "Restored / Restaurado: $f"
    done
    rm -f "$MARK"
    say "R36H Tweaks undone: stock values are back."
    say "Ajustes R36H deshechos: valores de fábrica."
else
    for f in "${CFGS[@]}"; do
        [ -f "$f" ] || continue
        [ -f "$f.before-r36h-tweaks" ] || cp -p "$f" "$f.before-r36h-tweaks"
        set_key "$f" input_menu_toggle_btn 2            # SELECT+X opens the menu (stock: 16, the FN button the R36H lacks)
        set_key "$f" input_state_slot_increase_btn 9    # save slot + moves to SELECT+Down (it was SELECT+X)
        set_key "$f" audio_latency 32                   # 128 -> 32 ms: 150 -> 84 ms from button to sound
        say "Done / Listo: $f"
    done
    touch "$MARK"
    say "R36H Tweaks applied. Run it again to undo."
    say "Ajustes R36H aplicados. Ábrelo otra vez para deshacerlos."
fi
sync
sleep 4
printf '\033c' > "$SCREEN" 2>/dev/null
