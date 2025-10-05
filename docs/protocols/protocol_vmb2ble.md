# VMB2BLE Advanced Blind Controller Protocol (Edition 6)

## Module Overview
- Two-channel blind actuator with integrated real-time clock, sunrise/sunset automation, and preset management (`VMB2BLE_TYPE = 0x1D`, page 4).
- Provides position control, forced/inhibit states, lock/unlock, and both global and local alarm clock scheduling (pages 1–2).
- Uses Velbus CAN framing; high-priority frames (`SID10..9 = 00`) signal relay transitions, while configuration and timekeeping travel on low-priority frames (`11`) (pages 3–4).

## Message Formats
- Timeouts and preset durations use 24-bit big-endian seconds; a zero timeout defers to firmware defaults, `0xFFFFFF` latches outputs (inherited from VMB2BL family).
- Clock and date payloads follow `COMMAND_REALTIME_CLOCK_STATUS (0xD8)` and `COMMAND_DATE_STATUS (0xB7)` structures; daylight savings flag is a single byte (`0 = disabled`, `1 = enabled`) (pages 3–4).
- Module type payload exposes serial number (two bytes), memory map version, build year, and week (page 4).

## Transmitted Messages
- **Clock & Calendar**: periodic `0xD7` requests, `0xD8` real-time clock status, `0xB7` date status, and `0xAF` daylight-saving flag (pages 3–4).
- **Blind & Relay Status**: `0x00` reports relay transitions, `0xEC` blind status with channel mask, LED states, timeout config, and active runtime counter (pages 3–5).
- **LED Control**: `0xF5` clear, `0xF6` set, `0xF8` fast blink for linked push-button indicators (page 4).
- **Diagnostics**: `0xDA` bus error counters; module type frame `0xFF` includes serial and memory-map version (page 4).
- **Memory & Naming**: `0xFE` word reads, `0xCC` block reads (addresses `0x0000–0x01FC`); blind names split across `0xF0/0xF1/0xF2` with per-channel mapping (pages 5–6).

## Accepted Commands
- **Motion & Position**: `0x04` off, `0x05/0x06` up/down (24-bit timeout), `COMMAND_SET_BLIND_POSITION` (opcode per PDF) for percentage positioning, plus forced up/down and cancel commands for lockout scenarios (pages 7–9).
- **State Management**: inhibit (`0x18` up, `0x19` down) and cancel, lock/unlock, and general inhibit toggles for presets (page 2).
- **Status Queries**: blind status request (`0xFA`), linked push-button status, module type RTR, LED clear (page 2).
- **Timekeeping**: requests and setters for real-time clock, date, daylight savings, sunrise/sunset enablement, local/global alarm clocks, and auto mode selection (pages 2–3, 10–13).
- **Memory & Addressing**: read/write word (`0xFD/0xFC`), block (`0xC9/0xCA`), dump (`0xCB`), and write module address + serial number commands for provisioning (pages 2, 5, 9–10).

## Channel Naming & LED Behaviour
- Blind channels expose 16-character ASCII names through three frames; unused characters ship as `0xFF` padding (pages 5–6).
- LED frames track standard precedence: steady-on overrides blink; `0xF8` toggles fast blink for emphasis, consistent with other Velbus modules (page 4).

## Program & Scheduling Controls
- Module stores both local and global alarm schedules; commands allow enabling/disabling sunrise/sunset triggered actions per channel and globally (pages 2, 12–13).
- Auto mode selection aligns blinds with stored presets, while manual overrides (forced/inhibit/lock) temporarily suspend automation until cancelled (pages 2, 8–9).

## Memory Map
- **Base Map** (page 693): contains blind channel links, preset timings, clock configuration, and sunrise/sunset flags.
- **Version 1 (Build 1409–1808)**: adds structured blocks for forced modes, inhibit timers, and calendar settings (page 765–854).
- **Version 2 (Build 1809–1816)**: reorganises sunrise/sunset structures and stores module serial/RTC offsets (page 855–935).
- **Version 3 (Build ≥1935)**: extends storage for position presets, daylight-saving history, and local/global alarms (page 937 onward).
- Unused entries default to `0xFF`; verify memory-map version via `COMMAND_MODULE_TYPE` before writing automation scripts.

## Conversion Notes
- OCR normalised repeated typos (e.g. `COMMAND_REALTIME_CLOCK_STATUS_REQUEST` vs `...TEMPERATUTE`); cross-check uncommon opcodes like inhibit/force indices directly against the PDF before implementation (pages 1–9).
- Memory tables are dense and sometimes clipped in text form; refer back to the scanned diagrams for detailed offset/bit-mask definitions when building tooling (pages 693–937).
