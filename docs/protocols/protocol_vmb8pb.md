# VMB8PB Eight-Button Module Protocol (Edition 1 rev.2)

## Module Overview
- Module type `0x01`; eight push buttons with associated LEDs share a common address configured via hex switches (page 2).
- Module status frame (`0xED`) reports button state plus LED steady/slow/fast masks, matching the behaviour used by VMB6IN and other keypad modules (page 2).
- Module type payload (build ≥0649) includes LED masks and build year/week for diagnostics (page 2).

## Message Formats
- Standard Velbus CAN frames with `SID10..9 = 00` for button transitions and `11` for telemetry, naming, and memory operations (page 2).
- Button identifiers are conveyed as bitmasks (`0b00000001` = button 1 … `0b10000000` = button 8) in name and LED frames (pages 2–3).
- Memory services operate on low memory only (`high address = 0x00`); block reads/writes (build ≥0736) span `0x0000–0x007F` (pages 3–4).

## Transmitted Messages
- **Button telemetry**: `0x00` `COMMAND_PUSH_BUTTON_STATUS` lists just-pressed, just-released, and long-pressed buttons (page 2).
- **Module status**: `0xED` returns button state and LED steady/slow/fast masks (page 2).
- **Module identity**: `0xFF` module type (type `0x01`) plus LED masks and production data (page 2).
- **Naming**: `0xF0`/`0xF1`/`0xF2` send up to 15-character button names; unused characters are `0xFF` (page 3).
- **Memory data**: `0xFE` single-byte read, `0xCC` 4-byte block read (build ≥0736) (page 3).

## Accepted Commands
- **LED control**: `0xF4` update LED masks, `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink, `0xF9` very fast blink; steady overrides blinking (pages 2 & 4).
- **Queries**: `0xFA` module-status request (select buttons via bitmask), RTR `COMMAND_MODULE_TYPE`, `0xD9` bus-error request (build ≥0649), `0xEF` button-name request (page 4).
- **Memory services**: `0xFD` read byte, `0xCB` dump (build ≥0736), `0xFC` write byte; block writes are not supported. Wait ≥10 ms after each write as per Velbus guidance (page 4).

## Conversion Notes
- OCR faithfully captured command mnemonics; numeric ranges were normalised to `0x` notation.
- When scripting automation, treat LED bit ordering and button masks consistently across status, update, and naming frames to avoid mismatches.
