# VMB8IR Infrared Receiver Module Protocol (Edition 3)

## Module Overview
- Module type `0x0A`; handles up to 40 learned infrared channels while exposing eight physical status LEDs for local feedback (page 2).
- LED/channel status frame (`0xEB`) reports the current press state for channels 1–8 together with continuous/slow/fast LED masks; slow + fast implies very-fast blink (page 2).
- Module type payload returns the serial number, memory-map version, and build year/week to validate firmware revisions (page 2).

## Message Formats
- Uses standard Velbus CAN framing with `SID10..9 = 00` for high-priority channel events and `11` for telemetry (page 2).
- Channel ID appears as an 8-bit index in name frames (`0xF0–0xF2`), while button status frames emit bitmasks for multiple channels (page 2).
- Memory services are limited to low memory (`high address` must be `0x00`); block transfers span `0x0000–0x00FC` (page 5).

## Transmitted Messages
- **Channel activity**: `0x00` `COMMAND_PUSH_BUTTON_STATUS` publishes just-pressed/just-released/long-pressed bits for channels associated with an IR code (page 2).
- **LED & channel status**: `0xEB` `COMMAND_IR_RECEIVER_STATUS` returns channel 1–8 pressed state plus LED steady/slow/fast masks (page 2).
- **Identity & diagnostics**: `0xFF` module type (type `0x0A`), `0xDA` bus error counters, `0xFE` memory data, `0xCC` 4-byte block read (pages 2–5).
- **Naming**: `0xF0`/`0xF1`/`0xF2` deliver 16-character ASCII labels for channels 1–8; unused characters contain `0xFF` (pages 2–3).

## Accepted Commands
- **Query & identity**: RTR `COMMAND_MODULE_TYPE`, `0xFA` module-status request, `0xEF` channel-name request, `0xD9` bus-error counter status request (pages 2 & 5).
- **LED control**: `0xF4` update LEDs, `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink, `0xF9` very fast blink maintain local indicators in sync with automation (pages 1–2).
- **Memory operations**: `0xFD` read byte, `0xCB` memory dump, `0xFC` write byte, `0xCA` write block (4 bytes); ensure the high address is zero and wait for read-back before issuing additional writes (pages 1 & 5).

## Conversion Notes
- The transcript lists only channel 1–8 naming frames; IR channel-to-button mapping for channels 9–40 is not described—consult “VMB8IR Protocol – edition 3” when defining extended keymaps.
- OCR preserved command mnemonics but page references are limited; verify exact byte semantics (e.g., LED masks, counter ranges) against the PDF before implementation.
