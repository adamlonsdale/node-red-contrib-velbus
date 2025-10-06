# VMB4RYNO Four-Channel Relay (Normally Open) Protocol (Edition 5)

## Module Overview
- Module type `0x11`; module-type frame returns serial number, memory-map version, build year/week (page 4).
- Four relay outputs with local push-button inputs; supports forced/inhibited states and relay timers identical to the VMB4RYLD family (pages 2–4).
- Relay status frame (`0xFB`) surfaces disable/inhibit/forced flags, live relay state, LED state, and a 24-bit timer countdown in seconds (page 4).
- Memory map spans `0x0000–0x04FC`; single- and quad-byte read/write commands are provided, no CAN FD extensions noted in this edition (page 4).

## Message Formats
- Standard Velbus CAN layout `<SOF – SID10…SID0 – RTR – IDE – r0 – DLC – DATA – CRC – ACK – EOF – IFS>` with `00` priority reserved for immediate relay control/status packets and `11` used for telemetry/configuration (page 2).

## Transmitted Messages
- **Push-button / relay switch feedback**: `0x00` `COMMAND_PUSH_BUTTON_STATUS` reports local presses, releases, and >0.85 s holds; combines relay toggles executed in local mode (page 2).
- **LED maintenance for linked keypads**: `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink, `0xF9` very fast blink; each uses a bitmask covering keypad LEDs 1–8 (pages 2–3).
- **Diagnostics and telemetry**
  - `0xDA` bus error counters (TX, RX, bus-off) (page 3).
  - `0xFB` relay status with 24-bit timer and LED info (page 3).
  - `0xFF` module type (type `0x11`, serial, memory-map version, build year/week) (page 4).
  - `0xFE` single-byte memory read; `0xCC` four-byte block read across `0x0000–0x04FC` (page 4).
- **Naming**: `0xF0`/`0xF1`/`0xF2` deliver relay name characters 1–16; unused slots filled with `0xFF` (pages 4–5).

## Accepted Commands
- **Relay controls** (pages 6–9)
  - `0x01` OFF, `0x02` ON.
  - `0x03` start timer: `0x000000` skips, `0xFFFFFF` keeps relay ON permanently.
  - `0x0D` start blinking timer with identical timeout semantics.
  - `0x12` force OFF / `0x13` cancel, `0x14` force ON / `0x15` cancel, `0x16` inhibit / `0x17` cancel; all accept 24-bit durations with `0xFFFFFF` = permanent state.
- **Status & identity queries** (pages 9–11)
  - `0xFA` relay status request, RTR `COMMAND_MODULE_TYPE`, `0xEF` relay name request.
  - `0xFD` read memory byte, `0xC9` read 4-byte block, `0xCB` dump request.
  - `0xFC` write byte (wait ≥10 ms before next command), `0xCA` write 4-byte block (await feedback).
  - `0xD9` bus error counter status request reissues the `0xDA` telemetry.
- **Commissioning**: `0x6A` rewrites address and serial after verifying the existing serial number (page 12).

## Memory Map & Timers
- Memory-map diagrams (pages 13–20) include NC/NO contact flags and timer/action definitions; OCR output loses offsets and many labels—consult the PDF for precise addresses.
- Timer preset tables list values such as “no timer”, 29 min 30 s, 1 h 15 min, 4 h 45 min, 5 h 30 min, and 9 h 30 min, but column headings are partially illegible in the transcript (pages 15 & 20).

## Conversion Notes
- OCR misread `F5` as `FS`, substituted `0` for `O`, and duplicated characters in the name tables; command bytes have been normalised to hexadecimal notation.
- Memory-map graphics, action tables, and NC/NO annotations remain unreliable in text—refer to “VMB4RYNO Protocol – edition 5” for authoritative layouts before implementing automation.
