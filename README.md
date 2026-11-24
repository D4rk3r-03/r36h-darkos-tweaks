# R36H dArkOS Tweaks

[![check](https://github.com/D4rk3r-03/r36h-darkos-tweaks/actions/workflows/check.yml/badge.svg)](https://github.com/D4rk3r-03/r36h-darkos-tweaks/actions/workflows/check.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)

🇪🇸 [Español](./README.es.md)

**Three measured tweaks for dArkOSRE on the R36H handheld.**

Three changes for the **R36H** running **dArkOSRE-R36**. Nothing to install, each one can be undone in seconds, and
each comes with what was measured on the handheld.

| Tweak | Improves | Measured |
|---|---|---|
| 1. `ondemand` governor for light systems | Battery | GBC −12.5% power draw, PSX −9%, no stutter |
| 2. RetroArch menu on SELECT + X | You can open the menu (today you can't) | — |
| 3. Audio latency from 128 to 32 | Sound arrives sooner | 150 → 84 ms from button press to sound (−44%) |

Tested on an R36H with board "HL-R36H-V21 2024-11-18", dArkOSRE 03082026 (Debian 13, kernel 4.4.189).

---

## 1. `ondemand` governor: more battery, same smoothness

Out of the box every game runs with the CPU, GPU and memory **at full speed the whole time** ("auto" means
`performance`). Light systems don't need it. With `ondemand` they only ramp up when needed.

**How:** START → **EMULATOR SETTINGS** → pick the system → **DEFAULT EMULATOR GOVERNOR** → `ondemand`.

It is saved per system, so you can keep `performance` where you need it.

**What was measured** (10 minutes per run, fixed brightness, on battery, median battery current):

| Game | Stock (`performance`) | `ondemand` | Difference |
|---|---|---|---|
| Pokémon Prism (GBC) | 535 mA | 468 mA | **−12.5%**, almost 1 more hour of play |
| Crash Bandicoot 2 (PSX) | 2.12 W | 1.93 W | **−9%** |

Both played with no stutter and no audio dropouts.

**Recommendation:** `ondemand` for 8- and 16-bit systems (GB, GBC, GBA, NES, SNES, Mega Drive…) and PSX. For the
heavier ones (N64, PSP, Dreamcast), try it yourself: if you notice stutter, go back to `performance`.

**Undo:** same menu, set it to "auto" or `performance`.

---

## 2. RetroArch menu on SELECT + X

On the R36H **the RetroArch menu can't be opened**. dArkOS maps it to the FN button, and the R36H has no FN
button. Without the menu there is no way to change settings, cores or cheats in-game.

The fix puts the menu on **SELECT + X**, like ArkOS. SELECT + X used to increase the save slot, so that moves to
**SELECT + Down**, which had no function before.

| Combo | Before | After |
|---|---|---|
| SELECT + X | Save slot + | **RetroArch menu** |
| SELECT + Down | — | Save slot + |
| SELECT + Y | Save slot − | (unchanged) |

## 3. Lower audio latency

dArkOS ships `audio_latency` at 128 ms. At 32 ms sound arrives almost twice as fast:

| `audio_latency` | Button-to-sound delay (median) |
|---|---|
| 128 (stock) | 150 ms |
| 64 | 116 ms |
| **32** | **84 ms** |

**How it was measured:** a laptop microphone recorded the tap on the A button and the beep from the *240p Test
Suite* (Game Boy sound test, 1000 Hz). A script measures the gap between the two sounds.

Pokémon Prism (GBC) and Crash Bandicoot 2 (PSX) were played at 32 ms with no crackling or dropouts. If a game
crackles for you, try 64.

---

## Applying tweaks 2 and 3

Both live in RetroArch's config file. dArkOS has two of them: one for 64-bit and one for 32-bit cores.

### Option A: from Ports, no computer needed

1. Copy [`R36H Tweaks.sh`](./R36H%20Tweaks.sh) to the `ports` folder on the SD card's **EASYROMS** partition.
2. Restart EmulationStation (or the handheld) so it shows up under **Ports**.
3. Run it. It says "R36H Tweaks applied" and returns to the menu.

To undo, run it again: it puts the three stock values back. The first run also keeps a copy of each file
(`retroarch.cfg.before-r36h-tweaks`).

### Option B: over SSH

Turn on SSH with **Options → Enable Remote Services**, log in as `ark` and paste this. It keeps a copy of each file before changing it:

```bash
for f in ~/.config/retroarch/retroarch.cfg ~/.config/retroarch32/retroarch.cfg; do
  cp -n "$f" "$f.before-r36h-tweaks"
  sed -i -e 's/^input_menu_toggle_btn = .*/input_menu_toggle_btn = "2"/' \
         -e 's/^input_state_slot_increase_btn = .*/input_state_slot_increase_btn = "9"/' \
         -e 's/^audio_latency = .*/audio_latency = "32"/' "$f"
done
```

To undo, replace `"2"`, `"9"` and `"32"` with the stock values: `"16"`, `"2"` and `"128"`.

**Notes:**
- dArkOS ships with `config_save_on_exit = "false"`, so RetroArch won't overwrite these changes when a game closes.
- Button numbers match the R36H controller: 2 = X, 9 = Down, 16 = FN.

---

## One more thing: PlayStation in analog mode

On PSX the controller starts in digital mode. **L1 + R1 + SELECT** switches it to analog, for games that require
a DualShock.

---

## Development

`tests/run.sh` applies and undoes the tweaks on a stock-like config (`tests/stock.cfg`); CI also runs
`shellcheck`.

## Credits and license

D4rk3r-03 · Claudio 🐾. [MIT](./LICENSE).

Measured and tested on the author's own handheld. If something behaves differently for you, please open an
[issue](https://github.com/D4rk3r-03/r36h-darkos-tweaks/issues).
