# VMB6PBN Six-Gang Push Button Module (Normal) Protocol (Edition 7)

## Module Overview
- Module type `0x17`; six push-button inputs with LEDs and local scheduling logic. Shares many behaviours with the VMB6PB-20 but targets older hardware revisions (page 4).
- Module status frame reports button state, enable/invert flags, lock status, and program disable bit, mirroring indicator LEDs (page 4).
- Module type payload returns serial number, memory-map version, and build year/week; no CAN FD-specific fields are mentioned in this edition (page 4).

## Message Formats
- Frames follow the Velbus CAN template with `SID10..9 = 00` for button events and `11` for telemetry and configuration (page 4).
- Daylight-saving and sunrise/sunset support requires build ≥1235; otherwise frames are ignored (page 3).
- Memory operations cover `0x0000–0x03FF`; block transfers remain 4 bytes (no CAN FD extension described) (page 5).

## Transmitted Messages
- **Clock & calendar**: `0xD7` RTC status request, `0xD8` RTC status (weekday, hour, minute), `0xB7` date status, and (build ≥1235) `0xAF` daylight-saving status (pages 3–4).
- **Button telemetry**: `0x00` `COMMAND_PUSH_BUTTON_STATUS` announces just pressed/released/long pressed states (page 4).
- **Module status**: `0xED` returns channel press bits, enable/disable, normal/invert, lock, program disable, and alarm/program selection (page 4).
- **Module type**: `0xFF` identifies module type `0x17`, serial number, memory-map version, and build info (page 4).
- **Diagnostics & memory**: `0xDA` bus error counters; `0xFE` byte read and `0xCC` 4-byte block read over `0x0000–0x03FC` (pages 4–5).
- **Channel naming**: `0xF0`/`0xF1`/`0xF2` provide up to 16 ASCII characters per channel; unused characters are `0xFF` (page 5).
- **Linked keypad LEDs**: `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink mirror remote LED states (page 2 list).

## Accepted Commands
- **Linked push-button input**: `0x00` relays remote keypad button events to the module (page 2).
- **Status & identity queries**: RTR `COMMAND_MODULE_TYPE`, `0xED` module-status request, `0xEF` channel-name request, `0xFA` module-status resend, `0xD9` bus error request (pages 2–3).
- **LED control**: `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink, `0xF9` very fast blink, and `0xF4` LED update for local channel LEDs (page 2).
- **Memory services**: `0xFD` read byte, `0xC9` read block, `0xCB` memory dump, `0xFC` write byte, `0xCA` write block; limit addresses to `0x03FF` (`0x03FC` for 4-byte writes) (pages 2–5).
- **Timekeeping**: `0xD8` set clock, `0xB7` set date, `0xAF` set daylight saving (build ≥1235), `0xAE` enable/disable sunrise/sunset globally (`address 0x00`) or locally (module address), `0xC3` configure global/local alarms (page 3).
- **Channel automation**: commands listed include lock/unlock channel, disable/enable channel program, program selection, and read/write program steps; the OCR transcript lacks payload detail—consult the PDF for exact byte layout (page 2).

## Memory & Scheduling Notes
- Program functionality mirrors the VMB6PB family, but the OCR text does not reproduce the action tables; refer to “VMB6PBN Protocol – edition 7” for calendar masks, action codes, and timer presets.
- Daylight-saving and sunrise/sunset controls are optional based on firmware build; automation should confirm support via properties or module type documentation.

## Conversion Notes
- OCR merged repeated headers and truncated program tables; action code mappings and schedule formats must be rechecked against the source PDF before implementation.
- Hex values normalised to `0x` notation; minor typos (e.g., “VMBOPBN”) retained where ambiguity exists until verified with the official document.
