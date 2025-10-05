# VMB2PBN Push-Button Interface Protocol (Edition 7)

## Module Overview
- Eight-channel push-button node with LED feedback and automation integration (`module type 0x18`, page 4).
- Publishes per-channel state, module configuration, and timekeeping data while providing remote control over locks, programs, and alarm clocks (pages 3–4).
- Uses Velbus CAN frames with `SID10..9 = 00` for urgent channel events and `11` for configuration and telemetry (pages 3–4).

## Message Formats
- Real-time information mirrors the common Velbus layout: `COMMAND_REALTIME_CLOCK_STATUS (0xD8)` for day/hour/minute and `COMMAND_DATE_STATUS (0xB7)` for day/month/year (page 3).
- Channel status frames flag just-pressed, just-released, and long-press events; module status aggregates enable/invert/lock/program bits for channels 1–8 (pages 3–4).
- Memory operations cover `0x0000–0x03FF` for single-byte reads (`0xFE`) and `0x0000–0x03FC` for 4-byte blocks (`0xCC`) (pages 4–5).

## Transmitted Messages
- **Clock & Calendar**: `0xD7` request, `0xD8` status, `0xB7` date, and (build ≥1235) `0xAF` daylight-saving flag (page 3).
- **Channel Status (`0x00`)**: high-priority report of channels just pressed/released with long-press indicator (page 3).
- **Module Status (`0xED`)**: publishes channel enable/invert/lock flags, program disable bits, and current alarm/program selection (page 4).
- **Diagnostics**: `0xDA` bus error counters; `0xFF` module type with serial, memory-map version, and build date (page 4).
- **Memory & Naming**: `0xFE`/`0xCC` for memory reads, and `0xF0/0xF1/0xF2` for 16-character channel names (pages 4–5).

## Accepted Commands
- **Channel LEDs**: `0xF4` update mask, `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink, `0xF9` very fast blink; linked push-button LEDs can also be driven via broadcast variants (pages 1–2).
- **State & Discovery**: linked push-button status (`0x00`), module type RTR, module status request (`0xFA`), channel name request (`0xEF`), and LED clear from external modules (pages 1–2, 8).
- **Memory Services**: read/write word (`0xFD/0xFC`), read/write block (`0xC9/0xCA`), dump (`0xCB`); wait for feedback frames before consecutive writes (pages 2, 8).
- **Clock & Automation**: set real-time clock/date/daylight savings; enable/disable global or local sunrise/sunset actions; configure local and global alarm clocks (pages 2–3, 10–13).
- **Channel Control**: lock/unlock, disable/enable channel program, and select program mode (`0xB3`) with support for timers on disable commands (pages 2–3).

## Channel Naming & LED Behaviour
- Channel name frames use a channel-bit selector in byte 2; unused characters are `0xFF` for safe parsing (pages 5–6).
- LED precedence follows the usual rule set: steady-on overrides blink; combining slow and fast blink flags yields the documented very-fast behaviour (pages 1–2).

## Program & Scheduling Controls
- Module status byte aggregates alarm/program selection flags, allowing supervisory software to track which automation profile currently applies (page 4).
- Sunrise/sunset and alarm clock commands let the module act autonomously when linked to other Velbus nodes; disable/enable program commands support timed overrides (pages 2–3, 10–13).

## Memory Map
- Primary map spans `0x0000–0x03FF`, storing channel configuration, LED settings, alarm/program data, and identification records (pages 5–7).
- Critical flags (forced locks, program disable states, addressing) reside near the end of the map; avoid overwriting without intent (pages 6–7).
- Unused bytes default to `0xFF`; read the `memory map version` from `COMMAND_MODULE_TYPE` before scripting writes to account for firmware differences (page 4).

## Conversion Notes
- OCR typos (e.g. `COMMAND _PUSH_BUTTON_STATUS`) were normalised; refer back to the PDF when implementing lesser-used opcodes such as sunrise/sunset toggles (pages 1–3).
- Memory tables in the scan are dense; consult the original document for exact offsets when bulk editing channel configuration (pages 5–7).
