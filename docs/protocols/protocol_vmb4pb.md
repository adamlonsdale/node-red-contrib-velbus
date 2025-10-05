# VMB4PB Four-Channel Push Button Module Protocol (Edition 2)

## Module Overview
- Four-channel push button interface with LED indicators, automation features, and program storage (`module type 0x44`, page 4).
- Publishes channel events, module status, and clock/calendar data; supports linked LED control and program step info (pages 3–4).
- Integrates with sunrise/sunset automation, local/global alarms, and provides read/write access to program steps (pages 2–3).

## Message Formats
- Power-up `0xAB` announces the module address; clock frames reuse `0xD7/0xD8`, date `0xB7`, daylight-saving `0xAF` (page 3).
- Module type frame carries serial number, memory-map version, build date, and terminator flag (0=open, 1=closed) (page 4).
- Channel status `0x00` reports pressed/released/long-press states; module status `0xED` returns channel enable/invert/lock bits plus program selection (pages 3–4).

## Transmitted Messages
- **Clock & Diagnostics**: `0xAB`, `0xD7`, `0xD8`, `0xB7`, `0xAF`, `0xFF`, `0xDA` (pages 3–4).
- **Channel & Module Status**: `0x00` channel events; `0xED` module status reflecting channel enable/disable, inversion, locks, program disable, and alarm/program selection (page 4).
- **LED Control Feedback**: clear/set/slow/fast/very-fast linked LED commands (`0xF4–0xF9`) outward to paired modules (page 2).
- **Naming & Programs**: channel names via `0xF0/0xF1/0xF2` and `0xC1` program step info frames (page 1 summary, 5–6).
- **Memory Echo**: `0xFE` single-byte read and `0xCC` block read (4 bytes) for map region (page 5).

## Accepted Commands
- **LED Management**: `0xF4` update, `0xF5` clear, `0xF6` set, `0xF7` slow, `0xF8` fast, `0xF9` very fast LED operations for the module and linked devices (pages 1–2).
- **Automation & Clock**: enable/disable sunrise/sunset actions, configure local/global alarm clocks, set clock/date/daylight-saving states (pages 2–3, 10–12).
- **Programs**: lock/unlock channels, disable/enable program with optional timer, select program, read/write program steps (`0xC0/0xC2`), read program step info (`0xC1`) (pages 2–3, 12–14).
- **Memory Services**: read/write word (`0xFD/0xFC`), read/write block (`0xC9/0xCA`), dump (`0xCB`); wait for memory response before issuing the next write (pages 2, 8–9).
- **Status Queries**: module type RTR, module status request (`0xFA`), channel name request (`0xEF`), LED clear, real-time clock status request (pages 1–2, 8).

## Channel Naming & LED Behaviour
- Channel name frames include a channel bitmask in byte 2 (1-of-8 encoding); unused characters are `0xFF` (pages 5–6).
- LED precedence follows Velbus norms: steady-on overrides blink; combined slow/fast results in very-fast blinking (pages 1–2).

## Program & Scheduling Controls
- Program step frames support editing and querying schedules; module status exposes current alarm/program selection to allow host-side synchronisation (pages 4, 12–14).
- Program disable commands accept timer durations, with `0xFFFFFF` creating a permanent disable until re-enabled (page 3).

## Memory Map
- Memory range `0x0000–0x03FF` stores channel configuration, LED defaults, program data, and addressing; ensure the `memory map version` matches expectations before scripted updates (page 4–5).
- Tables in the PDF outline offsets for button mappings, LED states, and program steps; consult the source for precise addresses when automating writes (pages 5–9).

## Conversion Notes
- OCR inconsistencies (spacing, capitalisation) were normalised; double-check less common opcodes like sunrise/sunset toggles before implementation (pages 2–3).
- The summary references program step info without detailed payload—refer to the PDF for the exact structure when parsing (page 1).
