# VMB6PB-20 Six-Gang Push Button Module Protocol (Edition 3)

## Module Overview
- Module type `0x4C`; six local buttons with LED indicators, channel lock/disable modes, sunrise/sunset automation, and onboard scheduling (page 5).
- Module status frame exposes button state, enable/invert flags, lock state, program disable bit, and alarm/program selector (page 5).
- Module type payload returns serial number, memory-map version, build year/week, and a properties byte describing available firmware options (page 4).

## Message Formats
- Uses standard Velbus CAN frames with `SID10..9 = 00` for high-priority button events, `11` for telemetry, configuration, and housekeeping (page 4).
- Supports CAN FD for memory blocks up to 60 B: unused payload bytes are filled with `0x55`; address range limited to `0x0000–0x03FF` (page 7).
- Channel identifiers appear either as bitmasks (`0x01`…`0x20`) or as numeric indexes (`1…8`) depending on the message; LED commands use bitmasks (pages 8–9, 12).

## Transmitted Messages
- **Bootstrap & timekeeping**: `0xAB` power-up, `0xD7` RTC status request (broadcast), `0xD8` clock status, `0xB7` date status, `0xAF` daylight saving flag (pages 3–4).
- **Button telemetry**: `0x00` `COMMAND_PUSH_BUTTON_STATUS` with just pressed/released/long pressed bitmasks (page 4).
- **Module status**: `0xED` returns button press state, enable/invert/lock bits, program disable bit, and alarm/program selector (page 5).
- **Module type**: `0xFF` returns module type `0x4C`, serial number, memory-map version, build info, and properties (page 4).
- **Diagnostics**: `0xDA` bus error counters (page 6).
- **Memory services**: `0xFE` byte read, `0xCC` block read (standard and CAN FD variants) across `0x0000–0x03FF` (pages 6–7).
- **Channel naming**: `0xF0`/`0xF1`/`0xF2` provide up to 16 ASCII characters per channel; unused characters are `0xFF` (page 8).
- **Linked LED control**: `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink aimed at remote keypads (page 8).
- **Program metadata**: `0xC1` program-step info enumerates calendar masks, group flags, actions, and channel targets; OCR lost several column headers—consult the PDF when encoding schedules (pages 9–11).

## Accepted Commands
- **Linked push-button input**: `0x00` mirrors remote button edges to this module (page 12).
- **Housekeeping**: accepts broadcast `0xAB` power-up echo, CAN-FD enable/disable (`0xB5`), and RTC queries `0xD7` (page 12).
- **Timekeeping**: `0xD8` set clock, `0xB7` set date, `0xAF` set daylight saving, `0xAE` enable/disable sunrise/sunset (global with address `0x00`, local with module address), `0xC3` set global/local alarms (pages 13–14).
- **Status & identity queries**: `0xFF` RTR module-type request, `0xED` module-status request, `0xEF` channel-name request, `0xFA` module-status request using channel mask (pages 12–13).
- **LED control**: `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink, `0xF9` very fast, `0xF4` LED update for channel LEDs (pages 12–13).
- **Memory services**: `0xFD` read byte, `0xC9` read block, `0xCB` dump, `0xFC` write byte, `0xCA` write block (CAN FD supported); wait for read-back before issuing the next write (pages 12–13).
- **Channel control**: commands to lock/unlock channels, disable/enable programs, and select program groups are present (page 3 list) though detailed payloads require PDF verification; automation typically uses `0xB1` `0xB2` and `0xB3` families (page 3).
- **Program editing**: `0xC0` read program step, `0xC2` write program step; see PDF for bit layout due to OCR loss (pages 9–11).

## Program & Scheduling Notes
- Program step tables capture weekday masks, day-of-month filters, “every” flags, group selection, action codes, and pulse durations; OCR retains only fragments. Recheck the source when generating schedules (pages 9–11).
- Action listings indicate timed pulses from 0.5 s through 18 h and links to specific channels; full mapping requires consulting the PDF (page 11).

## Memory & Configuration
- Memory map extends to `0x03FF`, with CAN FD reads/writes accounting for block length (`0x0400 – length`) to stay in range (page 7).
- Channel properties (enable/invert/lock, program disable) surface both in module-status frames and likely within configuration memory; use telemetry to confirm runtime state.

## Conversion Notes
- OCR dropped several labels in program tables and misrendered some byte names; verify calendar masks, action codes, and timer presets directly from “VMB6PB-20 Protocol – edition 3” when automating schedules.
- LED terminology standardised to “channel” for local LEDs and “linked push button” for remote keypads to avoid ambiguity in tooling.
