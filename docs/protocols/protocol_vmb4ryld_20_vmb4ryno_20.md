# VMB4RYLD-20 & VMB4RYNO-20 Eight-Channel Relay Protocol (Edition 2)

## Module Overview
- Module type codes: `0x26` (VMB4RYLD-20) and `0x27` (VMB4RYNO-20); legacy `0x0D` value appears for earlier VMB4RYS-20 references (page 5).
- Provide eight relay channels with support for force, inhibit, interval timers, and programmable schedules; properties byte in the module-type frame advertises installed options (page 5).
- Module status telemetry exposes per-channel inhibit, forced-on, forced-off, program-disable, and interval-timer flags plus alarm/program selection bits (page 9).
- Memory map spans `0x0000–0x07FF`; CAN FD transfers allow block reads/writes up to 60 bytes (`0xCC`/`0xCA`), with unused bytes filled with `0x55` (pages 6–8, 16).

## Message Formats
- Frames follow `<SOF – SID10…SID0 – RTR – IDE – r0 – DLC – DATA – CRC – ACK – EOF – IFS>` with priority derived from `SID10..SID9`; `00` is highest (real-time controls), `11` lowest (telemetry/config) (page 2).
- CAN FD extensions are explicitly supported for memory block transfers, returning or accepting more than four data bytes (pages 6 & 16).

## Transmitted Messages
- **Timekeeping & environment**
  - `0xD7` real-time clock status request (broadcast and addressed variants) and `0xD8` clock status response carrying weekday, hour, minute (pages 3–4).
  - `0xB7` date status with day/month/year, `0xAF` daylight-saving enable flag (pages 4–5).
- **Module identity & diagnostics**
  - `0xFF` module type: module code, serial number, memory map version, build year/week, and properties byte (page 5).
  - `0xDA` bus error counters (TX, RX, bus-off) (page 5).
- **Memory operations**
  - `0xFE` single-byte read; `0xCC` block read (4 bytes standard, 5–60 bytes for CAN FD). Address range `0x0000–0x07FF`, blocks limited to `0x07FC` or `0x0800 - length` (pages 5–7).
- **Channel naming**
  - `0xF0`/`0xF1`/`0xF2` deliver name characters 1–16 for channels 1–8; unused characters return `0xFF` (page 7).
- **Status & LED management**
  - `0x00` channel status (just pressed/released/long pressed bitmasks) for linked push-button states (page 8).
  - `0xFB` module status: channel state, inhibited/forced flags, program disable bits, interval timer status, alarm/program selection (page 9).
  - `0xF5`–`0xF8` LED control commands for linked push-button modules (page 9).
  - `0xC1` program step info returns schedule metadata such as program reference, calendar masks, and action/channel identifiers (pages 9–11).

## Accepted Commands
- **Housekeeping & global controls**
  - `0xAB` power-up message acknowledges module boot; `0xB5` toggles CAN FD support (pages 12–13).
  - Clock/date management via `0xD7` request, `0xD8` set clock, `0xB7` set date, and `0xAF` enable daylight saving (pages 13–14).
  - Sunrise/sunset enable flags (`0xAE`) support global (`address 0x00`) and local contexts (page 14).
  - `0xC3` configures global or local clock alarms (wake-up / bedtime) (pages 13–14).
- **Status queries & LED sync**
  - RTR `COMMAND_MODULE_TYPE` request, `0xFA` module status request, `0xEF` channel name request (channel `0xFF` targets all), and `0xF5` LED clear from linked modules (page 15).
- **Memory & diagnostics**
  - `0xFD` byte read, `0xC9` block read, `0xCB` dump request, `0xFC` byte write, `0xCA` block write (supports CAN FD lengths), `0xD9` bus error counter request (pages 15–17).
  - Writes require waiting for corresponding read-back frames; terminate writes with a final command at the highest modified address (pages 16–17).
- **Channel control**
  - `0x01` OFF, `0x02` ON, `0x03` start timer (`0x000000` ignored, `0xFFFFFF` permanent ON) (page 18).
  - `0x12` force OFF, `0x13` cancel force OFF, `0x14` force ON, `0x15` cancel force ON, `0x16` inhibit, `0x17` cancel inhibit; each accepts 24-bit durations and honours channel `0xFF` for broadcast (pages 18–19).
- **Program & action engine**
  - `0xB2` enable program (optional broadcast via channel `0xFF`), `0xB1` disable program with optional timer (`0xFFFFFF` = permanent disable) (page 20).
  - `0xB3` select program mode (none/group selection), `0xC0` read program step, `0xC2` write program step with complex calendar masks, `0xC1`/`0xC2` dwell on month/day, weekday, and group fields plus action/channel bytes (pages 10–11, 21–22).
  - `0x6A` commissioning command rewrites address and serial number; request includes current serial for validation (page 23).

## Scheduling & Action Tables
- Action codes cover toggling, forcing, interval timers, sunrise/sunset toggles, program enable/disable, alarm control, and other automation behaviours; parameter slots represent delay/pulse/pause durations and channel indexes (pages 26–28).
- Preset time constants include “no timer”, 29 min 30 s, 1 h 15 min, 4 h 45 min, 5 h 30 min, and 9 h 30 min; action-to-parameter mapping in the OCR output is partially illegible—cross-check the PDF before relying on specific combinations (pages 27–28).
- Program step tables outline weekday masks, monthly selection bits, and group identifiers for normal, winter, and holiday programs; OCR loses many column headers (pages 21–31).

## Operational Scenarios
- Startup sequence sends `0xAB` power-up, clock request, channel status (all released), and module status; expects a `COMMAND_MODULE_TYPE` reply from scanners (page 32).
- Button presses toggle associated relays, emit module & channel status frames, and optionally send LED feedback based on linked actions (page 32).
- Memory dump requests omit unused blocks to minimise bus time; power-up messages from other devices resynchronise blink timers (page 33).

## Conversion Notes
- OCR substitutions (e.g., `0`↔`O`, fragmented tables) were corrected where unambiguous; action table rows, program-byte diagrams, and memory maps remain partially unreadable—refer to “VMB4RYLD-20 & VMB4RYNO-20 Protocol – edition 2” for authoritative diagrams (pages 24–31).
- CAN FD block transfer lengths listed as placeholders (`memory data 12`, `data 44`, etc.) use column headers for DLC boundaries; verify exact byte positions in the PDF before automating writes.
