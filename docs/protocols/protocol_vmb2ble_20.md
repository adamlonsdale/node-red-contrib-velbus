# VMB2BLE-20 Blind Controller Protocol (Edition 1)

## Module Overview
- Next-generation blind actuator supporting CAN FD extended frames, on-board real-time clock, sunrise/sunset automation, and preset controls (`VMB2BLE-20 type = 0x61`, page 5).
- Adds serialised provisioning, larger memory maps (up to 0x07FF), and extended LED handling across up to eight linked push-button channels (pages 1–6, 15–16).
- Uses high-priority frames for motion commands (`SID10..9 = 00`) and low-priority frames for telemetry, timekeeping, and configuration (`11`) (pages 3–4, 17).

## Message Formats
- Timeout and override timers remain 24-bit big-endian seconds; unlike the -10 model, up/down commands forbid `0xFFFFFF` (page 17).
- CAN FD transfers support block lengths 5–60 bytes for both reads (`0xC9`) and writes (`0xCA`); unused payload bytes are padded with `0x55` (pages 15–16).
- Module type payload adds a properties byte (bit field for terminator, CAN FD enablement, etc.) after the build metadata (page 5).

## Transmitted Messages
- **Timekeeping**: `0xD7` clock request, `0xD8` status (day/hour/minute), `0xB7` date (day/month/year), and `0xAF` daylight-saving state (pages 3–5).
- **Relay Activity (`0x00`)**: high-priority report of channels just switched on/off; byte 4 reserved (page 3).
- **Diagnostics**: `0xDA` bus error counters; `0xFF` module type with serial, memory-map version, build date, and properties (page 5).
- **Memory Echo**: `0xFE` word read and `0xCC` block read (4 or 5–60 bytes) over address range `0x0000–0x07FF` (pages 5–6).
- **Naming**: channel names via `0xF0/0xF1/0xF2`; unused characters `0xFF` (page 6).
- **Program Insight**: documentation lists `0xC1` program step info and `0xFB` module status frames containing automation metadata (page 1 summary, 2).

## Accepted Commands
- **Motion & Position**: stop (`0x04`), up/down with timeout (`0x05/0x06`), set precise position (`0x1C`), and slat rotation via memory settings (pages 17–18).
- **Overrides**: lock/unlock (`0x1A/0x1B`), forced up/down (`0x12/0x18`), cancel forced states (`0x13/0x15`), inhibit/inhibit cancel (`0x16/0x17`), forced preset inhibits (`0x18/0x19`), and global inhibit toggles—each supports broadcast channel `0xFF` and 24-bit timers (pages 17–19).
- **Automation Controls**: enable/disable global or local sunrise/sunset actions (`0xAE`), configure local/global alarm clocks (`0xC3` variants), select auto mode, and manage daylight-saving enablement (pages 2–3, 12–14).
- **State Queries & LED Control**: channel status (`0x00`), module status request (`0xFA`), channel-name request (`0xEF`), LED clear (`0xF5`), and RTV of linked push buttons (pages 2, 14).
- **Memory Services**: read/write word (`0xFD/0xFC`), block (`0xC9/0xCA`), dump (`0xCB`); CAN FD commands accept an explicit block-length parameter. Always wait for the corresponding feedback packet before issuing another write (pages 15–16).
- **Provisioning**: write module address & serial number, change master address, and configure serial/terminator flags via dedicated commands (pages 13–14, 24).
- **Clock Maintenance**: set real-time clock, set date, refresh daylight-saving flag, and poll status via `0xD7/0xD8/0xB7/0xAF` round trip (pages 2–3, 10–11).

## Channel Naming & LED Behaviour
- Channels expose 16-character ASCII names across three frames; `0xFF` padding indicates unused slots, enabling consistent parsing (page 6).
- LED frames operate on linked push-button modules; steady-on requests override blink, and LED bitmasks follow the standard Velbus ordering (page 4, 15).

## Program & Scheduling Controls
- Supports multiple auto modes and alarm clock schedules; commands allow enabling/disabling programs, selecting program groups, and editing steps (pages 1–2, 22–23).
- Program read/write commands (`0xC0/0xC2`) operate with program step numbers, group identifiers, channel selection, and direction flags for searching next/previous matches (page 22).
- Additional program step info (`0xC1`) exposes schedule metadata for UI synchronisation (page 1 summary).

## Memory Map
- Base map spans `0x0000–0x07FF`, storing channel presets, automation flags, RTC mirrors, module addressing, and scene levels; verify `memory map version` from the module-type frame before scripting writes (pages 5, 693–937).
- Successive map versions (1 through 3) add storage for extended presets, sunrise/sunset settings, daylight-saving history, and global/calendar data; CAN FD support allows batch operations over these ranges (pages 693–937).
- Reserved areas mirror live state (forced/inhibit flags, alarm configuration); avoid overwriting without understanding firmware expectations (pages 693–940).

## Conversion Notes
- OCR misreadings (e.g. duplicated `0xD7` entries) were normalised to their documented command names; confirm uncommon opcodes such as inhibit preset up/down before implementation (pages 1–3, 17–19).
- Memory tables appear as dense grids in the scan; consult the PDF for exhaustive offsets and bit definitions when building automation tooling (pages 693–937).
