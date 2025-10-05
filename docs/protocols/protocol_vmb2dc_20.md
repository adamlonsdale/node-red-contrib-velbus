# VMB2DC-20 Two-Channel Dimmer Protocol (Edition 1)

## Module Overview
- Dual-channel dimmer with integrated real-time clock, scene engine, and DALI/Velbus gateway functions (`module type 0x24`, page 3).
- Supports CAN FD memory transfers, channel programs, per-channel device settings (including RGBW values), and comprehensive override logic (pages 2–4, 17–23).
- Uses high-priority frames (`SID10..9 = 00`) for immediate dimming actions, while configuration, telemetry, and scheduling travel on low-priority frames (`11`) (pages 2–3, 16–18).

## Message Formats
- Power-up broadcast `0xAB` includes the module address; clock/status frames follow `0xD7/0xD8/0xB7/0xAF` conventions shared across Velbus devices (page 2).
- Timers use 24-bit big-endian seconds; `0x000000` skips scheduling, `0xFFFFFF` enforces a permanent override (pages 17–19).
- CAN FD block operations (`0xCC` read, `0xCA` write) accept lengths 5–60 bytes and pad unused bytes with `0x55`; address space extends up to `0x07FF` (pages 4–5).

## Transmitted Messages
- **Power & Timekeeping**: `0xAB` power-up, `0xD7` clock request, `0xD8` clock status, `0xB7` date status, and `0xAF` daylight-saving status (pages 2–3).
- **Identification & Diagnostics**: `0xFF` module type with serial, memory-map version, build date, and properties; `0xDA` bus error counters (page 3).
- **Memory Echo**: `0xFE` word reads and `0xCC` block reads (4 or 5–60 bytes) across `0x0000–0x07FC` (pages 3–4).
- **Naming**: channel names via `0xF0/0xF1/0xF2` with ASCII characters and `0xFF` padding (pages 4–5).
- **Runtime Feedback**:
  - `0x00` channel status (pressed/released flags for channels 1–2) (page 5).
  - `0xEE` dimmer status including channel outputs, inhibit/forced/locked state, program enable flags, and error bits (pages 5–6).

## Accepted Commands
- **Core Dimming**: set dim value (`0x07`, supports fade mode), restore last value (`0x11`), start timer (`0x08`), stop dimming (`0x10`), and jump to scene (`0x1D`) (pages 17–18).
- **Overrides**: forced off/on (`0x12/0x14`), cancel forced states (`0x13/0x15`), inhibit/cancel inhibit (`0x16/0x17`), lock/unlock (`0x1A/0x1B`), each with optional 24-bit delay and broadcast channel `0xFF` (pages 17–19).
- **Scheduling & Programs**: enable/disable channel program (`0xB2/0xB1`), select program (`0xB3`), read/write program steps (`0xC0/0xC2`), and request program step info (`0xC1` referenced in summary) (pages 21–23).
- **Device Settings**: write granular channel settings via `0xE4` (scene levels, RGBW, fade profiles) and fetch stored or live device settings with `0xE7` (pages 19–21).
- **Provisioning & Diagnostics**: change module address/serial, read/write memory (`0xFD/0xFC`, `0xC9/0xCA`, `0xCB`), request bus-error counters (`0xD9`), module status (`0xFA`), channel names (`0xEF`), and clear linked LED indicators (`0xF5`) (pages 13–17, 21).
- **Clock Maintenance**: set RTC, date, and daylight-saving flag; respond to `0xD7` requests from other controllers (pages 2–3, 10–11).

## Channel Naming & LED Behaviour
- Channel names use three frames of ASCII (16 chars) with `0xFF` placeholders; the same structure supports bulk queries via `0xEF` (page 5).
- LED notifications rely on linked push-button modules; clearing LEDs uses standard `0xF5` semantics (page 15).

## Program & Scheduling Controls
- Channel programs support up to 72 steps grouped into three sets; read/write commands accept channel number and search direction to locate the next matching step (page 22).
- Scene data (levels, RGBW values, fade profiles) is configurable through `COMMAND_SET_TEMP (0xE4)` indices, enabling granular transition control (pages 19–20).
- Program enable/disable commands honour delays, letting the dimmer temporarily suspend automation before reverting (page 21).

## Memory Map
- Address space extends to `0x07FF`, holding channel states, automation flags, scene definitions, device settings, and gateway metadata; always reference the `memory map version` returned by `COMMAND_MODULE_TYPE` before scripting writes (pages 3–4, 19–23).
- CAN FD operations permit batched updates; terminate with a final write to the highest address updated to satisfy firmware expectations (pages 4–5, 16).
- Reserved locations mirror live status (forced/inhibit/program flags); avoid overwriting these without explicit intent (pages 16–21).

## Conversion Notes
- OCR glitches (e.g. duplicate headings, minor typos) were normalised to known Velbus command names; verify unusual indices (device settings 0–28, fade tables) against the PDF when implementing tooling (pages 19–21).
- Memory tables appear graphically in the scan; consult the original document for precise offsets, especially when scripting CAN FD block writes (pages 19–23).
