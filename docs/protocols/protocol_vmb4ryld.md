# VMB4RYLD Four-Channel Relay with Local Disable Protocol (Edition 5)

## Module Overview
- Module type `0x10`; module type frame also carries the 16-bit serial number, memory-map version, build year, and build week (page 5).
- Provides four relays with local push-button inputs; firmware ≥1105 adds force/inhibit features that override timers (pages 2 & 8).
- Relay status telegram (`0xFB`) exposes disable/inhibit/force flags, live output, LED state, and a 24-bit active timer in seconds (page 4).

## Message Formats
- Frames use the standard Velbus CAN layout `<SOF – SID10…SID0 – RTR – IDE – r0 – DLC – DATA – CRC – ACK – EOF – IFS>` (page 2).
- Highest priority (`SID10..SID9 = 00`) is used for real-time switch feedback and relay commands; lowest priority (`11`) is used for telemetry, configuration, and memory access (pages 2–3).

## Transmitted Messages
- **Push-button & relay switch status**: `0x00` `COMMAND_PUSH_BUTTON_STATUS` indicates which local buttons were pressed/released/held and mirrors relay transitions triggered locally (page 3).
- **LED control targeting remote keypads**: `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink, `0xF9` very fast blink; each carries a single LED bitmask byte for the addressed keypad (pages 3–4).
- **Diagnostics & telemetry**:
  - `0xDA` `COMMAND_BUSERROR_COUNTER_STATUS`: TX/RX/bus-off counters (page 4).
  - `0xFB` `COMMAND_RELAY_STATUS`: returns channel index, inhibit/force bits, output state, LED state, and 24-bit countdown (page 4).
  - `0xFF` `COMMAND_MODULE_TYPE`: module type `0x10`, serial number, memory-map version, build year/week (page 5).
  - `0xFE` `COMMAND_MEMORY_DATA` and `0xCC` `COMMAND_MEMORY_DATA_BLOCK` read EEPROM/flash (`0x0000`–`0x04FC`) (page 5).
- **Naming**: `0xF0`/`0xF1`/`0xF2` broadcast relay name characters 1–16; unused slots contain `0xFF` (pages 5–6).

## Accepted Commands
- **Keypad maintenance**: `0xF5` `COMMAND_CLEAR_LED` clears specific keypad LEDs to keep wall controllers in sync (page 6).
- **Relay control and timing** (pages 6–9)
  - `0x01` OFF, `0x02` ON, `0x03` start timer (0 sets “skip”, `0xFFFFFF` forces permanent ON).
  - `0x0D` start blink timer; interprets the 24-bit timer identically to the standard timer (page 7).
  - `0x12` force OFF, `0x13` cancel force OFF, `0x14` force ON, `0x15` cancel force ON, `0x16` inhibit, `0x17` cancel inhibit. Each accepts a 24-bit duration; `0x000000` is ignored, `0xFFFFFF` applies permanently (pages 8–9).
- **Status & metadata queries** (pages 9–11)
  - `0xFA` `COMMAND_RELAY_STATUS_REQUEST` fetches the latest status frame.
  - RTR `COMMAND_MODULE_TYPE` request: zero-length frame answered by the telemetry message.
  - `0xEF` relay name request.
  - `0xFD` read memory byte, `0xC9` read 4-byte block (`0x0000`–`0x04FC`), `0xCB` dump request.
  - `0xFC` write memory byte (observe ≥10 ms pause), `0xCA` write 4-byte block (wait for feedback) (page 10).
  - `0xD9` `COMMAND_BUS_ERROR_COUNTER_STATUS_REQUEST` triggers a fresh diagnostic report (page 10).
- **Commissioning**: `0x6A` `COMMAND_WRITE_ADDR_SERIALNR` (priority `01`) reprograms the module address and serial number; payload carries current and new serial/address fields for validation (page 12).

## Memory Map Notes
- Memory map diagrams are supplied for build 1026 and for “memory map version 1” (build ≥1409) but the OCR reproduction is illegible; consult the PDF for the actual offsets (pages 13–18).
- Unused locations contain `0xFF`; contact configuration uses `0xFF` for “normally open” and `0x00` for “normally closed” (pages 14 & 18).

## Timer Presets & Action Table
- Action summary tables (pages 15 & 20) enumerate preset durations (e.g. 29 min 30 s, 1 h 15 min, 4 h 45 min, 5 h 30 min, 9 h 30 min) but the linked action codes are unreadable in the OCR output.
- Review the original PDF when precise code-to-timer mappings are required.

## Conversion Notes
- OCR consistently misread `F5`/`F6` as `FS`/`F6` and duplicated characters in the name tables; the command bytes above were normalised to hexadecimal form.
- Timing tables and memory layouts could not be reconstructed reliably from the scan; retain the PDF (“VMB4RYLD Protocol – edition 5”) as the authoritative source for address maps and timer enumerations.
