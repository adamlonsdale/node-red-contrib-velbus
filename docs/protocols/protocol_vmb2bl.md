# VMB2BL Two-Channel Blind Module Protocol (Edition 1, Rev 4)

## Module Overview
- Hex-switch addressed dual blind relay with local up/down buttons and LED feedback (`TWO_CHANNEL_BLIND_MODULE_TYPE = 0x09`, page 5).
- Supports remote LED synchronisation, per-channel naming, and optional local button name frames for later firmware builds (pages 1, 6–7).
- Operates on Velbus CAN with high-priority (`SID10..9 = 00`) frames for push-button status and low-priority (`11`) frames for telemetry and configuration (pages 2–4).

## Message Formats
- 24-bit timing values are transmitted high/mid/low byte; `0x000000` defers to DIP-switch timeout, `0xFFFFFF` keeps outputs latched (pages 7–8).
- LED control payloads reuse the standard Velbus schema: continuous-on overrides blink, combined slow/fast flags yield the documented very-fast blink (pages 2–3).

## Transmitted Messages
- **Local Status (`0x00`)**: reports button presses, releases, long press events, and relay transitions (build ≥0815) with masks per channel (page 2).
- **Blind Status (`0xEC`)**: includes channel mask, timeout setting, current movement state, LED states, and active runtime counter (pages 4–5).
- **LED Control (`0xF4–0xF9`)**: update, clear, set, fast blink, and very-fast blink for associated push-button modules (pages 2–3).
- **Memory Echo**: `0xFE` word reads and `0xCC` 4-byte blocks (build ≥0735) (pages 3–4).
- **Diagnostics**: `0xDA` bus error counters, `0xFF` module type (with DIP timeout setting and build date) (pages 3–5).
- **Naming**: blind name segments via `0xF0/0xF1/0xF2`; build ≥0815 also exposes local button name segments with identifier bits (pages 5–7).

## Accepted Commands
- **Motion Control**: `0x04` off, `0x05` up, `0x06` down with optional 24-bit timeout; time `0` uses DIP setting, `0xFFFFFF` keeps the relay latched (pages 7–8).
- **Status & Discovery**: accepts push-button status (`0x00`), blind status request (`0xFA`), module type RTR, and LED clear commands for linked panels (pages 7–8).
- **Naming & Metadata**: `0xEF` requests blind or button names; replies depend on firmware build (pages 8–9).
- **Memory Services**: read/write word (`0xFD/0xFC`), read/write block (`0xC9/0xCA`), dump (`0xCB`); higher firmware variants extend the accessible high address from `0x00` to `0x01` (pages 8–9).
- **Diagnostics**: `0xD9` requests bus error counters (build ≥0648) (page 10).

## Channel Naming & LED Behaviour
- Each blind and optional local button exposes a 16-character ASCII name split across three frames with `0xFF` padding (pages 5–7).
- LED control frames apply to remote push-button modules; continuous-on supersedes blinking, and overlapping blink flags trigger very-fast blink (pages 2–3).

## Program & Timing Controls
- Timeout bytes in motion commands enforce automatic stop; when omitted (`0`), the module applies the DIP-configured travel time. Manual override by sending another motion command or off (`0x04`) (pages 7–8).
- Runtime counter in blind status (`0xEC`) returns elapsed seconds, enabling host-side watchdogs (page 4).

## Memory Map
- **Build ≤0802**: sections map push-button addresses and bitmasks for each blind (up/immediate up/down/immediate down) plus 16-character blind names (`0x0000–0x00FF`) (page 10–11).
- **Build 0805/0806/0811/0812**: adds combined up/down button slots and reorganises masks into 10/11-bit sections while retaining name storage (page 11–12).
- **Build ≥0815**: expands to 20-bit mask variants and introduces local button name storage (`0x00D0` onward) alongside blind names (page 12–13).
- Unused entries remain `0xFF`; consult firmware-specific map before automated writes (pages 10–13).

## Conversion Notes
- OCR artefacts such as `COMMAND _FAST_ BLINKING _LED` were normalised; verify opcode casing when scripting (pages 2–3).
- Memory-table scans are tabular images; refer to the PDF for exhaustive mask columns before performing indexed updates (pages 10–13).
