# VMB4RYLD-10 Four-Channel Relay with 10A Contacts Protocol (Edition 1)

## Module Overview
- Module type `0x48`; module type frame returns serial number, memory-map version, build year/week, and a terminator flag indicating whether the onboard line terminator is enabled (page 5).
- Adds heavy-duty 10 A relays while retaining the local button, force, and inhibit feature set from the VMB4RYLD family (pages 2–4).
- Relay status reports (`0xFB`) expose channel index, inhibit/force flags, relay output state, LED state, and a 24-bit active timer in seconds (page 4).

## CAN Frame Format
- Frames follow `<SOF – SID10…SID0 – RTR – IDE – r0 – DLC – DATA BYTES – CRC – ACK – EOF – IFS>` (page 2).
- Real-time control uses highest priority (`SID10..SID9 = 00`); telemetry and configuration use lowest priority (`11`) (pages 2–3).

## Published Frames
- **Local input feedback**: `0x00` `COMMAND_PUSH_BUTTON_STATUS` mirrors local push-button and relay switch transitions (`just pressed`, `just released`, `long pressed`) (page 3).
- **Keypad LED maintenance**: `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink, `0xF9` very fast blink use an LED bitmask addressed to a remote keypad (pages 3–4).
- **Operational telemetry**:
  - `0xDA` bus error counters (TX, RX, bus-off) (page 4).
  - `0xFB` relay status block (channel, inhibit/forced state, relay output, LED state, 24-bit timer) (page 4).
  - `0xFF` module type frame: type `0x48`, serial number, memory-map version, build year/week, terminator flag (page 5).
  - `0xFE` single-byte memory read and `0xCC` four-byte block read over `0x0000`–`0x04FC` (page 5).
- **Relay naming**: `0xF0`/`0xF1`/`0xF2` distribute up to 16 ASCII characters per channel; `0xFF` denotes unused slots (pages 5–7).

## Consumed Frames
- **Keypad synchronisation**: `0xF5` clear LED duplicates the outbound command so the module can honour remote requests (page 7).
- **Relay control and overrides** (pages 7–10)
  - `0x01` OFF, `0x02` ON, `0x03` start timer (skips when timer=0; `0xFFFFFF` keeps the relay ON).
  - `0x0D` start blink timer with identical 24-bit timer semantics.
  - `0x12` force OFF/`0x13` cancel force OFF, `0x14` force ON/`0x15` cancel force ON, `0x16` inhibit/`0x17` cancel inhibit. Each accepts a 24-bit duration; `0xFFFFFF` applies indefinitely, zero is ignored.
- **Status & configuration requests** (pages 10–12)
  - `0xFA` request relay status, RTR `COMMAND_MODULE_TYPE` request, `0xEF` relay name request.
  - `0xFD` read byte, `0xC9` read block, `0xCB` dump request; use address range `0x0000`–`0x04FC`.
  - `0xFC` write byte (≥10 ms spacing), `0xCA` write block (await feedback) (page 12).
  - `0xD9` bus error counter status request (page 12).
- **Commissioning**: `0x6A` `COMMAND_WRITE_ADDR_SERIALNR` (priority `01`) updates the module address and serial number after verifying the current serial (page 13).

## Memory Map Notes
- Memory-map diagrams (version 1) are provided but OCR omits offsets; refer to the PDF for the actual layout (pages 14–15).
- Flags indicate `0xFF` = normally open, `0x00` = normally closed relay contact (page 15).

## Timer Presets
- Preset durations listed include “no timer”, 29 min 30 s, 1 h 15 min, 4 h 45 min, 5 h 30 min, and 9 h 30 min, but the action-to-parameter table is unreadable in the OCR output (page 16).

## Conversion Notes
- OCR errors such as `F5`→`FS`, `0`→`O`, and duplicated characters were corrected where unambiguous.
- Timing/action tables and memory maps remain unresolved in text form; consult “VMB4RYLD-10 Protocol – edition 1” for definitive hex addresses and timer parameter mappings before implementation.
