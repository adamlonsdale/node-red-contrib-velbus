# VMB2BLE-10 Blind Controller Protocol (Edition 1)

## Module Overview
- Two-channel blind actuator with integrated scheduler and sunrise/sunset automation (`VMB2BLE-10_TYPE = 0x4A`, page 4).
- Provides relay control, LED feedback, alarm clocks, local/global automation toggles, and remote module address reassignment (pages 1–3, 12–14).
- Low-priority broadcasts (`SID10..9 = 11`) carry timekeeping and configuration, while relay transitions use high-priority frames (`SID10..9 = 00`) (pages 3–4).

## Message Formats
- Motion timeouts and override timers are 24-bit big-endian seconds; `0x000000` defers to firmware defaults, `0xFFFFFF` indicates a permanent override (pages 8–9).
- Clock frames follow the standard Velbus structure: `COMMAND_REALTIME_CLOCK_STATUS (0xD8)` with day/hour/minute, `COMMAND_DATE_STATUS (0xB7)` with day/month/year, and `COMMAND_DAYLIGHT_SAVING_STATUS (0xAF)` as a 1-byte flag (page 3).
- Module type response appends a terminator byte describing the wiring state (0 = open, 1 = closed) after build metadata (page 4).

## Transmitted Messages
- **Clock & Calendar**: periodic `0xD7` requests, `0xD8` status, `0xB7` date, and `0xAF` daylight-saving flag (page 3).
- **Relay Status (`0x00`)**: reports blinds that just switched on/off; byte 4 reserved (page 3).
- **LED Control (`0xF5/0xF6/0xF8`)**: clear, set, and fast blink instructions for linked push-button modules (pages 3–4).
- **Diagnostics**: `0xDA` bus-error counters; `0xFF` module type with serial, memory-map version, and terminator state (page 4).
- **Memory Echo**: `0xFE` word reads and `0xCC` 4-byte blocks for addresses `0x0000–0x01FC` (page 5).
- **Naming**: blind names split across `0xF0/0xF1/0xF2`; unused characters transmit `0xFF` (pages 5–6).

## Accepted Commands
- **Motion & Position**: `0x04` stop, `0x05/0x06` up/down with optional timeout, `0x1C` set position (0–100 %), plus slat rotation timing stored in memory (pages 8–9, 17).
- **Overrides**: forced up/down, cancel forced state, inhibit, inhibit preset up/down, lock/unlock, all sharing 24-bit timers and supporting broadcast (`channel = 0xFF`) (pages 8–10, 17).
- **Automation**: enable/disable global or local sunrise/sunset actions, set/clear local and global alarm clocks, choose auto modes 1–3, and toggle summer time (pages 2–3, 12–14, 17–18).
- **State Queries**: blind status request (`0xFA`), channel name request (`0xEF`), module type RTR, linked push-button status (`0x00`), and LED clear commands (pages 2, 8–9).
- **Memory & Provisioning**: read/write word (`0xFD/0xFC`), read/write block (`0xC9/0xCA`), dump (`0xCB`), and rewrite module address + serial number (page 13–15). Always wait for the matching memory feedback before issuing another write.
- **Clock Maintenance**: set RTC (`0xD8`), set date (`0xB7`), configure daylight savings (`0xAF`), and refresh real-time status via `0xD7` (pages 2–3, 10–11).

## Channel Naming & LED Behaviour
- Each blind exposes a 16-character ASCII name over three frames (`0xF0/0xF1/0xF2`) with `0xFF` padding; identical framing applies to linked push-button names in newer firmware (pages 5–7).
- LED precedence mirrors other Velbus devices: steady-on overrides blink, and simultaneous slow/fast requests escalate to very-fast blink (page 4).

## Program & Scheduling Controls
- Auto modes and alarm-clock settings live in dedicated registers (`0x00F4–0x00F7`), enabling per-channel schedules without controller intervention (page 16).
- Sunrise/sunset toggles and summertime flags are stored in the same region, allowing rapid reconfiguration via memory writes (page 18).

## Memory Map
- Memory-map version 1 exposes button links, channel states, and configuration between `0x0000–0x01FF`; key control bytes from `0x00EE–0x00FF` store forced/inhibit flags, auto-mode selections, real-time clock mirrors, and identification (page 16).
- Avoid overwriting critical status bytes (`0x00EE–0x00F3` for channel states, `0x00F4–0x00FF` for automation, address, and serial data) unless intentionally reconfiguring the device (page 16).
- All unused locations contain `0xFF`; confirm the memory-map version via `COMMAND_MODULE_TYPE` before scripted updates.

## Conversion Notes
- OCR artefacts (e.g. `COMMAND _FAST_BLINKING_LED`) were normalised to match Velbus constants; double-check uncommon opcodes such as inhibit preset commands before coding (pages 3–9).
- Table-based memory map sections are largely graphical in the scan; consult the source PDF for exhaustive address/bit listings when building automation tooling (pages 15–19).
