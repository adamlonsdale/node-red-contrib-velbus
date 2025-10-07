# VMB8PBU Eight-Button Universal Push Button Protocol (Edition 7)

## Module Overview
- Module type `0x16`; eight-button keypad with LED indicators, local scheduling, sunrise/sunset automation (build ≥1235), and linked push-button support (pages 2–4).
- Module status frame (`0xED`) reports button press state, enable/disable flag, normal/invert flag, lock state, and program disable flag, plus an alarm/program selection byte (page 4).
- Module type payload returns serial number, memory-map version, and build year/week, enabling firmware validation (page 4).

## Message Formats
- Standard Velbus CAN frames: `SID10..9 = 00` for real-time button events, `11` for telemetry/configuration (pages 2–4).
- Supports RTC/date/daylight frames (`0xD7/0xD8/0xB7/0xAF`) and automation commands mirroring the VMB6PB/VMB6PBN families (pages 3–4).
- Memory operations cover `0x0000–0x03FF`; block transfers use 4-byte pages, with CAN FD support implied by companion modules though not explicitly described (page 5).

## Transmitted Messages
- **Clock & calendar**: `0xD7` RTC request, `0xD8` RTC status, `0xB7` date status, `0xAF` daylight-saving status (build ≥1235) (pages 3–4).
- **Button telemetry**: `0x00` `COMMAND_PUSH_BUTTON_STATUS` lists just-pressed, just-released, and long-pressed buttons (page 3).
- **Module identity**: `0xFF` module type (type `0x16`), serial number, memory-map version, build info (page 4).
- **Module status**: `0xED` carries per-channel state, enable/invert/lock flags, program disable bit, and alarm/program selector (page 4).
- **Diagnostics & memory**: `0xDA` bus error counters, `0xFE` byte read, `0xCC` block read across `0x0000–0x03FC` (page 5).
- **Channel naming**: `0xF0`/`0xF1`/`0xF2` return 16-character channel names (unused characters `0xFF`) (pages 5–6).
- **Linked LED control**: `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink broadcast LED updates to remote keypads (page 2).

## Accepted Commands
- **Linked button input**: `0x00` mirrors remote keypad events to this module (page 2).
- **Status & identity queries**: RTR `COMMAND_MODULE_TYPE`, `0xED` module-status request, `0xEF` channel-name request, `0xFA` module-status resend, `0xD9` bus error request (pages 2–3).
- **LED control**: `0xF4` update local LEDs, `0xF5` clear, `0xF6` set, `0xF7` slow blink, `0xF8` fast blink, `0xF9` very fast blink (page 2).
- **Memory services**: `0xFD` read byte, `0xC9` read block, `0xCB` dump, `0xFC` write byte, `0xCA` write block; honour address limits (`0x03FF/0x03FC`) and await feedback before issuing further writes (pages 2 & 5).
- **Timekeeping & automation**: `0xD8` set clock, `0xB7` set date, `0xAF` set daylight saving (build ≥1235), `0xAE` toggle sunrise/sunset globally (`address 0x00`) or locally (module address), `0xC3` configure global/local alarms, `0xB1`/`0xB2` disable/enable program, `0xB3` select program, and `0xC0`/`0xC2` read/write program steps (pages 2–3).

## Conversion Notes
- OCR captures the command inventory but omits detailed program tables and action codes; rely on the PDF when scripting schedules or sunrise/sunset behaviour.
- Daylight-saving and sunrise/sunset commands are firmware dependent—confirm support via the properties byte or build number before enabling those features programmatically.
