# VMB4RYNO-10 Four-Channel Relay (10 A Contacts) Protocol (Edition 1)

## Module Overview
- Module type `0x49`; module-type frame reports serial number, memory-map version, build year/week, and a terminator flag indicating whether the on-board line terminator is active (page 4).
- Retains the four-channel architecture and force/inhibit capabilities of the VMB4RYNO while upgrading the relay hardware to 10 A contacts (pages 2–4).
- Relay status telegram (`0xFB`) exposes disable/inhibit/force flags, live output state, LED bits, and a 24-bit countdown timer in seconds (page 3).
- Memory map covers `0x0000–0x04FC`; no CAN FD block extensions are documented in this edition (page 4).

## CAN Frame Format
- Frames follow the Velbus CAN template `<SOF – SID10…SID0 – RTR – IDE – r0 – DLC – DATA – CRC – ACK – EOF – IFS>` with `SID10..SID9 = 00` reserved for immediate control and feedback, `11` for telemetry/configuration (page 2).

## Published Frames
- **Local input feedback**: `0x00` `COMMAND_PUSH_BUTTON_STATUS` summarises local button presses, releases, and long holds alongside relay state transitions (page 2).
- **Keypad LED control**: `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink, `0xF9` very fast blink each take an LED bitmask for the linked push-button module (pages 2–3).
- **Diagnostics & telemetry**
  - `0xDA` bus error counters (TX/RX/bus-off) (page 3).
  - `0xFB` relay status with 24-bit timer (page 4).
  - `0xFF` module type: module code `0x49`, serial number, memory-map version, build dates, terminator flag (page 4).
  - `0xFE` single-byte memory read and `0xCC` four-byte block read within `0x0000–0x04FC` (page 4).
- **Relay naming**: `0xF0`/`0xF1`/`0xF2` broadcast name characters 1–16, padding unused slots with `0xFF` (pages 4–6).

## Consumed Frames
- **Relay control & timing** (pages 7–10)
  - `0x01` OFF, `0x02` ON, `0x03` start timer (`0x000000` = ignore, `0xFFFFFF` = permanent ON).
  - `0x0D` start blink timer with identical 24-bit duration semantics.
  - `0x12` force OFF / `0x13` cancel, `0x14` force ON / `0x15` cancel, `0x16` inhibit / `0x17` cancel; each accepts 24-bit delays, ignoring `0x000000` and treating `0xFFFFFF` as permanent.
- **Status & metadata** (pages 10–12)
  - `0xFA` relay status request, RTR `COMMAND_MODULE_TYPE`, `0xEF` relay name request.
  - `0xFD` memory byte read, `0xC9` block read, `0xCB` dump request.
  - `0xFC` write memory byte (wait ≥10 ms before another write), `0xCA` write block (await confirmation).
  - `0xD9` bus error counter status request re-triggers the diagnostic telemetry.
- **Commissioning**: `0x6A` rewrite module address and serial after verifying the current serial number (page 13).

## Memory Map & Timer Presets
- Memory-map version 1 diagrams (pages 14–15) include NC/NO contact configuration (`0xFF` = normally open, `0x00` = normally closed); OCR copy lacks coordinates—use the PDF for exact offsets.
- Action/timer tables list presets such as “no timer”, 29 min 30 s, 1 h 15 min, 4 h 45 min, 5 h 30 min, and 9 h 30 min but do not retain the original column labels (page 16).

## Conversion Notes
- OCR artefacts (e.g., `F5` rendered as `FS`, dropped columns in tables) were normalised where values were certain; ambiguous timing/action rows remain unresolved and require checking “VMB4RYNO-10 Protocol – edition 1”.
- The transcript omits several figures (e.g., memory map grids); consult the PDF before scripting memory operations or relying on contact configuration defaults.
