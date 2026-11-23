# R36H dArkOS Tweaks

[![check](https://github.com/D4rk3r-03/r36h-darkos-tweaks/actions/workflows/check.yml/badge.svg)](https://github.com/D4rk3r-03/r36h-darkos-tweaks/actions/workflows/check.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](./LICENSE)

🇬🇧 [English](./README.md)

**Tres ajustes medidos para dArkOSRE en la consola R36H.**

Tres cambios para la **R36H** con **dArkOSRE-R36**. No hay que instalar nada, se deshacen en segundos y cada uno
viene con lo que se midió en la consola.

| Ajuste | Qué mejora | Medido |
|---|---|---|
| 1. Gobernador `ondemand` en sistemas livianos | Batería | GBC −12,5 % de consumo, PSX −9 %, sin tirones |
| 2. Menú de RetroArch en SELECT + X | Se puede abrir el menú (hoy no se puede) | — |
| 3. Retraso de audio de 128 a 32 | El sonido llega antes | De 150 a 84 ms entre el botón y el sonido (−44 %) |

Probado en una R36H con placa «HL-R36H-V21 2024-11-18», dArkOSRE 03082026 (Debian 13, kernel 4.4.189).

---

## 1. Gobernador `ondemand`: más batería sin perder fluidez

De fábrica, cada juego corre con el procesador, la GPU y la memoria **al máximo todo el tiempo** («auto» equivale a
`performance`). Los sistemas livianos no lo necesitan. Con `ondemand` suben solo cuando hace falta.

**Cómo:** START → **EMULATOR SETTINGS** (en español: «AJUSTES POR EMULADOR») → elige el sistema →
**DEFAULT EMULATOR GOVERNOR** («GOBERNADOR DEL EMULADOR POR DEFECTO») → `ondemand`.

Se guarda por sistema, así que se puede dejar `performance` en los que lo necesiten.

**Lo que se midió** (10 minutos por prueba, brillo fijo, descargando, mediana de la corriente de la batería):

| Juego | De fábrica (`performance`) | `ondemand` | Diferencia |
|---|---|---|---|
| Pokémon Prism (GBC) | 535 mA | 468 mA | **−12,5 %**, casi 1 hora más de batería |
| Crash Bandicoot 2 (PSX) | 2,12 W | 1,93 W | **−9 %** |

Los dos se jugaron sin tirones ni cortes de audio.

**Recomendación:** `ondemand` en los sistemas de 8 y 16 bits (GB, GBC, GBA, NES, SNES, Mega Drive…) y en PSX.
En los más exigentes (N64, PSP, Dreamcast), prueba tú: si notas tirones, vuelve a `performance`.

**Deshacer:** el mismo menú, en «auto» o `performance`.

---

## 2. Menú de RetroArch en SELECT + X

En la R36H **no se puede abrir el menú de RetroArch**. dArkOS lo tiene asignado al botón FN, y la R36H no tiene
ese botón. Sin menú no hay forma de cambiar ajustes, núcleos ni trucos dentro del juego.

El arreglo pone el menú en **SELECT + X**, como en ArkOS. Como SELECT + X subía la ranura de guardado, esa función
pasa a **SELECT + abajo**.

| Combinación | Antes | Después |
|---|---|---|
| SELECT + X | Ranura de guardado + | **Menú de RetroArch** |
| SELECT + abajo | — | Ranura de guardado + |
| SELECT + Y | Ranura de guardado − | (igual) |

## 3. Audio con menos retraso

dArkOS trae `audio_latency` en 128 ms. Con 32 ms el sonido llega casi el doble de rápido:

| `audio_latency` | Retraso entre botón y sonido (mediana) |
|---|---|
| 128 (de fábrica) | 150 ms |
| 64 | 116 ms |
| **32** | **84 ms** |

**Cómo se midió:** el micrófono de una laptop grabó el golpe en el botón A y el pitido de la *240p Test Suite*
(prueba de sonido de Game Boy, 1000 Hz). Un script mide la distancia entre los dos sonidos.

Se jugaron Pokémon Prism (GBC) y Crash Bandicoot 2 (PSX) con 32 ms, sin chasquidos ni cortes. Si en algún juego
oyes chasquidos, prueba con 64.

---

## Cómo aplicar los ajustes 2 y 3

Los dos van en el archivo de configuración de RetroArch, que en dArkOS son dos: el de 64 bits y el de 32 bits.

### Opción A: desde Ports, sin computador

1. Copia [`R36H Tweaks.sh`](./R36H%20Tweaks.sh) a la carpeta `ports` de la partición **EASYROMS** de la SD.
2. En la consola, reinicia el menú (o la consola) para que aparezca en **Ports**.
3. Ábrelo. Dice «Ajustes R36H aplicados» y vuelve al menú.

Para deshacerlo, ábrelo otra vez: devuelve los tres valores de fábrica. La primera vez guarda además una copia de cada
archivo (`retroarch.cfg.before-r36h-tweaks`).

### Opción B: por SSH

Activa SSH con **Opciones → Enable Remote Services**, entra como `ark` y pega esto. Guarda una copia de cada archivo antes de cambiarlo:

```bash
for f in ~/.config/retroarch/retroarch.cfg ~/.config/retroarch32/retroarch.cfg; do
  cp -n "$f" "$f.before-r36h-tweaks"
  sed -i -e 's/^input_menu_toggle_btn = .*/input_menu_toggle_btn = "2"/' \
         -e 's/^input_state_slot_increase_btn = .*/input_state_slot_increase_btn = "9"/' \
         -e 's/^audio_latency = .*/audio_latency = "32"/' "$f"
done
```

Para deshacerlo, cambia `"2"`, `"9"` y `"32"` por los valores de fábrica: `"16"`, `"2"` y `"128"`.

**Notas:**
- dArkOS trae `config_save_on_exit = "false"`, así que RetroArch no pisa estos cambios al cerrar un juego.
- Los números de botón corresponden al control de la R36H: 2 = X, 9 = abajo, 16 = FN.

---

## Un dato más: PlayStation en analógico

En PSX el control arranca en modo digital. **L1 + R1 + SELECT** lo cambia a analógico, por ejemplo para los juegos
que exigen DualShock.

---

## Desarrollo

`tests/run.sh` aplica y deshace los ajustes sobre una configuración como la de fábrica (`tests/stock.cfg`); el CI
corre además `shellcheck`.

## Créditos y licencia

D4rk3r-03 · Claudio. [MIT](./LICENSE).

Medido y probado en la consola de quien escribe. Si algo no te funciona igual, cuéntalo en un
[issue](https://github.com/D4rk3r-03/r36h-darkos-tweaks/issues).
